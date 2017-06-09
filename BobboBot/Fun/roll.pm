#!/usr/bin/perl

package BobboBot::Fun::roll;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;

sub run
{
  my $hash = shift();

  my $argv = $hash->{argv};
  return help() if (!defined $argv || index($argv, '-h') != -1);

  if ($argv =~ /^(?:([\d,]+)d)?([\d,]+)$/)
  {
    my $n = defined $1 ? $1 : 1;
    my $sides = defined $2 ? $2 : 1;
    $n =~ s/,//g;
    $sides =~ s/,//g;

    return 'Dice come with at least two sides.' if ($sides < 2);
    return 'Can\'t roll less than once.' if ($n < 1);
    return 'Can\'t roll more than six.' if ($n > 6);

    my @rolls;
    my $sum = 0;
    my $max = $n * $sides;
    for (1..$n)
    {
      my $x = random(1, $sides);
      $sum += $x;
      push(@rolls, commify($x));
    }

    my $ret = "<\@$hash->{author}{id}> rolled " . commify($sum);
    $ret .= " (" . join(', ', @rolls) . ")" if ($n > 1);
    $ret .= " out of " . commify($max) . ".";
    return $ret;
  }
  return  "Unrecognised rolling style, see `$main::config->{prefix}roll -h`.";
}

sub help
{
  return <<EOF
```
$main::config->{prefix}roll [Nd]S

Rolls a uniformly distributed dice.

[Nd]S:
  Roll an S sided dice, optionally N times. When supplied, N can't be greater than 6.
  $main::config->{prefix}roll 6 -- Rolls a 6 sided dice.
  $main::config->{prefix}roll 5d20 -- Rolls a 20 sided dice 5 times.
```
EOF
}

if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::module::addCommand('roll', \&BobboBot::Fun::roll::run);
}

1;
