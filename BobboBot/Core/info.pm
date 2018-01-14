#!/usr/bin/perl

package BobboBot::Core::info;

use v5.10;

use warnings;
use strict;

sub run
{
  return "Discord-BobboBot. Written by Bobbo. Source avalable from <https://github.com/JeffBobbo/DiscordBot>";
}

BobboBot::Core::module::addCommand('info', \&BobboBot::Core::info::run);

1;
