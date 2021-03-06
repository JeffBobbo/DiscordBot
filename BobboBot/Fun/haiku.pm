#!/usr/bin/perl

package BobboBot::Fun::haiku;

use v5.10;

use warnings;
use strict;

use Lingua::EN::Syllable;

use opts::opts;
use BobboBot::Core::db;

sub run
{
  my $hash = shift();
  return help() if ($hash->{opts}->option_count('h') > 0);
  return count() if ($hash->{opts}->option_count('c') > 0);

  my $h = BobboBot::Core::db::haiku_random();
  return if (!defined $h);

  # construct the haiku
  my $ret = '```' . "\n";
  $ret .= $h->{line0} . "\n";
  $ret .= $h->{line1} . "\n";
  $ret .= $h->{line2} . "\n";
  $ret .= '```' . "\n";
  $ret .= '    -- ' . $h->{user} . ' - ' . $h->{when};
  return $ret;
}

sub count
{
  my $count = BobboBot::Core::db::haiku_count();
  if ($count < 0)
  {
    return "I couldn't seem to count any";
  }

  if ($count == 1)
  {
    # fun fact, this is a haiku
    return "There is only one hiaku of which I know. And this isn't it"
  }
  else
  {
    return "I know of $count haikus.";
  }
}

sub check
{
  my $hash = shift();
  my $poem = $hash->{msg};
  my $author = $hash->{author};
  my $channel = $hash->{channel_id};

  # haikus have to be 17 syllables
  return if (syllable($poem) != 17);

  my @words = split(' ', $poem);
  my @lines = ('', '', '');
  my @form = (5, 7, 5);
  for (my $i = 0; $i < @form && @words; ++$i)
  {
    my $count = 0;
    do
    {
      $lines[$i] .= ' ' if (length($lines[$i]));
      $lines[$i] .= shift(@words);
      $count = syllable($lines[$i]);
    }
    while ($count < $form[$i] && @words);
    return if ($count > $form[$i]);
  }
  return if (@words);

  # if we're here, we have a valid haiku, we should add it to the db
  # assuming it's not already there....
  BobboBot::Core::db::haiku_add(\@lines, $author->{id}, $channel);
}


sub help
{
    return <<END
```
$main::config->{prefix}haiku - Prints a 'random' haiku.
OPTIONS
  -c
    counts the number of haikus known to the bot
```
END
}

if ($INC{'BobboBot/Core/module.pm'})
{
  BobboBot::Core::module::addCommand('haiku', \&BobboBot::Fun::haiku::run);
}
if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::event::add('ON_MESSAGE', \&BobboBot::Fun::haiku::check);
}

1;
