import assert from 'node:assert/strict';
import test from 'node:test';
import { S3Client } from '@aws-sdk/client-s3';

// Never use local credentials, database or bucket in tests.
Object.assign(process.env, {
  DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
  SHADOW_DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
  JWT_SECRET: 'test-only-secret-with-more-than-32-characters',
  R2_ACCOUNT_ID: 'test', R2_BUCKET_NAME: 'test', R2_ACCESS_KEY_ID: 'test',
  R2_SECRET_ACCESS_KEY: 'test', R2_PUBLIC_BASE_URL: 'https://test.invalid',
  R2_ENDPOINT: 'https://test.invalid', R2_MAX_IMAGE_SIZE_MB: '1',
});
const { prisma } = await import('../src/shared/database/prisma.js');
const { buildApp } = await import('../src/app.js');
const { hashPassword } = await import('../src/shared/security/password.js');
const { signAccessToken } = await import('../src/shared/security/jwt.js');
const { migrateAvatar, cleanupLegacyAvatars, avatarKey } = await import('../src/shared/users/avatar.js');
const ids = ['11111111-1111-4111-8111-111111111111', '22222222-2222-4222-8222-222222222222', '33333333-3333-4333-8333-333333333333'];
const png = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a6QAAAABJRU5ErkJggg==', 'base64');
const image = { fileName: 'photo.png', mimeType: 'image/png', contentBase64: png.toString('base64') };

