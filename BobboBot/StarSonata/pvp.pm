#!/usr/bin/perl

package BobboBot::StarSonata::pvp;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;
use POSIX; # floor

use constant
{
  EMP_MULT => 0.30,
  EFFECTIVE_MAX => 2200
};

my %war = (
  'none'      => 0.0,
  'one-sided' => 0.15,
  'mutual'    => 0.30
);

sub mult
{
  my $df = shift();
  my $w = shift();
  my $e = shift();

  my $mult;
  if ($df < 25)
  {
    $mult = 0.20;
  }
  elsif ($df < 75)
  {
    $mult = 0.35;
  }
  elsif ($df < 125)
  {
    $mult = 0.50;
  }
  else
  {
    $mult = 0.65;
  }

  if (defined $w && $war{$w})
  {
    $mult += $war{$w};
  }

  if (defined $e && $e)
  {
    $mult += EMP_MULT;
  }

  return min($mult, 1.0);
}

sub run
{
  my $hash = shift();

  my $argv = $hash->{argv};
  return help() if (!defined $argv || index($argv, '-h') != -1);

  my ($lvl) = $argv =~ /-l ?(\d+)/;
  my ($df)  = $argv =~ /-d ?(\d+)/;
  my ($war) = $argv =~ /-w ?((?:none)|(?:one-way)|(?:mutual))/;
  my ($emp) = $argv =~ /-e/;

  my $mult = mult($df, $war, $emp);

  my $top = min($lvl, EFFECTIVE_MAX);
  my $limit = floor($top * (1.0 - $mult));
  $limit = max(0.0, min($limit, floor($top - $mult * 50.0)));

  my $lower = max(0.0, min($top * (1.0 - $mult), $top - $mult * 50.0));
  my $upper = $mult == 1.0 ? EFFECTIVE_MAX : min(EFFECTIVE_MAX, max($top / (1.0 - $mult), $top + $mult * 50.0));
  $lower = floor($lower);
  $upper = floor($upper);

  return ' Your PvP range is [' . commify($lower) . ', ' . ($upper < EFFECTIVE_MAX ? commify($upper) : 'oo') . '].';
}

sub help
{
  return <<END
```$main::config->{prefix}pvp -l <lvl> -d <df> [-w none|one-way|mutual -e] - Calculates your PvP range based on conditions
  -l <lvl> - Your level
  -d <df> - Danger factor of the galaxy you're in
  -w [state] - War state, 'none', 'one-way' or 'mutual'. Default is none
  -e - Emperor, should be specified if you or the target is on the emperor's team. Default is false
```
END
}

BobboBot::Core::module::addCommand('pvp', \&BobboBot::StarSonata::pvp::run);

1;
