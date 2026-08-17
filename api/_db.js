let sqlClient;
let schemaReady;
let neonFactory;

function databaseUrl() {
  return process.env.DATABASE_URL || process.env.POSTGRES_URL || process.env.POSTGRES_PRISMA_URL;
}

async function loadNeon() {
  if (!neonFactory) {
    const mod = await import('@neondatabase/serverless');
    neonFactory = mod.neon;
  }
  return neonFactory;
}

async function sql() {
  const url = databaseUrl();
  if (!url) {
    const err = new Error('Neon database is not configured. Add DATABASE_URL to Vercel.');
    err.statusCode = 503;
    throw err;
  }
  if (!sqlClient) {
    const neon = await loadNeon();
    sqlClient = neon(url);
  }
  return sqlClient;
}

async function ensureSchema() {
  if (schemaReady) return schemaReady;
  schemaReady = (async () => {
    const db = await sql();
    await db`
      CREATE TABLE IF NOT EXISTS crown_dash_profiles (
        player_key TEXT PRIMARY KEY,
        gamer_name TEXT NOT NULL,
        best_score INTEGER NOT NULL DEFAULT 0,
        data JSONB NOT NULL DEFAULT '{}'::jsonb,
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `;
    await db`
      CREATE TABLE IF NOT EXISTS crown_dash_scores (
        id BIGSERIAL PRIMARY KEY,
        player_key TEXT NOT NULL,
        gamer_name TEXT NOT NULL,
        score INTEGER NOT NULL,
        coins INTEGER NOT NULL DEFAULT 0,
        story_won BOOLEAN NOT NULL DEFAULT FALSE,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `;
    await db`CREATE INDEX IF NOT EXISTS crown_dash_scores_rank_idx ON crown_dash_scores (score DESC, created_at ASC)`;
  })();
  return schemaReady;
}

function cleanName(value) {
  return String(value || '')
    .replace(/[<>]/g, '')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 14);
}

function playerKeyFromName(name) {
  const cleaned = cleanName(name);
  if (!cleaned) return '';
  return `name:${cleaned.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')}`;
}

function sendJson(res, status, body) {
  res.statusCode = status;
  res.setHeader('content-type', 'application/json; charset=utf-8');
  res.setHeader('cache-control', 'no-store');
  res.setHeader('access-control-allow-origin', '*');
  res.setHeader('access-control-allow-methods', 'GET, POST, OPTIONS');
  res.setHeader('access-control-allow-headers', 'content-type');
  res.end(JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', chunk => {
      raw += chunk;
      if (raw.length > 160_000) {
        reject(Object.assign(new Error('Request body too large'), { statusCode: 413 }));
        req.destroy();
      }
    });
    req.on('end', () => {
      if (!raw) return resolve({});
      try {
        resolve(JSON.parse(raw));
      } catch (err) {
        reject(Object.assign(new Error('Invalid JSON'), { statusCode: 400 }));
      }
    });
    req.on('error', reject);
  });
}

function publicMeta(meta) {
  const src = meta && typeof meta === 'object' ? meta : {};
  const out = { ...src };
  delete out.leaderboard;
  return out;
}

module.exports = {
  cleanName,
  ensureSchema,
  playerKeyFromName,
  publicMeta,
  readBody,
  sendJson,
  sql,
};
