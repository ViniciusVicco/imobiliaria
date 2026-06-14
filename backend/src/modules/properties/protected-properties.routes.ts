import { randomUUID } from 'node:crypto';

import type { Prisma, PropertyStatus } from '@prisma/client';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { sendApiError } from '../../shared/http/errors.js';
import {
  requireActiveAdmin,
  requireActiveBroker,
} from '../auth/auth.middleware.js';

const propertyStatusSchema = z.enum([
  'draft',
  'published',
  'sold',
  'inactive',
]);

const listPropertiesQuerySchema = z.object({
  status: propertyStatusSchema.optional(),
  brokerId: z.string().trim().optional(),
  query: z.string().trim().optional(),
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(24),
});

const propertyPayloadSchema = z.object({
  title: z.string().trim().min(1),
  description: z.string().trim().optional().default(''),
  segment: z.enum(['residential', 'commercial']),
  propertyType: z.string().trim().min(1),
  city: z.string().trim().min(1),
  neighborhood: z.string().trim().min(1),
  subNeighborhood: z.string().trim().optional().default(''),
  coverUrl: z.string().trim().url(),
  imageUrls: z.array(z.string().trim().url()).min(4).max(12),
  videoUrl: z.string().trim().url().optional().or(z.literal('')),
  areaM2: z.coerce.number().int().min(1),
  bedrooms: z.coerce.number().int().min(0).max(5).default(0),
  bathrooms: z.coerce.number().int().min(0).max(5),
  garageSpaces: z.coerce.number().int().min(0).max(5),
  propertyAgeYears: z.coerce.number().int().min(0).max(50).default(0),
  price: z.coerce.number().int().min(1),
  tagSlugs: z.array(z.string().trim().min(1)).default([]),
  isFeatured: z.boolean().default(false),
  isNewDevelopment: z.boolean().default(false),
  brokerId: z.string().trim().optional(),
});

const statusPayloadSchema = z.object({
  status: propertyStatusSchema,
});

export async function protectedPropertiesRoutes(app: FastifyInstance) {
  app.get(
    '/broker/properties',
    { preHandler: requireActiveBroker },
    async (request) => {
      const query = listPropertiesQuerySchema.parse(request.query);
      const brokerId = request.authenticatedUser?.id ?? '';
      return listProperties({
        query,
        where: buildListWhere(query, { brokerId }),
      });
    },
  );

  app.post(
    '/broker/properties',
    { preHandler: requireActiveBroker },
    async (request, reply) => {
      const payload = propertyPayloadSchema.parse(request.body);
      const brokerId = request.authenticatedUser?.id;
      if (!brokerId) {
        return sendApiError({
          reply,
          statusCode: 401,
          code: 'UNAUTHENTICATED',
          message: 'Entre para acessar esta area.',
        });
      }

      const validationError = await validateActiveTags(normalizeTagSlugs(payload));
      if (validationError) return sendApiError({ reply, ...validationError });

      const property = await upsertPropertyWithMedia({
        payload,
        brokerId,
        status: 'published',
      });

      return mapPropertyDetail(property);
    },
  );

  app.get(
    '/broker/properties/:id',
    { preHandler: requireActiveBroker },
    async (request, reply) => {
      const params = z.object({ id: z.string().min(1) }).parse(request.params);
      const brokerId = request.authenticatedUser?.id ?? '';
      const property = await findPropertyDetail({
        id: params.id,
        brokerId,
      });

      if (!property) return sendPropertyNotFound(reply);
      return mapPropertyDetail(property);
    },
  );

  app.patch(
    '/broker/properties/:id',
    { preHandler: requireActiveBroker },
    async (request, reply) => {
      const params = z.object({ id: z.string().min(1) }).parse(request.params);
      const payload = propertyPayloadSchema.parse(request.body);
      const brokerId = request.authenticatedUser?.id ?? '';
      const existing = await prisma.property.findFirst({
        where: { id: params.id, brokerId },
      });

      if (!existing) return sendPropertyNotFound(reply);

      const validationError = await validateActiveTags(normalizeTagSlugs(payload));
      if (validationError) return sendApiError({ reply, ...validationError });

      const property = await upsertPropertyWithMedia({
        id: params.id,
        payload,
        brokerId,
      });

      return mapPropertyDetail(property);
    },
  );

  app.patch(
    '/broker/properties/:id/status',
    { preHandler: requireActiveBroker },
    async (request, reply) => {
      const params = z.object({ id: z.string().min(1) }).parse(request.params);
      const payload = statusPayloadSchema.parse(request.body);
      const brokerId = request.authenticatedUser?.id ?? '';
      const existing = await prisma.property.findFirst({
        where: { id: params.id, brokerId },
      });

      if (!existing) return sendPropertyNotFound(reply);

      const property = await prisma.property.update({
        where: { id: params.id },
        data: { status: payload.status },
        include: propertyDetailInclude,
      });

      return mapPropertyDetail(property);
    },
  );

  app.get(
    '/admin/properties',
    { preHandler: requireActiveAdmin },
    async (request) => {
      const query = listPropertiesQuerySchema.parse(request.query);
      return listProperties({
        query,
        where: buildListWhere(query, {
          brokerId: query.brokerId,
        }),
      });
    },
  );

  app.get(
    '/admin/properties/:id',
    { preHandler: requireActiveAdmin },
    async (request, reply) => {
      const params = z.object({ id: z.string().min(1) }).parse(request.params);
      const property = await findPropertyDetail({ id: params.id });

      if (!property) return sendPropertyNotFound(reply);
      return mapPropertyDetail(property);
    },
  );

  app.patch(
    '/admin/properties/:id',
    { preHandler: requireActiveAdmin },
    async (request, reply) => {
      const params = z.object({ id: z.string().min(1) }).parse(request.params);
      const payload = propertyPayloadSchema.parse(request.body);
      const existing = await prisma.property.findUnique({
        where: { id: params.id },
      });

      if (!existing) return sendPropertyNotFound(reply);

      const validationError = await validateActiveTags(normalizeTagSlugs(payload));
      if (validationError) return sendApiError({ reply, ...validationError });

      const brokerValidationError = await validateBrokerId(payload.brokerId);
      if (brokerValidationError) {
        return sendApiError({ reply, ...brokerValidationError });
      }

      const property = await upsertPropertyWithMedia({
        id: params.id,
        payload,
        brokerId: payload.brokerId ?? null,
      });

      return mapPropertyDetail(property);
    },
  );

  app.patch(
    '/admin/properties/:id/status',
    { preHandler: requireActiveAdmin },
    async (request, reply) => {
      const params = z.object({ id: z.string().min(1) }).parse(request.params);
      const payload = statusPayloadSchema.parse(request.body);
      const existing = await prisma.property.findUnique({
        where: { id: params.id },
      });

      if (!existing) return sendPropertyNotFound(reply);

      const property = await prisma.property.update({
        where: { id: params.id },
        data: { status: payload.status },
        include: propertyDetailInclude,
      });

      return mapPropertyDetail(property);
    },
  );
}

