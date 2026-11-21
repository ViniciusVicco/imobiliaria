import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { brandContent } from '../../shared/brand-content.js';

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
      ...brandContent,
      about: brandContent.vision,
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
      include: {
        media: {
          where: { type: 'image', status: 'active', deletedAt: null },
          orderBy: { sortOrder: 'asc' },
          take: 1,
        },
      },
    });

    const r2BaseUrl = (process.env['R2_PUBLIC_BASE_URL'] ?? '').replace(/\/$/, '');

    function resolveCoverUrl(property: (typeof properties)[number]) {
      const stored = property.coverUrl?.trim() ?? '';
      if (stored) {
        const firstMedia = property.media[0];
        if (firstMedia && r2BaseUrl && stored.startsWith(`${r2BaseUrl}/`)) {
          const forwardedProto = request.headers['x-forwarded-proto'];
          const forwardedHost = request.headers['x-forwarded-host'];
          const protocol =
            (Array.isArray(forwardedProto) ? forwardedProto[0] : forwardedProto)
              ?.split(',')[0]
              ?.trim() || request.protocol;
          const host =
            (Array.isArray(forwardedHost) ? forwardedHost[0] : forwardedHost)
              ?.split(',')[0]
              ?.trim() ||
            request.headers.host ||
            request.hostname;
          return `${protocol}://${host}/api/v1/properties/${property.id}/cover`;
        }
        return stored;
      }
      // Fallback: first active image media public URL
      const fallback = property.media[0];
      return fallback?.publicUrl ?? fallback?.url ?? '';
    }

    return {
      items: properties.map((property) => ({
        id: property.id,
        title: property.title,
        segment: property.segment,
        propertyType: property.propertyType,
        city: property.city,
        neighborhood: property.neighborhood,
        subNeighborhood: property.subNeighborhood ?? '',
        coverUrl: resolveCoverUrl(property),
        tags: property.tagSlugs.slice(0, 3),
        areaM2: property.areaM2,
        privateAreaM2: property.privateAreaM2,
        totalAreaM2: property.totalAreaM2,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        garageSpaces: property.garageSpaces,
        propertyAgeYears: property.propertyAgeYears,
        price: property.price,
      })),
    };
  });
}
