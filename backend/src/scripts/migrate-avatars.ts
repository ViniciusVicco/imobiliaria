import { prisma } from '../shared/database/prisma.js';
import { migrateAvatar } from '../shared/users/avatar.js';

// Default is read-only; --apply migrates and retries cleanup of legacy files.
const apply = process.argv.includes('--apply');
try {
  const users = await prisma.user.findMany({ where: { avatarUrl: { not: null } }, select: { id: true } });
  for (const user of users) {
    if (!apply) { console.log(`Would migrate/clean avatar: ${user.id}`); continue; }
    try { console.log(user.id, await migrateAvatar(user.id) ? 'done' : 'skipped'); }
    catch (error) { console.error(user.id, error); process.exitCode = 1; }
  }
} finally { await prisma.$disconnect(); }
