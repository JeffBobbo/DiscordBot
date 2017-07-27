#!/usr/bin/perl

package Calculator::BinOp;

use warnings;
use strict;

use parent 'Calculator::AST';

use Exporter qw(import);
our @EXPORT = qw();

sub new
{
  my $class = shift();

  my $self = {};
  $self->{left}  = shift();
  $self->{op}    = shift();
  $self->{right} = shift();
  $self->{token} = $self->{op};

  bless($self, $class);

  return $self;
}

1;
