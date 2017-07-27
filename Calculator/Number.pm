#!/usr/bin/perl

package Calculator::Number;

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
  $self->{value} = $self->{token}->{value}+0; # bit hack, but forces perl to treat these as numbers instead of strings

  bless($self, $class);

  return $self;
}

1;
