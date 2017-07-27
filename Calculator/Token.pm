#!/usr/bin/perl

package Calculator::Token;

use warnings;
use strict;

use Exporter qw(import);
our @EXPORT = qw(NUMBER ADDITION SUBTRACTION MULTIPLY DIVIDE MODULO POWER FACTORIAL BITWISE_AND BITWISE_OR BITWISE_NOT BITWISE_XOR BITSHIFT_R BITSHIFT_L L_PARENTHESIS R_PARENTHESIS ID FUNCTION ASSIGN SEMICOLON COMMA EOF fromType);

my $i = 0;
use constant
{
  NUMBER        => $i++,
  ADDITION      => $i++,
  SUBTRACTION   => $i++,
  MULTIPLY      => $i++,
  DIVIDE        => $i++,
  MODULO        => $i++,
  POWER         => $i++,
  FACTORIAL     => $i++,
  BITWISE_AND   => $i++,
  BITWISE_OR    => $i++,
  BITWISE_NOT   => $i++,
  BITWISE_XOR   => $i++,
  BITSHIFT_R    => $i++,
  BITSHIFT_L    => $i++,
  L_PARENTHESIS => $i++,
  R_PARENTHESIS => $i++,
  ID            => $i++,
  FUNCTION      => $i++,
  ASSIGN        => $i++,
  SEMICOLON     => $i++,
  COMMA         => $i++,
  EOF           => $i++
};

sub new
{
  my $class = shift();
  my $self = {
    type  => shift(),
    value => shift()
  };

  bless($self, $class);

  return $self;
}

sub toString
{
  my $self = shift();

  return fromType($self->{type}, $self->{value});
}

sub fromType
{
  my $type = shift();
  my $value = shift();

  my $tStr = 'UNDEF';
  $tStr = 'NUMBER' if ($type == NUMBER);
  $tStr = 'ADDITION' if ($type == ADDITION);
  $tStr = 'SUBTRACTION' if ($type == SUBTRACTION);
  $tStr = 'MULTIPLY' if ($type == MULTIPLY);
  $tStr = 'DIVIDE' if ($type == DIVIDE);
  $tStr = 'MODULO' if ($type == MODULO);
  $tStr = 'POWER' if ($type == POWER);
  $tStr = 'FACTORIAL' if ($type == FACTORIAL);
  $tStr = 'BITWISE_AND' if ($type == BITWISE_AND);
  $tStr = 'BITWISE_OR' if ($type == BITWISE_OR);
  $tStr = 'BITWISE_NOT' if ($type == BITWISE_NOT);
  $tStr = 'BITWISE_XOR' if ($type == BITWISE_XOR);
  $tStr = 'BITSHIFT_R' if ($type == BITSHIFT_R);
  $tStr = 'BITSHIFT_L' if ($type == BITSHIFT_L);
  $tStr = 'L_PARENTHESIS' if ($type == L_PARENTHESIS);
  $tStr = 'R_PARENTHESIS' if ($type == R_PARENTHESIS);
  $tStr = 'ID' if ($type == ID);
  $tStr = 'ASSIGN' if ($type == ASSIGN);
  $tStr = 'SEMICOLON' if ($type == SEMICOLON);
  $tStr = 'COMMA' if ($type == COMMA);
  $tStr = 'EOF' if ($type == EOF);

  return "Token($tStr" . (defined($value) ? ", $value)" : ")");
}

1;
