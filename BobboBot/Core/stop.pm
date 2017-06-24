#!/usr/bin/perl

package BobboBot::Core::stop;

use v5.10;

use warnings;
use strict;

sub run
{
  exit(0);
}

BobboBot::Core::module::addCommand('stop', \&BobboBot::Core::stop::run);

1;
