#!/usr/bin/perl

package BobboBot::Core::help;

use v5.10;

use warnings;
use strict;

sub run
{
  return "Discord-BobboBot. Written by Bobbo.

All commands use switch-style parameters. A list of commands can be obtained with `" . $main::prefix . "list`.
All commands support a `-h` switch to receive their command specific help text.";
}

BobboBot::Core::module::addCommand('help', \&BobboBot::Core::help::run);

1;
