const express = require('express');
const router = express.Router();
const pool = require('../db');

// GET all anime
router.get('/', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM anime ORDER BY rating DESC');
    res.status(200).json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET anime by id
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await pool.execute('SELECT * FROM anime WHERE id = ?', [req.params.id]);
    if (rows.length === 0) return res.status(404).json({ error: 'Anime not found' });
    const [comments] = await pool.execute(
      'SELECT * FROM comments WHERE anime_id = ? ORDER BY created_at DESC',
      [req.params.id]
    );
    res.status(200).json({ ...rows[0], comments });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST create new anime
router.post('/', async (req, res) => {
  try {
    const { title, genre, year, synopsis, image_url, rating } = req.body;
    const [result] = await pool.execute(
      'INSERT INTO anime (title, genre, year, synopsis, image_url, rating) VALUES (?,?,?,?,?,?)',
      [title, genre, year, synopsis, image_url, rating || 0]
    );
    res.status(201).json({ id: result.insertId, message: 'Anime created' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PATCH update rating
router.patch('/:id/rating', async (req, res) => {
  try {
    const { rating } = req.body;
    if (rating < 0 || rating > 10) return res.status(400).json({ error: 'Rating must be 0-10' });
    const [check] = await pool.execute('SELECT id FROM anime WHERE id = ?', [req.params.id]);
    if (check.length === 0) return res.status(404).json({ error: 'Anime not found' });
    await pool.execute('UPDATE anime SET rating = ? WHERE id = ?', [rating, req.params.id]);
    res.status(200).json({ message: 'Rating updated', rating });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST add comment
router.post('/:id/comments', async (req, res) => {
  try {
    const { author, body } = req.body;
    const [result] = await pool.execute(
      'INSERT INTO comments (anime_id, author, body) VALUES (?,?,?)',
      [req.params.id, author || 'Anonymous', body]
    );
    res.status(201).json({ id: result.insertId, message: 'Comment added' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login proxy
router.post('/login', async (req, res) => {
  try {
    const response = await fetch('https://www.melivecode.com/api/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(req.body),
    });
    const data = await response.json();
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;