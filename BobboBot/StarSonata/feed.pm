#!/usr/bin/perl

package BobboBot::StarSonata::feed;

use v5.10;

use warnings;
use strict;

use LWP::Simple;
use XML::Simple;
use DateTime::Format::ISO8601;

use Data::Dumper;

my $source = 'http://www.starsonata.com/feeds/all';
my $postto = '240887860805369856';
my $maxposts = 3;

sub download
{
  my $src = get($source);
  return unless $src;

  my $xml = XML::Simple->new()->XMLin($src, KeepRoot=>1, ForceArray=>['entry'], KeyAttr=>[]);
  return $xml;
}

sub check
{
  my $xml = download();

  my $last;
  if (open(my $fh, '<', 'last'))
  {
    $last = <$fh>;
  }

  my @todo;
  for my $entry (@{$xml->{feed}{entry}})
  {
    if (!defined $last || $entry->{updated} gt $last)
    {
      push(@todo, $entry);
    }
  }
  # sort newest first
  @todo = sort {$b->{updated} cmp $a->{updated}} @todo;
  if (@todo > $maxposts)
  {
    @todo = splice(@todo, $maxposts);
  }

  my @posts;
  while (@todo)
  {
    # pop off the end to do the oldest post first
    my $entry = pop(@todo);
    my $post = $entry->{title} . "\n```\n" . $entry->{summary} . "\n```\n" . $entry->{link}{href};
    push(@posts, {channel => $postto,
                 message => $post});

    if (!defined $last || $entry->{updated} gt $last)
    {
      $last = $entry->{updated};
    }
  }

  open(my $fh, '>', 'last');
  print $fh $last;
  close($fh);
  return @posts;
}

if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::event::add('PERIODIC', \&BobboBot::StarSonata::feed::check, 60);
}

1;
