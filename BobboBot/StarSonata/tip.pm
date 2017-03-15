#!/usr/bin/perl

package BobboBot::StarSonata::tip;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::db;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);
  return count() if (index($hash->{argv}, '-c') != -1);

  my $t = BobboBot::Core::db::tip_random();
  return if (!defined $t);

  # construct the tip
  my $ret = '```' . "\n";
  $ret .= $t->{tip} . "\n";
  $ret .= '```' . "\n";
  return $ret;
}

sub count
{
  my $count = BobboBot::Core::db::tip_count();
  if ($count < 0)
  {
    return "I'm sorry, but it seems I can't help you.";
  }

  return "I know of $count piece" . ($count == 1 ? '' : 's') . " of advice";
}

sub help
{
    return <<END
```
$main::config->{prefix}tip - Produces a tidbit of game advice.
OPTIONS
  -h - prints this help text
  -c - prints how many tips are known
```
END
}

BobboBot::Core::module::addCommand('tip', \&BobboBot::StarSonata::tip::run);

1;
