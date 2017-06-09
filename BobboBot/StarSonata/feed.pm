#!/usr/bin/perl

package BobboBot::StarSonata::feed;

use v5.10;

use warnings;
use strict;

use LWP::Simple;
use XML::Simple;

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
      print "Entry: $entry->{updated}\nLast:  $last\n";
      push(@todo, $entry);
    }
  }
  if (@todo > 1)
  {
    @todo = sort {$a->{updated} cmp $b->{updated}} @todo;
    if (@todo > $maxposts)
    {
      @todo = splice(@todo, scalar(@todo)-$maxposts);
    }
  }

  my $message = '';
  foreach my $entry (@todo)
  {
    my $post = $entry->{title} . "\n```\n" . $entry->{summary} . "\n```\n" . $entry->{link}{href};
    $message .= "\n\n" if (length($message));
    $message .= $post;

    if (!defined $last || $entry->{updated} gt $last)
    {
      $last = $entry->{updated};
    }
  }

  open(my $fh, '>', 'last');
  print $fh $last;
  close($fh);
  return {channel => $postto, message => $message};
}

if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::event::add('PERIODIC', \&BobboBot::StarSonata::feed::check, 60);
}

1;
