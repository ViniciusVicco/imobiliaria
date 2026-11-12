import assert from 'node:assert/strict';
import test from 'node:test';
import Fastify from 'fastify';
Object.assign(process.env, { DATABASE_URL: 'postgresql://test:test@localhost:5432/test', JWT_SECRET: 'test-secret-at-least-thirty-two-characters' });
const { prisma } = await import('../src/shared/database/prisma.js');
const { homeRoutes } = await import('../src/modules/home/home.routes.js');
const { propertyTagsRoutes } = await import('../src/modules/properties/property-tags.routes.js');
const { mediaRoutes } = await import('../src/modules/media/media.routes.js');
const { signAccessToken } = await import('../src/shared/security/jwt.js');

test('showcase, tags authorization and upload body limit', async () => {
  const oldFind = prisma.property.findMany, oldUser = prisma.user.findUnique, oldTags = prisma.propertyTag.findMany, oldCreate = prisma.propertyTag.create, oldUpdate = prisma.propertyTag.update;
  let role = 'broker';
  prisma.property.findMany = (async (args: any) => {
    assert.deepEqual(args.where, { status: 'published', isFeatured: true });
    assert.deepEqual(args.orderBy, { updatedAt: 'desc' });
    assert.equal(args.take, 6); return [];
  }) as any;
  prisma.user.findUnique = (async () => ({ id: 'u', role, isActive: true })) as any;
  prisma.propertyTag.findMany = (async (args: any) => {
    if (role === 'broker') assert.deepEqual(args.where, { isActive: true }); return [];
  }) as any;
  prisma.propertyTag.create = (async ({ data }: any) => data) as any;
  prisma.propertyTag.update = (async ({ where, data }: any) => ({ slug: where.slug, ...data })) as any;
  const app = Fastify();
  try {
    await app.register(homeRoutes); await app.register(propertyTagsRoutes); await app.register(mediaRoutes);
    assert.equal((await app.inject('/home/featured-properties')).statusCode, 200);
    const headers = { authorization: `Bearer ${signAccessToken('u')}` };
    assert.equal((await app.inject({ url: '/broker/property-tags', headers })).statusCode, 200);
    assert.equal((await app.inject({ url: '/admin/property-tags', headers })).statusCode, 403);
    assert.equal((await app.inject({ method: 'POST', url: '/admin/property-tags', headers, payload: { slug: 'novo', label: 'Novo' } })).statusCode, 403);
    role = 'admin'; assert.equal((await app.inject({ url: '/admin/property-tags', headers })).statusCode, 200);
    const created = await app.inject({ method: 'POST', url: '/admin/property-tags', headers, payload: { slug: 'novo', label: 'Novo' } });
    assert.equal(created.statusCode, 200); assert.equal(created.json().isActive, true);
    const disabled = await app.inject({ method: 'PATCH', url: '/admin/property-tags/novo', headers, payload: { isActive: false } });
    assert.equal(disabled.statusCode, 200); assert.equal(disabled.json().isActive, false);
    const upload = await app.inject({ method: 'POST', url: '/media/property-images/temp', payload: { contentBase64: 'a'.repeat(1100000) } });
    assert.equal(upload.statusCode, 401);
  } finally {
    prisma.property.findMany = oldFind; prisma.user.findUnique = oldUser; prisma.propertyTag.findMany = oldTags; prisma.propertyTag.create = oldCreate; prisma.propertyTag.update = oldUpdate;
    await app.close(); await prisma.$disconnect();
  }
});
