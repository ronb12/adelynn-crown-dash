CREATE TABLE IF NOT EXISTS crown_dash_profiles (
  player_key TEXT PRIMARY KEY,
  gamer_name TEXT NOT NULL,
  best_score INTEGER NOT NULL DEFAULT 0,
  data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS crown_dash_scores (
  id BIGSERIAL PRIMARY KEY,
  player_key TEXT NOT NULL,
  gamer_name TEXT NOT NULL,
  score INTEGER NOT NULL,
  coins INTEGER NOT NULL DEFAULT 0,
  story_won BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS crown_dash_scores_rank_idx
  ON crown_dash_scores (score DESC, created_at ASC);

