const express = require('express');
const cors = require('cors');
require('dotenv').config();

const animeRoutes = require('./routes/anime');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Anime API running' });
});

app.use('/anime', animeRoutes);

if (process.env.NODE_ENV !== 'production') {
  const PORT = process.env.PORT || 3333;
  app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
}

module.exports = app;