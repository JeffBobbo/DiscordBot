#!/usr/bin/perl

package BobboBot::Fun::saidit;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::db;

sub check
{
  my $hash = shift();
  my $msg = $hash->{msg};
  my $author = $hash->{author};
  my $channel = $hash->{channel_id};

  if ($msg =~ /.*that.*what.*he.*said.*/)
  {
    BobboBot::Core::db::saidit_add($msg, $author->{id}, $channel);
    $main::discord->send_message($channel, "They've said it a total of " . BobboBot::Core::db::saidit_count() . " times.");
  }
}


if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::saidit::add('ON_MESSAGE', \&BobboBot::Fun::saidit::check);
}

1;
