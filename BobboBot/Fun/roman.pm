#!/usr/bin/perl

package BobboBot::Fun::roman;

use v5.10;

use warnings;
use strict;

sub roman
{
  my $x = shift();
  return '' if ($x < 0);
  return 'N' if ($x == 0);

  my $ret = '';
  $ret .= 'M' x ($x / 1000); # hard code this as a special one
  $x %= 1000;

  # now handle each digit separately
  my @letters = ('I', 'V', 'X', 'L', 'C', 'D', 'M');
  for (my $p = 2; $p >= 0; --$p)
  {
    my $d = ($x / (10**($p))) % 10;
    if ($d <= 3)
    {
      $ret .= $letters[$p*2] x $d;
    }
    elsif ($d == 4 || $d == 9)
    {
      my $offset = $d == 9 ? 1 : 0;
      $ret .= $letters[$p*2] . $letters[$p*2+1+$offset];
    }
    elsif ($d <= 8)
    {
      $ret .= $letters[$p*2 + 1] . $letters[$p*2] x ($d%5);
    }
  }
  return $ret;
}

sub arabic
{
  my $str = shift();
  return 0 if (!defined $str || length($str) == 0);# || $str eq 'N');

  my $ret = 0;
  my %hash = (
    'N' => 0,
    'I' => 1,
    'V' => 5,
    'X' => 10,
    'L' => 50,
    'C' => 100,
    'D' => 500,
    'M' => 1000
  );

  my $t = 0;
  for (my $i = 0; $i < length($str)-1; ++$i)
  {
    my $a = substr($str, $i, 1);
    my $b = substr($str, $i+1, 1);
    last if (!$hash{$a} || !$hash{$b}); # if we've got something that doesn't match valid characters, stop


    if ($hash{$a} < $hash{$b})
    {
      $ret -= $hash{$a};
    }
    else
    {
      $ret += $hash{$a};
    }
  }
  return $ret + $hash{substr($str, -1)};
}


sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my $value = $hash->{argv};

  if (!defined $value || length($value) == 0)
  {
    return "Nothing to convert";
  }

  # check and guess the type
  if ($value =~ /^\d+$/) # arabic to roman
  {
    return roman($value);
  }
  elsif ($value =~ /^N|[IVXLCDM]+$/) # roman to arabic
  {
    return arabic($value);
  }
  return "Invalid format";
}

sub help
{
  return <<END
```$main::config->{prefix}roman VALUE - Convert to and from Roman numerals
VALUE
  The value to convert, this can either be:
    A non-negative integer in arabic numerals (0-9).
    A Roman numeral, comprising of the letters I, V, X, L, C, D and M. N is used to represent zero
```
END
}

BobboBot::Core::module::addCommand('roman', \&BobboBot::Fun::roman::run);

1;
