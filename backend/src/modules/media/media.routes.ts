import { randomUUID } from 'node:crypto';

import type { FastifyInstance, FastifyReply } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { sendApiError } from '../../shared/http/errors.js';
import {
  buildR2PublicUrl,
  deleteR2Object,
  getAllowedImageMimeTypes,
  getMaxImageSizeBytes,
  getR2Object,
  R2ConfigurationError,
  uploadR2Object,
} from '../../shared/storage/r2-client.js';
import { requireAuthenticatedUser } from '../auth/auth.middleware.js';
import type { AuthenticatedUser } from '../auth/auth.types.js';

const uploadImageSchema = z.object({
  fileName: z.string().trim().min(1),
  mimeType: z.string().trim().min(1),
  contentBase64: z.string().trim().min(1),
});

const tempUploadImageSchema = uploadImageSchema.extend({
  uploadSessionId: z
    .string()
    .trim()
    .min(8)
    .max(80)
    .regex(/^[a-zA-Z0-9_-]+$/),
});

const propertyParamsSchema = z.object({
  propertyId: z.string().trim().min(1),
});

const mediaParamsSchema = z.object({
  mediaId: z.string().trim().min(1),
});

export async function mediaRoutes(app: FastifyInstance) {
  app.post(
    '/media/property-images/temp',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const payload = tempUploadImageSchema.parse(request.body);
      const user = request.authenticatedUser;

      if (!user) return sendUnauthenticated(reply);

      const validationError = validateImagePayload(payload);
      if (validationError) return sendApiError({ reply, ...validationError });

      const body = Buffer.from(payload.contentBase64, 'base64');
      if (body.length > getMaxImageSizeBytes()) {
        return sendApiError({
          reply,
          statusCode: 400,
          code: 'IMAGE_TOO_LARGE',
          message: 'Imagem acima do tamanho maximo permitido.',
        });
      }

      const storageKey = buildTempPropertyMediaStorageKey({
        uploadSessionId: payload.uploadSessionId,
        fileName: payload.fileName,
      });

      let publicUrl: string;
      try {
        publicUrl = buildR2PublicUrl(storageKey);
        await uploadR2Object({
          storageKey,
          body,
          contentType: payload.mimeType,
        });
      } catch (error) {
        if (error instanceof R2ConfigurationError) {
          return sendApiError({
            reply,
            statusCode: 500,
            code: 'R2_NOT_CONFIGURED',
            message: error.message,
          });
        }
        throw error;
      }

      const media = await prisma.propertyMedia.create({
        data: {
          id: randomUUID(),
          propertyId: null,
          url: publicUrl,
          publicUrl,
          storageKey,
          type: 'image',
          status: 'active',
          mimeType: payload.mimeType,
          sizeBytes: body.length,
          sortOrder: await getNextTempSortOrder({
            uploadedBy: user.id,
            uploadSessionId: payload.uploadSessionId,
          }),
          uploadedBy: user.id,
          uploadSessionId: payload.uploadSessionId,
        },
      });

      return mapMedia(media);
    },
  );

  app.post(
    '/media/properties/:propertyId/images',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const params = propertyParamsSchema.parse(request.params);
      const payload = uploadImageSchema.parse(request.body);
      const user = request.authenticatedUser;

      if (!user) return sendUnauthenticated(reply);

      const property = await findAccessibleProperty({
        propertyId: params.propertyId,
        user,
      });
      if (!property) return sendPropertyNotFound(reply);

      const validationError = validateImagePayload(payload);
      if (validationError) return sendApiError({ reply, ...validationError });

      const body = Buffer.from(payload.contentBase64, 'base64');
      if (body.length > getMaxImageSizeBytes()) {
        return sendApiError({
          reply,
          statusCode: 400,
          code: 'IMAGE_TOO_LARGE',
          message: 'Imagem acima do tamanho maximo permitido.',
        });
      }

      const storageKey = buildPropertyMediaStorageKey({
        propertyId: property.id,
        fileName: payload.fileName,
      });

      let publicUrl: string;
      try {
        publicUrl = buildR2PublicUrl(storageKey);
        await uploadR2Object({
          storageKey,
          body,
          contentType: payload.mimeType,
        });
      } catch (error) {
        if (error instanceof R2ConfigurationError) {
          return sendApiError({
            reply,
            statusCode: 500,
            code: 'R2_NOT_CONFIGURED',
            message: error.message,
          });
        }
        throw error;
      }

      const media = await prisma.propertyMedia.create({
        data: {
          id: randomUUID(),
          propertyId: property.id,
          url: publicUrl,
          publicUrl,
          storageKey,
          type: 'image',
          status: 'active',
          mimeType: payload.mimeType,
          sizeBytes: body.length,
          sortOrder: await getNextSortOrder(property.id),
          uploadedBy: user.id,
        },
      });

      if (!property.coverUrl.trim()) {
        await prisma.property.update({
          where: { id: property.id },
          data: { coverUrl: publicUrl },
        });
      }

      return mapMedia(media);
    },
  );

  app.get(
    '/media/:mediaId/file',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const params = mediaParamsSchema.parse(request.params);
      const user = request.authenticatedUser;
      if (!user) return sendUnauthenticated(reply);

      const media = await findAccessibleMedia({
        mediaId: params.mediaId,
        user,
      });

      if (!media) return sendMediaNotFound(reply);
      if (!media.storageKey) {
        return sendApiError({
          reply,
          statusCode: 400,
          code: 'MEDIA_FILE_NOT_AVAILABLE',
          message: 'Arquivo da midia nao esta disponivel.',
        });
      }

      try {
        const file = await getR2Object(media.storageKey);
        return reply
          .header('Content-Type', media.mimeType ?? file.contentType)
          .header('Cache-Control', 'private, max-age=300')
          .send(file.body);
      } catch (error) {
        if (error instanceof R2ConfigurationError) {
          return sendApiError({
            reply,
            statusCode: 500,
            code: 'R2_NOT_CONFIGURED',
            message: error.message,
          });
        }

        return sendApiError({
          reply,
          statusCode: 502,
          code: 'MEDIA_FILE_UNAVAILABLE',
          message: 'Nao foi possivel carregar o arquivo da midia.',
        });
      }
    },
  );

  app.patch(
    '/media/:mediaId/cover',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const params = mediaParamsSchema.parse(request.params);
      const user = request.authenticatedUser;
      if (!user) return sendUnauthenticated(reply);

      const media = await findAccessibleMedia({
        mediaId: params.mediaId,
        user,
      });

      if (!media) return sendMediaNotFound(reply);
      if (!media.propertyId || media.type !== 'image' || media.status !== 'active') {
        return sendApiError({
          reply,
          statusCode: 400,
          code: 'INVALID_COVER_MEDIA',
          message: 'Escolha uma imagem ativa da propriedade.',
        });
      }

      await prisma.property.update({
        where: { id: media.propertyId },
        data: { coverUrl: media.publicUrl ?? media.url },
      });

      return mapMedia(media);
    },
  );

  app.patch(
    '/media/:mediaId/pending-delete',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const params = mediaParamsSchema.parse(request.params);
      const user = request.authenticatedUser;
      if (!user) return sendUnauthenticated(reply);

      const media = await findAccessibleMedia({
        mediaId: params.mediaId,
        user,
      });

      if (!media) return sendMediaNotFound(reply);

      const updatedMedia = await prisma.propertyMedia.update({
        where: { id: media.id },
        data: {
          status: 'pending_delete',
          pendingDeleteAt: new Date(),
        },
      });

      return mapMedia(updatedMedia);
    },
  );

  app.patch(
    '/media/:mediaId/restore',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const params = mediaParamsSchema.parse(request.params);
      const user = request.authenticatedUser;
      if (!user) return sendUnauthenticated(reply);

      const media = await findAccessibleMedia({
        mediaId: params.mediaId,
        user,
      });

      if (!media) return sendMediaNotFound(reply);

      const updatedMedia = await prisma.propertyMedia.update({
        where: { id: media.id },
        data: {
          status: 'active',
          pendingDeleteAt: null,
        },
      });

      return mapMedia(updatedMedia);
    },
  );

  app.post(
    '/media/cleanup/pending-delete',
    { preHandler: requireAuthenticatedUser },
    async (request, reply) => {
      const user = request.authenticatedUser;
      if (!user) return sendUnauthenticated(reply);
      if (user.role !== 'admin') {
        return sendApiError({
          reply,
          statusCode: 403,
          code: 'FORBIDDEN',
          message: 'Seu perfil nao pode acessar esta area.',
        });
      }

      const threshold = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      const mediaItems = await prisma.propertyMedia.findMany({
        where: {
          deletedAt: null,
          OR: [
            {
              status: 'pending_delete',
              pendingDeleteAt: { lte: threshold },
            },
            {
              propertyId: null,
              createdAt: { lte: threshold },
            },
          ],
        },
      });

      const deletedIds: string[] = [];
      for (const media of mediaItems) {
        if (media.storageKey) await deleteR2Object(media.storageKey);
        await prisma.propertyMedia.update({
          where: { id: media.id },
          data: { deletedAt: new Date() },
        });
        deletedIds.push(media.id);
      }

      return {
        deletedIds,
        total: deletedIds.length,
      };
    },
  );
}

