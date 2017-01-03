#!/usr/bin/perl

package BobboBot::Fun::roll;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;

sub run
{
  my $hash = shift();

  my $argv = $hash->{argv};
  return help() if (!defined $argv || index($argv, '-h') != -1);

  if ($argv !~ /^[\d,]+$/)
  {
    return 'I can\'t roll on that.';
  }

  $argv =~ s/,//g;

  if ($argv < 2)
  {
    return 'Can\'t roll on less than a two.';
  }

  my $r = commify(random(1, $argv));
  $argv = commify($argv);
  return "<\@$hash->{author}{id}> rolled $r out of $argv.";
}

sub help
{
  return $main::config->{prefix} . 'roll (max) - Roll a random number from 1 to max';
}

BobboBot::Core::module::addCommand('roll', \&BobboBot::Fun::roll::run);

1;
