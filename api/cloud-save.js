const {
  cleanName,
  ensureSchema,
  playerKeyFromName,
  publicMeta,
  readBody,
  sendJson,
  sql,
} = require('./_db');

module.exports = async function handler(req, res) {
  try {
    if (req.method === 'OPTIONS') return sendJson(res, 204, {});
    await ensureSchema();
    const db = await sql();

    if (req.method === 'GET') {
      const url = new URL(req.url, `https://${req.headers.host || 'localhost'}`);
      const name = cleanName(url.searchParams.get('name'));
      const playerKey = playerKeyFromName(name);
      if (!playerKey) return sendJson(res, 400, { ok: false, error: 'Gamer name required' });
      const rows = await db`
        SELECT gamer_name, best_score, data, updated_at
        FROM crown_dash_profiles
        WHERE player_key = ${playerKey}
        LIMIT 1
      `;
      if (!rows.length) return sendJson(res, 200, { ok: true, found: false });
      return sendJson(res, 200, {
        ok: true,
        found: true,
        gamerName: rows[0].gamer_name,
        bestScore: rows[0].best_score,
        meta: rows[0].data || {},
        updatedAt: rows[0].updated_at,
      });
    }

    if (req.method === 'POST') {
      const body = await readBody(req);
      const name = cleanName(body.gamerName);
      const playerKey = playerKeyFromName(name);
      if (!playerKey) return sendJson(res, 400, { ok: false, error: 'Gamer name required' });
      const bestScore = Math.max(0, Math.min(999999999, Math.floor(Number(body.bestScore) || 0)));
      const meta = publicMeta(body.meta);
      meta.gamerName = name;
      await db`
        INSERT INTO crown_dash_profiles (player_key, gamer_name, best_score, data, updated_at)
        VALUES (${playerKey}, ${name}, ${bestScore}, ${JSON.stringify(meta)}::jsonb, NOW())
        ON CONFLICT (player_key) DO UPDATE SET
          gamer_name = EXCLUDED.gamer_name,
          best_score = GREATEST(crown_dash_profiles.best_score, EXCLUDED.best_score),
          data = EXCLUDED.data,
          updated_at = NOW()
      `;
      return sendJson(res, 200, { ok: true });
    }

    res.setHeader('allow', 'GET, POST');
    return sendJson(res, 405, { ok: false, error: 'Method not allowed' });
  } catch (err) {
    return sendJson(res, err.statusCode || 500, {
      ok: false,
      error: err.message || 'Server error',
    });
  }
};