async function findAccessibleProperty({
  propertyId,
  user,
}: {
  propertyId: string;
  user: AuthenticatedUser;
}) {
  return prisma.property.findFirst({
    where: {
      id: propertyId,
      ...(user.role === 'broker' ? { brokerId: user.id } : {}),
    },
  });
}

async function findAccessibleMedia({
  mediaId,
  user,
}: {
  mediaId: string;
  user: AuthenticatedUser;
}) {
  return prisma.propertyMedia.findFirst({
    where: {
      id: mediaId,
      deletedAt: null,
      OR: [
        {
          property: {
            ...(user.role === 'broker' ? { brokerId: user.id } : {}),
          },
        },
        {
          propertyId: null,
          uploadedBy: user.id,
        },
      ],
    },
  });
}

async function getNextSortOrder(propertyId: string) {
  const lastMedia = await prisma.propertyMedia.findFirst({
    where: { propertyId },
    orderBy: { sortOrder: 'desc' },
  });

  return (lastMedia?.sortOrder ?? -1) + 1;
}

async function getNextTempSortOrder({
  uploadedBy,
  uploadSessionId,
}: {
  uploadedBy: string;
  uploadSessionId: string;
}) {
  const lastMedia = await prisma.propertyMedia.findFirst({
    where: {
      propertyId: null,
      uploadedBy,
      uploadSessionId,
    },
    orderBy: { sortOrder: 'desc' },
  });

  return (lastMedia?.sortOrder ?? -1) + 1;
}

