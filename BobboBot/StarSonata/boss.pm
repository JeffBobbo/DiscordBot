#!/usr/bin/perl

package BobboBot::StarSonata::boss;

use v5.10;

use warnings;
use strict;

use POSIX; # floor

my $bosses = {
  'Barbe Noire' => {
    galaxy => 'Kiernan',
    dungeon => '',
    splits => ['9.12A', '5.12B']
  },
  'Black Bart' => {
    galaxy => 'Gratification',
    dungeon => '10.9',
    splits => ['3.9B']
  },
  'Cardinal Bellarmine from Hell' => {
    galaxy => 'Tarazet',
    dungeon => '10.69',
    splits => []
  },
  'Captain Albatross' => {
    galaxy => 'Mexico Way',
    dungeon => '11.17',
    splits => ['7.17B', '2.17B']
  },
  'Dark Curse' => {
    galaxy => 'Parmenides',
    dungeon => '11.18',
    splits => ['5.18B']
  },
  'George Ohm' => {
    galaxy => 'Crunchy Catapillar',
    dungeon => '',
    splits => []
  },
  'James Watt' => {
    galaxy => 'Lidius',
    dungeon => '12.323',
    splits => ['8.323A', '2.323A']
  },
  'Nathaniel Courthope' => {
    galaxy => 'Kiernan',
    dungeon => '',
    splits => ['9.12B', '2.12B']
  },
  'Sputty Nutty' => {
    galaxy => 'Gratification',
    dungeon => '10.9',
    splits => ['3.9A']
  },
  'Marco Columbus' => {
    galaxy => 'Mexico Way',
    dungeon => '',
    splits => ['11.17A', '2.17A']
  }
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
