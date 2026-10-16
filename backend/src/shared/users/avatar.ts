import { randomUUID } from 'node:crypto';
import { z } from 'zod';
import { prisma } from '../database/prisma.js';
import { buildBrokerCode } from './broker-code.js';
import { buildR2PublicUrl, deleteR2Object, getAllowedImageMimeTypes,
  getMaxImageSizeBytes, getR2Object, listR2Objects, uploadR2Object } from '../storage/r2-client.js';

export class AvatarError extends Error {
  constructor(public code: string, message: string, public statusCode = 400) { super(message); }
}
export const uploadAvatarBodySchema = z.object({
  fileName: z.string().trim().min(1), mimeType: z.string().trim().min(1),
  contentBase64: z.string().trim().min(1),
}).strict();
export const avatarBodyLimit = () => Math.ceil(getMaxImageSizeBytes() / 3) * 4 + 4096;
export const avatarKey = (id: string) => `users/${id}/avatar/current`;

export function validateAvatar(body: z.infer<typeof uploadAvatarBodySchema>) {
  if (!getAllowedImageMimeTypes().includes(body.mimeType)) {
    throw new AvatarError('INVALID_AVATAR_MIME_TYPE', 'Envie uma imagem JPEG, PNG ou WEBP.');
  }
  if (body.contentBase64.length % 4 !== 0 || /[^A-Za-z0-9+/=]/.test(body.contentBase64)) {
    throw new AvatarError('INVALID_AVATAR_CONTENT', 'Imagem invalida.');
  }
  const content = Buffer.from(body.contentBase64, 'base64');
  if (!content.length || content.length > getMaxImageSizeBytes()) {
    throw new AvatarError('INVALID_AVATAR_SIZE', 'Envie uma imagem dentro do tamanho permitido.', 413);
  }
  if (content.toString('base64') !== body.contentBase64) {
    throw new AvatarError('INVALID_AVATAR_CONTENT', 'Imagem invalida.');
  }
  const valid = body.mimeType === 'image/jpeg' ? content.subarray(0, 3).equals(Buffer.from([255, 216, 255]))
    : body.mimeType === 'image/png' ? content.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))
    : body.mimeType === 'image/webp' && content.toString('ascii', 0, 4) === 'RIFF' && content.toString('ascii', 8, 12) === 'WEBP';
  if (!valid) throw new AvatarError('INVALID_AVATAR_CONTENT', 'O arquivo nao corresponde ao formato da imagem.');
  return content;
}

// Never delete outside this user's avatar prefix. Safe to retry after partial failure.
export async function cleanupLegacyAvatars(id: string) {
  const prefix = `users/${id}/avatar/`;
  for (const key of await listR2Objects(prefix)) {
    if (key.startsWith(prefix) && key !== avatarKey(id)) await deleteR2Object(key);
  }
}

// Row locks serialize uploads and migration across API instances, including admin edits.
export async function replaceAvatar(id: string, actorId: string,
  body: z.infer<typeof uploadAvatarBodySchema>, brokerOnly = false) {
  const content = validateAvatar(body);
  const key = avatarKey(id);
  const url = buildR2PublicUrl(key);
  return prisma.$transaction(async (tx) => {
    await tx.$queryRaw`SELECT id FROM users WHERE id = ${id} FOR UPDATE`;
    const user = await tx.user.findUnique({ where: { id } });
    if (!user || (brokerOnly && user.role !== 'broker')) {
      throw new AvatarError('USER_NOT_FOUND', 'Corretor nao encontrado.', 404);
    }
    const previous = user.avatarUrl?.split('?')[0] === url ? await getR2Object(key) : null;
    await uploadR2Object({ storageKey: key, body: content, contentType: body.mimeType, cacheControl: 'no-store' });
    try {
      return await tx.user.update({
        where: { id },
        data: {
          avatarUrl: `${url}?v=${randomUUID()}`,
          ...(user.role === 'broker' && !user.brokerCode ? { brokerCode: buildBrokerCode(id) } : {}),
          updatedBy: actorId,
        },
      });
    } catch (error) {
      // Compensate while still holding the lock; never roll back another upload.
      if (previous) {
        await uploadR2Object({ storageKey: key, body: previous.body, contentType: previous.contentType, cacheControl: 'no-store' });
      } else {
        await deleteR2Object(key);
      }
      throw error;
    }
  }, { timeout: 60000 });
}

// Called by the explicit maintenance command, never on application startup.
export async function migrateAvatar(id: string) {
  const result = await prisma.$transaction(async (tx) => {
    await tx.$queryRaw`SELECT id FROM users WHERE id = ${id} FOR UPDATE`;
    const user = await tx.user.findUnique({ where: { id } });
    if (!user?.avatarUrl) return false;
    const key = avatarKey(id);
    const canonical = buildR2PublicUrl(key);
    if (user.avatarUrl.split('?')[0] === canonical) return true;
    const prefix = buildR2PublicUrl(`users/${id}/avatar/`);
    if (!user.avatarUrl.startsWith(prefix)) throw new Error(`Avatar externo ou fora da pasta: ${id}`);
    const suffix = user.avatarUrl.slice(prefix.length).split('?')[0];
    if (!suffix || suffix.includes('/') || suffix === '.' || suffix === '..') throw new Error(`Chave invalida: ${id}`);
    const file = await getR2Object(`users/${id}/avatar/${suffix}`);
    await uploadR2Object({ storageKey: key, body: file.body, contentType: file.contentType, cacheControl: 'no-store' });
    await tx.user.update({ where: { id }, data: { avatarUrl: `${canonical}?v=${randomUUID()}` } });
    return true;
  }, { timeout: 60000 });
  if (result) await cleanupLegacyAvatars(id);
  return result;
}
