/*
  Logs of people who said "that's what she said"
 */
CREATE TABLE IF NOT EXISTS `saidit`
(
  `id`      INTEGER  PRIMARY KEY AUTOINCREMENT,
  `message` TEXT     NOT NULL,
  `author`  BIGINT   REFERENCES users(id),
  `when`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `channel` BIGINT NOT NULL
);
