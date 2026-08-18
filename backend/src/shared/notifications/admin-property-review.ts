import { prisma } from '../database/prisma.js';
import { sendAdminPropertyReviewEmail } from '../email/broker-welcome-email.js';

export async function notifyAdminsOfPropertyReview({
  propertyId,
  revisionId,
  type,
}: {
  propertyId: string;
  revisionId?: string;
  type: 'new_submission' | 'resubmission';
}) {
  const property = await prisma.property.findUnique({
    where: { id: propertyId },
    include: { broker: true },
  });
  if (!property) return;

  const admins = await prisma.user.findMany({
    where: { role: 'admin', isActive: true },
    select: { id: true, email: true },
  });
  if (admins.length === 0) return;

  const eventLabel = type === 'new_submission' ? 'enviado' : 'reenviado';
  const title = type === 'new_submission'
    ? 'Novo imovel aguardando aprovacao'
    : 'Edicao de imovel aguardando aprovacao';
  const message = `${property.title} foi ${eventLabel} por ${property.broker?.name ?? 'um corretor'}.`;

  const notifications = await prisma.$transaction(
    admins.map((admin) => prisma.adminNotification.create({
      data: {
        adminId: admin.id,
        propertyId,
        revisionId,
        type,
        title,
        message,
      },
    })),
  );

  await Promise.all(notifications.map(async (notification, index) => {
    try {
      await sendAdminPropertyReviewEmail({
        email: admins[index].email,
        propertyTitle: property.title,
        brokerName: property.broker?.name ?? 'Corretor nao atribuido',
        eventLabel,
        propertyId,
      });
      await prisma.adminNotification.update({
        where: { id: notification.id },
        data: { emailStatus: 'sent', emailError: null },
      });
    } catch (error) {
      await prisma.adminNotification.update({
        where: { id: notification.id },
        data: {
          emailStatus: 'failed',
          emailError: error instanceof Error ? error.message : 'Falha desconhecida no e-mail.',
        },
      });
    }
  }));
}

export async function recordPropertyStatusChange({
  propertyId,
  actorId,
  fromStatus,
  toStatus,
  note,
  source = 'manual',
}: {
  propertyId: string;
  actorId: string;
  fromStatus: string | null;
  toStatus: string;
  note?: string;
  source?: string;
}) {
  await prisma.propertyStatusHistory.create({
    data: {
      propertyId,
      actorId,
      fromStatus: fromStatus as never,
      toStatus: toStatus as never,
      note: note?.trim() || null,
      source,
    },
  });
}
