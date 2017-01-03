#!/usr/bin/perl

package BobboBot::Core::list;

use v5.10;

use warnings;
use strict;

sub run
{
  my $hash = shift();

  my @list = BobboBot::Core::module::commandList();
  return "Available commands: " . join(', ', @list);
}

BobboBot::Core::module::addCommand('list', \&BobboBot::Core::list::run);

1;
