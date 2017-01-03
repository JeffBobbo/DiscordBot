#!/usr/bin/perl

package BobboBot::Fun::8ball;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;
use POSIX; # floor

my @good = (
  "It is certain",
  "It is decidedly so",
  "Without a doubt",
  "Yes definitely",
  "You may rely on it",
  "As I see it, yes",
  "Most likely",
  "Outlook good",
  "Yes",
  "Signs point to yes"
);
my @neutral = (
  "Reply hazy try again",
  "Ask again later",
  "Better not tell you now",
  "Cannot predict now",
  "Concentrate and ask again"
);
my @bad = (
  "Don't count on it",
  "My reply is no",
  "My sources say no",
  "Outlook not so good",
  "Very doubtful"
);
my @responses = (\@good, \@neutral, \@bad);
my @fails = (
  "Query looks questionable",
  "Questioning if your question is a question.",
  "Put your hand up to ask a question.",
  "Have you no respect for proper etiquette?",
  "Ask properly and ye shall know.",
  "Clearly not a fan of Question Time.",
  "8ball hears you, 8ball don't care."
);

my @badQs  = qw(how why where when);
my @goodQs = qw(can is will should do would);
sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my $question = $hash->{argv};

  if (!defined $question || length($question) == 0)
  {
    return $fails[random(@fails)];
  }

  foreach (@badQs)
  {
    if (index(lc($question), $_) != -1)
    {
      return $neutral[random(@neutral)];
    }
  }
  foreach (@goodQs)
  {
    if (index(lc($question), $_) != -1)
    {
      my @pool = @{$responses[random(@responses)]};
      return $pool[random(@pool)];
    }
  }

  return $fails[random(@fails)];
}

sub help
{
  return $main::config->{prefix} . '8ball <question> - Connect to the aether via the 8ball for wisdom';
}

BobboBot::Core::module::addCommand('8ball', \&BobboBot::Fun::8ball::run);

1;
