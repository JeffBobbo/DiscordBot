#!/usr/bin/perl

package BobboBot::StarSonata::savings;

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

  my $quant = $argv;
  {
    my $idx = index($argv, ' ');
    if ($idx != -1)
    {
      $quant = substr($argv, 0, $idx, "");
    }
  }

  if ($quant <= 0)
  {
    return "Build quantity must be 1 or greater. See `$main::config->{prefix}savings` -h";
  }

  my ($items) = $argv =~ /-i ?(\d+)/;
  $items = 1 if (!defined $items);

  if ($items <= 0)
  {
    return "Item quantity must be 1 or greater. See `$main::config->{prefix}savings` -h";
  }

  my $mult = BobboBot::StarSonata::util::discount($quant) * 100;
  my $cost = ceil($quant * $items * $mult);
  my $tot = $quant * $items;
  my $save = floor($tot - ($cost / 100));

  return 'Number builds: ' . commify($quant) . ', Number items: ' . commify($items) . '. Savings: ' . commify($save) . '/' . commify($tot) . '(' . sprintf("%.2f", 100 - $mult)  . '%).';
}

sub help
{
  return <<END
```$main::config->{prefix}savings NUM_BUILDS [-i NUM_ITEMS]

Options:
  NUM_BUILDS:
    Number of items to calculate the savings for

  -i NUM_ITEMS
    The quantity of an item required for this build.
```
END
}

BobboBot::Core::module::addCommand('savings', \&BobboBot::StarSonata::savings::run);

1;
