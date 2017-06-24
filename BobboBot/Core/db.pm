#!/usr/bin/perl

package BobboBot::Core::db;

use v5.10;

use warnings;
use strict;

use DBI;
use Data::Dumper;

use BobboBot::Core::module;

my $dh;
sub init
{
  if (openDB())
  {
    create();
  }
}

sub openDB
{
  my $driver = $main::config->{database}{db_driver};
  my $name   = $main::config->{database}{db_name};

  my $dbd = "DBI:$driver:dbname=$name";
  my $user = '';
  my $pass = '';

  $dh = DBI->connect($dbd, $user, $pass, { RaiseError => 1 }) or die $DBI::errstr;
  return $dh;
}

sub closeDB
{
  if ($dh)
  {
    $dh->disconnect();
    undef $dh;
  }
}

sub create
{
  my $base = $main::config->{database}{tables_dir};
  my @tables = @{$main::config->{database}{tables_sql}};

  foreach (@tables)
  {
    print "Creating table from file $_\n";
    open(my $fh, '<', $base . '/' . $_) or return 0;
    my $sql = join('', <$fh>);
    close($fh);
    return 0 if (!defined $sql || length($sql) == 0);

    $dh->do($sql) or die $DBI::errstr;
  }
  return 1;
}

# END generic functions
# BEGIN table specific functions

sub user
{
  my $user = shift();

  my $statement = $dh->prepare_cached(qq(INSERT OR IGNORE INTO `users`(`id`, `user`) VALUES(?, ?)));
  my $ret = $statement->execute($user->{id}, $user->{username});
  $statement->finish();
}

sub user_access
{
  my $userid = shift();

  my $statement = $dh->prepare_cached(qq(SELECT `access` FROM `users` WHERE `id`=?));
  my $ret = $statement->execute($userid);

  my $a = $ret >= 0 ? $statement->fetch()->[0] : undef;
  $statement->finish();
  return $a;
}

sub command_count
{
  my $command = shift();

  if (defined $command && BobboBot::Core::module::valid($command) == 0)
  {
    print "Invalid command\n";
    return -1;
  }

  my $statement;
  my $ret;
  if (defined $command)
  {
    $statement = $dh->prepare_cached(qq(SELECT COUNT(*) FROM `log_command` WHERE `command`=?));
    $ret = $statement->execute($command);
  }
  else
  {
    $statement = $dh->prepare_cached(qq(SELECT COUNT(*) FROM `log_command`));
    $ret = $statement->execute();
  }
  my $count = $ret >= 0 ? $statement->fetch()->[0] : -1;
  $statement->finish();
  return $count;
}

sub command_use
{
  my $command = shift();
  my $argv = shift();
  my $author = shift();
  my $channel = shift();

  my $statement = $dh->prepare_cached(qq(INSERT INTO `log_command`(`command`, `argv`, `author`, `channel`)
VALUES(?, ?, ?, ?)));
  my $ret = $statement->execute($command, $argv || '', $author->{id}, $channel);
  $statement->finish();
}

sub haiku_add
{
  my $lines = shift();
  my $author = shift();
  my $channel = shift();

  my $statement = $dh->prepare_cached(qq(INSERT INTO `haiku`(`line0`,`line1`,`line2`,`author`,`channel`)
VALUES(?, ?, ?, ?, ?)));
  my $ret = $statement->execute($lines->[0], $lines->[1], $lines->[2], $author, $channel);
  $statement->finish();
}

sub haiku_random
{
  my $statement = $dh->prepare_cached(qq(SELECT `line0`,`line1`,`line2`,`user`,`when` FROM `haiku` JOIN `users` ON `haiku`.`author`=`users`.`id` ORDER BY RANDOM() LIMIT 1));

  my $ret = $statement->execute();
  my $haiku = $ret >= 0 ? $statement->fetchrow_hashref() : undef;
  $statement->finish();
  return $haiku;
}

sub haiku_count
{
  my $statement = $dh->prepare_cached(qq(SELECT COUNT(*) FROM `haiku`));
  my $ret = $statement->execute();
  my $count = $ret >= 0 ? $statement->fetch()->[0] : -1;
  $statement->finish();
  return $count;
}

