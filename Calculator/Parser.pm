#!/usr/bin/perl

package Calculator::Parser;

use warnings;
use strict;

use Carp;

use Exporter qw(import);
our @EXPORT = qw();

use Calculator::Token;

use Calculator::Assign;
use Calculator::Variable;
use Calculator::Compound;
use Calculator::Number;
use Calculator::UnaryOp;
use Calculator::BinOp;
use Calculator::NoOp;
use Calculator::Function;

use Data::Dumper;

sub new
{
  my $class = shift();

  my $self = {};
  $self->{lexer} = shift();
  $self->{token} = $self->{lexer}->next();

  bless($self, $class);

  return $self;
}

sub warning
{
  my $self = shift();
  $self->{lexer}->warning(@_);
}

sub error
{
  my $self = shift();
  $self->{lexer}->error(@_);
}

sub eat
{
  my $self = shift();
  my $type = shift();

  if ($self->{token}{type} == $type)
  {
    $self->{token} = $self->{lexer}->next();
  }
  else
  {
    $self->error("expected " . fromType($type) . ", got " . $self->{token}->toString());
  }
}

sub factor
{
  my $self = shift();

  my $token = $self->{token};

  if ($token->{type} == NUMBER)
  {
    $self->eat(NUMBER);
    return Calculator::Number->new($token);
  }
  elsif ($token->{type} == ADDITION)
  {
    $self->eat(ADDITION);
    my $node = Calculator::UnaryOp->new($token, $self->factor());
    return $node;
  }
  elsif ($token->{type} == SUBTRACTION)
  {
    $self->eat(SUBTRACTION);
    my $node = Calculator::UnaryOp->new($token, $self->factor());
    return $node;
  }
  elsif ($token->{type} == BITWISE_NOT)
  {
    $self->eat(BITWISE_NOT);
    my $node = Calculator::UnaryOp->new($token, $self->factor());
    return $node;
  }
  elsif ($token->{type} == L_PARENTHESIS)
  {
    $self->eat(L_PARENTHESIS);
    my $node = $self->expr();
    $self->eat(R_PARENTHESIS);
    return $node;
  }
  elsif ($token->{type} == ID)
  {
    return $self->variable();
  }
  elsif ($token->{type} == FUNCTION)
  {
    return $self->function();
  }
}

sub factorial
{
  my $self = shift();

  my $node = $self->factor();
  while ($self->{token}{type} == FACTORIAL)
  {
    my $token = $self->{token};
    $self->eat(FACTORIAL);
    $node = Calculator::UnaryOp->new($token, $node);
  }
  return $node;
}

sub power
{
  my $self = shift();

  my $node = $self->factorial();
  while ($self->{token}{type} == POWER)
  {
    my $token = $self->{token};
    $self->eat(POWER);
    $node = Calculator::BinOp->new($node, $token, $self->factorial());
  }
  return $node;
}

sub term
{
  my $self = shift();

  my $node = $self->power();

  while ($self->{token}{type} == MULTIPLY ||
         $self->{token}{type} == DIVIDE ||
         $self->{token}{type} == MODULO)
  {
    my $token = $self->{token};
    $self->eat($token->{type});
    $node = Calculator::BinOp->new($node, $token, $self->power());
  }
  return $node;
}

sub expr
{
  my $self = shift();

  my $node = $self->term();

  while ($self->{token}{type} == ADDITION ||
         $self->{token}{type} == SUBTRACTION ||
         $self->{token}{type} == BITWISE_AND ||
         $self->{token}{type} == BITWISE_OR ||
         $self->{token}{type} == BITWISE_XOR ||
         $self->{token}{type} == BITSHIFT_L ||
         $self->{token}{type} == BITSHIFT_R
        )
  {
    my $token = $self->{token};
    $self->eat($token->{type});
    $node = Calculator::BinOp->new($node, $token, $self->term());
  }
  return $node;
}

sub variable
{
  my $self = shift();

  my $node = Calculator::Variable->new($self->{token});
  $self->eat(ID);
  return $node;
}

sub function
{
  my $self = shift();

  my $func = $self->{token};
  $self->eat(FUNCTION);
  $self->eat(L_PARENTHESIS);
  my @params;
  if ($self->{token}{type} != R_PARENTHESIS)
  {
    push(@params, $self->expr());
    while ($self->{token}{type} == COMMA)
    {
      $self->eat(COMMA);
      push(@params, $self->expr());
    }
  }
  $self->eat(R_PARENTHESIS);

  return Calculator::Function->new($func, @params);
}

sub assignment_statement
{
  my $self = shift();

  my $left  = $self->variable();
  my $token = $self->{token};
  $self->eat(ASSIGN);
  my $right = $self->expr();
  my $node = Calculator::Assign->new($left, $token, $right);
  return $node;
}

sub void_statement
{
  return NoOp->new();
}

sub statement
{
  my $self = shift();

  if ($self->{token}{type} == ID && $self->{lexer}->peekToken()->{type} == ASSIGN)
  {
    return $self->assignment_statement();
  }
  else
  {
    return $self->expr();
  }
}

sub statement_list
{
  my $self = shift();

  my @statements;

  push(@statements, $self->statement());
  while ($self->{token}{type} == SEMICOLON)
  {
    $self->eat(SEMICOLON);
    push(@statements, $self->statement()) if ($self->{token}{type} != EOF);
  }

  return \@statements;
}

sub compound_statement
{
  my $self = shift();
  my $nodes = $self->statement_list();

  my $root = Calculator::Compound->new();
  foreach my $node (@{$nodes})
  {
    push(@{$root->{children}}, $node);
  }
  return $root;
}

sub program
{
  my $self = shift();
  my $node = $self->compound_statement();
  return $node;
}


sub parse
{
  my $self = shift();

  my $node = $self->program();
  if ($self->{token}{type} != EOF)
  {
    $self->error("unexpected end of input");
  }
  return $node;
}

1;
