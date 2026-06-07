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
});

export const env = envSchema.parse(process.env);
