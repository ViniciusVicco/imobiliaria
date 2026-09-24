import assert from 'node:assert/strict';
import test from 'node:test';
import Fastify from 'fastify';

// All database calls are replaced below; never connect to a real database.
process.env.DATABASE_URL = 'postgresql://test:test@localhost:5432/test';
process.env.SHADOW_DATABASE_URL = process.env.DATABASE_URL;
const { prisma } = await import('../src/shared/database/prisma.js');
const { propertiesRoutes } = await import('../src/modules/properties/properties.routes.js');

test('public detail contract, publication filter, media authorization and contact fallback', async () => {
  let available = true;
  let broker: { name: string; phone: string | null; avatarUrl: string } | null = {
    name: 'Corretor', phone: '5563999999999', avatarUrl: 'https://example.com/avatar.jpg',
  };
  const originalProperty = prisma.property.findFirst;
  const originalBrand = prisma.brandContent.findUnique;
  const originalMedia = prisma.propertyMedia.findFirst;
  prisma.property.findFirst = (async (args: any) => {
    assert.equal(args.where.status, 'published');
    assert.deepEqual(args.include.media.where, { status: 'active', deletedAt: null });
    return available ? {
      id: 'property', title: 'Casa', description: 'Descrição', segment: 'residential', propertyType: 'Casa',
      city: 'Palmas', neighborhood: 'Sul', subNeighborhood: '', coverUrl: 'old-cover.jpg',
      privateAreaM2: 130, totalAreaM2: 252, bedrooms: 3, bathrooms: 2, garageSpaces: 2, propertyAgeYears: 1,
      price: 820000, tagSlugs: [], broker,
      media: [{ id: 'cover', url: 'old-cover.jpg', publicUrl: null, storageKey: 'stored/image.jpg', type: 'image', sortOrder: 0 }],
    } : null;
  }) as typeof prisma.property.findFirst;
  prisma.brandContent.findUnique = (async () => ({ contactWhatsapp: '5563888888888', contactPhone: '' })) as any;
  prisma.propertyMedia.findFirst = (async (args: any) => {
    assert.deepEqual(args.where, { id: 'hidden', propertyId: 'property', type: 'image', status: 'active', deletedAt: null,
      property: { status: 'published' } });
    return null;
  }) as typeof prisma.propertyMedia.findFirst;
  const app = Fastify();
  try {
    await app.register(propertiesRoutes, { prefix: '/api/v1' });
    const published = await app.inject('/api/v1/properties/property');
    assert.equal(published.statusCode, 200);
    const json = published.json();
    assert.equal(json.brokerContact.avatarUrl, broker.avatarUrl);
    assert.equal(json.coverUrl, json.media[0].url);
    assert.match(json.coverUrl, /\/api\/v1\/properties\/property\/media\/cover$/);
    assert.equal(json.facts.privateAreaM2, 130);
    assert.equal(json.facts.totalAreaM2, 252);
    broker = { name: 'Sem telefone', phone: null, avatarUrl: 'private-avatar' };
    const fallback = (await app.inject('/api/v1/properties/property')).json().brokerContact;
    assert.equal(fallback.name, 'Seletta');
    assert.equal(fallback.whatsapp, '5563888888888');
    assert.equal(fallback.avatarUrl, null);
    broker = null;
    assert.equal((await app.inject('/api/v1/properties/property')).json().brokerContact.name, 'Seletta');
    available = false;
    assert.equal((await app.inject('/api/v1/properties/property')).statusCode, 404);
    assert.equal((await app.inject('/api/v1/properties/property/media/hidden')).statusCode, 404);
  } finally {
    prisma.property.findFirst = originalProperty;
    prisma.brandContent.findUnique = originalBrand;
    prisma.propertyMedia.findFirst = originalMedia;
    await app.close();
    await prisma.$disconnect();
  }
});
