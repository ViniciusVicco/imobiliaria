import { createHmac, timingSafeEqual } from 'node:crypto';

import { env } from '../../config/env.js';

type JwtPayload = {
  sub: string;
  iat: number;
  exp: number;
};

const algorithm = 'HS256';

export function signAccessToken(userId: string) {
  const issuedAt = Math.floor(Date.now() / 1000);
  const payload: JwtPayload = {
    sub: userId,
    iat: issuedAt,
    exp: issuedAt + env.JWT_EXPIRES_IN_SECONDS,
  };

  const encodedHeader = encodeBase64Url(
    JSON.stringify({ alg: algorithm, typ: 'JWT' }),
  );
  const encodedPayload = encodeBase64Url(JSON.stringify(payload));
  const signature = sign(`${encodedHeader}.${encodedPayload}`);

  return `${encodedHeader}.${encodedPayload}.${signature}`;
}

export function verifyAccessToken(token: string) {
  const [encodedHeader, encodedPayload, receivedSignature] = token.split('.');
  if (!encodedHeader || !encodedPayload || !receivedSignature) return null;

  const expectedSignature = sign(`${encodedHeader}.${encodedPayload}`);
  if (!safeEqual(receivedSignature, expectedSignature)) return null;

  const header = parseJson<Record<string, string>>(encodedHeader);
  if (header?.alg !== algorithm || header.typ !== 'JWT') return null;

  const payload = parseJson<JwtPayload>(encodedPayload);
  if (!payload?.sub || !payload.exp) return null;

  const now = Math.floor(Date.now() / 1000);
  if (payload.exp <= now) return null;

  return payload;
}

function sign(value: string) {
  return createHmac('sha256', env.JWT_SECRET).update(value).digest('base64url');
}

function encodeBase64Url(value: string) {
  return Buffer.from(value, 'utf8').toString('base64url');
}

function parseJson<T>(encodedValue: string) {
  try {
    return JSON.parse(Buffer.from(encodedValue, 'base64url').toString('utf8')) as T;
  } catch (_) {
    return null;
  }
}

function safeEqual(left: string, right: string) {
  const leftBuffer = Buffer.from(left);
  const rightBuffer = Buffer.from(right);
  if (leftBuffer.length !== rightBuffer.length) return false;
  return timingSafeEqual(leftBuffer, rightBuffer);
}
