import type { FastifyReply } from 'fastify';

export function sendApiError({
  reply,
  statusCode,
  code,
  message,
  details = {},
  fieldErrors = {},
  requestId,
}: {
  reply: FastifyReply;
  statusCode: number;
  code: string;
  message: string;
  details?: Record<string, unknown>;
  fieldErrors?: Record<string, string[]>;
  requestId?: string;
}) {
  return reply.code(statusCode).send({
    error: {
      code,
      message,
      details,
      fieldErrors,
      requestId: requestId ?? reply.request?.id,
    },
  });
}
