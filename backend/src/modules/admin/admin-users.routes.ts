import { profileFields } from '../../shared/users/profile-schema.js';
import { avatarBodyLimit, uploadAvatarBodySchema, replaceAvatar, cleanupLegacyAvatars } from '../../shared/users/avatar.js';
import type { Prisma, UserRole } from '@prisma/client';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { requireActiveAdmin } from '../auth/auth.middleware.js';
import { prisma } from '../../shared/database/prisma.js';
import { sendApiError } from '../../shared/http/errors.js';
import { hashPassword } from '../../shared/security/password.js';

const userRoleSchema = z.enum(['admin', 'broker']);

const listUsersQuerySchema = z.object({
  query: z.string().trim().optional(),
  role: userRoleSchema.optional(),
  isActive: z.coerce.boolean().optional(),
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
});

const createUserBodySchema = z.object({
  name: z.string().trim().min(2),
  email: z.string().trim().email(),
  phone: z.string().trim().optional(),
  role: userRoleSchema,
  password: z.string().min(8),
});

const updateUserBodySchema = z.object({
  name: profileFields.name.optional(),
  phone: profileFields.phone.optional(),
  whatsapp: profileFields.whatsapp.optional(),
  creci: profileFields.creci.optional(),
  about: profileFields.about.optional(),
  role: userRoleSchema.optional(),
  isActive: z.boolean().optional(),
});

const updatePasswordBodySchema = z.object({
  password: z.string().min(8),
});

const paramsSchema = z.object({
  id: z.string().uuid(),
});

export async function adminUsersRoutes(app: FastifyInstance) {
  app.get('/admin/property-responsibles', { preHandler: requireActiveAdmin }, async () => {
    const users = await prisma.user.findMany({
      where: { isActive: true, role: { in: ['broker', 'admin'] } },
      orderBy: [{ name: 'asc' }, { id: 'asc' }],
    });
    return { items: users.map(toAdminUserResponse) };
  });

  app.get('/admin/users', { preHandler: requireActiveAdmin }, async (request) => {
    const query = listUsersQuerySchema.parse(request.query);
    const where = buildUserWhere(query);
    const skip = (query.page - 1) * query.pageSize;

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take: query.pageSize,
      }),
      prisma.user.count({ where }),
    ]);

    return {
      items: users.map(toAdminUserResponse),
      pagination: {
        page: query.page,
        pageSize: query.pageSize,
        total,
        totalPages: Math.ceil(total / query.pageSize),
      },
    };
  });

  app.post('/admin/users', { preHandler: requireActiveAdmin }, async (request) => {
    const body = createUserBodySchema.parse(request.body);
    const currentUser = request.authenticatedUser!;

    const user = await prisma.user.create({
      data: {
        name: body.name,
        email: body.email.toLowerCase(),
        phone: body.phone?.trim() || null,
        role: body.role,
        passwordHash: await hashPassword(body.password),
        createdBy: currentUser.id,
        updatedBy: currentUser.id,
      },
    });

    return toAdminUserResponse(user);
  });

  app.get(
    '/admin/users/:id',
    { preHandler: requireActiveAdmin },
    async (request) => {
      const params = paramsSchema.parse(request.params);
      const user = await prisma.user.findUnique({ where: { id: params.id } });

      if (!user) {
        return null;
      }

      return toAdminUserResponse(user);
    },
  );

  app.patch(
    '/admin/users/:id',
    { preHandler: requireActiveAdmin },
    async (request, reply) => {
      const params = paramsSchema.parse(request.params);
      const body = updateUserBodySchema.parse(request.body);
      const currentUser = request.authenticatedUser!;

      const existingUser = await prisma.user.findUnique({
        where: { id: params.id },
      });

      if (!existingUser) {
        return sendApiError({
          reply,
          statusCode: 404,
          code: 'USER_NOT_FOUND',
          message: 'Usuario nao encontrado.',
        });
      }

      const guardResult = await validateAdminMutation({
        currentUserId: currentUser.id,
        targetUserId: existingUser.id,
        nextRole: body.role,
        nextIsActive: body.isActive,
      });
      if (guardResult) return sendApiError({ reply, ...guardResult });

      const data = {
          ...(body.name ? { name: body.name } : {}),
          ...(body.phone !== undefined ? { phone: body.phone?.trim() || null } : {}),
          ...(body.whatsapp !== undefined ? { whatsapp: body.whatsapp || null } : {}),
          ...(body.creci !== undefined ? { creci: body.creci || null } : {}),
          ...(body.about !== undefined ? { about: body.about || null } : {}),
          ...(body.role ? { role: body.role } : {}),
          ...(body.isActive !== undefined ? { isActive: body.isActive } : {}),
          updatedBy: currentUser.id,

      };
      const user = body.isActive === false
        ? await prisma.$transaction(async (tx) => {
            const updated = await tx.user.update({ where: { id: params.id }, data });
            const properties = await tx.property.findMany({
              where: { brokerId: params.id, status: 'published' }, select: { id: true },
            });
            await tx.property.updateMany({
              where: { brokerId: params.id, status: 'published' }, data: { status: 'pending_review' },
            });
            if (properties.length) await tx.propertyStatusHistory.createMany({
              data: properties.map(({ id }) => ({ propertyId: id, actorId: currentUser.id,
                fromStatus: 'published' as const, toStatus: 'pending_review' as const, source: 'responsible_deactivated' })),
            });
            return updated;
          })
        : await prisma.user.update({ where: { id: params.id }, data });

      return toAdminUserResponse(user);
    },
  );

  app.post('/admin/users/:id/avatar',
    { preHandler: requireActiveAdmin, bodyLimit: avatarBodyLimit() }, async (request) => {
      const { id } = paramsSchema.parse(request.params);
      const user = await replaceAvatar(id, request.authenticatedUser!.id,
        uploadAvatarBodySchema.parse(request.body), true);
      try { await cleanupLegacyAvatars(id); }
      catch (err) { request.log.error({ err, userId: id }, 'Avatar cleanup pending; retry maintenance command'); }
      return toAdminUserResponse(user);
    });

  app.patch(
    '/admin/users/:id/password',
    { preHandler: requireActiveAdmin },
    async (request, reply) => {
      const params = paramsSchema.parse(request.params);
      const body = updatePasswordBodySchema.parse(request.body);
      const currentUser = request.authenticatedUser!;

      const existingUser = await prisma.user.findUnique({
        where: { id: params.id },
      });

      if (!existingUser) {
        return sendApiError({
          reply,
          statusCode: 404,
          code: 'USER_NOT_FOUND',
          message: 'Usuario nao encontrado.',
        });
      }

      const user = await prisma.user.update({
        where: { id: params.id },
        data: {
          passwordHash: await hashPassword(body.password),
          updatedBy: currentUser.id,
        },
      });

      return toAdminUserResponse(user);
    },
  );
}

