import cors from '@fastify/cors';
import Fastify from 'fastify';

import { env } from './config/env.js';
import { adminBrokersRoutes } from './modules/admin/admin-brokers.routes.js';
import { adminReportsRoutes } from './modules/admin/admin-reports.routes.js';
import { adminUsersRoutes } from './modules/admin/admin-users.routes.js';
import { authRoutes } from './modules/auth/auth.routes.js';
import { healthRoutes } from './modules/health/health.routes.js';
import { homeRoutes } from './modules/home/home.routes.js';
import { propertiesRoutes } from './modules/properties/properties.routes.js';

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

  await app.register(
    async (api) => {
      await api.register(healthRoutes);
      await api.register(authRoutes);
      await api.register(adminBrokersRoutes);
      await api.register(adminUsersRoutes);
      await api.register(adminReportsRoutes);
      await api.register(homeRoutes);
      await api.register(propertiesRoutes);
    },
    { prefix: '/api/v1' },
  );

  return app;
}

function isAllowedLocalOrigin(origin: string) {
  try {
    const url = new URL(origin);
    return url.hostname === 'localhost' || url.hostname === '127.0.0.1';
  } catch (_) {
    return false;
  }
}
