#!/usr/bin/perl

package BobboBot::Fun::haiku;

use v5.10;

use warnings;
use strict;

use Lingua::EN::Syllable;

use BobboBot::Core::db;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);
  return count() if (index($hash->{argv}, '-c') != -1);

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
  my $poem = shift();
  my $author = shift();
  my $channel = shift();


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
  -h - prints this help text
  -c - counts the number of haikus known to the bot
```
END
}

BobboBot::Core::module::addCommand('haiku', \&BobboBot::Fun::haiku::run);

1;
