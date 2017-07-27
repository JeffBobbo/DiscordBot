#!/usr/bin/perl

package Calculator::NoOp;

use warnings;
use strict;

use parent 'Calculator::AST';

use Exporter qw(import);
our @EXPORT = qw();

sub new
{
  my $class = shift();

  my $self = {};

  bless($self, $class);

  return $self;
}

1;
