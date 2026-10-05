import { z } from 'zod';

export const profileFields = {
  name: z.string().trim().min(2, 'Informe o nome completo.'),
  phone: z.string().trim().min(1, 'Informe o celular.'),
  whatsapp: z.string().trim().nullable(),
  creci: z.string().trim().nullable(),
  about: z.string().trim().nullable(),
};
export const updateProfileBodySchema = z.object(profileFields).partial().strict();
