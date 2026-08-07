import { createReadStream } from 'node:fs';
import { stat } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, join, normalize, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const projectRoot = resolve(fileURLToPath(new URL('..', import.meta.url)));
const webRoot = join(projectRoot, 'web');

const contentTypes = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
};

export function createStaticServer() {
  return createServer(async (request, response) => {
    const pathname = decodeURIComponent(new URL(request.url ?? '/', 'http://localhost').pathname);
    const filePath = resolveRequestPath(pathname);

    if (!filePath) {
      response.writeHead(404);
      response.end('Not found');
      return;
    }

    try {
      const fileStat = await stat(filePath);
      if (!fileStat.isFile()) {
        response.writeHead(404);
        response.end('Not found');
        return;
      }

      response.writeHead(200, {
        'Content-Type': contentTypes[extname(filePath)] ?? 'application/octet-stream',
        'Cache-Control': 'no-store',
      });
      createReadStream(filePath).pipe(response);
    } catch {
      response.writeHead(404);
      response.end('Not found');
    }
  });
}

function resolveRequestPath(pathname) {
  const normalized = normalize(pathname).replace(/^(\.\.[/\\])+/, '');
  const basePath = normalized === '/' ? '/index.html' : normalized;
  const root = basePath.startsWith('/src/') ? projectRoot : webRoot;
  const candidate = resolve(join(root, basePath));
  if (!candidate.startsWith(root)) {
    return null;
  }
  return candidate;
}

if (import.meta.url === `file://${process.argv[1]}`) {
  const port = Number(process.env.PORT ?? 4173);
  const host = process.env.HOST ?? '127.0.0.1';
  const server = createStaticServer();
  server.listen(port, host, () => {
    console.log(`《我》Demo running at http://${host}:${port}/`);
  });
}