function validateImagePayload(payload: z.infer<typeof uploadImageSchema>) {
  const allowedMimeTypes = getAllowedImageMimeTypes();
  if (!allowedMimeTypes.includes(payload.mimeType)) {
    return {
      statusCode: 400,
      code: 'INVALID_IMAGE_TYPE',
      message: 'Tipo de imagem nao permitido.',
    };
  }

  return null;
}

export function buildPropertyMediaStorageKey({
  propertyId,
  fileName,
}: {
  propertyId: string;
  fileName: string;
}) {
  const safeFileName = fileName
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return `media/properties/${propertyId}/${randomUUID()}-${safeFileName || 'image'}`;
}

function buildTempPropertyMediaStorageKey({
  uploadSessionId,
  fileName,
}: {
  uploadSessionId: string;
  fileName: string;
}) {
  const safeSessionId = uploadSessionId.replace(/[^a-zA-Z0-9_-]+/g, '-');
  const safeFileName = fileName
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return `media/temp/${safeSessionId}/${randomUUID()}-${safeFileName || 'image'}`;
}

function mapMedia(media: {
  id: string;
  propertyId: string | null;
  url: string;
  publicUrl: string | null;
  storageKey: string | null;
  type: string;
  status: string;
  mimeType: string | null;
  sizeBytes: number | null;
  sortOrder: number;
  pendingDeleteAt: Date | null;
  deletedAt: Date | null;
}) {
  return {
    id: media.id,
    propertyId: media.propertyId ?? '',
    url: media.publicUrl ?? media.url,
    publicUrl: media.publicUrl ?? media.url,
    storageKey: media.storageKey,
    type: media.type,
    status: media.status,
    mimeType: media.mimeType,
    sizeBytes: media.sizeBytes,
    sortOrder: media.sortOrder,
    pendingDeleteAt: media.pendingDeleteAt?.toISOString() ?? null,
    deletedAt: media.deletedAt?.toISOString() ?? null,
  };
}

function sendUnauthenticated(reply: FastifyReply) {
  return sendApiError({
    reply,
    statusCode: 401,
    code: 'UNAUTHENTICATED',
    message: 'Entre para acessar esta area.',
  });
}

function sendPropertyNotFound(reply: FastifyReply) {
  return sendApiError({
    reply,
    statusCode: 404,
    code: 'PROPERTY_NOT_FOUND',
    message: 'Imovel nao encontrado.',
  });
}

function sendMediaNotFound(reply: FastifyReply) {
  return sendApiError({
    reply,
    statusCode: 404,
    code: 'MEDIA_NOT_FOUND',
    message: 'Midia nao encontrada.',
  });
}
