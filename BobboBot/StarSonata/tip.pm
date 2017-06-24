#!/usr/bin/perl

package BobboBot::StarSonata::tip;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::db;
use BobboBot::Core::permissions;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);
  return count() if (index($hash->{argv}, '-c') != -1);
  return add($hash) if (index($hash->{argv}, '--add') != -1);
  return del($hash) if (index($hash->{argv}, '--del') != -1);

  my $t;
  if ($hash->{argv} eq '')
  {
    $t = BobboBot::Core::db::tip_random();
  }
  else
  {
    $t = BobboBot::Core::db::tip_search($hash->{argv});
  }
  return "No advice for you, sorry." if (!defined $t);

  # construct the tip
  if ($t->{count} && $t->{count} > 1)
  {
    return "Tip #$t->{id}\n```$t->{tip}\n```\nFound " . ($t->{count}-1) . " other tips.";
  }
  return "Tip #$t->{id}\n```\n$t->{tip}\n```";
}

sub count
{
  my $count = BobboBot::Core::db::tip_count();
  if ($count < 0)
  {
    return "I'm sorry, but it seems I can't help you.";
  }

  return "I know of $count piece" . ($count == 1 ? '' : 's') . " of advice";
}

sub add
{
  my $hash = shift();

  return "Permission denied." if (BobboBot::Core::permissions::access($hash->{author}{id}) < 1);

  my $tip = substr($hash->{argv}, index($hash->{argv}, '--add')+5);
  if (length($tip) == 0)
  {
    return "No tip specified to add.";
  }
  if (substr($tip, 0, 1) eq ' ')
  {
    $tip = substr($tip, 1);
  }

  my $id = BobboBot::Core::db::tip_add($tip, $hash->{author}{id});
  if ($id < 0)
  {
    return "Failed to add the tip.";
  }
  return "Added `$tip` to the list of tips as tip #$id.";
}

sub del
{
  my $hash = shift();

  return "Permission denied." if (BobboBot::Core::permission::access($hash->{author}{id}) < 1);

  my $id = substr($hash->{argv}, index($hash->{argv}, '--del')+5);
  if (length($id) == 0)
  {
    return "No tip specified to delete.";
  }
  if (substr($id, 0, 1) eq ' ')
  {
    $id = substr($id, 1);
  }

  my $s = BobboBot::Core::db::tip_del($id);
  if ($s < 0)
  {
    return "Failed to remove the tip.";
  }
  return "Removed tip #$id from the list.";
}

sub help
{
    return <<END
```
$main::config->{prefix}tip - Produces a tidbit of game advice.
OPTIONS
  -h - prints this help text
  -c - prints how many tips are known
  --add TIP - adds a new tip
```
END
}

BobboBot::Core::module::addCommand('tip', \&BobboBot::StarSonata::tip::run);

1;
