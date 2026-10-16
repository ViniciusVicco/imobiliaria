import { config } from 'dotenv';
import { z } from 'zod';

config();

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  SHADOW_DATABASE_URL: z.string().min(1),
  PORT: z.coerce.number().int().positive().default(3333),
  CORS_ORIGIN: z.string().default('http://localhost:8080'),
  JWT_SECRET: z
    .string()
    .min(32)
    .default('seletta-local-development-jwt-secret-change-me'),
  JWT_EXPIRES_IN_SECONDS: z.coerce.number().int().positive().default(60 * 60 * 8),
  FIRST_ADMIN_EMAIL: z.string().email().default('admin@seletta.local'),
  FIRST_ADMIN_PASSWORD: z.string().min(8).default('AdminLocal123!'),
  FIRST_ADMIN_NAME: z.string().min(1).default('Admin Local'),
  GMAIL_SMTP_SECRET: z.string().default(''),
  GMAIL_SMTP_USER: z.string().email().default('admin@seletta.local'),
  GMAIL_SMTP_FROM: z.string().default('Seletta'),
  R2_ACCOUNT_ID: z.string().default(''),
  R2_BUCKET_NAME: z.string().default(''),
  R2_ACCESS_KEY_ID: z.string().default(''),
  R2_SECRET_ACCESS_KEY: z.string().default(''),
  R2_PUBLIC_BASE_URL: z.string().default(''),
  R2_ENDPOINT: z.string().default(''),
  R2_REGION: z.string().default('auto'),
  R2_MAX_IMAGE_SIZE_MB: z.coerce.number().int().positive().default(10),
  R2_ALLOWED_IMAGE_MIME_TYPES: z
    .string()
    .default('image/jpeg,image/png,image/webp'),
});

export const env = envSchema.parse(process.env);
