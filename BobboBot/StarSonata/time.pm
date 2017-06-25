#!/usr/bin/perl

package BobboBot::StarSonata::time;

use v5.10;

use warnings;
use strict;

use BobboBot::StarSonata::util;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  return "Server time is " . BobboBot::StarSonata::util::servertime();
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
