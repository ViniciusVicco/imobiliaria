import type { FastifyInstance } from 'fastify';

import { prisma } from '../../shared/database/prisma.js';

export async function healthRoutes(app: FastifyInstance) {
  app.get('/health', async () => {
    await prisma.$queryRaw`SELECT 1`;

    return {
      status: 'ok',
      database: 'ok',
      version: '0.1.0',
    };
  });
}
