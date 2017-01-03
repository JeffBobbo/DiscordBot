/*
  The users table lets us keep track of users
  that have left the server via their username
 */
CREATE TABLE IF NOT EXISTS `users`
(
  `id`   BIGINT   PRIMARY KEY,
  `user` CHAR(32) NOT NULL
);
