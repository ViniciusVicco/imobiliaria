import assert from 'node:assert/strict';
import test from 'node:test';
import Fastify from 'fastify';
import { ZodError } from 'zod';

process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/test';
process.env.SHADOW_DATABASE_URL = process.env.DATABASE_URL;
const { prisma } = await import('../src/shared/database/prisma.js');
const { signAccessToken } = await import('../src/shared/security/jwt.js');
const { outboundLinksRoutes } = await import('../src/modules/outbound-links/outbound-links.routes.js');

test('records anonymous and authenticated clicks, creating leads only for contact or property', async () => {
  const saved: any[] = [];
  const originalCreate = prisma.outboundClick.create;
  const originalUser = prisma.user.findUnique;
  const originalProperty = prisma.property.findUnique;
  prisma.outboundClick.create = (async ({ data }: any) => {
    saved.push(data);
    return { id: `click-${saved.length}` };
  }) as any;
  prisma.user.findUnique = (async () => ({ id: 'user-1', role: 'broker', isActive: true })) as any;
  prisma.property.findUnique = (async () => ({ id: 'home-1', status: 'published' })) as any;
  const app = Fastify();
  app.setErrorHandler((error, _request, reply) => {
    if (error instanceof ZodError) return reply.code(400).send({ code: 'VALIDATION_ERROR' });
    return reply.code(500).send({ code: 'INTERNAL_ERROR' });
  });
  try {
    await app.register(outboundLinksRoutes, { prefix: '/api/v1' });
    const anonymous = await app.inject({ method: 'POST', url: '/api/v1/outbound-links/clicks', payload: {
      targetUrl: 'https://wa.me/5511999999999', source: 'home_whatsapp', userId: 'forged-user',
    } });
    assert.equal(anonymous.statusCode, 201);
    assert.equal(saved[0].userId, null);
    assert.ok(saved[0].lead?.create);

    const authenticated = await app.inject({ method: 'POST', url: '/api/v1/outbound-links/clicks', headers: {
      authorization: `Bearer ${signAccessToken('user-1')}`,
    }, payload: { targetUrl: 'https://instagram.com/p/test', source: 'property_instagram', propertyId: 'home-1' } });
    assert.equal(authenticated.statusCode, 201);
    assert.equal(saved[1].userId, 'user-1');
    assert.equal(saved[1].userRole, 'broker');
    assert.equal(saved[1].propertyId, 'home-1');
    assert.ok(saved[1].lead?.create);

    const social = await app.inject({ method: 'POST', url: '/api/v1/outbound-links/clicks', payload: {
      targetUrl: 'https://youtube.com/test', source: 'header_youtube',
    } });
    assert.equal(social.statusCode, 201);
    assert.equal(saved[2].lead, undefined);

    const invalid = await app.inject({ method: 'POST', url: '/api/v1/outbound-links/clicks', payload: {
      targetUrl: 'javascript:alert(1)', source: 'header_youtube',
    } });
    assert.equal(invalid.statusCode, 400);
    assert.equal(saved.length, 3);
  } finally {
    prisma.outboundClick.create = originalCreate;
    prisma.user.findUnique = originalUser;
    prisma.property.findUnique = originalProperty;
    await app.close();
    await prisma.$disconnect();
  }
});

test('admin can page through clicks and anonymous users cannot read them', async () => {
  const originalUser = prisma.user.findUnique;
  const originalTransaction = prisma.$transaction;
  const originalCount = prisma.outboundClick.count;
  const originalFindMany = prisma.outboundClick.findMany;
  let query: any;
  prisma.user.findUnique = (async ({ where }: any) => ({ id: where.id, role: where.id === 'admin-1' ? 'admin' : 'broker', isActive: true })) as any;
  prisma.outboundClick.count = (() => Promise.resolve(26)) as any;
  prisma.outboundClick.findMany = ((args: any) => {
    query = args;
    return Promise.resolve([{ id: 'one', source: 'header_youtube', targetUrl: 'https://youtube.com',
      createdAt: new Date(), userId: null, userRole: null, propertyId: null, user: null, property: null, lead: null }]);
  }) as any;
  prisma.$transaction = (async (requests: Promise<unknown>[]) => Promise.all(requests)) as any;
  const app = Fastify();
  try {
    await app.register(outboundLinksRoutes, { prefix: '/api/v1' });
    assert.equal((await app.inject('/api/v1/admin/outbound-links/clicks')).statusCode, 401);
    assert.equal((await app.inject({ url: '/api/v1/admin/outbound-links/clicks', headers: {
      authorization: `Bearer ${signAccessToken('broker-1')}`,
    } })).statusCode, 403);
    const response = await app.inject({ url: '/api/v1/admin/outbound-links/clicks?page=2&pageSize=1', headers: {
      authorization: `Bearer ${signAccessToken('admin-1')}`,
    } });
    assert.equal(response.statusCode, 200);
    assert.equal(response.json().total, 26);
    assert.equal(response.json().items[0].leadId, null);
    assert.equal(query.skip, 1);
    assert.equal(query.take, 1);
  } finally {
    prisma.user.findUnique = originalUser;
    prisma.$transaction = originalTransaction;
    prisma.outboundClick.count = originalCount;
    prisma.outboundClick.findMany = originalFindMany;
    await app.close();
    await prisma.$disconnect();
  }
});
