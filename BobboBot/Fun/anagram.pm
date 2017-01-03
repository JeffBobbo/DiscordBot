#!/usr/bin/perl

package BobboBot::Fun::anagram;

use v5.10;

use warnings;
use strict;

my $DICT = '/usr/share/dict/british-english';

my @words;
sub run
{
  my $hash = shift();

  if ($hash->{argv} !~ /^[a-zA-Z]+$/)
  {
    return "I won't be finding anagrams of that.";
  }

  readdict() if (@words == 0);

  my @subs = (join('', sort(split('', $hash->{argv}))), sort(subwords($hash->{argv})));
  print "Found " . scalar(@subs) . " subwords\n";
  my @anagrams;
  foreach my $w (@words)
  {
    # if $w is longer than the word we're trying to find anagrams of,
    # it can't possibly be an anagram, because there aren't enough letters
    next if (length($w) > length($hash->{argv}));

    my $s = join('', sort(split('', $w)));
    foreach (@subs)
    {
      push(@anagrams, $w) if ($s eq $_);
    }
  }
#  @anagrams = sort { length($b) <=> length($a) } uniq(@anagrams);

  my @best;
  my $len = 0;
  foreach (@anagrams)
  {
    my $l = length($_);
    if ($l > $len)
    {
      @best = ($_);
      $len = $l;
    }
    elsif ($l == $len)
    {
      push(@best, $_);
    }
  }
  @best = sort { $a cmp $b } @best;
  if (@best > 0)
  {
    return "Anagrams of $hash->{argv}:\n  Longest found: `" . $best[0] . "`\n  Total found: " . scalar(@anagrams);
  }
  return "I couldn't find any anagrams of `$hash->{argv}`";
}

sub help
{
  return $main::config->{prefix} . 'anagram LETTERS - Computes the best, and how many full and partial anagrams of LETTERS up to 10 ';
}

sub readdict
{
  my $dict = shift() || $DICT;

  open(my $fh, '<', $dict) or return 0;
  @words = ();
  while (<$fh>)
  {
    chomp();
    next if (uc(substr($_, 0, 1)) eq substr($_, 0, 1)); # skip proper nouns
    next if (length($_) < 5);  # skip small words
    next if (length($_) > 10); # skip large words
    next if (index($_, "'") != -1); # skip words with apostrophes
    push(@words, lc($_));
  }
  close($fh);
  print "Read " . @words . " words\n";
  return 1;
}

sub subwords
{
  my $str = shift();
  my $min = shift() || 5;
  my @ret;
  for (my $i = 0; $i < length($str); ++$i)
  {
    my $x = substr($str, 0, $i);
    $x .= substr($str, $i+1) if ($i < length($str) - 1);
    if (length($x) >= $min)
    {
      push(@ret, join('', sort(split('', $x))));
      push(@ret, subwords($x));
    }
    ++$i while (substr($str, $i, 1) eq substr($str, $i+1, 1));
  }
  return @ret;
}


BobboBot::Core::module::addCommand('anagram', \&BobboBot::Fun::anagram::run);

1;
