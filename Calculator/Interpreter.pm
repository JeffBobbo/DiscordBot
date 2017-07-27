#!/usr/bin/perl

package Calculator::Interpreter;

use warnings;
use strict;

use Carp;

use Exporter qw(import);
our @EXPORT = qw(CONST FUNCT);

use Calculator::Token;
use Calculator::Lexer;
use Calculator::Parser;

sub pi
{
  return atan2(0.0, -1.0);
}

use constant
{
  CONST => 0,
  FUNCT => 1
};

sub new
{
  my $class = shift();

  my $self = {};
  $self->{vtable} = {}; # variable table
  $self->{ftable} = {
    abs  =>
    {
      name => 'abs(n)',
      desc => 'Returns absolute value of `n`, e.g., `abs(-5) => 5`.',
      type => FUNCT,
      fn => sub { return abs($_[0]) }
    },
    sqrt =>
    {
      name => 'sqrt(n)',
      desc => 'Returns the square root of `abs(n)`, e.g., `sqrt(64) => 8`.',
      type => FUNCT,
      fn => sub { return sqrt(abs($_[0])) }
    },
    root =>
    {
      name => 'root(x, n)',
      desc => 'Returns the `n`th root of `abs(x)`, e.g., `root(27, 3) => 3`.',
      type => FUNCT,
      fn => sub { return abs($_[0]) ** (1.0 / $_[1]) }
    },

    # logarithms
    log   => {
      name => 'log(n)',
      desc => 'Returns the natural logarithm (base `e`) of `n`, e.g., `log(7.3890561) => 2`. See <http://perldoc.perl.org/functions/log.html>.',
      type => FUNCT,
      fn => sub { return log($_[0]) }
    },
    log2  => {
      name => 'log2(n)',
      desc => 'Returns the logarithm (base 2) of `n`, e.g., `log2(32) => 5`.',
      type => FUNCT,
      fn => sub { return log($_[0]) / log(2) }
    },
    log10 => {
      name => 'log10(n)',
      desc => 'Returns the logarithm (base 10) of `n`, e.g., `log10(1000) => 3`.',
      type => FUNCT,
      fn => sub { return log($_[0]) / log(10) }
    },
    logN  => {
      name => 'logN(n, b)',
      desc => 'Returns the logarithm (base `b`) of `n`, e.g., `logN(64, 4) => 3`.',
      type => FUNCT,
      fn => sub { return log($_[0]) / log($_[1]) }
    },
    exp  =>
    {
      name => 'exp(n)',
      desc => 'Returns `e` to the power of `n`, e.g., `exp(1) => e`. See <http://perldoc.perl.org/functions/exp.html>.',
      type => FUNCT,
      fn => sub { return exp($_[0]) }
    },

    # trig
    sin => {
      name => 'sin(x)',
      desc => 'Returns the sine of `x` (expressed in radians), e.g., `sin(pi()) => 0`.',
      type => FUNCT,
      fn => sub { return sin($_[0]) }
    },
    cos => {
      name => 'cos(x)',
      desc => 'Returns the cosine of `x` (expressed in radians), e.g., `cos(pi()) => 1`.',
      type => FUNCT,
      fn => sub { return cos($_[0]) }
    },
    tan => {
      name => 'tan(x)',
      desc => 'Returns the tangent of `x` (expressed in radians), e.g., `tan(pi()) => 0`.',
      type => FUNCT,
      fn => sub { return sin($_[0]) / cos($_[0]) }
    },
    asin  => {
      name => 'asin(x)',
      desc => 'Returns the arcsine of `x` in radians, e.g., `asin(0) => pi()`.',
      type => FUNCT,
      fn => sub { return atan2($_[0], sqrt(1 - $_[0] * $_[0])) }
    },
    acos  => {
      name => 'acos(x)',
      desc => 'Returns the arccosine of `x` in radians, e.g., `acos(1) => pi()`.',
      type => FUNCT,
      fn => sub { return atan2(sqrt(1 - $_[0] * $_[0]), $_[0]) }
    },
    atan2 => {
      name => 'atan2(y, x)',
      desc => 'Returns the arctangent of `y/x` in radians, e.g., `atan2(0, -1) => pi()`.',
      type => FUNCT,
      fn => sub { return atan2($_[0], $_[1]) }
    },

    # other
    min => {
      name => 'min(a, b)',
      desc => 'Returns the smaller value of `a` and `b`, e.g., `min(5, -10) => -10`.',
      type => FUNCT,
      fn => sub { return $_[0] < $_[1] ? $_[0] : $_[1] }
    },
    max => {
      name => 'max(a, b)',
      desc => 'Returns the larger value of `a` and `b`, e.g., `max(34, 2) => 34`.',
      type => FUNCT,
      fn => sub { return $_[0] > $_[1] ? $_[0] : $_[1] }
    },
    deg => {
      name => 'deg(x)',
      desc => 'Converts a value, `x`, expressed in radians to degrees, e.g., `deg(pi()) => 90`.',
      type => FUNCT,
      fn => sub { return $_[0] * 180.0 / pi() }
    },
    rad => {
      name => 'rad(x)',
      desc => 'Converts a value, `x`, expressed in degrees to radians, e.g., `rad(360) => pi() * 4`.',
      type => FUNCT,
      fn => sub { return $_[0] * pi() / 180.0 }
    },
    time => {
      name => 'time()',
      desc => 'Returns the number of seconds from 1970-01-01 00:00:00 UTC. See <http://perldoc.perl.org/functions/time.html>.',
      type => FUNCT,
      fn => sub { return time() }
    },

    # constants
    tau=> {
      name => 'tau()',
      desc => 'Returns `tau`, a value equal to 2 * Pi. See <https://tauday.com/tau-manifesto>.',
      type => CONST,
      fn => sub { return 2*pi() }
    },
    pi => {
      name => 'pi()',
      desc => 'Returns `pi`.',
      type => CONST,
      fn => sub { return pi() }
    },
    e  => {
      name => 'e()',
      desc => 'Returns `e`, Euler\'s number.',
      type => CONST,
      fn => sub { return exp(1) }
    },
    c  => {
      name => 'c()',
      desc => 'Returns `c`, the speed of light in a vacuum.',
      type => CONST,
      fn => sub { return 2.997924580e8 }
    },
    g  => {
      name => 'g()',
      desc => 'Returns `g`, the strength of Earth\' gravitational field at the surface.',
      type => CONST,
      fn => sub { return 9.81 }
    },
    G  => {
      name => 'G()',
      desc => 'Returns `G`, Newton\'s gravitational constant.',
      type => CONST,
      fn => sub { return 6.67384e-11 }
    }
  }; # function table

  bless($self, $class);

  return $self;
}

