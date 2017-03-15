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
  my $statement = $dh->prepare_cached(qq(SELECT `tip` FROM `tip` ORDER BY RANDOM() LIMIT 1));

  my $ret = $statement->execute();
  my $haiku = $ret >= 0 ? $statement->fetchrow_hashref() : undef;
  $statement->finish();
  return $haiku;
}

sub tip_count
{
  my $statement = $dh->prepare_cached(qq(SELECT COUNT(*) FROM `tip`));
  my $ret = $statement->execute();
  my $count = $ret >= 0 ? $statement->fetch()->[0] : -1;
  $statement->finish();
  return $count;
}

1;
