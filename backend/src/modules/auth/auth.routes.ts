import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { sendApiError } from '../../shared/http/errors.js';
import { signAccessToken } from '../../shared/security/jwt.js';
import { hashPassword, verifyPassword } from '../../shared/security/password.js';
import { updateProfileBodySchema } from '../../shared/users/profile-schema.js';
import { avatarBodyLimit, uploadAvatarBodySchema, replaceAvatar, cleanupLegacyAvatars } from '../../shared/users/avatar.js';
import { buildBrokerCode } from '../../shared/users/broker-code.js';
import { requireAuthenticatedUser } from './auth.middleware.js';

const loginBodySchema = z.object({
  email: z.string().trim().email(),
  password: z.string().min(1),
});

const updatePasswordBodySchema = z
  .object({
    currentPassword: z.string().min(1),
    newPassword: z.string().min(8),
    newPasswordConfirmation: z.string().min(8),
  })
  .refine((body) => body.newPassword === body.newPasswordConfirmation, {
    path: ['newPasswordConfirmation'],
    message: 'Confirme a mesma nova senha.',
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
    return toUserResponse(request.authenticatedUser!);
  });

  app.patch(
    '/me/profile',
    { preHandler: requireAuthenticatedUser },
    async (request) => {
      const body = updateProfileBodySchema.parse(request.body);
      const currentUser = request.authenticatedUser!;

      const user = await prisma.user.update({
        where: { id: currentUser.id },
        data: {
          ...(body.name !== undefined ? { name: body.name } : {}),
          ...(body.phone !== undefined
            ? { phone: body.phone?.trim() || null }
            : {}),
          ...(body.whatsapp !== undefined
            ? { whatsapp: body.whatsapp?.trim() || null }
            : {}),
          ...(body.creci !== undefined
            ? { creci: body.creci?.trim() || null }
            : {}),
          ...(body.about !== undefined
            ? { about: body.about?.trim() || null }
            : {}),
          ...(currentUser.role === 'broker' && !currentUser.brokerCode
            ? { brokerCode: buildBrokerCode(currentUser.id) }
            : {}),
          updatedBy: currentUser.id,
        },
      });

      return toUserResponse(user);
    },
  );

  app.patch(
    '/me/password',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const body = updatePasswordBodySchema.parse(request.body);
      const currentUser = request.authenticatedUser!;
      const user = await prisma.user.findUnique({
        where: { id: currentUser.id },
      });

      if (!user) {
        return sendApiError({
          reply,
          statusCode: 404,
          code: 'PROFILE_NOT_FOUND',
          message: 'Perfil de acesso nao encontrado.',
        });
      }

      const hasValidPassword = await verifyPassword({
        password: body.currentPassword,
        passwordHash: user.passwordHash,
      });

      if (!hasValidPassword) {
        return sendApiError({
          reply,
          statusCode: 400,
          code: 'INVALID_CURRENT_PASSWORD',
          message: 'Senha atual invalida.',
        });
      }

      const updatedUser = await prisma.user.update({
        where: { id: currentUser.id },
        data: {
          passwordHash: await hashPassword(body.newPassword),
          updatedBy: currentUser.id,
        },
      });

      return toUserResponse(updatedUser);
    },
  );

  app.post(
    '/me/avatar',
    { preHandler: requireAuthenticatedUser, bodyLimit: avatarBodyLimit() },
    async (request) => {
      const body = uploadAvatarBodySchema.parse(request.body);
      const currentUser = request.authenticatedUser!;
      const user = await replaceAvatar(currentUser.id, currentUser.id, body);
      try { await cleanupLegacyAvatars(user.id); }
      catch (err) { request.log.error({ err, userId: user.id }, 'Avatar cleanup pending; retry maintenance command'); }
      return toUserResponse(user);
    },
  );

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
  whatsapp?: string | null;
  creci?: string | null;
  about?: string | null;
  avatarUrl?: string | null;
  brokerCode?: string | null;
  role: 'admin' | 'broker';
  isActive: boolean;
  createdAt?: Date;
}) {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    phone: user.phone ?? '',
    whatsapp: user.whatsapp ?? '',
    creci: user.creci ?? '',
    about: user.about ?? '',
    avatarUrl: user.avatarUrl ?? '',
    brokerCode:
      user.brokerCode ?? (user.role === 'broker' ? buildBrokerCode(user.id) : ''),
    role: user.role,
    isActive: user.isActive,
    createdAt: user.createdAt?.toISOString() ?? '',
  };
}
