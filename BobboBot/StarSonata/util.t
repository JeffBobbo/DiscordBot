#!/usr/bin/perl

use warnings;
use strict;

use Test::More "no_plan";

use BobboBot::StarSonata::util;

is(BobboBot::StarSonata::util::discount(10), 0.9, 'discount(10) == 0.9');
is(BobboBot::StarSonata::util::discount(1000), 0.729, 'discount(1000) == 0.729');
is(BobboBot::StarSonata::util::discount(10000), BobboBot::StarSonata::util::discount(1000), 'discount(10000) == discount(1000)');
