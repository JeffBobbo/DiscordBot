#!/usr/bin/perl

package BobboBot::Core::event;

use v5.10;

use warnings;
use strict;

use Data::Dumper;

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

my @stash;
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

  # if we're not ready, stash
  if ($main::discord->{ready} != 1 && @send)
  {
    push(@stash, @send);
    return;
  }
  # if we have a stash, pop it
  if (@stash)
  {
    unshift(@send, @stash);
    @stash = ();
  }

  foreach my $s (@send)
  {
    next if (!defined $s);
    if (ref($s) ne 'HASH')
    {
      print "Recieved message unable to send while processing a $type event:\n";
      print "`$s`:\n";
      print Dumper($s);
      next;
    }
    $main::discord->send_message($s->{channel}, $s->{message});
  }
}

1;
