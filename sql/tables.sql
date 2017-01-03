/*
  When a user first and last spoke
 */
/*
CREATE TABLE IF NOT EXISTS `spoke`
(
  `id`          BIGINT  PRIMARY KEY REFERENCES users(id),
  `spoke_first` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `spoke_last`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `messages`    BIGINT DEFAULT 0,
  `edits`       BIGINT DEFAULT 0,
  `deletes`     BIGINT DEFAULT 0
);
*/
/* ********************************* */
/* game tables
these tables are for storing game state information
*/

/*
  game_roulette stores a single game, which will have
    an id
    a loser
    a completion date
 */

/*
CREATE TABLE IF NOT EXISTS `game_roulette`
(
  `id` BIGINT PRIMARY KEY AUTOINCREMENT,
  `loser` BIGINT REFERENCES users(id),
  `completed` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS `game_roulette_player`
(

);
*/
