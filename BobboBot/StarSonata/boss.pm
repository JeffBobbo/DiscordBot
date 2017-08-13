#!/usr/bin/perl

package BobboBot::StarSonata::boss;

use v5.10;

use warnings;
use strict;

use POSIX; # floor

my $bosses = {
  'Barbe Noire' => {
    galaxy => 'Tyro',
    dungeon => '8.6',
    splits => ['2.6B']
  },
  'Black Bart' => {
    galaxy => 'Seagull',
    dungeon => '8.76',
    splits => ['2.76B']
  },
  'Cardinal Bellarmine from Hell' => {
    galaxy => 'Torcularis Septentrionalis',
    dungeon => '4.21',
    splits => []
  },
  'Captain Albatross' => {
    galaxy => 'Parthibb',
    dungeon => '10.30',
    splits => ['3.30B']
  },
  'Dark Curse' => {
    galaxy => 'Verdi',
    dungeon => '10.2',
    splits => ['3.2B']
  },
#  'George Ohm' => {
#    galaxy => '',
#    dungeon => '',
#    splits => []
#  },
#  'James Watt' => {
#    galaxy => '',
#    dungeon => '',
#    splits => []
#  },
  'Marco Columbus' => {
    galaxy => 'Verdi',
    dungeon => '10.2',
    splits => ['2.2A']
  }
  'Nathaniel Courthope' => {
    galaxy => 'Komna',
    dungeon => '6.34',
    splits => []
  },
  'Sputty Nutty' => {
    galaxy => 'Seagull',
    dungeon => '8.76',
    splits => ['4.76A']
  },
};

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  if (length($hash->{argv}))
  {
    my $boss = $bosses->{$hash->{argv}};
    return "Unknown or boss not found: `$hash->{argv}`. See `$main::config->{prefix}boss` for the list." if (!defined $boss);

    my $str = "```\n$hash->{argv}\n  Location: $boss->{galaxy}\n  Dungeon: $boss->{dungeon}\n";
    if ($boss->{splits} && @{$boss->{splits}})
    {
      my @splits = @{$boss->{splits}};
      $str .= '  Splits: ' . join(', ', @splits);
    }
    return $str . "\n```";
  }
  return "Known locations: `" . join('`, `', keys(%{$bosses})) . "`.";
}

sub help
{
  return <<END
```
$main::config->{prefix}boss [BOSS] - Retrives the location of DG bosses.
When called without a name, the command returns a list of bosses with known locations.

  Options:
    BOSS
      Returns the location of a specific boss.
```
END
}

if ($INC{'BobboBot/Core/module.pm'})
{
  BobboBot::Core::module::addCommand('boss', \&BobboBot::StarSonata::boss::run);
}

1;
