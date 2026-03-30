const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// DB connection pool
const pool = mysql.createPool({
  host: process.env.TIDB_HOST,
  port: process.env.TIDB_PORT || 4000,
  user: process.env.TIDB_USER,
  password: process.env.TIDB_PASSWORD,
  database: process.env.TIDB_DATABASE,
  ssl: { rejectUnauthorized: true },
});

// ── SEED (run once to create table + data) ──────────────────
app.get('/api/seed', async (req, res) => {
  const conn = await pool.getConnection();
  await conn.execute(`
    CREATE TABLE IF NOT EXISTS anime (
      id INT AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      genre VARCHAR(100),
      year INT,
      synopsis TEXT,
      image_url VARCHAR(500),
      rating DECIMAL(3,1) DEFAULT 0.0,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  await conn.execute(`
    CREATE TABLE IF NOT EXISTS comments (
      id INT AUTO_INCREMENT PRIMARY KEY,
      anime_id INT NOT NULL,
      author VARCHAR(100),
      body TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (anime_id) REFERENCES anime(id)
    )
  `);
  // Insert sample data (ignore duplicates)
  const animeData = [
    ['Attack on Titan', 'Action', 2013, 'Humanity fights giant humanoid Titans behind massive walls.', 'https://cdn.myanimelist.net/images/anime/10/47347.jpg', 9.0],
    ['Fullmetal Alchemist: Brotherhood', 'Adventure', 2009, 'Two brothers seek the Philosopher\'s Stone to restore their bodies.', 'https://cdn.myanimelist.net/images/anime/1223/96541.jpg', 9.1],
    ['Demon Slayer', 'Action', 2019, 'A boy becomes a demon slayer to avenge his family and cure his sister.', 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg', 8.7],
    ['Your Name', 'Romance', 2016, 'Two strangers find they are mysteriously swapping bodies.', 'https://cdn.myanimelist.net/images/anime/5/87048.jpg', 8.9],
    ['One Piece', 'Adventure', 1999, 'Monkey D. Luffy sails the seas to find the legendary One Piece treasure.', 'https://cdn.myanimelist.net/images/anime/6/73245.jpg', 8.8],
  ];
  for (const row of animeData) {
    await conn.execute(
      `INSERT IGNORE INTO anime (title, genre, year, synopsis, image_url, rating) VALUES (?,?,?,?,?,?)`,
      row
    );
  }
  conn.release();
  res.json({ message: 'Database seeded successfully!' });
});

// ── 1. GET all anime ─────────────────────────────────────────
app.get('/api/anime', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM anime ORDER BY rating DESC');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── 2. GET single anime by id ────────────────────────────────
app.get('/api/anime/:id', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM anime WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Not found' });
    const [comments] = await pool.execute(
      'SELECT * FROM comments WHERE anime_id = ? ORDER BY created_at DESC',
      [req.params.id]
    );
    res.json({ ...rows[0], comments });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── 3. POST add new anime ────────────────────────────────────
app.post('/api/anime', async (req, res) => {
  try {
    const { title, genre, year, synopsis, image_url, rating } = req.body;
    const [result] = await pool.execute(
      'INSERT INTO anime (title, genre, year, synopsis, image_url, rating) VALUES (?,?,?,?,?,?)',
      [title, genre, year, synopsis, image_url, rating || 0]
    );
    res.status(201).json({ id: result.insertId, message: 'Anime added!' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── 4. PATCH update rating ───────────────────────────────────
app.patch('/api/anime/:id/rating', async (req, res) => {
  try {
    const { rating } = req.body;
    if (rating < 0 || rating > 10) return res.status(400).json({ error: 'Rating must be 0–10' });
    await pool.execute('UPDATE anime SET rating = ? WHERE id = ?', [rating, req.params.id]);
    res.json({ message: 'Rating updated!', rating });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── 5. POST add comment ──────────────────────────────────────
app.post('/api/anime/:id/comments', async (req, res) => {
  try {
    const { author, body } = req.body;
    const [result] = await pool.execute(
      'INSERT INTO comments (anime_id, author, body) VALUES (?,?,?)',
      [req.params.id, author, body]
    );
    res.status(201).json({ id: result.insertId, message: 'Comment added!' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Root health check ────────────────────────────────────────
app.get('/', (req, res) => res.json({ status: 'Anime API is running!' }));

if (require.main === module) {
  app.listen(3000, () => console.log('Server running on port 3000'));
}
module.exports = app;