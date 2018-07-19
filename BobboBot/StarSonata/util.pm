#!/usr/bin/perl

package BobboBot::StarSonata::util;

use v5.10;

use warnings;
use strict;

use DateTime;

use BobboBot::Core::util;

sub discount
{
  my $quant = min(shift(), 1000);
  return 0.9 ** logN($quant, 10);
}

sub servertime
{
  my $t = shift();
  my $dt = DateTime->from_epoch(epoch => $t, time_zone => 'America/New_York');
  return $dt->datetime(' ') . ' ' . ($dt->is_dst() ? 'EDT' : 'EST');
}

1;
