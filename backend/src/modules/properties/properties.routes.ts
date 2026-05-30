import type { Prisma } from '@prisma/client';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';

const searchQuerySchema = z.object({
  city: z.string().trim().default('Palmas'),
  segment: z.enum(['residential', 'commercial', 'investments']).optional(),
  propertyType: z.string().trim().optional(),
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
    const skip = (query.page - 1) * query.pageSize;

    const [properties, total] = await Promise.all([
      prisma.property.findMany({
        where,
        orderBy: { updatedAt: 'desc' },
        skip,
        take: query.pageSize,
      }),
      prisma.property.count({ where }),
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
        coverUrl: property.coverUrl,
        areaM2: property.areaM2,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        garageSpaces: property.garageSpaces,
        propertyAgeYears: property.propertyAgeYears,
        price: property.price,
      })),
      pagination: {
        page: query.page,
        pageSize: query.pageSize,
        total,
        totalPages: Math.ceil(total / query.pageSize),
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
          orderBy: { sortOrder: 'asc' },
        },
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
        url: media.url,
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
    };
  });
}

function buildPublishedPropertyWhere(
  query: z.infer<typeof searchQuerySchema>,
): Prisma.PropertyWhereInput {
  return {
    status: 'published',
    city: query.city,
    ...(query.segment ? { segment: query.segment } : {}),
    ...(query.propertyType
      ? { propertyType: normalizePropertyType(query.propertyType) }
      : {}),
    ...(query.bedroomsMin ? { bedrooms: { gte: query.bedroomsMin } } : {}),
    ...(query.bathroomsMin ? { bathrooms: { gte: query.bathroomsMin } } : {}),
    ...(query.garageSpacesMin
      ? { garageSpaces: { gte: query.garageSpacesMin } }
      : {}),
    ...(query.priceMin || query.priceMax
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

function normalizePropertyType(propertyType: string) {
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
    'new-development': 'Oportunidades na planta',
    'near-delivery': 'Proximos de entregar',
  };

  return propertyTypeBySlug[propertyType] ?? propertyType;
}
