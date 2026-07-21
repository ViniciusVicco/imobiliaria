import { randomUUID } from 'node:crypto';

import type { Prisma, PropertyStatus } from '@prisma/client';
import type { FastifyInstance, FastifyReply } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { sendApiError } from '../../shared/http/errors.js';
import {
  buildR2PublicUrl,
  copyR2Object,
  deleteR2Object,
  R2ConfigurationError,
} from '../../shared/storage/r2-client.js';
import {
  requireActiveAdmin,
  requireActiveBroker,
} from '../auth/auth.middleware.js';
import { buildPropertyMediaStorageKey } from '../media/media.routes.js';

const propertyStatusSchema = z.enum([
  'draft',
  'pending_review',
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
  title: z.string().trim(),
  description: z.string().trim().optional().default(''),
  segment: z.enum(['residential', 'commercial']),
  propertyType: z.string().trim(),
  city: z.string().trim(),
  neighborhood: z.string().trim(),
  subNeighborhood: z.string().trim().optional().default(''),
  coverUrl: z.string().trim().url().or(z.literal('')).default(''),
  imageUrls: z.array(z.string().trim().url()).max(12).default([]),
  videoUrl: z.string().trim().url().optional().or(z.literal('')),
  areaM2: z.coerce.number().int().min(0),
  bedrooms: z.coerce.number().int().min(0).max(10).default(0),
  bathrooms: z.coerce.number().int().min(0).max(10),
  garageSpaces: z.coerce.number().int().min(0).max(10),
  propertyAgeYears: z.coerce.number().int().min(0).max(50).default(0),
  price: z.coerce.number().int().min(0),
  tagSlugs: z.array(z.string().trim().min(1)).default([]),
  isFeatured: z.boolean().default(false),
  isNewDevelopment: z.boolean().default(false),
  brokerId: z.string().trim().optional(),
  mediaIds: z.array(z.string().trim().min(1)).max(12).default([]),
  coverMediaId: z.string().trim().optional(),
  uploadSessionId: z.string().trim().optional(),
});

const statusPayloadSchema = z.object({
  status: propertyStatusSchema,
});

