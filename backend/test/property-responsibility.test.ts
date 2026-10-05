import assert from 'node:assert/strict';
import test from 'node:test';
import Fastify from 'fastify';
import { S3Client } from '@aws-sdk/client-s3';
import { ZodError } from 'zod';

Object.assign(process.env, {
  DATABASE_URL: 'postgresql://test:test@localhost:5432/test', SHADOW_DATABASE_URL: 'postgresql://test:test@localhost:5432/test',
  JWT_SECRET: 'test-secret-at-least-thirty-two-characters', R2_ACCOUNT_ID: 'test', R2_BUCKET_NAME: 'test',
  R2_ACCESS_KEY_ID: 'test', R2_SECRET_ACCESS_KEY: 'test', R2_PUBLIC_BASE_URL: 'https://test.invalid', R2_ENDPOINT: 'https://test.invalid',
});
const { prisma } = await import('../src/shared/database/prisma.js');
const { protectedPropertiesRoutes } = await import('../src/modules/properties/protected-properties.routes.js');
const { adminUsersRoutes } = await import('../src/modules/admin/admin-users.routes.js');
const { signAccessToken } = await import('../src/shared/security/jwt.js');
const admin = '11111111-1111-4111-8111-111111111111';
const broker = '22222222-2222-4222-8222-222222222222';
const otherAdmin = '33333333-3333-4333-8333-333333333333';
const payload = { title: 'Casa', segment: 'residential', propertyType: 'Casa', city: 'Palmas', neighborhood: 'Centro',
  areaM2: 120, privateAreaM2: 120, totalAreaM2: 200, bathrooms: 2, garageSpaces: 1, price: 500000,
  mediaIds: ['a', 'b', 'c', 'd'], coverMediaId: 'a', uploadSessionId: 'session' };

