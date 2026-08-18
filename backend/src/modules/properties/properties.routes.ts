import type { Prisma } from '@prisma/client';
import type { FastifyInstance, FastifyRequest } from 'fastify';
import { z } from 'zod';

import { env } from '../../config/env.js';
import { prisma } from '../../shared/database/prisma.js';
import { getR2Object } from '../../shared/storage/r2-client.js';

const searchQuerySchema = z.object({
  city: z.string().trim().default('Palmas'),
  segment: z.enum(['residential', 'commercial', 'investments']).optional(),
  propertyType: z.string().trim().optional(),
  tag: z.string().trim().optional(),
  blockOrNeighborhood: z.string().trim().optional(),
  query: z.string().trim().optional(),
  bedroomsMin: z.coerce.number().int().min(0).optional(),
  bathroomsMin: z.coerce.number().int().min(0).optional(),
  garageSpacesMin: z.coerce.number().int().min(0).optional(),
  priceMin: z.coerce.number().int().min(0).optional(),
  priceMax: z.coerce.number().int().min(0).optional(),
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(24),
});

export async function propertiesRoutes(app: FastifyInstance) {
  app.get('/properties/search', async (request) => {
    const query = searchQuerySchema.parse(request.query);
    const where = buildPublishedPropertyWhere(query);
    const facetWhere = buildPublishedPropertyWhere(query, {
      ignorePrice: true,
    });
    const skip = (query.page - 1) * query.pageSize;

    const [properties, total, brandContent, priceRange] = await Promise.all([
      prisma.property.findMany({
        where,
        orderBy: { updatedAt: 'desc' },
        skip,
        take: query.pageSize,
        include: {
          broker: true,
          media: {
            where: {
              type: 'image',
              status: 'active',
              deletedAt: null,
            },
            orderBy: { sortOrder: 'asc' },
            take: 1,
          },
        },
      }),
      prisma.property.count({ where }),
      prisma.brandContent.findUnique({ where: { id: 'home' } }),
      prisma.property.aggregate({
        where: facetWhere,
        _min: { price: true },
        _max: { price: true },
      }),
    ]);

    return {
      items: properties.map((property) => ({
        id: property.id,
        title: property.title,
        segment: property.segment,
        propertyType: property.propertyType,
        city: property.city,
        neighborhood: property.neighborhood,
        subNeighborhood: property.subNeighborhood ?? '',
        coverUrl: publicCoverUrl({
          request,
          propertyId: property.id,
          coverUrl: property.coverUrl,
          mediaId: property.media[0]?.id,
        }),
        tags: property.tagSlugs.slice(0, 3),
        areaM2: property.areaM2,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        garageSpaces: property.garageSpaces,
        propertyAgeYears: property.propertyAgeYears,
        price: property.price,
        brokerContact: mapBrokerContact(property.broker, brandContent),
      })),
      pagination: {
        page: query.page,
        pageSize: query.pageSize,
        total,
        totalPages: Math.ceil(total / query.pageSize),
      },
      facets: {
        priceRange: {
          min: priceRange._min.price,
          max: priceRange._max.price,
        },
      },
    };
  });

  app.get('/properties/:id', async (request, reply) => {
    const params = z.object({ id: z.string().min(1) }).parse(request.params);
    const property = await prisma.property.findFirst({
      where: {
        id: params.id,
        status: 'published',
      },
      include: {
        media: {
          where: {
            status: 'active',
            deletedAt: null,
          },
          orderBy: { sortOrder: 'asc' },
        },
        broker: true,
      },
    });

    if (!property) {
      return reply.code(404).send({
        error: {
          code: 'PROPERTY_NOT_FOUND',
          message: 'Imovel nao encontrado.',
        },
      });
    }

    return {
      id: property.id,
      title: property.title,
      description: property.description ?? '',
      segment: property.segment,
      propertyType: property.propertyType,
      city: property.city,
      neighborhood: property.neighborhood,
      subNeighborhood: property.subNeighborhood ?? '',
      media: property.media.map((media) => ({
        id: media.id,
        url: media.publicUrl ?? media.url,
        type: media.type,
        sortOrder: media.sortOrder,
      })),
      facts: {
        areaM2: property.areaM2,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        garageSpaces: property.garageSpaces,
        propertyAgeYears: property.propertyAgeYears,
      },
      price: property.price,
      tags: property.tagSlugs.slice(0, 3),
      brokerContact: mapBrokerContact(
        property.broker,
        await prisma.brandContent.findUnique({ where: { id: 'home' } }),
      ),
    };
  });

  app.get('/properties/:id/cover', async (request, reply) => {
    const { id } = z.object({ id: z.string().min(1) }).parse(request.params);
    const property = await prisma.property.findFirst({
      where: { id, status: 'published' },
      include: {
        media: {
          where: {
            type: 'image',
            status: 'active',
            deletedAt: null,
          },
          orderBy: { sortOrder: 'asc' },
        },
      },
    });

    if (!property) return reply.code(404).send();

    const media = property.media.find(
      (item) => item.publicUrl === property.coverUrl || item.url === property.coverUrl,
    ) ?? property.media[0];
    if (!media?.storageKey) return reply.code(404).send();

    const file = await getR2Object(media.storageKey);
    return reply
      .header('Content-Type', media.mimeType ?? file.contentType ?? 'application/octet-stream')
      .header('Cache-Control', 'public, max-age=300')
      .send(file.body);
  });
}

