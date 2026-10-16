import type { UserRole } from '@prisma/client';

export type AuthenticatedUser = {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  whatsapp: string | null;
  creci: string | null;
  about: string | null;
  avatarUrl: string | null;
  brokerCode: string | null;
  role: UserRole;
  isActive: boolean;
  createdAt: Date;
};