sub visit
{
  my $self = shift();
  my $node = shift();

  if (ref($node) eq 'Calculator::NoOp')
  {
    return $self->visitNoOp($node);
  }
  elsif (ref($node) eq 'Calculator::UnaryOp')
  {
    return $self->visitUnaryOp($node);
  }
  elsif (ref($node) eq 'Calculator::BinOp')
  {
    return $self->visitBinOp($node);
  }
  elsif (ref($node) eq 'Calculator::Number')
  {
    return $self->visitNumber($node);
  }
  elsif (ref($node) eq 'Calculator::Compound')
  {
    return $self->visitCompound($node);
  }
  elsif (ref($node) eq 'Calculator::Assign')
  {
    return $self->visitAssign($node);
  }
  elsif (ref($node) eq 'Calculator::Variable')
  {
    return $self->visitVariable($node);
  }
  elsif (ref($node) eq 'Calculator::Function')
  {
    return $self->visitFunction($node);
  }
  else
  {
    croak("Unknown visit: " . ref($node));
  }
}

sub visitNoOp
{
  my $self = shift();
  my $node = shift();
}

sub visitUnaryOp
{
  my $self = shift();
  my $node = shift();

  if ($node->{op}{type} == FACTORIAL)
  {
    my $n = $self->visit($node->{expr});
    my $r = $n;
    my $i = 1;
    $r *= $i while (++$i < $n);
    return $r;
  }
  if ($node->{op}{type} == ADDITION)
  {
    return $self->visit($node->{expr});
  }
  elsif ($node->{op}{type} == SUBTRACTION)
  {
    return -$self->visit($node->{expr});
  }
  elsif ($node->{op}{type} == BITWISE_NOT)
  {
    return ~$self->visit($node->{expr});
  }
  else
  {
    croak("bad unaryop visit");
  }
}

