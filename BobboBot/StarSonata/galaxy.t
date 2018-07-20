#!/usr/bin/perl

use warnings;
use strict;

use Test::More "no_plan";

BEGIN { use_ok('BobboBot::StarSonata::galaxy') }
#BobboBot::StarSonata::galaxy::update();
#BobboBot::StarSonata::galaxy::run({argv => 'Sol'});
ok(BobboBot::StarSonata::galaxy::sector({x => 5, y => 0}) eq "east", "sector-east");
ok(BobboBot::StarSonata::galaxy::sector({x => 0.5, y => 0.5}) eq "central", "sector-central");
ok(BobboBot::StarSonata::galaxy::sector({x => -5, y => 0.1}) eq "west", "sector-west");
ok(BobboBot::StarSonata::galaxy::sector({x => 5, y => 5}) eq "north east", "sector-north-east");
