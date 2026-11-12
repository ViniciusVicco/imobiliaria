import type { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { prisma } from '../../shared/database/prisma.js';
import { requireActiveAdmin, requireActiveBroker } from '../auth/auth.middleware.js';

const tagSchema = z.object({
  slug: z.string().trim().regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/).max(80),
  label: z.string().trim().min(1).max(100),
  description: z.string().trim().max(500).default(''),
  sortOrder: z.number().int().default(0),
  isActive: z.boolean().default(true),
});
export async function propertyTagsRoutes(app: FastifyInstance) {
  app.get('/broker/property-tags', { preHandler: requireActiveBroker }, async () => ({ items: await prisma.propertyTag.findMany({ where: { isActive: true }, orderBy: [{ sortOrder: 'asc' }, { label: 'asc' }] }) }));
  app.get('/admin/property-tags', { preHandler: requireActiveAdmin }, async () => ({ items: await prisma.propertyTag.findMany({ orderBy: [{ sortOrder: 'asc' }, { label: 'asc' }] }) }));
  app.post('/admin/property-tags', { preHandler: requireActiveAdmin }, async (request) => prisma.propertyTag.create({ data: tagSchema.parse(request.body) }));
  app.patch('/admin/property-tags/:slug', { preHandler: requireActiveAdmin }, async (request) => {
    const { slug } = z.object({ slug: z.string().min(1) }).parse(request.params);
    const data = tagSchema.omit({ slug: true }).partial().parse(request.body);
    return prisma.propertyTag.update({ where: { slug }, data });
  });
}
