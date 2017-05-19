#!/usr/bin/perl

package BobboBot::Util::rpn;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;

sub Pi
{
  return atan2(0, -1);
}

sub factorial
{
  my $n = shift();
  my $r = $n;
  my $i = 1;
  $r *= $i while (++$i < $n || ($r ne 'nan' || $r ne 'inf' || $r ne '-inf'));
  return $r;
}

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

my $last = 0;

use constant {
  MATHEMATIC => 0,
  FUNCTION   => 1,
  TRIG       => 2,
  BITWISE    => 3,
  CONSTANT   => 4,
  K_NUM_TYPES => 5
};

sub typeToString
{
  my $t = shift();
  return "Mathematic operator" if ($t == MATHEMATIC);
  return "Function" if ($t == FUNCTION);
  return "Trigonometric function" if ($t == TRIG);
  return "Bitwise operator" if ($t == BITWISE);
  return "Constant" if ($t == CONSTANT);
}

my $operators = {
  '+' => { ops => 2, t => MATHEMATIC, fn => sub { return $_[0] +  $_[1] } },
  '-' => { ops => 2, t => MATHEMATIC, fn => sub { return $_[0] -  $_[1] } },
  '*' => { ops => 2, t => MATHEMATIC, fn => sub { return $_[0] *  $_[1] } },
  '/' => { ops => 2, t => MATHEMATIC, fn => sub { return $_[0] /  $_[1] } },
  '^' => { ops => 2, t => MATHEMATIC, fn => sub { return $_[0] ** $_[1] } },
  '%' => { ops => 2, t => MATHEMATIC, fn => sub { return $_[0] %  $_[1] } },

  'sqrt'  => { ops => 1, t => FUNCTION, fn => sub { return sqrt(abs($_[0])) } },
  'root'  => { ops => 2, t => FUNCTION, fn => sub { return abs($_[0]) ** (1 / $_[1]) } },
  'log'   => { ops => 1, t => FUNCTION, fn => sub { return log($_[0]) } },
  'log10' => { ops => 1, t => FUNCTION, fn => sub { return log($_[0]) / log(10) } },
  'logN'  => { ops => 2, t => FUNCTION, fn => sub { return log($_[0]) / log($_[1]) } },
  #'!'     => { ops => 1, t => FUNCTION, fn => sub { return factorial($_[0]) } },

  # trig
  'sin'   => { ops => 1, t => TRIG, fn => sub { return sin($_[0]) } },
  'asin'  => { ops => 1, t => TRIG, fn => sub { return atan2($_[0], sqrt(1 - $_[0] * $_[0])) } },
  'cos'   => { ops => 1, t => TRIG, fn => sub { return cos($_[0]) } },
  'acos'  => { ops => 1, t => TRIG, fn => sub { return atan2(sqrt(1 - $_[0] * $_[0]), $_[0]) } },
  'tan'   => { ops => 1, t => TRIG, fn => sub { return sin($_[0]) / cos($_[0]) } },
  'atan2' => { ops => 2, t => TRIG, fn => sub { return atan2($_[0], $_[1]) } },

  # bitwise
  '<<'  => { ops => 2, t => BITWISE, fn => sub { return $_[0] << $_[1]} },
  '>>'  => { ops => 2, t => BITWISE, fn => sub { return $_[0] >> $_[1]} },
  'AND' => { ops => 2, t => BITWISE, fn => sub { return $_[0] & $_[1] } },
  'OR'  => { ops => 2, t => BITWISE, fn => sub { return $_[0] | $_[1] } },
  'XOR' => { ops => 2, t => BITWISE, fn => sub { return $_[0] ^ $_[1] } },
  'NOT' => { ops => 1, t => BITWISE, fn => sub { return ~$_[0] } },

  # special functions
  'min'  => { ops => 2, t => FUNCTION, fn => sub { return $_($_[0] < $_[1] ? 0 : 1) } },
  'max'  => { ops => 2, t => FUNCTION, fn => sub { return $_($_[0] > $_[1] ? 0 : 1) } },
  'deg'  => { ops => 1, t => FUNCTION, fn => sub { return $_[0] * 180 / Pi() } },
  'rad'  => { ops => 1, t => FUNCTION, fn => sub { return $_[0] * Pi() / 180 } },
  'last' => { ops => 0, t => FUNCTION, fn => sub { return $last } },
  'time' => { ops => 0, t => FUNCTION, fn => sub { return time() } },
  'gcd'  => { ops => 2, t => FUNCTION, fn => sub { return gcd($_[0], $_[1]) } },

  #constants
  'pi' => { ops => 0, t => CONSTANT, fn => sub { return Pi() } },
  'e'  => { ops => 0, t => CONSTANT, fn => sub { return exp(1) } },
  'c'  => { ops => 0, t => CONSTANT, fn => sub { return 2.997924580e8 } },
  'g'  => { ops => 0, t => CONSTANT, fn => sub { return 9.81 } },
  'G'  => { ops => 0, t => CONSTANT, fn => sub { return 6.67384e-11 } }
};