function buildPublishedPropertyWhere(
  query: z.infer<typeof searchQuerySchema>,
  options: { ignorePrice?: boolean } = {},
): Prisma.PropertyWhereInput {
  const normalizedSegment =
    query.segment === 'investments' ? undefined : query.segment;
  const normalizedTag = normalizeSearchTag(query);
  const normalizedPropertyType = normalizePropertyType(query.propertyType);

  return {
    status: 'published',
    city: query.city,
    ...(normalizedSegment ? { segment: normalizedSegment } : {}),
    ...(normalizedPropertyType ? { propertyType: normalizedPropertyType } : {}),
    ...(normalizedTag ? { tagSlugs: { has: normalizedTag } } : {}),
    ...(query.bedroomsMin ? { bedrooms: { gte: query.bedroomsMin } } : {}),
    ...(query.bathroomsMin ? { bathrooms: { gte: query.bathroomsMin } } : {}),
    ...(query.garageSpacesMin
      ? { garageSpaces: { gte: query.garageSpacesMin } }
      : {}),
    ...(!options.ignorePrice && (query.priceMin || query.priceMax)
      ? {
          price: {
            ...(query.priceMin ? { gte: query.priceMin } : {}),
            ...(query.priceMax ? { lte: query.priceMax } : {}),
          },
        }
      : {}),
    ...(query.blockOrNeighborhood
      ? {
          OR: [
            {
              neighborhood: {
                contains: query.blockOrNeighborhood,
                mode: 'insensitive',
              },
            },
            {
              subNeighborhood: {
                contains: query.blockOrNeighborhood,
                mode: 'insensitive',
              },
            },
          ],
        }
      : {}),
    ...(query.query
      ? {
          AND: [
            {
              OR: [
                {
                  title: {
                    contains: query.query,
                    mode: 'insensitive',
                  },
                },
                {
                  description: {
                    contains: query.query,
                    mode: 'insensitive',
                  },
                },
              ],
            },
          ],
        }
      : {}),
  };
}

function normalizeSearchTag(query: z.infer<typeof searchQuerySchema>) {
  if (query.tag) return query.tag;
  if (query.segment === 'investments') return 'na-planta';
  if (query.propertyType === 'new-development') return 'na-planta';
  if (query.propertyType === 'near-delivery') return 'recem-entregue';
  return undefined;
}

function normalizePropertyType(propertyType?: string) {
  if (!propertyType) return undefined;
  if (propertyType === 'new-development' || propertyType === 'near-delivery') {
    return undefined;
  }

  const propertyTypeBySlug: Record<string, string> = {
    apartment: 'Apartamento',
    house: 'Casa',
    'condominium-house': 'Casa em condominio',
    townhouse: 'Sobrado',
    kitchenette: 'Kitnet',
    studio: 'Studio',
    'commercial-room': 'Sala comercial',
    store: 'Loja',
    warehouse: 'Galpao',
    'commercial-building': 'Predio comercial',
    'business-point': 'Ponto comercial',
    'commercial-land': 'Terreno comercial',
    coworking: 'Coworking',
    'clinic-office': 'Consultorio',
  };

  return propertyTypeBySlug[propertyType] ?? propertyType;
}

function mapBrokerContact(
  broker: { name: string; phone: string | null } | null,
  brandContent: { contactWhatsapp: string; contactPhone: string } | null,
) {
  const brokerPhone = broker?.phone?.trim();
  const fallbackPhone = brandContent?.contactWhatsapp || brandContent?.contactPhone || '';

  return {
    name: brokerPhone ? broker?.name ?? '' : 'Seletta',
    phone: brokerPhone || fallbackPhone,
    whatsapp: brokerPhone || fallbackPhone,
  };
}

function publicCoverUrl({
  request,
  propertyId,
  coverUrl,
  mediaId,
}: {
  request: FastifyRequest;
  propertyId: string;
  coverUrl: string;
  mediaId?: string;
}) {
  const r2BaseUrl = env.R2_PUBLIC_BASE_URL.replace(/\/$/, '');
  if (!mediaId || !r2BaseUrl || !coverUrl.startsWith(`${r2BaseUrl}/`)) {
    return coverUrl;
  }

  const forwardedProto = request.headers['x-forwarded-proto'];
  const forwardedHost = request.headers['x-forwarded-host'];
  const protocol = (Array.isArray(forwardedProto) ? forwardedProto[0] : forwardedProto)
    ?.split(',')[0]
    ?.trim() || request.protocol;
  const host = (Array.isArray(forwardedHost) ? forwardedHost[0] : forwardedHost)
    ?.split(',')[0]
    ?.trim() || request.headers.host || request.hostname;

  return `${protocol}://${host}/api/v1/properties/${propertyId}/cover`;
}
