#!/usr/bin/perl

package BobboBot::Core::permissions;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::db;

sub access
{
  my $userid = shift();

  return BobboBot::Core::db::user_access($userid) || 0;
}

sub level
{
  my $command = shift();

  return {
    'stop' => 2
  }->{$command} || 0;
}

1;
