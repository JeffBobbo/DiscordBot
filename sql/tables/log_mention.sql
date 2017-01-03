/*
  The log_mention table stores when people were mentioned
  This'll allow us to build fancy scene graphs of being mentioning people
 */
CREATE TABLE IF NOT EXISTS `log_mention`
(
  `id`      BIGINT REFERENCES users(id),
  `by`      BIGINT REFERENCES users(id),
  `channel` CHAR(32) NOT NULL,
  `when`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `direct`  BOOLEAN NOT NULL /* A 'direct' mention is @user, indirect is @role */
);
