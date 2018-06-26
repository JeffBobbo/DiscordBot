#!/usr/bin/perl

package BobboBot::StarSonata::suit;

use warnings;
use strict;

use BobboBot::Core::util;

use POSIX;

use constant {
  CA_BONUS => 0.05,
  MAX_SUIT => 1.25
};

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my @arg = split(' ', $hash->{argv});

  my $conditions = {
    heavy => 0.5,
    low => 0.75,
    normal => 1.0,
    frozen => 0.5,
    blistering => 0.75,
    temperate => 1.0,
    gaseous => 0.5,
    noxious => 0.75,
    terran => 1.0
  };

  my @conditions = splice(@arg, 0, 3);

  my $suitability = 1.0;
  foreach my $condition (@conditions)
  {
    if ($conditions->{lc($condition)})
    {
      $suitability *= $conditions->{lc($condition)};
    }
    else
    {
      return 'Unrecognized planet condition: ' . $condition . '.';
    }
  }

  my ($caLevel) = (shift(@arg) || "0") =~ /(\d+)/;
  return 'Can\'t have a skill trained to a negative level.' if ($caLevel < 0);

  $suitability = min(MAX_SUIT, $suitability * (1 + $caLevel * CA_BONUS));

  return 'Planet suitability: ' . (floor($suitability * 1000) / 10) . '%.';
}

sub help
{
  return <<END
```
$main::config->{prefix}suit CONDITIONS [CA] - Calculates planet suitability from conditions

CONDITIONS
  Gravity: Heavy, Low, Normal
  Temperature: Frozen, Blistering, Temperate
  Atmosphere: Gaseous, Noxious, Terran
CA
  Colonial Administration level
```
END
}

BobboBot::Core::module::addCommand('suit', \&BobboBot::StarSonata::suit::run);

1;