const propertyDetailInclude = {
  media: {
    orderBy: { sortOrder: 'asc' },
  },
  broker: true,
} satisfies Prisma.PropertyInclude;

async function listProperties({
  query,
  where,
}: {
  query: z.infer<typeof listPropertiesQuerySchema>;
  where: Prisma.PropertyWhereInput;
}) {
  const skip = (query.page - 1) * query.pageSize;
  const [properties, total] = await Promise.all([
    prisma.property.findMany({
      where,
      orderBy: { updatedAt: 'desc' },
      skip,
      take: query.pageSize,
      include: { broker: true },
    }),
    prisma.property.count({ where }),
  ]);

  return {
    items: properties.map(mapPropertyListItem),
    pagination: {
      page: query.page,
      pageSize: query.pageSize,
      total,
      totalPages: Math.ceil(total / query.pageSize),
    },
  };
}

function buildListWhere(
  query: z.infer<typeof listPropertiesQuerySchema>,
  options: { brokerId?: string },
): Prisma.PropertyWhereInput {
  return {
    ...(options.brokerId ? { brokerId: options.brokerId } : {}),
    ...(query.status ? { status: query.status } : {}),
    ...(query.query
      ? {
          OR: [
            { title: { contains: query.query, mode: 'insensitive' } },
            { description: { contains: query.query, mode: 'insensitive' } },
            { neighborhood: { contains: query.query, mode: 'insensitive' } },
            { subNeighborhood: { contains: query.query, mode: 'insensitive' } },
          ],
        }
      : {}),
  };
}

async function findPropertyDetail({
  id,
  brokerId,
}: {
  id: string;
  brokerId?: string;
}) {
  return prisma.property.findFirst({
    where: {
      id,
      ...(brokerId ? { brokerId } : {}),
    },
    include: propertyDetailInclude,
  });
}

