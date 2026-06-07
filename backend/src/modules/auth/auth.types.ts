import type { UserRole } from '@prisma/client';

export type AuthenticatedUser = {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  role: UserRole;
  isActive: boolean;
};
