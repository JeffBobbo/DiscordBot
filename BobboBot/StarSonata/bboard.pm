#!/usr/bin/perl

package BobboBot::StarSonata::bboard;

use v5.10;

use warnings;
use strict;

use DateTime;
use LWP::Simple;
use XML::Simple;

use BobboBot::Core::util;

my $source = 'http://starsonata.com/ss_api/bboard.xml';
my $postto = '326719908102537237';
my $postid = '327847763351961601';

sub bboard
{
  return XML::Simple->new->XMLin(get($source), KeepRoot => 1, ForceArray => ['ENTRY']);
}

sub post
{
  $postid = shift() || $postid;
  my $bboard = bboard();

  # do nothing if there's nothing to do
  return if (!defined $bboard);

  my $dt = DateTime->now(time_zone => 'America/New_York');
  my $topost = "```Last updated: " . $dt->datetime(' ') . ' ' . ($dt->is_dst() ? 'EDT' : 'EST');

  my @posts = sort {$b->{credits} <=> $a->{credits}} @{$bboard->{BBOARD}{ENTRY}};
  while (@posts)
  {
    my $old = $topost;
    my $e = shift(@posts);
    $topost = "$e->{notice}\n$e->{author} at " . commify($e->{credits}) . " credits\n" . ("=" x 10) . "\n" . $topost;
    if (length($topost) > 2000)
    {
      $topost = $old;
      last;
    }
  }
  $topost = '```' . $topost;

  my $globals = XML::Simple->new->XMLin(get('http://starsonata.com/ss_api/globals.xml'), KeepRoot => 1, SuppressEmpty => '');
  my $dawn = DateTime->from_epoch(epoch => $globals->{GLOBALS}{UNISTART}, time_zone => 'America/New_York');
  my $topic = "Dawn of time: " . $dawn->datetime(' ') . ' ' . ($dawn->is_dst() ? 'EDT' : 'EST');
  if ($globals->{GLOBALS}{LOGIN_MSG} ne '')
  {
    $topic .= ". Login message: " . $globals->{GLOBALS}{LOGIN_MSG};
  }
  $main::discord->set_topic($postto, $topic);
  if (defined $postid)
  {
    $main::discord->edit_message($postto, $postid, $topost);
  }
  else
  {
    $main::discord->send_message($postto, $topost);
  }
  return;
}

sub check
{
  #$main::discord->get_message($postto, {limit => 1}, sub { print Dumper($_[0]); post($_[0]->[0]->{id}); });
  post();
  return;
}

if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::event::add('PERIODIC', \&BobboBot::StarSonata::bboard::check, 60);
}

1;
