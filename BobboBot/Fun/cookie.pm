#!/usr/bin/perl

package BobboBot::Fun::cookie;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::db;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);
  #return count() if (index($hash->{argv}, '-c') != -1);

  my $f = BobboBot::Core::db::fortune_random();
  return if (!defined $f);

  # construct the fortune
  my $ret = '```' . "\n";
  $ret .= $f . "\n";
  $ret .= '```' . "\n";
  return $ret;
}

sub count
{
  my $count = BobboBot::Core::db::fortune_count();
  if ($count < 0)
  {
    return "I couldn't seem to count any";
  }

  return "I know of $count fortune" . ($count == 1 ? '' : 's');
}

sub help
{
    return <<END
```
$main::config->{prefix}cookie - Reads a fortune cookie for you.
OPTIONS
  -h - prints this help text
```
END
}

BobboBot::Core::module::addCommand('cookie', \&BobboBot::Fun::cookie::run);

1;
