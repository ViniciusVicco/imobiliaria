import type { FastifyReply } from 'fastify';

export function sendApiError({
  reply,
  statusCode,
  code,
  message,
}: {
  reply: FastifyReply;
  statusCode: number;
  code: string;
  message: string;
}) {
  return reply.code(statusCode).send({
    error: {
      code,
      message,
    },
  });
}
