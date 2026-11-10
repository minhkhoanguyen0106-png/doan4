const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const WEB_DIR = path.join(__dirname, 'build', 'web');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json',
  '.css': 'text/css',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2'
};

function handleRequest(req, res) {
  console.log(`[HTTP REQ] ${req.method} ${req.url} from ${req.socket.remoteAddress}`);

  // 1. Reverse proxy cho /api/ chuyển thẳng về Spring Boot (port 8080)
  if (req.url.startsWith('/api/') || req.url === '/api') {
    const proxyReq = http.request({
      hostname: '127.0.0.1',
      port: 8080,
      path: req.url,
      method: req.method,
      headers: {
        ...req.headers,
        host: '127.0.0.1:8080'
      }
    }, (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res, { end: true });
    });

    proxyReq.on('error', (err) => {
      console.error('[API Proxy Error]', err.message);
      res.writeHead(502, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: 'Backend unreachable: ' + err.message }));
    });

    req.pipe(proxyReq, { end: true });
    return;
  }

  // 2. Phục vụ tài nguyên tĩnh Web
  let safePath = path.normalize(decodeURIComponent(req.url.split('?')[0])).replace(/^(\.\.[\/\\])+/, '');
  let filePath = path.join(WEB_DIR, safePath);

  if (fs.existsSync(filePath) && fs.statSync(filePath).isDirectory()) {
    filePath = path.join(filePath, 'index.html');
  }

  // Fallback to index.html for SPA client-side routing
  if (!fs.existsSync(filePath)) {
    filePath = path.join(WEB_DIR, 'index.html');
  }

  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  fs.readFile(filePath, (err, content) => {
    if (err) {
      res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('500 Server Error: ' + err.message);
      return;
    }

    res.writeHead(200, {
      'Content-Type': contentType,
      'Access-Control-Allow-Origin': '*',
      'Cache-Control': 'no-cache'
    });
    res.end(content);
  });
}

const server3000 = http.createServer(handleRequest);
server3000.listen(PORT, '0.0.0.0', () => {
  console.log(`PONDORA Web Server running at http://localhost:${PORT}`);
});

// Chạy thêm cổng 80 (cổng HTTP mặc định) để người dùng gõ IP không cần nhập :3000 vẫn vào được
try {
  const server80 = http.createServer(handleRequest);
  server80.listen(80, '0.0.0.0', () => {
    console.log(`PONDORA Web Server also running at http://localhost:80 (Default HTTP)`);
  }).on('error', (err) => {
    console.log(`Port 80 is busy: ${err.message}. Using port ${PORT}.`);
  });
} catch (e) {
  // Bỏ qua nếu không cấp quyền port 80
}

