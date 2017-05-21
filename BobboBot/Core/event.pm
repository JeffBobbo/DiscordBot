#!/usr/bin/perl

package BobboBot::Core::event;

use v5.10;

use warnings;
use strict;

my %events = (
  LOAD => [], # after modules are loaded
  CONNECT => [], # after "READY"
  DISCONNECT => [], # when we DC, whenever that is
  PERIODIC => [], # periodically called every so often

  START => [], # ??
  STOP => [], # ??
  RESTART => [], # ??

  ON_MESSAGE => [] # when a user sends a message, for commands that run background stuff, e.g., haiku
);

sub add
{
  my $type = shift();
  my $func = shift();
  my $opt  = shift();

  if (!$events{$type})
  {
    die "Tried to register for non-existing event: " . $type . " " . $func . "\n";
  }

  push(@{$events{$type}}, {function => $func, opt => $opt});
}

sub run
{
  my $type = shift();
  my $data = shift();

  my @send = ();
  if ($type eq 'LOAD' || $type eq 'CONNECT' || $type eq 'DISCONNECT' ||
      $type eq 'START' || $type eq 'STOP' || $type eq 'RESTART' ||
      $type eq 'ON_MESSAGE')
  {
    foreach my $e (@{$events{$type}})
    {
      push(@send, $e->{function}($data));
    }
  }
  elsif ($type eq 'PERIODIC')
  {
    foreach my $e (@{$events{$type}})
    {
      my $now = time();
      if (!$e->{last} || $now - $e->{last} > $e->{opt})
      {
        push(@send, $e->{function}($data));
        $e->{last}= $now;
      }
    }
  }
}

1;
