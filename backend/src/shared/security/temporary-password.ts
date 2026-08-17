import { randomBytes } from 'node:crypto';

const alphabet =
  'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@$%*?';

export function generateTemporaryPassword(length = 14) {
  const bytes = randomBytes(length);
  return Array.from(bytes, (byte) => alphabet[byte % alphabet.length]).join('');
}