sub visitBinOp
{
  my $self = shift();
  my $node = shift();

  if ($node->{op}{type} == POWER)
  {
    return $self->visit($node->{left}) ** $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == ADDITION)
  {
    return $self->visit($node->{left}) + $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == SUBTRACTION)
  {
    return $self->visit($node->{left}) - $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == MULTIPLY)
  {
    return $self->visit($node->{left}) * $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == DIVIDE)
  {
    return $self->visit($node->{left}) / $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == MODULO)
  {
    return $self->visit($node->{left}) % $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == BITWISE_AND)
  {
    return $self->visit($node->{left}) & $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == BITWISE_OR)
  {
    return $self->visit($node->{left}) | $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == BITWISE_XOR)
  {
    return $self->visit($node->{left}) ^ $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == BITSHIFT_R)
  {
    return $self->visit($node->{left}) >> $self->visit($node->{right});
  }
  elsif ($node->{op}{type} == BITSHIFT_L)
  {
    return $self->visit($node->{left}) << $self->visit($node->{right});
  }
  else
  {
    croak("bad binop visit");
  }
}

sub visitNumber
{
  my $self = shift();
  my $node = shift();

  return $node->{value};
}

sub visitCompound
{
  my $self = shift();
  my $node = shift();

  my $r;
  foreach my $child (@{$node->{children}})
  {
    $r = $self->visit($child);
  }
  return $r;
}

sub visitAssign
{
  my $self = shift();
  my $node = shift();

  my $vname = $node->{left}{name};
  $self->{vtable}{$vname} = $self->visit($node->{right});
}

sub visitVariable
{
  my $self = shift();
  my $node = shift();

  my $vname = $node->{name};
  my $val = $self->{vtable}{$vname};
  if (!defined($val))
  {
    $self->error("unknown variable '$vname'.");
  }
  else
  {
    return $val;
  }
}

sub visitFunction
{
  my $self = shift();
  my $node = shift();

  my $fname = $node->{name};

  my $fn = $self->{ftable}{$fname};
  if (!defined($fn))
  {
    $self->error("unknown function '$fname'.");
  }
  else
  {
    my @p = ();
    foreach (@{$node->{params}})
    {
      push(@p, $self->visit($_));
    }
    return $fn->{fn}->(@p);
  }
}

sub error
{
  my $self = shift();
  my $node = shift();
  my $message = shift();

  croak $message;
}

sub interpret
{
  my $self = shift();
  my $source = shift();

  my $lexer = Calculator::Lexer->new($source);
  my $parser = Calculator::Parser->new($lexer);
  my $tree = $parser->parse();
  my $r = $self->visit($tree);
  return $r;
}

sub type
{
  my $self = shift();
  my $type = shift();

  my @fns;
  foreach (keys(%{$self->{ftable}}))
  {
    push(@fns, $_) if ($self->{ftable}{$_}{type} == $type);
  }

  return sort(@fns);
}

sub help
{
  my $self = shift();
  my $function = shift();

  if (defined($function))
  {
    my $fn = $self->{ftable}{$function};
    if (!defined($fn))
    {
      return 'No such function.';
    }

    return "`$fn->{name}` -- $fn->{desc}";
  }
  return undef;
}

1;