function buildUserWhere(
  query: z.infer<typeof listUsersQuerySchema>,
): Prisma.UserWhereInput {
  return {
    ...(query.role ? { role: query.role } : {}),
    ...(query.isActive !== undefined ? { isActive: query.isActive } : {}),
    ...(query.query
      ? {
          OR: [
            {
              name: {
                contains: query.query,
                mode: 'insensitive',
              },
            },
            {
              email: {
                contains: query.query,
                mode: 'insensitive',
              },
            },
          ],
        }
      : {}),
  };
}

async function validateAdminMutation({
  currentUserId,
  targetUserId,
  nextRole,
  nextIsActive,
}: {
  currentUserId: string;
  targetUserId: string;
  nextRole?: UserRole;
  nextIsActive?: boolean;
}) {
  if (currentUserId === targetUserId && nextIsActive === false) {
    return {
      statusCode: 400,
      code: 'CANNOT_DEACTIVATE_SELF',
      message: 'Voce nao pode desativar a propria conta.',
    };
  }

  const isRemovingAdminAccess = nextRole === 'broker' || nextIsActive === false;
  if (!isRemovingAdminAccess) return null;

  const activeAdmins = await prisma.user.count({
    where: {
      role: 'admin',
      isActive: true,
      id: { not: targetUserId },
    },
  });

  if (activeAdmins === 0) {
    return {
      statusCode: 400,
      code: 'LAST_ACTIVE_ADMIN',
      message: 'Mantenha pelo menos um admin ativo.',
    };
  }

  return null;
}

function toAdminUserResponse(user: {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  whatsapp?: string | null;
  creci?: string | null;
  about?: string | null;
  avatarUrl?: string | null;
  brokerCode?: string | null;
  role: UserRole;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  lastLoginAt: Date | null;
}) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    phone: user.phone ?? '',
    whatsapp: user.whatsapp ?? '',
    creci: user.creci ?? '',
    about: user.about ?? '',
    avatarUrl: user.avatarUrl ?? '',
    brokerCode: user.brokerCode ?? '',
    role: user.role,
    isActive: user.isActive,
    createdAt: user.createdAt.toISOString(),
    updatedAt: user.updatedAt.toISOString(),
    lastLoginAt: user.lastLoginAt?.toISOString() ?? null,
  };
}
