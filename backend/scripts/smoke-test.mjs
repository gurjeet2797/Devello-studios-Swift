import http from 'node:http';

const baseUrl = process.env.BASE_URL ?? 'http://localhost:3000';

function request(path, method = 'GET', body) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, baseUrl);
    const payload = body ? JSON.stringify(body) : null;
    const req = http.request(
      url,
      {
        method,
        headers: payload
          ? {
              'Content-Type': 'application/json',
              'Content-Length': Buffer.byteLength(payload),
            }
          : undefined,
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => resolve({ status: res.statusCode, data }));
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function run() {
  const root = await request('/');
  if (root.status !== 200) {
    throw new Error(`Root check failed: ${root.status}`);
  }

  const lighting = await request('/api/ios/lighting', 'POST', {});
  if (lighting.status !== 400) {
    throw new Error(`Lighting validation check failed: ${lighting.status}`);
  }

  const edit = await request('/api/ios/edit', 'POST', {});
  if (edit.status !== 400) {
    throw new Error(`Edit validation check failed: ${edit.status}`);
  }

  const ideaSpark = await request('/api/ideas/spark', 'POST', {});
  if (ideaSpark.status !== 400) {
    throw new Error(`Idea spark validation check failed: ${ideaSpark.status}`);
  }

  console.log('Smoke test passed.');
}

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
