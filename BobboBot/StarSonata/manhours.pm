#!/usr/bin/perl

package BobboBot::StarSonata::manhours;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;
use BobboBot::StarSonata::util;
use POSIX;

sub run
{
  my $hash = shift();
  my $argv = $hash->{argv};
  return help() if (index($argv, '-h') != -1);

  my ($manhours) = $argv =~ /-m ?(\d+)/;
  my ($workers) = $argv =~ /-w ?(\d+)/;
  my ($num) = $argv =~ /-n ?(\d+)/;
  my ($perc) = $argv =~ /-p ?(\d+)%/;
  my ($roverts) = $argv =~ /-r/;
  my ($unique) = $argv =~ /-u/;

  if (!defined $manhours)
  {
    return "No manhours given";
  }
  if ($manhours < 1)
  {
    return "A build with no manhours is no build at all.";
  }

  if (!defined $workers)
  {
    $workers = 1;
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
  $result .= ".";


  return $result;
}

sub help
{
  return <<END
```$main::config->{prefix}manhours -m MANHOURS [-w WORKERS] [-n NUMBER] [-p PERCENT%] [-r] - Calculate item build time

Flags:
  -m MANHOURS
    Number of manhours the blueprint requires.
  -w WORKERS
    The total number of workers available to build the construction.
  -n NUMBER
    The number of items being constructed in the order, maximum of 10,000.
  -p PERCENT%
    For calculating the time remaining on running builds, should be in range 0..99 followed by a % sign.
  -r
    A `Rovert Nanobotics Facility` is in use.
```
END
}

BobboBot::Core::module::addCommand('manhours', \&BobboBot::StarSonata::manhours::run);

1;
