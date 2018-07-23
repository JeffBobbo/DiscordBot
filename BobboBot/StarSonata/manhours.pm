#!/usr/bin/perl

package BobboBot::StarSonata::manhours;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;
use BobboBot::StarSonata::util;
use POSIX;

use opts::opts;

sub run
{
  my $hash = shift();
  my $argv = $hash->{argv};
  my $opts = $hash->{opts};
  return help() if ($opts->has('h'));

  my $manhours = $opts->argument_next();
  my $workers = $opts->argument_next() || 1;
  my $num = $opts->option_next('n');
  my $perc = $opts->option_next('p');
  my $roverts = $opts->has('r');
  my $unique = $opts->has('u');

  if (!defined $manhours)
  {
    return "No manhours given";
  }
  if ($manhours < 1)
  {
    return "A build with no manhours is no build at all.";
  }

  if ($workers < 1)
  {
    return "Things don't build themselves.";
  }

  if (!defined $num)
  {
    $num = 1;
  }
  if ($num < 1)
  {
    return "Can't build nothing.";
  }
  if ($num > 10000)
  {
    return "Can't build more than 10,000 items in one order.";
  }
  if (defined $perc)
  {
    if ($perc < 0)
    {
      return "A build can't be less done than not started.";
    }
    if ($perc >= 100)
    {
      return "This build is already done.";
    }
  }

  my $mult = BobboBot::StarSonata::util::discount($num) * 100;
  my $bTime = (($manhours * 10) / $workers) * $mult;

  $bTime /= 2.0 if ($roverts);
  $bTime *= 1.0 - ($perc / 100.0) if ($perc);
  $bTime = floor($bTime / 100);

  my $result = commify($num) . " build" . ($num != 1 ? "s" : "") . ", requiring " . commify($manhours) . " manhour" . ($manhours != 1 ? "s" : "") . " each, using " . commify($workers) . " worker" . ($workers != 1 ? "s" : "") . " should take " . readableTime($bTime * $num);

  $result .= " (" . readableTime($bTime) . " per item)" if ($num > 1);

  if (defined $perc)
  {
    $result .= " from " . $perc . "%";
  }
  if ($roverts)
  {
    $result .= " when boosted with a Rovert Nanobotics Facility";
  }
  $result .= ".";

  return $result;
}

sub help
{
  return <<END
```$main::config->{prefix}manhours MANHOURS [WORKERS] [-n NUMBER] [-p PERCENT%] [-r] [-u] - Calculate item build time

Arguments:
  MANHOURS
    Number of manhours the blueprint requires.
  WORKERS
    Number of workers available to work on the construction (or the max workforce).
    Defaults to 1.

Flags:
  -n NUMBER
    The number of items being constructed in the order, maximum of 10,000.
  -p PERCENT%
    For calculating the time remaining on running builds, should be in range 0..99 followed by a % sign.
  -r
    A `Rovert Nanobotics Facility` is in use.
  -u
    A "unique" build, where items are built one by one, instead of in one batch.
```
END
}

BobboBot::Core::module::addCommand('manhours', \&BobboBot::StarSonata::manhours::run);

1;