test('profile authorization, password, single avatar and migration', async (t) => {
  const passwordHash = await hashPassword('OldPassword123');
  const users = new Map(ids.map((id, i) => [id, {
    id, name: `User ${i}`, email: `user${i}@example.com`, phone: '63999999999',
    whatsapp: '', creci: '', about: '', avatarUrl: null as string | null, brokerCode: `B${i}`,
    role: i === 2 ? 'admin' : 'broker', isActive: true, passwordHash,
    createdAt: new Date(), updatedAt: new Date(), lastLoginAt: null, updatedBy: null,
  }]));
  const objects = new Map<string, { body: Buffer; contentType: string; cacheControl?: string }>();
  let failUpload = false, failDelete = false, failUpdate = false;
  let lockCount = 0;
  const originals = { findUnique: prisma.user.findUnique, update: prisma.user.update, transaction: prisma.$transaction, send: S3Client.prototype.send };
  prisma.user.findUnique = (async ({ where }: any) => where.id ? users.get(where.id) ?? null : [...users.values()].find(u => u.email === where.email) ?? null) as any;
  prisma.user.update = (async ({ where, data }: any) => {
    if (failUpdate) throw new Error('DB failed');
    const value = { ...users.get(where.id), ...data };
    users.set(where.id, value); return value;
  }) as any;
  // Serial transaction double; SQL lock presence is asserted separately.
  let previous = Promise.resolve();
  prisma.$transaction = ((run: any) => {
    const operation = previous.then(() => run({ user: prisma.user, $queryRaw: async (query: TemplateStringsArray) => {
      assert.match(query.join('?'), /FOR UPDATE/); lockCount++; return [];
    } }));
    previous = operation.catch(() => undefined); return operation;
  }) as any;
  S3Client.prototype.send = (async (command: any) => {
    const input = command.input;
    switch (command.constructor.name) {
      case 'PutObjectCommand':
        if (failUpload) throw new Error('Storage failed');
        objects.set(input.Key, { body: input.Body, contentType: input.ContentType, cacheControl: input.CacheControl }); return {};
      case 'GetObjectCommand': {
        const stored = objects.get(input.Key);
        if (!stored) throw new Error('No object');
        return { Body: { transformToByteArray: async () => stored.body }, ContentType: stored.contentType };
      }
      case 'ListObjectsV2Command': return { Contents: [...objects.keys()].filter(key => key.startsWith(input.Prefix)).map(Key => ({ Key })) };
      case 'DeleteObjectCommand':
        if (failDelete) throw new Error('Delete failed');
        objects.delete(input.Key); return {};
      default: throw new Error(`Unexpected storage call: ${command.constructor.name}`);
    }
  }) as any;
  const app = await buildApp();
  const request = (actor: number | null, method: any, url: string, payload?: any) => app.inject({
    method, url: `/api/v1${url}`, payload,
    headers: actor === null ? {} : { authorization: `Bearer ${signAccessToken(ids[actor])}` },
  });
  try {
    await t.test('only self or admin can change profile', async () => {
      assert.equal((await request(null, 'PATCH', '/me/profile', { name: 'New Name' })).statusCode, 401);
      assert.equal((await request(0, 'PATCH', '/me/profile', { name: 'New Name', phone: '63123456789' })).statusCode, 200);
      assert.equal(users.get(ids[0])!.name, 'New Name');
      assert.equal(users.get(ids[1])!.name, 'User 1');
      for (const forbidden of [{ id: ids[1] }, { role: 'admin' }, { email: 'hacker@example.com' }, { isActive: false }, { avatarUrl: 'https://other.invalid' }]) {
        assert.equal((await request(0, 'PATCH', '/me/profile', forbidden)).statusCode, 400);
      }
      assert.equal((await request(0, 'PATCH', `/admin/users/${ids[1]}`, { name: 'Forbidden' })).statusCode, 403);
      assert.equal((await request(0, 'POST', `/admin/users/${ids[1]}/avatar`, image)).statusCode, 403);
      assert.equal((await request(0, 'POST', '/me/avatar', { ...image, userId: ids[1] })).statusCode, 400);
      assert.equal((await request(0, 'PATCH', '/me/profile', { phone: ' ' })).statusCode, 400);
      const admin = await request(2, 'PATCH', `/admin/users/${ids[1]}`, { name: 'Edited by admin', phone: '63988888888', whatsapp: '63977777777', creci: '123', about: 'Professional' });
      assert.equal(admin.statusCode, 200);
      assert.equal(admin.json().whatsapp, '63977777777');
      assert.equal(admin.json().about, 'Professional');
      assert.equal(admin.json().brokerCode, 'B1');
      assert.equal(users.get(ids[1])!.updatedBy, ids[2]);
      users.get(ids[0])!.isActive = false;
      for (const [method, path, payload] of [['PATCH', '/me/profile', { name: 'No' }], ['POST', '/me/avatar', image], ['PATCH', '/me/password', {}]]) {
        assert.equal((await request(0, method, path as string, payload)).statusCode, 403);
      }
      users.get(ids[0])!.isActive = true;
    });
    await t.test('password rejects invalid input; old login stops working', async () => {
      const valid = { currentPassword: 'OldPassword123', newPassword: 'NewPassword123', newPasswordConfirmation: 'NewPassword123' };
      for (const body of [{ ...valid, currentPassword: 'wrong' }, { ...valid, newPassword: 'short', newPasswordConfirmation: 'short' }, { ...valid, newPasswordConfirmation: 'DifferentPassword' }]) {
        assert.equal((await request(0, 'PATCH', '/me/password', body)).statusCode, 400);
      }
      const response = await request(0, 'PATCH', '/me/password', valid);
      assert.equal(response.statusCode, 200); assert.equal(response.json().passwordHash, undefined);
      assert.equal((await request(null, 'POST', '/auth/login', { email: 'user0@example.com', password: 'OldPassword123' })).statusCode, 401);
      assert.equal((await request(null, 'POST', '/auth/login', { email: 'user0@example.com', password: 'NewPassword123' })).statusCode, 200);
    });
    await t.test('validates MIME, content, size and HTTP limit', async () => {
      assert.equal((await request(0, 'POST', '/me/avatar', { ...image, mimeType: 'image/svg+xml' })).statusCode, 400);
      assert.equal((await request(0, 'POST', '/me/avatar', { ...image, contentBase64: '!!!!' })).statusCode, 400);
      assert.equal((await request(0, 'POST', '/me/avatar', { ...image, contentBase64: Buffer.from('text').toString('base64') })).statusCode, 400);
      assert.equal((await request(0, 'POST', '/me/avatar', { ...image, contentBase64: Buffer.alloc(1024 * 1024 + 1).toString('base64') })).statusCode, 413);
      assert.equal((await request(0, 'POST', '/me/avatar', { ...image, contentBase64: 'A'.repeat(1500000) })).statusCode, 413);
    });
    await t.test('replaces formats at one key; concurrent admin and self uploads', async () => {
      objects.set(`users/${ids[0]}/avatar/old.png`, { body: png, contentType: 'image/png' });
      objects.set(`users/${ids[1]}/avatar/unrelated.png`, { body: png, contentType: 'image/png' });
      const first = await request(0, 'POST', '/me/avatar', image);
      assert.equal(first.statusCode, 200);
      const jpeg = { fileName: 'different.jpg', mimeType: 'image/jpeg', contentBase64: Buffer.from([255,216,255,224,0]).toString('base64') };
      const results = await Promise.all([request(0, 'POST', '/me/avatar', jpeg), request(2, 'POST', `/admin/users/${ids[0]}/avatar`, image)]);
      for (const response of results) assert.equal(response.statusCode, 200);
      assert.equal(new Set([first.json().avatarUrl, ...results.map(r => r.json().avatarUrl)]).size, 3);
      assert.deepEqual([...objects.keys()].filter(k => k.startsWith(`users/${ids[0]}/`)), [avatarKey(ids[0])]);
      assert.ok(objects.has(`users/${ids[1]}/avatar/unrelated.png`));
      assert.equal(objects.get(avatarKey(ids[0]))!.cacheControl, 'no-store');
      assert.ok(lockCount >= 3);
    });
    await t.test('storage failure preserves reference and cleanup can be retried', async () => {
      const before = users.get(ids[0])!.avatarUrl;
      failUpload = true;
      assert.equal((await request(0, 'POST', '/me/avatar', image)).statusCode, 500);
      assert.equal(users.get(ids[0])!.avatarUrl, before);
      failUpload = false;
      const old = `users/${ids[0]}/avatar/leftover.png`;
      objects.set(old, { body: png, contentType: 'image/png' });
      failDelete = true;
      assert.equal((await request(0, 'POST', '/me/avatar', image)).statusCode, 200);
      assert.ok(objects.has(old));
      failDelete = false;
      await cleanupLegacyAvatars(ids[0]);
      assert.ok(!objects.has(old));
    });
    await t.test('database failure restores previous avatar under the lock', async () => {
      const before = objects.get(avatarKey(ids[0]))!;
      const url = users.get(ids[0])!.avatarUrl;
      failUpdate = true;
      const jpeg = { fileName: 'new.jpg', mimeType: 'image/jpeg', contentBase64: Buffer.from([255,216,255,224,0]).toString('base64') };
      assert.equal((await request(0, 'POST', '/me/avatar', jpeg)).statusCode, 500);
      assert.deepEqual(objects.get(avatarKey(ids[0])), before);
      assert.equal(users.get(ids[0])!.avatarUrl, url);
      failUpdate = false;
    });
    await t.test('migration never deletes before DB reference; repeat safely', async () => {
      const id = ids[1], key = `users/${id}/avatar/unrelated.png`;
      users.get(id)!.avatarUrl = `https://test.invalid/${key}`;
      failUpdate = true;
      await assert.rejects(migrateAvatar(id));
      assert.ok(objects.has(key));
      assert.equal(users.get(id)!.avatarUrl, `https://test.invalid/${key}`);
      failUpdate = false;
      assert.equal(await migrateAvatar(id), true);
      assert.ok(!objects.has(key));
      assert.equal(await migrateAvatar(id), true);
      assert.deepEqual([...objects.keys()].filter(k => k.startsWith(`users/${id}/`)), [avatarKey(id)]);
      users.get(id)!.avatarUrl = `https://external.invalid/${key}`;
      await assert.rejects(migrateAvatar(id), /externo/);
    });
  } finally {
    await app.close();
    prisma.user.findUnique = originals.findUnique; prisma.user.update = originals.update;
    prisma.$transaction = originals.transaction; S3Client.prototype.send = originals.send;
    await prisma.$disconnect();
  }
});
