#!/usr/bin/perl

package BobboBot::Util::usage;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::module;
use BobboBot::Core::db;

my $FORMAT = "%12s | %5s";

sub run
{
  my $hash = shift();

  my $return = '```';
  my @commands = BobboBot::Core::module::commandList();
  $return .= sprintf($FORMAT . "\n", "Command", "Count");
  $return .= "=" x 20;
  foreach (@commands)
  {
    my $count = BobboBot::Core::db::command_count($_);
    if ($count < 0)
    {
      return 'Failed to retrieve usage counts';
    }
    my $str = sprintf($FORMAT, $_, $count);
    $return .= "\n$str";
  }
  my $total = BobboBot::Core::db::command_count();
  if ($total >= 0)
  {
    $return .= "\n" . "-" x 20 . "\n";
    $return .= sprintf($FORMAT, "Total", $total) . "\n";
  }
  return $return . "```";
}

sub help
{
  return $main::prefix . 'usage - Prints bot command usage statistics';
}

BobboBot::Core::module::addCommand('usage', \&BobboBot::Util::usage::run);

1;
