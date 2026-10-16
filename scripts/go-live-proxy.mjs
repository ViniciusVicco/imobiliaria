import { createReadStream } from 'node:fs';
import { realpath, stat } from 'node:fs/promises';
import { createServer, request } from 'node:http';
import { dirname, extname, isAbsolute, relative, resolve, sep } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const defaultWebRoot = resolve(dirname(fileURLToPath(import.meta.url)), '../build/web');
const contentTypes = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.gif': 'image/gif',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

function inside(root, target) {
  const path = relative(root, target);
  return !isAbsolute(path) && path !== '..' && !path.startsWith(`..${sep}`);
}

function endError(response, status, message) {
  if (response.destroyed) return;
  if (response.headersSent) {
    response.destroy();
    return;
  }
  response.writeHead(status, { 'content-type': 'application/json; charset=utf-8' });
  response.end(JSON.stringify({ message }));
}

function forwardingHeaders(headers) {
  const copy = { ...headers };
  const hopHeaders = ['connection', 'keep-alive', 'proxy-authenticate',
    'proxy-authorization', 'te', 'trailer', 'transfer-encoding', 'upgrade'];
  for (const name of String(headers.connection ?? '').split(',')) {
    delete copy[name.trim().toLowerCase()];
  }
  for (const name of hopHeaders) delete copy[name];
  return copy;
}

function proxyApi(incoming, outgoing, backendPort) {
  const upstream = request({
    hostname: '127.0.0.1',
    port: backendPort,
    path: incoming.url,
    method: incoming.method,
    headers: { ...forwardingHeaders(incoming.headers), host: `127.0.0.1:${backendPort}` },
  }, (response) => {
    outgoing.writeHead(response.statusCode ?? 502, forwardingHeaders(response.headers));
    response.on('error', () => outgoing.destroy());
    response.pipe(outgoing);
  });
  upstream.setTimeout(60_000, () => {
    endError(outgoing, 504, 'O backend demorou para responder.');
    upstream.destroy();
  });
  upstream.on('error', () => endError(outgoing, 502, 'Backend indisponivel na porta ' + backendPort));
  incoming.on('error', () => upstream.destroy());
  incoming.on('aborted', () => upstream.destroy());
  outgoing.on('close', () => upstream.destroy());
  incoming.pipe(upstream);
}

export async function createGoLiveServer({ webRoot = defaultWebRoot, backendPort = 3333 } = {}) {
  const root = await realpath(webRoot);
  const indexPath = await realpath(resolve(root, 'index.html'));
  if (!inside(root, indexPath)) throw new Error('index.html fora de build/web.');

  return createServer(async (incoming, outgoing) => {
    try {
      if (!incoming.url?.startsWith('/') || incoming.url.startsWith('//')) {
        return endError(outgoing, 400, 'URL invalida.');
      }
      const rawPath = incoming.url.split('?')[0];
      if (rawPath === '/api/v1' || rawPath.startsWith('/api/v1/')) {
        proxyApi(incoming, outgoing, backendPort);
        return;
      }
      if (incoming.method !== 'GET' && incoming.method !== 'HEAD') {
        outgoing.setHeader('allow', 'GET, HEAD');
        return endError(outgoing, 405, 'Metodo nao permitido.');
      }
      let pathname;
      try {
        pathname = decodeURIComponent(rawPath);
      } catch {
        return endError(outgoing, 400, 'URL invalida.');
      }
      // Reject traversal, hidden files and Windows path/stream syntax.
      if (pathname.includes('\\') || pathname.includes(':') || pathname.includes('\0') ||
          pathname.split('/').some((part) => part.startsWith('.'))) {
        return endError(outgoing, 403, 'Caminho nao permitido.');
      }
      let filePath = resolve(root, '.' + pathname);
      if (!inside(root, filePath)) return endError(outgoing, 403, 'Caminho nao permitido.');
      try {
        filePath = await realpath(filePath);
        if (!inside(root, filePath)) return endError(outgoing, 403, 'Caminho nao permitido.');
        if (!(await stat(filePath)).isFile()) filePath = indexPath;
      } catch (error) {
        if (error.code !== 'ENOENT' && error.code !== 'ENOTDIR') throw error;
        // Client-side routes such as /estoque need index.html. Missing assets
        // must remain 404, otherwise browsers try to execute HTML as JavaScript.
        if (extname(pathname) || /^\/(assets|canvaskit|icons)(\/|$)/.test(pathname)) {
          return endError(outgoing, 404, 'Arquivo nao encontrado.');
        }
        filePath = indexPath;
      }
      const info = await stat(filePath);
      outgoing.writeHead(200, {
        'content-type': contentTypes[extname(filePath).toLowerCase()] ?? 'application/octet-stream',
        'content-length': info.size,
        'cache-control': 'no-store',
        'x-content-type-options': 'nosniff',
      });
      if (incoming.method === 'HEAD') return outgoing.end();
      const stream = createReadStream(filePath);
      stream.on('error', () => outgoing.destroy());
      outgoing.on('close', () => stream.destroy());
      stream.pipe(outgoing);
    } catch {
      endError(outgoing, 500, 'Nao foi possivel servir o site.');
    }
  });
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  try {
    const server = await createGoLiveServer();
    server.on('error', (error) => {
      console.error(`Proxy: ${error.message}`);
      process.exitCode = 1;
    });
    server.listen(8090, '127.0.0.1', () => {
      console.log('SELETTA_PROXY_READY http://127.0.0.1:8090');
    });
    for (const signal of ['SIGINT', 'SIGTERM']) {
      process.on(signal, () => {
        server.close();
        server.closeAllConnections();
      });
    }
  } catch (error) {
    console.error(`Proxy: execute primeiro o build Flutter (build/web/index.html). ${error.message}`);
    process.exitCode = 1;
  }
}