test('property responsibility across creation, edits, review, transfer and deactivation', async (t) => {
  const users = new Map([admin, broker, otherAdmin].map(id => [id, {
    id, name: id, email: `${id}@test.invalid`, phone: '63999999999', whatsapp: '', avatarUrl: `https://test.invalid/${id}.png`,
    role: id === broker ? 'broker' : 'admin', isActive: true, createdAt: new Date(), updatedAt: new Date(), lastLoginAt: null,
  }]));
  const properties = new Map<string, any>();
  let revision: any = null;
  const original: Array<() => void> = [];
  function stub(object: any, key: string, value: any) {
    const previous = object[key]; object[key] = value; original.push(() => { object[key] = previous; });
  }
  const detail = (property: any) => ({ ...property, broker: users.get(property.brokerId) ?? null, media: [], updatedAt: new Date() });
  stub(prisma.user, 'findUnique', async ({ where }: any) => users.get(where.id) ?? null);
  stub(prisma.user, 'findFirst', async ({ where }: any) => {
    assert.deepEqual(where.role, { in: ['broker', 'admin'] });
    const user = users.get(where.id); return user?.isActive ? user : null;
  });
  stub(prisma.user, 'findMany', async ({ where, orderBy }: any) => {
    assert.equal(where.isActive, true); assert.deepEqual(where.role.in, ['broker', 'admin']);
    assert.deepEqual(orderBy, [{ name: 'asc' }, { id: 'asc' }]);
    return [...users.values()].filter(u => u.isActive);
  });
  stub(prisma.user, 'count', async () => 2);
  stub(prisma.user, 'update', async ({ where, data }: any) => { const user = { ...users.get(where.id), ...data }; users.set(where.id, user); return user; });
  stub(prisma.property, 'create', async ({ data }: any) => {
    const property = { ...data, media: [], updatedAt: new Date() }; properties.set(data.id, property); return detail(property);
  });
  stub(prisma.property, 'findUnique', async ({ where }: any) => properties.get(where.id) ?? null);
  stub(prisma.property, 'findUniqueOrThrow', async ({ where }: any) => detail(properties.get(where.id)));
  stub(prisma.property, 'upsert', async ({ where, create, update }: any) => {
    const values = Object.fromEntries(Object.entries(update).filter(([, value]) => value !== undefined));
    const property = properties.has(where.id) ? { ...properties.get(where.id), ...values } : create;
    properties.set(where.id, property); return detail(property);
  });
  stub(prisma.property, 'update', async ({ where, data }: any) => {
    const property = { ...properties.get(where.id), ...data }; properties.set(where.id, property); return detail(property);
  });
  stub(prisma.property, 'findMany', async ({ where }: any) => [...properties.values()].filter(p => p.brokerId === where.brokerId && p.status === where.status));
  stub(prisma.property, 'updateMany', async ({ where, data }: any) => {
    for (const p of properties.values()) if (p.brokerId === where.brokerId && p.status === where.status) Object.assign(p, data);
    return { count: 1 };
  });
  stub(prisma.propertyMedia, 'count', async () => 4);
  stub(prisma.propertyMedia, 'findMany', async () => payload.mediaIds.map(id => ({ id, storageKey: `temp/${id}.png`, type: 'image', status: 'active' })));
  stub(prisma.propertyMedia, 'update', async () => ({}));
  stub(prisma.propertyMedia, 'deleteMany', async () => ({ count: 0 }));
  stub(prisma.propertyMedia, 'createMany', async () => ({ count: 0 }));
  stub(prisma.propertyRevision, 'findFirst', async () => revision);
  stub(prisma.propertyRevision, 'update', async () => ({}));
  stub(prisma.propertyStatusHistory, 'create', async () => ({}));
  stub(prisma.propertyStatusHistory, 'createMany', async ({ data }: any) => { assert.ok(data.every((item: any) => item.source === 'responsible_deactivated')); return { count: data.length }; });
  stub(prisma, '$transaction', async (run: any) => typeof run === 'function' ? run(prisma) : Promise.all(run));
  stub(S3Client.prototype, 'send', async () => ({}));
  const app = Fastify();
  app.setErrorHandler((error, _, reply) => { reply.code(error instanceof ZodError ? 400 : 500).send({ error: String(error) }); });
  await app.register(protectedPropertiesRoutes, { prefix: '/api/v1' });
  await app.register(adminUsersRoutes, { prefix: '/api/v1' });
  const request = (actor: string, method: any, url: string, data?: any) => app.inject({ method, url: `/api/v1${url}`, payload: data,
    headers: { authorization: `Bearer ${signAccessToken(actor)}` } });
  try {
    await t.test('admin creation and draft belong to creator by default', async () => {
      const created = await request(admin, 'POST', '/admin/properties', payload);
      assert.equal(created.statusCode, 200, created.body);
      assert.equal(created.json().broker.id, admin);
      assert.equal(created.json().status, 'published');
      const draft = await request(admin, 'POST', '/admin/properties/draft');
      assert.equal(draft.json().broker.id, admin);
      const explicit = await request(admin, 'POST', '/admin/properties', { ...payload, brokerId: broker });
      assert.equal(explicit.json().broker.id, broker);
      const ownAdmin = await request(admin, 'POST', '/broker/properties', payload);
      assert.equal(ownAdmin.statusCode, 200); assert.equal(ownAdmin.json().broker.id, admin);
      assert.equal(ownAdmin.json().status, 'published');
      const ownBroker = await request(broker, 'POST', '/broker/properties', { ...payload, brokerId: admin });
      assert.equal(ownBroker.statusCode, 200); assert.equal(ownBroker.json().broker.id, broker);
      assert.equal(ownBroker.json().status, 'pending_review');

    });
    await t.test('edits preserve association and orphans; transfer accepts active admins', async () => {
      properties.set('owned', { ...payload, id: 'owned', brokerId: broker, status: 'published' });
      properties.set('orphan', { ...payload, id: 'orphan', brokerId: null, status: 'published' });
      let response = await request(admin, 'PATCH', '/admin/properties/owned', payload);
      assert.equal(response.statusCode, 200, response.body); assert.equal(response.json().broker.id, broker);
      response = await request(admin, 'PATCH', '/admin/properties/orphan', payload);
      assert.equal(response.statusCode, 200); assert.equal(response.json().broker, null);
      response = await request(admin, 'PATCH', '/admin/properties/owned', { ...payload, brokerId: otherAdmin });
      assert.equal(response.statusCode, 200); assert.equal(response.json().broker.id, otherAdmin);
      assert.equal((await request(admin, 'PATCH', '/admin/properties/owned', { ...payload, brokerId: '' })).statusCode, 400);
      assert.equal((await request(broker, 'PATCH', '/admin/properties/owned', payload)).statusCode, 403);
      users.get(otherAdmin)!.isActive = false;
      assert.equal((await request(admin, 'PATCH', '/admin/properties/orphan', { ...payload, brokerId: otherAdmin })).statusCode, 400);
      users.get(otherAdmin)!.isActive = true;
    });
    await t.test('approval preserves responsible even when revision snapshot contains another ID', async () => {
      properties.set('review', { ...payload, id: 'review', brokerId: broker, status: 'pending_review' });
      revision = { id: 'revision', snapshot: { ...payload, brokerId: admin } };
      const response = await request(admin, 'POST', '/admin/properties/review/approve');
      assert.equal(response.statusCode, 200, response.body); assert.equal(response.json().broker.id, broker);
      revision = null;
      assert.equal((await request(otherAdmin, 'POST', '/admin/properties/review/approve')).json().broker.id, broker);
    });
    await t.test('role changes retain ownership; deactivation hides published properties and prevents approval', async () => {
      const promoted = await request(admin, 'PATCH', `/admin/users/${broker}`, { role: 'admin' });
      assert.equal(promoted.statusCode, 200); assert.equal(properties.get('review').brokerId, broker);
      properties.set('sold', { ...payload, id: 'sold', brokerId: broker, status: 'sold' });
      properties.set('draft', { ...payload, id: 'draft', brokerId: broker, status: 'draft' });
      const inactive = await request(admin, 'PATCH', `/admin/users/${broker}`, { isActive: false });
      assert.equal(inactive.statusCode, 200, inactive.body);
      assert.equal(properties.get('review').status, 'pending_review');
      assert.equal(properties.get('sold').status, 'sold'); assert.equal(properties.get('draft').status, 'draft');
      assert.equal((await request(admin, 'POST', '/admin/properties/review/approve')).statusCode, 400);
      assert.equal((await request(admin, 'PATCH', '/admin/properties/review/status', { status: 'published' })).statusCode, 400);
      const transferred = await request(admin, 'PATCH', '/admin/properties/review', { ...payload, brokerId: otherAdmin });
      assert.equal(transferred.statusCode, 200); assert.equal(transferred.json().status, 'pending_review');
      assert.equal((await request(admin, 'POST', '/admin/properties/review/approve')).statusCode, 200);
    });
    await t.test('responsible list includes active admins and excludes inactive users; brokers cannot access', async () => {
      const response = await request(admin, 'GET', '/admin/property-responsibles');
      assert.equal(response.statusCode, 200); assert.deepEqual(response.json().items.map((u: any) => u.id), [admin, otherAdmin]);
      users.get(broker)!.isActive = true; users.get(broker)!.role = 'broker';
      assert.equal((await request(broker, 'GET', '/admin/property-responsibles')).statusCode, 403);
    });
  } finally {
    await app.close(); for (const restore of original.reverse()) restore(); await prisma.$disconnect();
  }
});
