/*
  The log_command table keeps track of when commands are issued and by who
  Invalid commands are not logged
 */
CREATE TABLE IF NOT EXISTS `log_command`
(
  `id`      INTEGER  PRIMARY KEY AUTOINCREMENT,
  `command` TEXT     NOT NULL,
  `argv`    TEXT     NOT NULL,
  `author`  BIGINT   REFERENCES users(id),
  `when`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `channel` BIGINT NOT NULL
);
