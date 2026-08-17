const {
  cleanName,
  ensureSchema,
  playerKeyFromName,
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
      const rows = await db`
        SELECT gamer_name, score, coins, story_won, created_at
        FROM crown_dash_scores
        ORDER BY score DESC, created_at ASC
        LIMIT 25
      `;
      return sendJson(res, 200, {
        ok: true,
        scores: rows.map((row, index) => ({
          rank: index + 1,
          name: row.gamer_name,
          score: row.score,
          coins: row.coins,
          storyWon: row.story_won,
          createdAt: row.created_at,
        })),
      });
    }

    if (req.method === 'POST') {
      const body = await readBody(req);
      const name = cleanName(body.gamerName);
      const playerKey = playerKeyFromName(name);
      if (!playerKey) return sendJson(res, 400, { ok: false, error: 'Gamer name required' });
      const score = Math.max(0, Math.min(999999999, Math.floor(Number(body.score) || 0)));
      const coins = Math.max(0, Math.min(999999, Math.floor(Number(body.coins) || 0)));
      const storyWon = Boolean(body.storyWon);
      if (score <= 0) return sendJson(res, 400, { ok: false, error: 'Score required' });

      await db`
        INSERT INTO crown_dash_scores (player_key, gamer_name, score, coins, story_won)
        VALUES (${playerKey}, ${name}, ${score}, ${coins}, ${storyWon})
      `;
      await db`
        INSERT INTO crown_dash_profiles (player_key, gamer_name, best_score, data, updated_at)
        VALUES (${playerKey}, ${name}, ${score}, '{}'::jsonb, NOW())
        ON CONFLICT (player_key) DO UPDATE SET
          gamer_name = EXCLUDED.gamer_name,
          best_score = GREATEST(crown_dash_profiles.best_score, EXCLUDED.best_score),
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
