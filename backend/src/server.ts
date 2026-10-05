import { buildApp } from './app.js';
import { env } from './config/env.js';
import { prisma } from './shared/database/prisma.js';

const app = await buildApp();

try {
  await app.listen({
    port: env.PORT,
    host: '0.0.0.0',
  });
} catch (error) {
  app.log.error(error);
  await prisma.$disconnect();
  process.exit(1);
}

const shutdown = async () => {
  await app.close();
  await prisma.$disconnect();
};

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
