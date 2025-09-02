CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  baseline_nutrition INTEGER,
  baseline_fall INTEGER,
  lighting INTEGER,
  noise_pollution INTEGER
);

INSERT INTO users (id, baseline_nutrition, baseline_fall, lighting, noise_pollution) VALUES
('user1', 5, 2, 7, 3),
('user2', 6, 1, 8, 4);