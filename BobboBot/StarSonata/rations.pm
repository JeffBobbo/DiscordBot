#!/usr/bin/perl

package BobboBot::StarSonata::rations;

use warnings;
use strict;

use BobboBot::Core::util;

use POSIX;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my $workers = decommify($hash->{argv}) || "0";
  if ($workers !~ /^\d+$/ || $workers <= 0)
  {
    return "Invalid number of workers. See `~rations -h` for usage";
  }
  my $consumption = $workers * 0.6;
  my $factories = ceil($consumption / 3600 * 12);
  my $hydroponics = ceil($workers / 300);

  my $result = commify($workers) . ' workers consume ' . commify($consumption) . ' rations every hour.';
  if ($factories > 0)
  {
    $result .= ' This requires at least ' . commify($factories) . ' MRE Factor' . ($factories == 1 ? 'y' : 'ies') . ' and ' . commify($hydroponics) . ' hydroponic' . ($hydroponics != 1 ? 's' : '') . ' to support.';
  }
  return $result;
}

sub help
{
  return <<END
```
$main::config->{prefix}rations WORKERS - Calculates the ration consumption rate
WORKERS
  Number of workers to compute ration consumption rate for.
```
END
}

BobboBot::Core::module::addCommand('rations', \&BobboBot::StarSonata::rations::run);

1;
