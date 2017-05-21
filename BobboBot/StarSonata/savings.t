#!/usr/bin/perl

use warnings;
use strict;

use Test::More "no_plan";

use BobboBot::StarSonata::savings;

is(BobboBot::StarSonata::savings::run({argv=>"11 -r"}), 'A stack of 11 items building items requiring 1 each will produce 12 items with 0 spare.', "savings 11 -r");
is(BobboBot::StarSonata::savings::run({argv=>"1000 -r"}), 'A stack of 1,000 items building items requiring 1 each will produce 1,343 items with 0 spare.', "savings 1000 -r");
is(BobboBot::StarSonata::savings::run({argv=>"100 -n 10 -r"}), 'A stack of 100 items building items requiring 10 each will produce 11 items with 0 spare.', "savings 100 -i 10 -r");
