import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { sendApiError } from '../../shared/http/errors.js';
import { signAccessToken } from '../../shared/security/jwt.js';
import { verifyPassword } from '../../shared/security/password.js';
import { requireAuthenticatedUser } from './auth.middleware.js';

const loginBodySchema = z.object({
  email: z.string().trim().email(),
  password: z.string().min(1),
});

export async function authRoutes(app: FastifyInstance) {
  app.post('/auth/login', async (request, reply) => {
    const body = loginBodySchema.parse(request.body);
    const user = await prisma.user.findUnique({
      where: { email: body.email.toLowerCase() },
    });

    if (!user) {
      return sendInvalidCredentials(reply);
    }

    if (!user.isActive) {
      return sendApiError({
        reply,
        statusCode: 403,
        code: 'INACTIVE_USER',
        message: 'Este usuario esta inativo.',
      });
    }

    const hasValidPassword = await verifyPassword({
      password: body.password,
      passwordHash: user.passwordHash,
    });

    if (!hasValidPassword) {
      return sendInvalidCredentials(reply);
    }

    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    return {
      accessToken: signAccessToken(user.id),
      user: toUserResponse(user),
    };
  });

  app.get('/me', { preHandler: requireAuthenticatedUser }, async (request) => {
    return request.authenticatedUser;
  });

  app.post(
    '/auth/logout',
    { preHandler: requireAuthenticatedUser },
    async () => ({ success: true }),
  );
}

function sendInvalidCredentials(reply: Parameters<typeof sendApiError>[0]['reply']) {
  return sendApiError({
    reply,
    statusCode: 401,
    code: 'INVALID_CREDENTIALS',
    message: 'Email ou senha invalidos.',
  });
}

function toUserResponse(user: {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  role: 'admin' | 'broker';
  isActive: boolean;
}) {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    phone: user.phone ?? '',
    role: user.role,
    isActive: user.isActive,
  };
}