sub saidit_add
{
  my $msg = shift();
  my $author = shift();
  my $channel = shift();

  my $statement = $dh->prepare_cached(qq(INSERT INTO `saidit`(`message`,`author`,`channel`)
VALUES(?, ?, ?)));
  my $ret = $statement->execute($msg, $author, $channel);
  $statement->finish();
}

sub saidit_count
{
  my $statement = $dh->prepare_cached(qq(SELECT COUNT(*) FROM `saidit`));
  my $ret = $statement->execute();
  my $count = $ret >= 0 ? $statement->fetch()->[0] : 0;
  $statement->finish();
  return $count;
}

sub fortune_random
{
  my $statement = $dh->prepare_cached(qq(SELECT `fortune` FROM `fortune` ORDER BY RANDOM() LIMIT 1));

  my $ret = $statement->execute();
  my $fortune = $ret >= 0 ? $statement->fetch()->[0] : undef;
  $statement->finish();
  return $fortune;
}

sub tip_random
{
  my $statement = $dh->prepare_cached(qq(SELECT * FROM `tip` ORDER BY RANDOM() LIMIT 1));

  my $ret = $statement->execute();
  my $haiku = $ret >= 0 ? $statement->fetchrow_hashref() : undef;
  $statement->finish();
  return $haiku;
}

sub tip_search
{
  my $search = shift();
  my $statement = $dh->prepare_cached(qq(SELECT * FROM ((SELECT * FROM `tip` WHERE `tip` LIKE ? ORDER BY RANDOM()) JOIN (SELECT COUNT(*) AS `count` FROM `tip` WHERE `tip` LIKE ?))));
  my $ret = $statement->execute('%' . $search . '%', '%' . $search . '%');

  my $data = $ret >= 0 ? $statement->fetchrow_hashref() : undef;
  $statement->finish();
  return $data;
}

sub tip_add
{
  my $tip = shift();
  my $authorid = shift();

  my $statement = $dh->prepare_cached(qq(INSERT INTO `tip`(`tip`, `author`) VALUES(?, ?)));

  my $ret = $statement->execute($tip, $authorid);
  $statement->finish();
  if ($ret < 0)
  {
    return -1;
  }

  $statement = $dh->prepare_cached(qq(SELECT `id` FROM `tip` WHERE `tip`=?));
  $ret = $statement->execute($tip);
  my $id = $ret >= 0 ? $statement->fetch()->[0] : -1;
  $statement->finish();
  return $id;
}

sub tip_del
{
  my $id = shift();

  my $statement = $dh->prepare_cached(qq(DELETE FROM `tip` WHERE `id`=?));
  my $ret = $statement->execute($id);
  $statement->finish();
  return $ret >= 0;
}

sub tip_count
{
  my $statement = $dh->prepare_cached(qq(SELECT COUNT(*) FROM `tip`));
  my $ret = $statement->execute();
  my $count = $ret >= 0 ? $statement->fetch()->[0] : -1;
  $statement->finish();
  return $count;
}

sub faq_get
{
  my $name = shift();

  my $statement = $dh->prepare_cached(qq(SELECT * FROM `faq` WHERE `name`=?));
  my $ret = $statement->execute($name);
  my $faq = $ret >= 0 ? $statement->fetchrow_hashref() : undef;
  $statement->finish();
  return $faq;
}

sub faq_count
{
  my $statement = $dh->prepare_cached(qq(SELECT COUNT(*) FROM `faq`));
  my $ret = $statement->execute();
  my $count = $ret >= 0 ? $statement->fetch()->[0] : -1;
  $statement->finish();
  return $count;
}

sub faq_add
{
  my $name = shift();
  my $text = shift();
  my $userid = shift();

  my $statement = $dh->prepare_cached(qq(INSERT INTO `faq`(`name`, `text`, `author`) VALUES(?, ?, ?)));
  my $ret = $statement->execute($name, $text, $userid);
  $statement->finish();
  return $ret >= 0;
}

sub faq_del
{
  my $name = shift();

  my $faq = faq_get($name);
  return undef if (!defined $faq);

  my $statement = $dh->prepare_cached(qq(DELETE FROM `faq` WHERE `id`=?));
  my $ret = $statement->execute($faq->{id});
  $statement->finish();
  return $ret >= 0 ? $faq : undef;
}

1;
