#!/usr/bin/perl

use warnings;
use strict;

use Test::More "no_plan";

use BobboBot::Util::calc;

is(BobboBot::Util::calc::run({argv=>"3+4"}), 'Result: 7', "calc 3+4");
is(BobboBot::Util::calc::run({argv=>"a = 5; 4+a"}), 'Result: 9', "calc a = 5; 4+a");
is(BobboBot::Util::calc::run({argv=>"min(4, 5)"}), 'Result: 4', "calc min(4, 5)");
