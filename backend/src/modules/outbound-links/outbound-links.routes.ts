import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { verifyAccessToken } from '../../shared/security/jwt.js';
import { requireActiveAdmin } from '../auth/auth.middleware.js';

const sources = [
  'header_instagram', 'header_youtube', 'home_video', 'home_whatsapp',
  'home_property_whatsapp', 'property_instagram', 'property_whatsapp',
] as const;

const clickBodySchema = z.object({
  targetUrl: z.string().trim().max(2048).url().refine((value) => {
    const url = new URL(value);
    return (url.protocol === 'http:' || url.protocol === 'https:') && !!url.hostname;
  }),
  source: z.enum(sources),
  propertyId: z.string().trim().min(1).max(200).optional(),
});

const listQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(25),
});

export async function outboundLinksRoutes(app: FastifyInstance) {
  app.post('/outbound-links/clicks', async (request, reply) => {
    const body = clickBodySchema.parse(request.body);
    const propertySource = body.source.startsWith('property_') || body.source === 'home_property_whatsapp';
    if (propertySource !== !!body.propertyId) {
      return reply.code(400).send({ code: 'INVALID_PROPERTY_CONTEXT', message: 'Informe o imóvel de origem.' });
    }
    if (body.propertyId) {
      const property = await prisma.property.findUnique({ where: { id: body.propertyId }, select: { id: true, status: true } });
      if (!property || property.status !== 'published') {
        return reply.code(400).send({ code: 'INVALID_PROPERTY_CONTEXT', message: 'Imóvel indisponível.' });
      }
    }

    const bearer = request.headers.authorization?.match(/^Bearer (\S+)$/)?.[1];
    const payload = bearer ? verifyAccessToken(bearer) : null;
    const user = payload ? await prisma.user.findUnique({
      where: { id: payload.sub }, select: { id: true, role: true, isActive: true },
    }) : null;
    const activeUser = user?.isActive ? user : null;
    const isLead = body.source.endsWith('_whatsapp') || propertySource;
    const click = await prisma.outboundClick.create({ data: {
      targetUrl: body.targetUrl,
      source: body.source,
      userId: activeUser?.id ?? null,
      userRole: activeUser?.role ?? null,
      propertyId: body.propertyId ?? null,
      ...(isLead ? { lead: { create: {
        userId: activeUser?.id ?? null,
        propertyId: body.propertyId ?? null,
      } } } : {}),
    }, select: { id: true } });
    return reply.code(201).send({ id: click.id });
  });

  app.get('/admin/outbound-links/clicks', { preHandler: requireActiveAdmin }, async (request) => {
    const { page, pageSize } = listQuerySchema.parse(request.query);
    const [total, clicks] = await prisma.$transaction([
      prisma.outboundClick.count(),
      prisma.outboundClick.findMany({
        skip: (page - 1) * pageSize,
        take: pageSize,
        orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
        include: {
          user: { select: { name: true, email: true } },
          property: { select: { title: true } },
          lead: { select: { id: true } },
        },
      }),
    ]);
    return { page, pageSize, total, items: clicks.map((click) => ({
      id: click.id,
      targetUrl: click.targetUrl,
      source: click.source,
      createdAt: click.createdAt,
      userId: click.userId,
      userRole: click.userRole,
      userName: click.user?.name ?? null,
      userEmail: click.user?.email ?? null,
      propertyId: click.propertyId,
      propertyTitle: click.property?.title ?? null,
      leadId: click.lead?.id ?? null,
    })) };
  });
}
