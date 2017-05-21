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
    return "Build quantity must be 1 or greater. See `$main::config->{prefix}savings -h`";
  }

  my ($items) = $argv =~ /-n ?(\d+)/;
  $items = 1 if (!defined $items);

  return "Item quantity must be 1 or greater. See `$main::config->{prefix}savings -h`" if ($items <= 0);

  my ($r) = $argv =~ /-r/;

  if (defined $r)
  {
    my $produced = 0;
    my $left = $quant;
    while ($left >= $items)
    {
      my $possible = floor($left / $items);
      $produced += $possible;
      my $mult = BobboBot::StarSonata::util::discount($possible) * 100;
      my $cost = ceil($possible * $items * $mult);
      $left -= ceil($cost / 100);
    }
    return 'A stack of ' . commify($quant) . ' items building items requiring ' . commify($items) . ' each will produce ' . commify($produced) . ' items with ' . commify($left) . ' spare.';
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
```$main::config->{prefix}savings QUANT [-n NUM]

Options:
  QUANT:
    Number of items to calculate the savings for, or the size of the stack of your items when `-r` is passed.

  -n NUM
    The quantity of an item required to build a single item.
    Defaults to 1.

  -r
    When given, the calculation will be performed recursively to deduce the total number of products that can be produced from a stack of QUANT items, rather than calculating the amount of savings made by doing QUANT builds.
```
END
}

if (exists $INC{'BobboBot/Core/module.pm'})
{
  BobboBot::Core::module::addCommand('savings', \&BobboBot::StarSonata::savings::run);
}

1;
