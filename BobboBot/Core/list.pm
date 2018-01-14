#!/usr/bin/perl

package BobboBot::Core::list;

use v5.10;

use warnings;
use strict;

sub run
{
  my $hash = shift();

  my @list = BobboBot::Core::module::commandList();
  return "Available commands: " . join(', ', @list) . "

All commands use switch-style parameters.
All commands with help text (nearly all) support a `-h` switch to print it, e.g., `~haiku -h`";
}

BobboBot::Core::module::addCommand('list', \&BobboBot::Core::list::run);
BobboBot::Core::module::addCommand('help', \&BobboBot::Core::list::run);

1;
