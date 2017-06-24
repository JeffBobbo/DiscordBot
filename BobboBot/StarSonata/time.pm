#!/usr/bin/perl

package BobboBot::StarSonata::time;

use v5.10;

use warnings;
use strict;

use POSIX qw(tzset);

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my $old = $ENV{TZ};
  $ENV{TZ} = 'America/New_York';
  tzset;
  my ($s, $n, $h, $d, $m, $y, undef, undef, $dst) = localtime();
  $ENV{TZ} = $old;
  tzset;

  return sprintf("Server time is %d-%02d-%02d %02d:%02d:%02d %s", $y+1900, $m, $d, $h, $n, $s, ($dst ? 'EDT' : 'EST'));
}

sub help
{
  return <<END
```
$main::config->{prefix}time - Returns the current time for the game server.
```
END
}

if ($INC{'BobboBot/Core/module.pm'})
{
  BobboBot::Core::module::addCommand('time', \&BobboBot::StarSonata::time::run);
}

1;
