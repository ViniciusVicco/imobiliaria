import { config } from 'dotenv';
import { z } from 'zod';

config();

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  SHADOW_DATABASE_URL: z.string().min(1),
  PORT: z.coerce.number().int().positive().default(3333),
  CORS_ORIGIN: z.string().default('http://localhost:8080'),
  FIREBASE_PROJECT_ID: z.string().default('seletta-imobiliaria'),
});

export const env = envSchema.parse(process.env);
