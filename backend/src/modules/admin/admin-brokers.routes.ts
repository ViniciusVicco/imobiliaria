import { randomUUID } from 'node:crypto';

import { Prisma } from '@prisma/client';
import type { FastifyInstance } from 'fastify';
import { z } from 'zod';

import { requireActiveAdmin } from '../auth/auth.middleware.js';
import { prisma } from '../../shared/database/prisma.js';
import {
  EmailDeliveryError,
  sendBrokerWelcomeEmail,
} from '../../shared/email/broker-welcome-email.js';
import { sendApiError } from '../../shared/http/errors.js';
import { hashPassword } from '../../shared/security/password.js';
import { generateTemporaryPassword } from '../../shared/security/temporary-password.js';
import { buildBrokerCode } from '../../shared/users/broker-code.js';

const duplicateEmailMessage = 'Esse e-mail já se encontra na nossa base de dados';

const createBrokerBodySchema = z
  .object({
    name: z.string().trim().min(2),
    email: z.string().trim().email(),
    emailConfirmation: z.string().trim().email(),
    phone: z.string().trim().optional(),
  })
  .refine(
    (body) => body.email.toLowerCase() === body.emailConfirmation.toLowerCase(),
    {
      path: ['emailConfirmation'],
      message: 'Confirme o mesmo e-mail do corretor.',
    },
  );

export async function adminBrokersRoutes(app: FastifyInstance) {
  app.post(
    '/admin/brokers',
    { preHandler: requireActiveAdmin },
    async (request, reply) => {
      const body = createBrokerBodySchema.parse(request.body);
      const currentUser = request.authenticatedUser!;
      const email = body.email.toLowerCase();

      const existingUser = await prisma.user.findUnique({
        where: { email },
      });

      if (existingUser) {
        return sendApiError({
          reply,
          statusCode: 409,
          code: 'EMAIL_ALREADY_EXISTS',
          message: duplicateEmailMessage,
        });
      }

      const temporaryPassword = generateTemporaryPassword();
      const passwordHash = await hashPassword(temporaryPassword);

      try {
        await sendBrokerWelcomeEmail({
          name: body.name,
          email,
          temporaryPassword,
        });

        const broker = await prisma.user.create({
          data: {
            id: randomUUID(),
            name: body.name,
            email,
            phone: body.phone?.trim() || null,
            role: 'broker',
            passwordHash,
            brokerCode: '',
            createdBy: currentUser.id,
            updatedBy: currentUser.id,
          },
        });

        const brokerWithCode = await prisma.user.update({
          where: { id: broker.id },
          data: { brokerCode: buildBrokerCode(broker.id) },
        });

        return {
          id: brokerWithCode.id,
          name: brokerWithCode.name,
          email: brokerWithCode.email,
          phone: brokerWithCode.phone ?? '',
          role: brokerWithCode.role,
          isActive: brokerWithCode.isActive,
          createdAt: brokerWithCode.createdAt.toISOString(),
          updatedAt: brokerWithCode.updatedAt.toISOString(),
          lastLoginAt: brokerWithCode.lastLoginAt?.toISOString() ?? null,
        };
      } catch (error) {
        if (
          error instanceof Prisma.PrismaClientKnownRequestError &&
          error.code === 'P2002'
        ) {
          return sendApiError({
            reply,
            statusCode: 409,
            code: 'EMAIL_ALREADY_EXISTS',
            message: duplicateEmailMessage,
          });
        }

        if (error instanceof EmailDeliveryError) {
          return sendApiError({
            reply,
            statusCode: 502,
            code: 'BROKER_INVITE_FAILED',
            message: error.message,
          });
        }

        return sendApiError({
          reply,
          statusCode: 502,
          code: 'BROKER_INVITE_FAILED',
          message: 'Nao foi possivel enviar o convite do corretor.',
        });
      }
    },
  );
}
