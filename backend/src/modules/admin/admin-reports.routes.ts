import type { FastifyInstance } from 'fastify';

import { requireActiveAdmin } from '../auth/auth.middleware.js';
import { prisma } from '../../shared/database/prisma.js';

export async function adminReportsRoutes(app: FastifyInstance) {
  app.get(
    '/admin/reports/brokers-property-summary',
    { preHandler: requireActiveAdmin },
    async () => {
      const brokers = await prisma.user.findMany({
        where: { role: 'broker' },
        orderBy: { name: 'asc' },
        include: {
          properties: {
            select: { status: true },
          },
        },
      });

      return {
        items: brokers.map((broker) => {
          const statusCount = broker.properties.reduce(
            (accumulator, property) => ({
              ...accumulator,
              [property.status]: accumulator[property.status] + 1,
            }),
            {
              draft: 0,
              pending_review: 0,
              published: 0,
              sold: 0,
              inactive: 0,
            },
          );

          return {
            brokerId: broker.id,
            brokerName: broker.name,
            brokerEmail: broker.email,
            totalProperties: broker.properties.length,
            draftProperties: statusCount.draft,
            pendingReviewProperties: statusCount.pending_review,
            publishedProperties: statusCount.published,
            soldProperties: statusCount.sold,
            inactiveProperties: statusCount.inactive,
          };
        }),
      };
    },
  );
}
