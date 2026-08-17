import cors from '@fastify/cors';
import { Prisma } from '@prisma/client';
import Fastify from 'fastify';
import { ZodError } from 'zod';

import { env } from './config/env.js';
import { adminBrokersRoutes } from './modules/admin/admin-brokers.routes.js';
import { adminReportsRoutes } from './modules/admin/admin-reports.routes.js';
import { adminUsersRoutes } from './modules/admin/admin-users.routes.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { healthRoutes } from './modules/health/health.routes.js';
import { homeRoutes } from './modules/home/home.routes.js';
import { mediaRoutes } from './modules/media/media.routes.js';
import { propertiesRoutes } from './modules/properties/properties.routes.js';
import { protectedPropertiesRoutes } from './modules/properties/protected-properties.routes.js';
import { sendApiError } from './shared/http/errors.js';

export async function buildApp() {
  const app = Fastify({
    logger: true,
  });

  await app.register(cors, {
    origin: (origin, callback) => {
      if (!origin) {
        callback(null, true);
        return;
      }

      const allowedOrigin = isAllowedLocalOrigin(origin) || origin === env.CORS_ORIGIN;
      callback(null, allowedOrigin);
    },
  });

  app.setErrorHandler((error, request, reply) => {
    request.log.error({ err: error }, 'request failed');

    if (error instanceof ZodError) {
      return sendApiError({
        reply,
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Confira os dados informados.',
        details: {
          issues: error.issues.map((issue) => ({
            path: issue.path.join('.'),
            message: issue.message,
            code: issue.code,
          })),
        },
        fieldErrors: mapZodFieldErrors(error),
        requestId: request.id,
      });
    }

    if (error instanceof Prisma.PrismaClientKnownRequestError) {
      const mapped = mapPrismaError(error);
      return sendApiError({
        reply,
        ...mapped,
        requestId: request.id,
      });
    }

    return sendApiError({
      reply,
      statusCode: 500,
      code: 'INTERNAL_ERROR',
      message: 'Nao foi possivel concluir a operacao agora.',
      requestId: request.id,
    });
  });

  await app.register(
    async (api) => {
      await api.register(healthRoutes);
      await api.register(authRoutes);
      await api.register(adminBrokersRoutes);
      await api.register(adminUsersRoutes);
      await api.register(adminReportsRoutes);
      await api.register(homeRoutes);
      await api.register(propertiesRoutes);
      await api.register(protectedPropertiesRoutes);
      await api.register(mediaRoutes);
    },
    { prefix: '/api/v1' },
  );

  return app;
}

function mapZodFieldErrors(error: ZodError) {
  const fieldErrors: Record<string, string[]> = {};

  for (const issue of error.issues) {
    const field = issue.path.join('.') || 'root';
    fieldErrors[field] ??= [];
    fieldErrors[field].push(issue.message);
  }

  return fieldErrors;
}

function mapPrismaError(error: Prisma.PrismaClientKnownRequestError) {
  if (error.code === 'P2002') {
    return {
      statusCode: 409,
      code: 'RESOURCE_ALREADY_EXISTS',
      message: 'Ja existe um registro com esses dados.',
      details: { prismaCode: error.code, target: error.meta?.target },
    };
  }

  if (error.code === 'P2025') {
    return {
      statusCode: 404,
      code: 'RESOURCE_NOT_FOUND',
      message: 'Registro nao encontrado.',
      details: { prismaCode: error.code },
    };
  }

  return {
    statusCode: 500,
    code: 'DATABASE_ERROR',
    message: 'Nao foi possivel salvar os dados agora.',
    details: { prismaCode: error.code },
  };
}

function isAllowedLocalOrigin(origin: string) {
  try {
    const url = new URL(origin);
    return url.hostname === 'localhost' || url.hostname === '127.0.0.1';
  } catch (_) {
    return false;
  }
}
