#!/usr/bin/perl

package BobboBot::StarSonata::workers;

use warnings;
use strict;

use BobboBot::Core::util;

use POSIX;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my $rations = decommify($hash->{argv}) || "0";
  if ($rations !~ /^\d+$/ || $rations <= 0)
  {
    return "Invalid number of rations. See `~workers -h` for usage";
  }
  my $consumption = $rations / 0.6;

  my $result = commify($rations) . ' rations will support ' . commify($consumption) . ' workers every hour.';
  return $result;
}

sub help
{
  return <<END
```
$main::config->{prefix}workers RATIONS - Calculates how many workers can be supported
RATIONS
  Number of rations to compute worker support for.
```
END
}

BobboBot::Core::module::addCommand('workers', \&BobboBot::StarSonata::workers::run);

1;
