import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { prisma } from '../../shared/database/prisma.js';
import { sendAdminPropertyReviewEmail } from '../../shared/email/broker-welcome-email.js';
import { requireActiveAdmin } from '../auth/auth.middleware.js';

export async function adminNotificationsRoutes(app: FastifyInstance) {
  app.get('/admin/notifications', { preHandler: requireActiveAdmin }, async (request) => {
    const query = z.object({ unreadOnly: z.coerce.boolean().default(false) }).parse(request.query);
    const adminId = request.authenticatedUser?.id ?? '';
    const [items, unreadCount] = await Promise.all([
      prisma.adminNotification.findMany({
        where: { adminId, ...(query.unreadOnly ? { isRead: false } : {}) },
        orderBy: { createdAt: 'desc' },
        take: 50,
        include: { property: { select: { id: true, title: true, status: true } } },
      }),
      prisma.adminNotification.count({ where: { adminId, isRead: false } }),
    ]);
    return {
      unreadCount,
      items: items.map((item) => ({
        id: item.id,
        propertyId: item.propertyId,
        revisionId: item.revisionId,
        type: item.type,
        title: item.title,
        message: item.message,
        isRead: item.isRead,
        emailStatus: item.emailStatus,
        createdAt: item.createdAt.toISOString(),
        property: item.property,
      })),
    };
  });

  app.patch('/admin/notifications/:id/read', { preHandler: requireActiveAdmin }, async (request) => {
    const { id } = z.object({ id: z.string().min(1) }).parse(request.params);
    const adminId = request.authenticatedUser?.id ?? '';
    return prisma.adminNotification.update({
      where: { id, adminId },
      data: { isRead: true, readAt: new Date() },
    });
  });

  app.post('/admin/notifications/:id/retry-email', { preHandler: requireActiveAdmin }, async (request, reply) => {
    const { id } = z.object({ id: z.string().min(1) }).parse(request.params);
    const adminId = request.authenticatedUser?.id ?? '';
    const notification = await prisma.adminNotification.findFirst({
      where: { id, adminId },
      include: { property: { include: { broker: true } } },
    });
    if (!notification) return reply.code(404).send({ error: { code: 'NOTIFICATION_NOT_FOUND' } });

    try {
      await sendAdminPropertyReviewEmail({
        email: (await prisma.user.findUniqueOrThrow({ where: { id: adminId } })).email,
        propertyTitle: notification.property.title,
        brokerName: notification.property.broker?.name ?? 'Corretor nao atribuido',
        eventLabel: notification.type === 'new_submission' ? 'enviado' : 'reenviado',
        propertyId: notification.propertyId,
      });
      return prisma.adminNotification.update({
        where: { id },
        data: { emailStatus: 'sent', emailError: null },
      });
    } catch (error) {
      const updated = await prisma.adminNotification.update({
        where: { id },
        data: { emailStatus: 'failed', emailError: error instanceof Error ? error.message : 'Falha no e-mail.' },
      });
      return reply.code(502).send(updated);
    }
  });
}
