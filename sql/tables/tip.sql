/*
  A table of tips
 */
CREATE TABLE IF NOT EXISTS `tip`
(
  `id`      INTEGER  PRIMARY KEY AUTOINCREMENT,
  `tip`     TEXT NOT NULL,
  `author`  BIGINT   REFERENCES users(id),
  `when`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
