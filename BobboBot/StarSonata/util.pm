#!/usr/bin/perl

package BobboBot::StarSonata::util;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;

sub discount
{
  my $quant = min(shift(), 1000);
  return 0.9 ** logN($quant, 10);
}

1;
