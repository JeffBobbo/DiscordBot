#!/usr/bin/perl

package BobboBot::StarSonata::bots;

use v5.10;

use warnings;
use strict;

use POSIX; # floor

sub trade
{
  return (shift() + shift() || 0) * 2;
}

sub combat
{
  my $rc = shift();
  my $br = shift() || 0;
  my $phd = shift() || 0;

  my $t = trade($rc, $br);
  $t += 8 if ($phd);
  return $t;
}

sub wild
{
  my $rc = shift();
  my $wm = shift() || 0;

  return floor($rc * 2 * 1.5) if ($wm);
  return $rc * 2;
}

sub run
{
  my $hash = shift();
  my $opts = $hash->{opts};

  return help() if ($opts->has('h'));

  my $rc = $opts->argument_next();
  my $br = $opts->option_next('r');
  my $phd = $opts->has('p');
  my $wm = $opts->has('w');

  return "No Remote Control level" if (!defined $rc);

  return "You have " . trade($rc, $br) . " trade, " . combat($rc, $br, $phd) . " combat, and " . wild($rc, $wm) . " wild bot slots.";
}

sub help
{
  return <<END
```$main::config->{prefix}bots RC [-r BR] [-p] [-w] - Calculates the number of trade, combat, and wild bot slots you have

Arguments
  RC
    Your level in Remote Control.

Options
  -r BR - Your level in Bot Research.
  -p - Bot Ph.D, specify this if you trained it.
  -w - Wild Man, specify this if you have trained it.
```
END
}

BobboBot::Core::module::addCommand('bots', \&BobboBot::StarSonata::bots::run);

1;
