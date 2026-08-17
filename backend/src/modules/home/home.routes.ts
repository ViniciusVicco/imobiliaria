import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';

const featuredQuerySchema = z.object({
  limit: z.coerce.number().int().min(1).max(24).default(6),
});

export async function homeRoutes(app: FastifyInstance) {
  app.get('/home/brand-content', async (_, reply) => {
    const content = await prisma.brandContent.findUnique({
      where: { id: 'home' },
    });

    if (!content) {
      return reply.code(404).send({
        error: {
          code: 'BRAND_CONTENT_NOT_FOUND',
          message: 'Conteudo institucional nao encontrado.',
        },
      });
    }

    return {
      mission: content.mission,
      about: content.about,
      contact: {
        phone: content.contactPhone,
        email: content.contactEmail,
        whatsapp: content.contactWhatsapp,
      },
      videoProvider: content.videoProvider,
      videoTitle: content.videoTitle,
      videoThumbnailUrl: content.videoThumbnailUrl,
      videoUrl: content.videoUrl,
    };
  });

  app.get('/home/featured-properties', async (request) => {
    const query = featuredQuerySchema.parse(request.query);
    const properties = await prisma.property.findMany({
      where: {
        status: 'published',
        isFeatured: true,
      },
      orderBy: { updatedAt: 'desc' },
      take: query.limit,
    });

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
        tags: property.tagSlugs.slice(0, 3),
        areaM2: property.areaM2,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        garageSpaces: property.garageSpaces,
        propertyAgeYears: property.propertyAgeYears,
        price: property.price,
      })),
    };
  });
}
