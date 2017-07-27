#!/usr/bin/perl

package Calculator::Function;

use warnings;
use strict;

use parent 'Calculator::AST';

use Exporter qw(import);
our @EXPORT = qw();

sub new
{
  my $class = shift();

  my $self = {};
  $self->{token} = shift();
  $self->{name} = $self->{token}{value};
  $self->{params} = [];
  while (my $p = shift())
  {
    push(@{$self->{params}}, $p);
  }

  bless($self, $class);

  return $self;
}

1;
