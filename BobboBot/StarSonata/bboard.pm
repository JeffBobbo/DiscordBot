#!/usr/bin/perl

package BobboBot::StarSonata::bboard;

use v5.10;

use warnings;
use strict;

use JSON qw(decode_json);
use DateTime;

use BobboBot::Core::util;

my $source = '../sssave/bboard.json';
my $postto = '326719908102537237';
my $postid = '327847763351961601';

sub bboard
{
  open(my $fh, '<', $source) or return undef;
  my $src = join('', <$fh>);
  close($fh);
  return decode_json($src);
}

sub post
{
  $postid = shift() || $postid;
  my $json = bboard();

  # do nothing if there's nothing to do
  return if (!defined $json);

  my $dt = DateTime->from_epoch(epoch=>(stat($source))[9], time_zone => 'America/New_York');
  my $topost = "```Last updated: " . $dt->datetime(' ') . ' ' . ($dt->is_dst() ? 'EDT' : 'EST');

  my @posts = sort {$b->{credits} <=> $a->{credits}} @{$json->{bboard}};
  while (@posts)
  {
    my $old = $topost;
    my $e = shift(@posts);
    $topost = "$e->{note}\n$e->{name} at " . commify($e->{credits}) . " credits\n" . ("=" x 10) . "\n" . $topost;
    if (length($topost) > 2000)
    {
      $topost = $old;
      last;
    }
  }
  $topost = '```' . $topost;

  $main::discord->set_topic($postto, "Login message: " . $json->{login});
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