async function upsertPropertyWithMedia({
  id,
  payload,
  brokerId,
  status,
}: {
  id?: string;
  payload: z.infer<typeof propertyPayloadSchema>;
  brokerId: string | null;
  status?: PropertyStatus;
}) {
  const propertyId = id ?? randomUUID();
  const tagSlugs = normalizeTagSlugs(payload);
  const propertyAgeYears = payload.isNewDevelopment
    ? 0
    : payload.propertyAgeYears;

  return prisma.$transaction(async (tx) => {
    const property = await tx.property.upsert({
      where: { id: propertyId },
      create: {
        id: propertyId,
        brokerId,
        title: payload.title,
        description: payload.description,
        segment: payload.segment,
        propertyType: payload.propertyType,
        tagSlugs,
        city: payload.city,
        neighborhood: payload.neighborhood,
        subNeighborhood: payload.subNeighborhood,
        coverUrl: payload.coverUrl,
        areaM2: payload.areaM2,
        bedrooms: payload.bedrooms,
        bathrooms: payload.bathrooms,
        garageSpaces: payload.garageSpaces,
        propertyAgeYears,
        price: payload.price,
        status: status ?? 'published',
        isFeatured: payload.isFeatured,
      },
      update: {
        brokerId,
        title: payload.title,
        description: payload.description,
        segment: payload.segment,
        propertyType: payload.propertyType,
        tagSlugs,
        city: payload.city,
        neighborhood: payload.neighborhood,
        subNeighborhood: payload.subNeighborhood,
        coverUrl: payload.coverUrl,
        areaM2: payload.areaM2,
        bedrooms: payload.bedrooms,
        bathrooms: payload.bathrooms,
        garageSpaces: payload.garageSpaces,
        propertyAgeYears,
        price: payload.price,
        isFeatured: payload.isFeatured,
      },
    });

    await tx.propertyMedia.deleteMany({ where: { propertyId } });
    await tx.propertyMedia.createMany({
      data: buildMediaRows({
        propertyId,
        imageUrls: payload.imageUrls,
        videoUrl: payload.videoUrl,
      }),
    });

    return tx.property.findUniqueOrThrow({
      where: { id: property.id },
      include: propertyDetailInclude,
    });
  });
}

function buildMediaRows({
  propertyId,
  imageUrls,
  videoUrl,
}: {
  propertyId: string;
  imageUrls: string[];
  videoUrl?: string;
}) {
  const imageRows = imageUrls.map((url, index) => ({
    id: randomUUID(),
    propertyId,
    url,
    type: 'image' as const,
    sortOrder: index,
  }));

  if (!videoUrl) return imageRows;

  return [
    ...imageRows,
    {
      id: randomUUID(),
      propertyId,
      url: videoUrl,
      type: 'video' as const,
      sortOrder: imageRows.length,
    },
  ];
}

function normalizeTagSlugs(payload: z.infer<typeof propertyPayloadSchema>) {
  const tagSlugs = new Set(payload.tagSlugs);
  if (payload.isNewDevelopment) tagSlugs.add('na-planta');
  return [...tagSlugs];
}

async function validateActiveTags(tagSlugs: string[]) {
  if (tagSlugs.length === 0) return null;

  const activeTags = await prisma.propertyTag.findMany({
    where: {
      slug: { in: tagSlugs },
      isActive: true,
    },
    select: { slug: true },
  });

  const activeTagSlugs = new Set(activeTags.map((tag) => tag.slug));
  const hasInactiveOrUnknownTag = tagSlugs.some(
    (tagSlug) => !activeTagSlugs.has(tagSlug),
  );

  if (!hasInactiveOrUnknownTag) return null;

  return {
    statusCode: 400,
    code: 'INVALID_PROPERTY_TAG',
    message: 'Informe apenas tags de imovel conhecidas e ativas.',
  };
}

async function validateBrokerId(brokerId?: string) {
  if (!brokerId) return null;

  const broker = await prisma.user.findFirst({
    where: {
      id: brokerId,
      role: 'broker',
      isActive: true,
    },
  });

  if (broker) return null;

  return {
    statusCode: 400,
    code: 'INVALID_BROKER',
    message: 'Informe um corretor ativo para este imovel.',
  };
}

function mapPropertyListItem(
  property: Prisma.PropertyGetPayload<{ include: { broker: true } }>,
) {
  return {
    id: property.id,
    title: property.title,
    segment: property.segment,
    propertyType: property.propertyType,
    city: property.city,
    neighborhood: property.neighborhood,
    subNeighborhood: property.subNeighborhood ?? '',
    coverUrl: property.coverUrl,
    tags: property.tagSlugs,
    areaM2: property.areaM2,
    bedrooms: property.bedrooms,
    bathrooms: property.bathrooms,
    garageSpaces: property.garageSpaces,
    propertyAgeYears: property.propertyAgeYears,
    price: property.price,
    status: property.status,
    isFeatured: property.isFeatured,
    updatedAt: property.updatedAt.toISOString(),
    broker: property.broker
      ? {
          id: property.broker.id,
          name: property.broker.name,
          phone: property.broker.phone ?? '',
        }
      : null,
  };
}

function mapPropertyDetail(
  property: Prisma.PropertyGetPayload<{ include: typeof propertyDetailInclude }>,
) {
  return {
    ...mapPropertyListItem(property),
    description: property.description ?? '',
    imageUrls: property.media
      .filter((media) => media.type === 'image')
      .map((media) => media.url),
    videoUrl:
      property.media.find((media) => media.type === 'video')?.url ?? '',
    media: property.media.map((media) => ({
      id: media.id,
      url: media.url,
      type: media.type,
      sortOrder: media.sortOrder,
    })),
  };
}

function sendPropertyNotFound(reply: Parameters<typeof sendApiError>[0]['reply']) {
  return sendApiError({
    reply,
    statusCode: 404,
    code: 'PROPERTY_NOT_FOUND',
    message: 'Imovel nao encontrado.',
  });
}
