import { connect } from 'node:tls';

import { env } from '../../config/env.js';

type SendBrokerWelcomeEmailParams = {
  name: string;
  email: string;
  temporaryPassword: string;
};

type SmtpClient = {
  send(command: string, expectedCode: number | number[]): Promise<string>;
  close(): void;
};

export class EmailDeliveryError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'EmailDeliveryError';
  }
}

export async function sendBrokerWelcomeEmail({
  name,
  email,
  temporaryPassword,
}: SendBrokerWelcomeEmailParams) {
  await sendSmtpEmail({
    to: email,
    subject: 'Seu acesso ao painel Seletta',
    text: buildBrokerWelcomeText({ name, email, temporaryPassword }),
    html: buildBrokerWelcomeHtml({ name, email, temporaryPassword }),
  });
}

export async function sendAdminPropertyReviewEmail({
  email,
  propertyTitle,
  brokerName,
  eventLabel,
  propertyId,
}: {
  email: string;
  propertyTitle: string;
  brokerName: string;
  eventLabel: string;
  propertyId: string;
}) {
  const text = [
    `Um imovel foi ${eventLabel} e aguarda aprovacao.`,
    '',
    `Imovel: ${propertyTitle}`,
    `Corretor: ${brokerName}`,
    `ID: ${propertyId}`,
  ].join('\n');
  const html = `<p>Um imovel foi <strong>${escapeHtml(eventLabel)}</strong> e aguarda aprovacao.</p><p><strong>Imovel:</strong> ${escapeHtml(propertyTitle)}<br><strong>Corretor:</strong> ${escapeHtml(brokerName)}<br><strong>ID:</strong> ${escapeHtml(propertyId)}</p>`;
  await sendSmtpEmail({
    to: email,
    subject: `Imovel aguardando aprovacao: ${propertyTitle}`,
    text,
    html,
  });
}

async function sendSmtpEmail({
  to,
  subject,
  text,
  html,
}: {
  to: string;
  subject: string;
  text: string;
  html: string;
}) {
  if (!env.GMAIL_SMTP_SECRET) {
    throw new EmailDeliveryError('Configure a chave GMAIL_SMTP_SECRET do Gmail.');
  }

  if (!env.GMAIL_SMTP_USER || env.GMAIL_SMTP_USER === 'admin@seletta.local') {
    throw new EmailDeliveryError('Configure GMAIL_SMTP_USER com seu Gmail.');
  }

  const client = await connectToGmailSmtp();

  try {
    const gmailPassword = env.GMAIL_SMTP_SECRET.replace(/\s/g, '');

    await client.send(`EHLO seletta.local`, 250);
    await client.send('AUTH LOGIN', 334);
    await client.send(Buffer.from(env.GMAIL_SMTP_USER).toString('base64'), 334);
    await client.send(Buffer.from(gmailPassword).toString('base64'), 235);
    await client.send(`MAIL FROM:<${env.GMAIL_SMTP_USER}>`, 250);
    await client.send(`RCPT TO:<${to}>`, [250, 251]);
    await client.send('DATA', 354);
    await client.send(buildEmailMessage({ to, subject, text, html }), 250);
    await client.send('QUIT', 221);
  } finally {
    client.close();
  }
}

async function connectToGmailSmtp(): Promise<SmtpClient> {
  const socket = connect({
    host: 'smtp.gmail.com',
    port: 465,
    servername: 'smtp.gmail.com',
  });

  socket.setEncoding('utf8');

  let buffer = '';
  const waitForResponse = (expectedCode: number | number[]) =>
    new Promise<string>((resolve, reject) => {
      const expectedCodes = Array.isArray(expectedCode)
        ? expectedCode
        : [expectedCode];

      const onData = (chunk: string) => {
        buffer += chunk;
        const lines = buffer.split(/\r?\n/).filter(Boolean);
        const lastLine = lines.at(-1);
        if (!lastLine || !/^\d{3}[ -]/.test(lastLine)) return;

        const code = Number(lastLine.substring(0, 3));
        const isFinalLine = lastLine[3] === ' ';
        if (!isFinalLine) return;

        socket.off('data', onData);
        socket.off('error', onError);
        const response = buffer;
        buffer = '';

        if (expectedCodes.includes(code)) {
          resolve(response);
          return;
        }

        reject(
          new EmailDeliveryError(
            `Gmail SMTP recusou o envio (${code}): ${response.trim()}`,
          ),
        );
      };

      const onError = (error: Error) => {
        socket.off('data', onData);
        socket.off('error', onError);
        reject(
          new EmailDeliveryError(
            `Nao foi possivel conectar ao Gmail SMTP: ${error.message}`,
          ),
        );
      };

      socket.on('data', onData);
      socket.on('error', onError);
    });

  await waitForResponse(220);

  return {
    send(command, expectedCode) {
      socket.write(`${command}\r\n`);
      return waitForResponse(expectedCode);
    },
    close() {
      socket.end();
    },
  };
}

function buildEmailMessage({
  to,
  subject,
  text,
  html,
}: {
  to: string;
  subject: string;
  text: string;
  html: string;
}) {
  const fromName = encodeHeader(env.GMAIL_SMTP_FROM);
  const boundary = `seletta-${Date.now()}`;

  return [
    `From: ${fromName} <${env.GMAIL_SMTP_USER}>`,
    `To: ${to}`,
    `Subject: ${encodeHeader(subject)}`,
    'MIME-Version: 1.0',
    `Content-Type: multipart/alternative; boundary="${boundary}"`,
    '',
    `--${boundary}`,
    'Content-Type: text/plain; charset=UTF-8',
    'Content-Transfer-Encoding: 8bit',
    '',
    text,
    '',
    `--${boundary}`,
    'Content-Type: text/html; charset=UTF-8',
    'Content-Transfer-Encoding: 8bit',
    '',
    html,
    '',
    `--${boundary}--`,
    '.',
  ].join('\r\n');
}

function buildBrokerWelcomeText({
  name,
  email,
  temporaryPassword,
}: SendBrokerWelcomeEmailParams) {
  return [
    `Ola, ${name}.`,
    '',
    'Seu acesso ao painel Seletta foi criado.',
    '',
    `Email: ${email}`,
    `Senha temporaria: ${temporaryPassword}`,
    '',
    'Use esses dados para entrar no sistema. Quando o fluxo de troca de senha estiver disponivel, atualize sua senha no primeiro acesso.',
  ].join('\n');
}

function buildBrokerWelcomeHtml({
  name,
  email,
  temporaryPassword,
}: SendBrokerWelcomeEmailParams) {
  return `
    <p>Ola, ${escapeHtml(name)}.</p>
    <p>Seu acesso ao painel Seletta foi criado.</p>
    <p><strong>Email:</strong> ${escapeHtml(email)}</p>
    <p><strong>Senha temporaria:</strong> ${escapeHtml(temporaryPassword)}</p>
    <p>Use esses dados para entrar no sistema. Quando o fluxo de troca de senha estiver disponivel, atualize sua senha no primeiro acesso.</p>
  `;
}

function escapeHtml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function encodeHeader(value: string) {
  return `=?UTF-8?B?${Buffer.from(value, 'utf8').toString('base64')}?=`;
}
