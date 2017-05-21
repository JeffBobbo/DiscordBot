#!/usr/bin/perl

use warnings;
use strict;

use Test::More "no_plan";

use BobboBot::Core::util;

is(min( 3, 4),  3, 'min( 3, 4) ==  3');
is(min(-1, 0), -1, 'min(-1, 0) == -1');
is(min( 0, 0),  0, 'min( 0, 0) ==  0');

is(max( 3, 4),  4, 'max( 3, 4) ==  4');
is(max(-1, 0),  0, 'max(-1, 0) ==  0');
is(max( 0, 0),  0, 'max( 0, 0) ==  0');

is(commify(5555), '5,555', 'commify(5555) == "5,555"');
is(commify(22.5), '22.5', 'commify(22.5) == "22.5"');
is(commify(-123456789.12), '-123,456,789.12', 'commify(-123456789.12) == "-123,456,789.12"');

is(decommify('500'), 500, 'decommify("500") == 500');
is(decommify('1,234.56'), 1234.56, 'decommify("1,234.56") == 1234.56');

TODO: {
  local $TODO = "Figure out how to test random calls";

  fail('random()');
  fail('randomf()');
}

TODO: {
  local $TODO = "Implement readableTime() tests";

  fail('readableTime()');
}
