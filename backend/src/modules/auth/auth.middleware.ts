import type { FastifyReply, FastifyRequest } from 'fastify';

import { prisma } from '../../shared/database/prisma.js';
import { sendApiError } from '../../shared/http/errors.js';
import { verifyAccessToken } from '../../shared/security/jwt.js';
import type { AuthenticatedUser } from './auth.types.js';

declare module 'fastify' {
  interface FastifyRequest {
    authenticatedUser?: AuthenticatedUser;
  }
}

export async function requireAuthenticatedUser(
  request: FastifyRequest,
  reply: FastifyReply,
) {
  const token = getBearerToken(request);
  if (!token) {
    return sendApiError({
      reply,
      statusCode: 401,
      code: 'UNAUTHENTICATED',
      message: 'Entre para acessar esta area.',
    });
  }

  const payload = verifyAccessToken(token);
  if (!payload) {
    return sendApiError({
      reply,
      statusCode: 401,
      code: 'INVALID_TOKEN',
      message: 'Sua sessao expirou. Entre novamente.',
    });
  }

  const user = await prisma.user.findUnique({
    where: { id: payload.sub },
  });

  if (!user) {
    return sendApiError({
      reply,
      statusCode: 404,
      code: 'PROFILE_NOT_FOUND',
      message: 'Perfil de acesso nao encontrado.',
    });
  }

  if (!user.isActive) {
    return sendApiError({
      reply,
      statusCode: 403,
      code: 'INACTIVE_USER',
      message: 'Este usuario esta inativo.',
    });
  }

  request.authenticatedUser = {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    whatsapp: user.whatsapp,
    creci: user.creci,
    about: user.about,
    avatarUrl: user.avatarUrl,
    brokerCode: user.brokerCode,
    role: user.role,
    isActive: user.isActive,
    createdAt: user.createdAt,
  };
}

export async function requireActiveAdmin(
  request: FastifyRequest,
  reply: FastifyReply,
) {
  await requireAuthenticatedUser(request, reply);
  if (reply.sent) return;

  if (request.authenticatedUser?.role !== 'admin') {
    return sendApiError({
      reply,
      statusCode: 403,
      code: 'FORBIDDEN',
      message: 'Seu perfil nao pode acessar esta area.',
    });
  }
}

export async function requireActiveBroker(
  request: FastifyRequest,
  reply: FastifyReply,
) {
  await requireAuthenticatedUser(request, reply);
  if (reply.sent) return;

  const role = request.authenticatedUser?.role;
  if (role !== 'broker' && role !== 'admin') {
    return sendApiError({
      reply,
      statusCode: 403,
      code: 'FORBIDDEN',
      message: 'Seu perfil nao pode acessar esta area.',
    });
  }
}

function getBearerToken(request: FastifyRequest) {
  const authorization = request.headers.authorization;
  const [scheme, token] = authorization?.split(' ') ?? [];
  if (scheme !== 'Bearer' || !token) return null;
  return token;
}