sub list
{
  my $list = "```";
  foreach my $t (0..K_NUM_TYPES-1)
  {
    $list .= typeToString($t) . "s:";
    my $i = 0;
    foreach (sort(keys(%{$operators})))
    {
      next if ($operators->{$_}{t} != $t);
      $list .= ($i++ % 2 == 0 ? "\n" : "    ");
      $list .= $_ . " - ";
      if ($t == MATHEMATIC || $t == BITWISE)
      {
        $list .= "Operands: " . $operators->{$_}{ops};
      }
      elsif ($t == CONSTANT)
      {
        $list .= commify($operators->{$_}{fn}());
      }
      else
      {
        $list .= "Number of arguments: " . $operators->{$_}{ops};
      }
    }
    $list .= "\n";
  }
  return $list . '```';
}

sub run
{
  my $hash = shift();

  my $argv = $hash->{argv};
  return help() if (!defined $argv || index($argv, '-h') != -1);
  return list() if (index($argv, '-l') != -1);

  my @stack = split(' ', $argv);
  foreach (@stack)
  {
    if (!$operators->{$_} && $_ !~ /^_?[0-9\.]+$/)
    {
      return 'Malformed or unknown argument: `' . $_ . '`. Operators and operands must be separated.';
    }
    $_ =~ s/_/-/g;
  }

  my $result = eval
  {
    while (@stack > 1)
    {
      my $op;
      for (my $i = 0; $i < @stack && !defined $op; $i++)
      {
        foreach my $operator (keys %{$operators})
        {
          if ($operator eq $stack[$i])
          {
            $op = $i;
            last;
          }
        }
      }

      return 'Malformed expression: missing operator.' if (!defined $op);
      my $num = $operators->{$stack[$op]}->{ops};
      if ($op < $num)
      {
        return 'Malformed expressoin: not enough arguments for `' . $stack[$op] . '`, expected ' . $num . '.';
      }

      if ($operators->{$stack[$op]})
      {
        if ($stack[$op] eq '/' && $stack[$op - 1] == 0)
        {
          return 'Error: div/0';
        }
        my @ops;
        for (my $x = $num; $x >= 1; --$x)
        {
          push(@ops, $stack[$op - $x]);
        }
        $stack[$op - $num] = $operators->{$stack[$op]}->{fn}(@ops);
        splice(@stack, $op - ($num - 1), $num);
      }
      else # should never happen
      {
        return 'Unknown operator: `' . $stack[$op] . '`.';
      }
    }
    return $stack[$0];
  };
  if ($@)
  {
    return "Computation error: `$@`";
  }

  $last = $result;
  return "Result: $result";
}

sub help
{
  return <<END
!rpn [-h|-l|<expr>] - RPN (postfix) calculator. Calculates the given expression, stack depth is "indefinite".
Switches:
  -h - This help text
  -l - List of operators and functions supported
Example use:
`!rpn 5 4 +'` = 9
`!rpn 6 4 + last *` = 90
END
}

BobboBot::Core::module::addCommand('rpn', \&BobboBot::Util::rpn::run);

1;
