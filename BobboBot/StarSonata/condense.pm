#!/usr/bin/perl

package BobboBot::StarSonata::condense;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;
use BobboBot::StarSonata::util;
use POSIX;

my %augRef = (
  MINOR => 0x01,
  BASIC => 0x02,
  STD   => 0x04,
  GOOD  => 0x08,
  EXC   => 0x10,
  SUP   => 0x20,
  ULT   => 0x40,
);

sub run
{
  my $hash = shift();

  my $argv = $hash->{argv};
  print $argv . "\n";
  return help() if (!defined $argv || index($argv, '-h') != -1);

  my ($minor) = $argv =~ /-m ?(\d+)/;
  my ($basic) = $argv =~ /-b ?(\d+)/;
  my ($std)   = $argv =~ /-s ?(\d+)/;
  my ($good)  = $argv =~ /-g ?(\d+)/;
  my ($exc)   = $argv =~ /-e ?(\d+)/;
  my ($sup)   = $argv =~ /-p ?(\d+)/;
  my ($ult)   = $argv =~ /-u ?(\d+)/;

  my %augCount = (
    minor => $minor || 0,
    basic => $basic || 0,
    std   => $std   || 0,
    good  => $good  || 0,
    exc   => $exc   || 0,
    sup   => $sup   || 0,
    ult   => $ult   || 0
  );
  my %old = %augCount;
  my ($dest)  = $argv =~ /-d ?(basic|std|good|exc|sup|ult)\.?/i;

  if (!$augRef{uc($dest)})
  {
    return 'Augmenter type ' . $dest . ' doesn\'t seem to exist.';
  }

  my @levels = sort {$augRef{uc($a)} <=> $augRef{uc($b)}} keys(%augCount);

  for (my $i = 0; $i < @levels; ++$i)
  {
    my $level = $levels[$i];

    next if ($augRef{uc($level)} >= $augRef{uc($dest)});

    while ($augCount{$level} >= 2)
    {
      my $num = min($augCount{$level} >> 1, 10000); # build at most half, or 10,000
      my $cost = ceil(ceil(2 * $num) * (BobboBot::StarSonata::util::discount($num) * 100)) / 100;
      $augCount{$level} -= $cost;
      $augCount{$levels[$i+1]} += $num;
    }
  }


  my $points = 0;
  while (my ($type, $num) = each (%augCount))
  {
    next if ($augRef{uc($type)} > $augRef{uc($dest)});
    $points += $augRef{uc($type)} * $num;
  }
  if ($points <= 0)
  {
    return "No combinations possible.";
  }

  my $result = floor($points / $augRef{uc($dest)});
  my $remain = $points % $augRef{uc($dest)};

  my $augs = '';
  foreach (@levels)
  {
    next if ($old{$_} <= 0);
    if (length($augs))
    {
      $augs  .= ', ';
    }
    $augs .= commify($old{$_}) . ' ' . $_ . ($old{$_} != 1 ? 's' : '');
  }


  my $return = 'Combining ' . $augs . ' will produce ' . commify($result) . ' ' . $dest . ' augmenter' . ($result != 1 ? 's.' : '.');
  if ($remain > 0)
  {
    $return .= " Leaving $remain 'augmenter points'.";
  }
  return $return;
}

sub help
{
  return <<END
```
$main::config->{prefix}condense -d TYPE AUGS [... AUGS] - Calculates, with build discount, how many augmenters of a target level you can produce from a given combination of augmenters

Flags:
  -d TYPE
    The target type you are combining, 'basic', 'std', 'good', 'exc', 'sup' and 'ult'.

AUGS:
  -[m|b|s|g|e|p] COUNT
    Quantity of augmenters at each level to use, 'm' for minor, b for basic, etc. 'p' for sup.
```
END
}

BobboBot::Core::module::addCommand('condense', \&BobboBot::StarSonata::condense::run);

1;
