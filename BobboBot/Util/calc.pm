#!/usr/bin/perl

package BobboBot::Util::calc;

use v5.10;

use warnings;
use strict;

use Calculator::Lexer;
use Calculator::Parser;
use Calculator::Interpreter;

use BobboBot::Core::util;

my $interpreter = Calculator::Interpreter->new();

sub gcd
{
  my $a = shift();
  my $b = shift();
  while ($a != 0 && $b != 0)
  {
    if ($a > $b)
    {
      $a %= $b;
    }
    else
    {
      $b %= $a;
    }
  }
  return $a || $b;
}

sub constants
{
  my @constants = $interpreter->type(CONST);

  my $report = "List of constants:\n";
  foreach (@constants)
  {
    $report .= $interpreter->help($_) . "\n";
  }
  return $report;
}

sub functions
{
  my @functions = $interpreter->type(FUNCT);

  my $report = "List of functions:\n`" . join("`, `", @functions) . "`";
  return $report;
}

sub run
{
  my $hash = shift();

  my $argv = $hash->{argv};
  return help() if (!defined $argv || index($argv, '-h') != -1);
  return constants() if (index($argv, '-c') != -1);
  return functions() if (index($argv, '-f') != -1);

  my $result;
  eval {
    $result = $interpreter->interpret($argv);
  };
  if ($@ || !defined $result)
  {
    return "Computation error.";
  }
  return 'Result: ' . $result;
}

sub help
{
  return <<END
$main::config->{prefix}calc [-h|-l|<expr>] - calculator. Calculates the given expression.
Switches:
  -h - This help text
  -c - List of constants avilable
  -f - List of functions avilable

The calculator can handle normal arithmatic, has support for variables and functions.
Multiplication (`*`), division (`/`) and modulo (`%`) have the same precedence and are evaluated left to right.

Multiple expressions are supported, with the result being the value of the last given expression. Expressions must be separated by a semicolon.

Variables must start with a letter or underscore, but otherwise can contain alphanumeric characters. Assignment is done with a single equals `=`.

Example use:
`$main::config->{prefix}calc 5 + 4` = 9
`$main::config->{prefix}calc (6 + 4) * last` = 90
`$main::config->{prefix}calc a = 5; b = 9; a * b ** a` = 295245
END
}

if ($INC{'BobboBot/Core/module.pm'})
{
  BobboBot::Core::module::addCommand('calc', \&BobboBot::Util::calc::run);
}

1;
