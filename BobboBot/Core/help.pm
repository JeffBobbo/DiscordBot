#!/usr/bin/perl

package BobboBot::Core::help;

use v5.10;

use warnings;
use strict;

sub run
{
  return <<EOH
BobboBot, written by Bobbo. Source is available on GitHub; <https://github.com/JeffBobbo/DiscordBot>.

A list of commands can be obtained from `$main::config->{prefix}list`. Nearly all commands have accompanying help text, which can be retrieved by issuing the command with `-h` afterwards (e.g., `$main::config->{prefix}haiku -h`).
Commands take arguments and options (or flags) through switch-style like a command line.
Arguments are provided without an option flag, while an option (or flag) is provided with one (e.g., `$main::config->{prefix} argument --option`).
In help text, arguments and options surrounded by square brackets are optional, those not surrounded are required.
Options may be specified in any order, arguments may be specified whenever, but must be in the same relative order.
EOH
}

BobboBot::Core::module::addCommand('help', \&BobboBot::Core::help::run);

1;
