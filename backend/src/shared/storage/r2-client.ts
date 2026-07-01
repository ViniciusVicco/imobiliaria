import {
  DeleteObjectCommand,
  GetObjectCommand,
  PutObjectCommand,
  S3Client,
} from '@aws-sdk/client-s3';

import { env } from '../../config/env.js';

export class R2ConfigurationError extends Error {
  constructor(message = 'Configure as credenciais do Cloudflare R2.') {
    super(message);
  }
}

let client: S3Client | null = null;

export function getR2Client() {
  assertR2Configured();

  client ??= new S3Client({
    region: env.R2_REGION,
    endpoint: env.R2_ENDPOINT,
    credentials: {
      accessKeyId: env.R2_ACCESS_KEY_ID,
      secretAccessKey: env.R2_SECRET_ACCESS_KEY,
    },
  });

  return client;
}

export async function uploadR2Object({
  storageKey,
  body,
  contentType,
}: {
  storageKey: string;
  body: Buffer;
  contentType: string;
}) {
  await getR2Client().send(
    new PutObjectCommand({
      Bucket: env.R2_BUCKET_NAME,
      Key: storageKey,
      Body: body,
      ContentType: contentType,
    }),
  );
}

export async function getR2Object(storageKey: string) {
  const response = await getR2Client().send(
    new GetObjectCommand({
      Bucket: env.R2_BUCKET_NAME,
      Key: storageKey,
    }),
  );

  if (!response.Body) {
    throw new R2ConfigurationError('Nao foi possivel ler o arquivo no R2.');
  }

  const bytes = await response.Body.transformToByteArray();
  return {
    body: Buffer.from(bytes),
    contentType: response.ContentType ?? 'application/octet-stream',
  };
}

export async function deleteR2Object(storageKey: string) {
  await getR2Client().send(
    new DeleteObjectCommand({
      Bucket: env.R2_BUCKET_NAME,
      Key: storageKey,
    }),
  );
}

export function buildR2PublicUrl(storageKey: string) {
  assertR2Configured();
  return `${env.R2_PUBLIC_BASE_URL.replace(/\/$/, '')}/${storageKey}`;
}

export function assertR2Configured() {
  const missingKeys = [
    ['R2_ACCOUNT_ID', env.R2_ACCOUNT_ID],
    ['R2_BUCKET_NAME', env.R2_BUCKET_NAME],
    ['R2_ACCESS_KEY_ID', env.R2_ACCESS_KEY_ID],
    ['R2_SECRET_ACCESS_KEY', env.R2_SECRET_ACCESS_KEY],
    ['R2_PUBLIC_BASE_URL', env.R2_PUBLIC_BASE_URL],
    ['R2_ENDPOINT', env.R2_ENDPOINT],
  ]
    .filter(([, value]) => !value)
    .map(([key]) => key);

  if (missingKeys.length > 0) {
    throw new R2ConfigurationError(
      `Configure as variaveis R2: ${missingKeys.join(', ')}.`,
    );
  }
}

export function getAllowedImageMimeTypes() {
  return env.R2_ALLOWED_IMAGE_MIME_TYPES.split(',')
    .map((mimeType) => mimeType.trim())
    .filter(Boolean);
}

export function getMaxImageSizeBytes() {
  return env.R2_MAX_IMAGE_SIZE_MB * 1024 * 1024;
}
