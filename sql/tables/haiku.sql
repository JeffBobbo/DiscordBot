/*
  Logs of haikus created unawares
 */
CREATE TABLE IF NOT EXISTS `haiku`
(
  `id`      INTEGER  PRIMARY KEY AUTOINCREMENT,
  `line0`   TEXT     NOT NULL,
  `line1`   TEXT     NOT NULL,
  `line2`   TEXT     NOT NULL,
  `author`  BIGINT   REFERENCES users(id),
  `when`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `channel` BIGINT NOT NULL
);
