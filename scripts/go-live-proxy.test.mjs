import assert from 'node:assert/strict';
import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { createServer, request } from 'node:http';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { after, before, test } from 'node:test';
import { createGoLiveServer } from './go-live-proxy.mjs';

let root, backend, proxy, port;
const listen = (server) => new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
const close = (server) => new Promise((resolve) => {
  server.close(resolve);
  server.closeAllConnections();
});

function send(path, { method = 'GET', headers = {}, body } = {}) {
  return new Promise((resolve, reject) => {
    const req = request({ hostname: '127.0.0.1', port, path, method, headers }, (res) => {
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(chunks) }));
    });
    req.on('error', reject);
    req.end(body);
  });
}

before(async () => {
  root = await mkdtemp(join(tmpdir(), 'seletta-proxy-'));
  await writeFile(join(root, 'index.html'), '<html>Seletta</html>');
  await writeFile(join(root, 'main.dart.js'), 'console.log("Seletta");');
  await writeFile(join(root, 'test.wasm'), Buffer.from([0, 97, 115, 109]));
  backend = createServer(async (req, res) => {
    const chunks = [];
    for await (const chunk of req) chunks.push(chunk);
    if (req.method === 'OPTIONS') {
      res.writeHead(204, { 'access-control-allow-origin': req.headers.origin });
      return res.end();
    }
    res.writeHead(req.url.startsWith('/api/v1/missing') ? 404 : 201, { 'content-type': 'application/json' });
    res.end(JSON.stringify({ url: req.url, method: req.method, authorization: req.headers.authorization,
      contentType: req.headers['content-type'], body: Buffer.concat(chunks).toString('base64') }));
  });
  await listen(backend);
  proxy = await createGoLiveServer({ webRoot: root, backendPort: backend.address().port });
  await listen(proxy);
  port = proxy.address().port;
});

after(async () => {
  await close(proxy);
  if (backend.listening) await close(backend);
  await rm(root, { recursive: true, force: true });
});

test('serves the homepage and direct client routes', async () => {
  for (const path of ['/', '/estoque?city=Palmas', '/imovel/123']) {
    const result = await send(path);
    assert.equal(result.status, 200);
    assert.match(result.headers['content-type'], /text\/html/);
    assert.equal(result.body.toString(), '<html>Seletta</html>');
  }
});

test('serves JS, WASM and HEAD with correct headers; missing assets stay 404', async () => {
  assert.match((await send('/main.dart.js')).headers['content-type'], /javascript/);
  assert.equal((await send('/test.wasm')).headers['content-type'], 'application/wasm');
  const head = await send('/', { method: 'HEAD' });
  assert.equal(head.status, 200);
  assert.equal(head.body.length, 0);
  assert.ok(Number(head.headers['content-length']) > 0);
  for (const path of ['/missing.js', '/assets/missing']) {
    assert.equal((await send(path)).status, 404);
  }
});

test('forwards path, query, authorization and binary upload body without rewriting', async () => {
  const body = Buffer.from([0, 255, 1, 2, 3, 13, 10]);
  const result = await send('/api/v1/media/upload?type=image', {
    method: 'POST', body,
    headers: { authorization: 'Bearer test-token', 'content-type': 'application/octet-stream' },
  });
  assert.equal(result.status, 201);
  const echo = JSON.parse(result.body);
  assert.equal(echo.url, '/api/v1/media/upload?type=image');
  assert.equal(echo.method, 'POST');
  assert.equal(echo.authorization, 'Bearer test-token');
  assert.equal(echo.contentType, 'application/octet-stream');
  assert.equal(echo.body, body.toString('base64'));
});

test('preserves API errors and CORS preflight responses', async () => {
  const error = await send('/api/v1/missing');
  assert.equal(error.status, 404);
  assert.equal(error.headers['content-type'], 'application/json');
  const preflight = await send('/api/v1/me', {
    method: 'OPTIONS', headers: { origin: 'https://example.ngrok-free.dev' },
  });
  assert.equal(preflight.status, 204);
  assert.equal(preflight.headers['access-control-allow-origin'], 'https://example.ngrok-free.dev');
});

test('rejects filesystem traversal, hidden files and invalid URLs', async () => {
  for (const path of ['/../backend/.env', '/%2e%2e/backend/.env', '/.env', '/..%5cbackend/.env', '/index.html:secret']) {
    assert.equal((await send(path)).status, 403);
  }
  assert.equal((await send('/%ZZ')).status, 400);
  assert.equal((await send('//example.com/')).status, 400);
  assert.equal((await send('/', { method: 'POST' })).status, 405);
});

test('returns a useful 502 when the backend is offline', async () => {
  await close(backend);
  const result = await send('/api/v1/health');
  assert.equal(result.status, 502);
  assert.match(JSON.parse(result.body).message, /Backend indisponivel/);
});
