USE test;

INSERT INTO anime (title, genre, year, synopsis, image_url, rating) VALUES
('Attack on Titan', 'Action', 2013, 'Humanity fights giant humanoid Titans behind massive walls.', 'https://cdn.myanimelist.net/images/anime/10/47347.jpg', 9.0),
('Fullmetal Alchemist: Brotherhood', 'Adventure', 2009, 'Two brothers seek the Philosopher Stone to restore their bodies.', 'https://cdn.myanimelist.net/images/anime/1223/96541.jpg', 9.1),
('Demon Slayer', 'Action', 2019, 'A boy becomes a demon slayer to avenge his family and cure his sister.', 'https://cdn.myanimelist.net/images/anime/1286/99889.jpg', 8.7),
('Your Name', 'Romance', 2016, 'Two strangers find they are mysteriously swapping bodies.', 'https://cdn.myanimelist.net/images/anime/5/87048.jpg', 8.9),
('One Piece', 'Adventure', 1999, 'Monkey D. Luffy sails the seas to find the legendary One Piece treasure.', 'https://cdn.myanimelist.net/images/anime/6/73245.jpg', 8.8);
```

---

**Update your `.env`** to match teacher's style:
```
DB_HOST=gateway01.ap-southeast-1.prod.aws.tidbcloud.com
DB_PORT=4000
DB_USERNAME=3Tg8kihGzGK4xPY.root
DB_PASSWORD=WI44o1IaiXPxfY1D
DB_DATABASE=test
DB_SSL=true