export async function protectedPropertiesRoutes(app: FastifyInstance) {
  app.post(
    '/broker/properties/draft',
    { preHandler: requireActiveBroker },
    async (request, reply) => {
      const brokerId = request.authenticatedUser?.id;
      if (!brokerId) {
        return sendApiError({
          reply,
          statusCode: 401,
          code: 'UNAUTHENTICATED',
          message: 'Entre para acessar esta area.',
        });
      }

      const property = await prisma.property.create({
        data: {
          id: randomUUID(),
          brokerId,
          title: 'Novo imovel',
          description: '',
          segment: 'residential',
          propertyType: 'Apartamento',
          tagSlugs: [],
          city: 'Palmas',
          neighborhood: 'A definir',
          subNeighborhood: '',
          coverUrl: '',
          areaM2: null,
          bedrooms: null,
          bathrooms: null,
          garageSpaces: null,
          propertyAgeYears: null,
          price: null,
          status: 'draft',
          isFeatured: false,
        },
        include: propertyDetailInclude,
      });

      return mapPropertyDetail(property);
    },
  );

  app.post(
    '/admin/properties/draft',
    { preHandler: requireActiveAdmin },
    async () => {
      const property = await prisma.property.create({
        data: {
          id: randomUUID(),
          brokerId: null,
          title: 'Novo imovel',
          description: '',
          segment: 'residential',
          propertyType: 'Apartamento',
          tagSlugs: [],
          city: 'Palmas',
          neighborhood: 'A definir',
          subNeighborhood: '',
          coverUrl: '',
          areaM2: null,
          bedrooms: null,
          bathrooms: null,
          garageSpaces: null,
          propertyAgeYears: null,
          price: null,
          status: 'draft',
          isFeatured: false,
        },
        include: propertyDetailInclude,
      });

      return mapPropertyDetail(property);
    },
  );

  app.get(
    '/broker/properties',
    { preHandler: requireActiveBroker },
    async (request) => {
      const query = listPropertiesQuerySchema.parse(request.query);
      const brokerId = request.authenticatedUser?.id ?? '';
      const countWhere = buildListWhere(query, {
        brokerId,
        omitStatus: true,
        excludeInactiveWhenNoStatus: true,
      });
      return listProperties({
        query,
        where: buildListWhere(query, {
          brokerId,
          excludeInactiveWhenNoStatus: true,
        }),
        countWhere,
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

      const property = await createPropertyWithTemporaryMedia({
        payload,
        brokerId,
        status: 'pending_review',
        uploadedBy: brokerId,
        reply,
      });

      if (!property) return;
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

      const nextStatus =
        existing.status === 'published' ? 'pending_review' : existing.status;
      const property = await upsertPropertyWithMedia({
        id: params.id,
        payload,
        brokerId,
        status: nextStatus,
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

      if (payload.status === 'pending_review' || payload.status === 'published') {
        const finalizationError = await validatePropertyReadyForPublication(
          params.id,
        );
        if (finalizationError) return sendApiError({ reply, ...finalizationError });
      }

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

  app.post(
    '/admin/properties',
    { preHandler: requireActiveAdmin },
    async (request, reply) => {
      const payload = propertyPayloadSchema.parse(request.body);

      const validationError = await validateActiveTags(normalizeTagSlugs(payload));
      if (validationError) return sendApiError({ reply, ...validationError });

      const brokerValidationError = await validateBrokerId(payload.brokerId);
      if (brokerValidationError) {
        return sendApiError({ reply, ...brokerValidationError });
      }

      const adminId = request.authenticatedUser?.id ?? '';
      const property = await createPropertyWithTemporaryMedia({
        payload,
        brokerId: payload.brokerId ?? null,
        status: 'published',
        uploadedBy: adminId,
        reply,
      });

      if (!property) return;
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

      if (payload.status === 'pending_review' || payload.status === 'published') {
        const finalizationError = await validatePropertyReadyForPublication(
          params.id,
        );
        if (finalizationError) return sendApiError({ reply, ...finalizationError });
      }

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
    where: {
      deletedAt: null,
    },
    orderBy: { sortOrder: 'asc' },
  },
  broker: true,
} satisfies Prisma.PropertyInclude;

const propertyListInclude = {
  broker: true,
  media: {
    where: {
      status: 'active',
      deletedAt: null,
    },
    orderBy: { sortOrder: 'asc' },
  },
} satisfies Prisma.PropertyInclude;

async function listProperties({
  query,
  where,
  countWhere,
}: {
  query: z.infer<typeof listPropertiesQuerySchema>;
  where: Prisma.PropertyWhereInput;
  countWhere?: Prisma.PropertyWhereInput;
}) {
  const skip = (query.page - 1) * query.pageSize;
  const statusCountWhere = countWhere ?? where;
  const [properties, total, published, pendingReview, sold] = await Promise.all([
    prisma.property.findMany({
      where,
      orderBy: { updatedAt: 'desc' },
      skip,
      take: query.pageSize,
      include: propertyListInclude,
    }),
    prisma.property.count({ where }),
    prisma.property.count({ where: { ...statusCountWhere, status: 'published' } }),
    prisma.property.count({
      where: { ...statusCountWhere, status: 'pending_review' },
    }),
    prisma.property.count({ where: { ...statusCountWhere, status: 'sold' } }),
  ]);

  const all = published + pendingReview + sold;
  return {
    items: properties.map(mapPropertyListItem),
    pagination: {
      page: query.page,
      pageSize: query.pageSize,
      total,
      totalPages: Math.ceil(total / query.pageSize),
    },
    statusCounts: {
      all,
      published,
      pending_review: pendingReview,
      sold,
    },
  };
}

function buildListWhere(
  query: z.infer<typeof listPropertiesQuerySchema>,
  options: {
    brokerId?: string;
    omitStatus?: boolean;
    excludeInactiveWhenNoStatus?: boolean;
  },
): Prisma.PropertyWhereInput {
  return {
    ...(options.brokerId ? { brokerId: options.brokerId } : {}),
    ...(!options.omitStatus && query.status
      ? { status: query.status }
      : {}),
    ...(!query.status && options.excludeInactiveWhenNoStatus
      ? { status: { not: 'inactive' } }
      : {}),
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

async function createPropertyWithTemporaryMedia({
  payload,
  brokerId,
  status,
  uploadedBy,
  reply,
}: {
  payload: z.infer<typeof propertyPayloadSchema>;
  brokerId: string | null;
  status: PropertyStatus;
  uploadedBy: string;
  reply: FastifyReply;
}) {
  const validationError = await validatePayloadReadyForCreation(payload, uploadedBy);
  if (validationError) {
    sendApiError({ reply, ...validationError });
    return null;
  }

  const propertyId = randomUUID();
  const tagSlugs = normalizeTagSlugs(payload);
  const propertyAgeYears = payload.isNewDevelopment
    ? 0
    : payload.propertyAgeYears;

  const mediaItems = await prisma.propertyMedia.findMany({
    where: {
      id: { in: payload.mediaIds },
      propertyId: null,
      uploadedBy,
      uploadSessionId: payload.uploadSessionId,
      type: 'image',
      status: 'active',
      deletedAt: null,
    },
    orderBy: { sortOrder: 'asc' },
  });

  const mediaById = new Map(mediaItems.map((media) => [media.id, media]));
  const coverMedia = payload.coverMediaId
    ? mediaById.get(payload.coverMediaId)
    : null;

  if (mediaItems.length !== payload.mediaIds.length || !coverMedia) {
    sendApiError({
      reply,
      statusCode: 400,
      code: 'INVALID_PROPERTY_MEDIA',
      message: 'Use apenas imagens enviadas nesta criacao.',
    });
    return null;
  }

  const promotedMedia: Array<{
    id: string;
    sourceKey: string;
    storageKey: string;
    publicUrl: string;
    sortOrder: number;
  }> = [];
  try {
    for (const [index, mediaId] of payload.mediaIds.entries()) {
      const media = mediaById.get(mediaId);
      if (!media?.storageKey) throw new Error('TEMP_MEDIA_FILE_NOT_AVAILABLE');

      const destinationKey = buildPropertyMediaStorageKey({
        propertyId,
        fileName: media.storageKey.split('/').pop() ?? 'image',
      });
      const publicUrl = buildR2PublicUrl(destinationKey);

      await copyR2Object({
        sourceKey: media.storageKey,
        destinationKey,
      });

      promotedMedia.push({
        id: media.id,
        sourceKey: media.storageKey,
        storageKey: destinationKey,
        publicUrl,
        sortOrder: index,
      });
    }
  } catch (error) {
    if (
      error instanceof R2ConfigurationError ||
      error instanceof Error
    ) {
      sendApiError({
        reply,
        statusCode: 502,
        code: 'PROPERTY_MEDIA_PROMOTION_FAILED',
        message: 'Nao foi possivel finalizar as imagens do imovel.',
      });
      return null;
    }

    throw error;
  }

  const promotedCover = promotedMedia.find(
    (media) => media.id === payload.coverMediaId,
  );
  if (!promotedCover) {
    sendApiError({
      reply,
      statusCode: 400,
      code: 'PROPERTY_COVER_INVALID',
      message: 'Defina uma foto de capa ativa antes de criar o imovel.',
    });
    return null;
  }

  try {
    const property = await prisma.$transaction(async (tx) => {
      const property = await tx.property.create({
        data: {
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
          coverUrl: promotedCover.publicUrl,
          areaM2: payload.areaM2,
          bedrooms: payload.bedrooms,
          bathrooms: payload.bathrooms,
          garageSpaces: payload.garageSpaces,
          propertyAgeYears,
          price: payload.price,
          status,
          isFeatured: payload.isFeatured,
        },
      });

      for (const media of promotedMedia) {
        await tx.propertyMedia.update({
          where: { id: media.id },
          data: {
            propertyId,
            url: media.publicUrl,
            publicUrl: media.publicUrl,
            storageKey: media.storageKey,
            sortOrder: media.sortOrder,
            uploadSessionId: null,
          },
        });
      }

      return tx.property.findUniqueOrThrow({
        where: { id: property.id },
        include: propertyDetailInclude,
      });
    });

    for (const media of promotedMedia) {
      await deleteR2Object(media.sourceKey).catch(() => undefined);
    }

    return property;
  } catch (error) {
    for (const media of promotedMedia) {
      await deleteR2Object(media.storageKey).catch(() => undefined);
    }

    if (error instanceof Error && error.message === 'INVALID_TEMP_MEDIA_STATE') {
      sendApiError({
        reply,
        statusCode: 400,
        code: 'INVALID_PROPERTY_MEDIA',
        message: 'Use apenas imagens enviadas nesta criacao.',
      });
      return null;
    }
    throw error;
  }
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
        ...(status ? { status } : {}),
      },
    });

    if (payload.imageUrls.length > 0) {
      await tx.propertyMedia.deleteMany({ where: { propertyId } });
      await tx.propertyMedia.createMany({
        data: buildMediaRows({
          propertyId,
          imageUrls: payload.imageUrls,
          videoUrl: payload.videoUrl,
        }),
      });
    } else {
      await tx.propertyMedia.deleteMany({
        where: { propertyId, type: 'video' },
      });
      if (payload.videoUrl) {
        await tx.propertyMedia.create({
          data: {
            id: randomUUID(),
            propertyId,
            url: payload.videoUrl,
            type: 'video',
            sortOrder: 1000,
          },
        });
      }
    }

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

function validatePayloadReadyForPublication(
  payload: z.infer<typeof propertyPayloadSchema>,
) {
  const hasMissingText = [
    payload.title,
    payload.propertyType,
    payload.city,
    payload.neighborhood,
  ].some((value) => !value.trim());
  if (
    hasMissingText ||
    payload.areaM2 <= 0 ||
    payload.price <= 0
  ) {
    return {
      statusCode: 400,
      code: 'PROPERTY_REQUIRED_FIELDS',
      message: 'Preencha os dados obrigatorios antes de publicar.',
    };
  }

  if (!payload.coverUrl) {
    return {
      statusCode: 400,
      code: 'PROPERTY_COVER_REQUIRED',
      message: 'Defina uma foto de capa antes de publicar.',
    };
  }

  if (payload.imageUrls.length < 4 || payload.imageUrls.length > 12) {
    return {
      statusCode: 400,
      code: 'PROPERTY_IMAGES_INVALID',
      message: 'Informe entre 4 e 12 fotos antes de publicar.',
    };
  }

  if (!payload.imageUrls.includes(payload.coverUrl)) {
    return {
      statusCode: 400,
      code: 'PROPERTY_COVER_INVALID',
      message: 'A capa deve ser uma imagem ativa do imovel.',
    };
  }

  return null;
}

async function validatePayloadReadyForCreation(
  payload: z.infer<typeof propertyPayloadSchema>,
  uploadedBy: string,
) {
  const baseValidationError = validatePayloadRequiredFields(payload);
  if (baseValidationError) return baseValidationError;

  const mediaIds = [...new Set(payload.mediaIds)];
  if (
    !payload.uploadSessionId?.trim() ||
    mediaIds.length !== payload.mediaIds.length ||
    mediaIds.length < 4 ||
    mediaIds.length > 12
  ) {
    return {
      statusCode: 400,
      code: 'PROPERTY_IMAGES_INVALID',
      message: 'Envie entre 4 e 12 fotos antes de criar o imovel.',
    };
  }

  if (!payload.coverMediaId || !mediaIds.includes(payload.coverMediaId)) {
    return {
      statusCode: 400,
      code: 'PROPERTY_COVER_INVALID',
      message: 'Defina uma foto de capa ativa antes de criar o imovel.',
    };
  }

  const mediaCount = await prisma.propertyMedia.count({
    where: {
      id: { in: mediaIds },
      propertyId: null,
      uploadedBy,
      uploadSessionId: payload.uploadSessionId,
      type: 'image',
      status: 'active',
      deletedAt: null,
    },
  });

  if (mediaCount !== mediaIds.length) {
    return {
      statusCode: 400,
      code: 'INVALID_PROPERTY_MEDIA',
      message: 'Use apenas imagens enviadas nesta criacao.',
    };
  }

  return null;
}

function validatePayloadRequiredFields(
  payload: z.infer<typeof propertyPayloadSchema>,
) {
  const hasMissingText = [
    payload.title,
    payload.propertyType,
    payload.city,
    payload.neighborhood,
  ].some((value) => !value.trim());

  if (
    hasMissingText ||
    payload.areaM2 <= 0 ||
    payload.price <= 0 ||
    payload.bathrooms === null ||
    payload.garageSpaces === null
  ) {
    return {
      statusCode: 400,
      code: 'PROPERTY_REQUIRED_FIELDS',
      message: 'Preencha os dados obrigatorios antes de criar o imovel.',
    };
  }

  return null;
}

async function validatePropertyReadyForPublication(propertyId: string) {
  const property = await prisma.property.findUnique({
    where: { id: propertyId },
    include: {
      media: {
        where: {
          type: 'image',
          status: 'active',
          deletedAt: null,
        },
      },
    },
  });

  if (!property) {
    return {
      statusCode: 404,
      code: 'PROPERTY_NOT_FOUND',
      message: 'Imovel nao encontrado.',
    };
  }

  const requiredFields = [
    property.title,
    property.propertyType,
    property.city,
    property.neighborhood,
  ];
  const hasMissingText = requiredFields.some((value) => !value.trim());
  const hasMissingNumbers =
    !property.areaM2 ||
    property.bathrooms === null ||
    property.garageSpaces === null ||
    !property.price;

  if (hasMissingText || hasMissingNumbers) {
    return {
      statusCode: 400,
      code: 'PROPERTY_REQUIRED_FIELDS',
      message: 'Preencha os dados obrigatorios antes de publicar.',
    };
  }

  if (property.media.length < 4 || property.media.length > 12) {
    return {
      statusCode: 400,
      code: 'PROPERTY_IMAGES_INVALID',
      message: 'Envie entre 4 e 12 fotos antes de publicar.',
    };
  }

  const coverUrl = property.coverUrl.trim();
  const hasActiveCover = property.media.some(
    (media) => media.url === coverUrl || media.publicUrl === coverUrl,
  );

  if (!coverUrl || !hasActiveCover) {
    return {
      statusCode: 400,
      code: 'PROPERTY_COVER_INVALID',
      message: 'Defina uma foto de capa ativa antes de publicar.',
    };
  }

  return null;
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
  property: Prisma.PropertyGetPayload<{ include: typeof propertyListInclude }>,
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
    media: property.media.map((media) => ({
      id: media.id,
      propertyId: media.propertyId,
      url: media.publicUrl ?? media.url,
      publicUrl: media.publicUrl ?? media.url,
      storageKey: media.storageKey,
      type: media.type,
      status: media.status,
      mimeType: media.mimeType,
      sizeBytes: media.sizeBytes,
      sortOrder: media.sortOrder,
      pendingDeleteAt: media.pendingDeleteAt?.toISOString() ?? null,
      deletedAt: media.deletedAt?.toISOString() ?? null,
    })),
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
      .filter((media) => media.type === 'image' && media.status === 'active')
      .map((media) => media.publicUrl ?? media.url),
    videoUrl:
      property.media.find(
        (media) => media.type === 'video' && media.status === 'active',
      )?.publicUrl ??
      property.media.find(
        (media) => media.type === 'video' && media.status === 'active',
      )?.url ??
      '',
    media: property.media.map((media) => ({
      id: media.id,
      propertyId: media.propertyId,
      url: media.publicUrl ?? media.url,
      publicUrl: media.publicUrl ?? media.url,
      storageKey: media.storageKey,
      type: media.type,
      status: media.status,
      mimeType: media.mimeType,
      sizeBytes: media.sizeBytes,
      sortOrder: media.sortOrder,
      pendingDeleteAt: media.pendingDeleteAt?.toISOString() ?? null,
      deletedAt: media.deletedAt?.toISOString() ?? null,
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
