#!/usr/bin/perl

package BobboBot::Core::util;

use v5.10;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(min max commify logN random readableTime);

use POSIX;
use Math::Random::MT;
my $mt;

sub min
{
  return $_[0] < $_[1] ? $_[0] : $_[1];
}
sub max
{
  return $_[0] > $_[1] ? $_[0] : $_[1];
}

sub commify
{
  my $x = shift();

  my ($sign, $int, $frac) = ($x =~ /^([+-]?)(\d*)(.*)/);
  my $commified = (
    reverse scalar join ',',
    unpack '(A3)*',
    scalar reverse $int
  );
  return $sign . $commified . $frac;
}

sub logN
{
  return log(shift()) / log(shift());
}

sub random
{
  my $min = shift();
  my $max = shift();

  $mt = Math::Random::MT->new(time) unless (defined $mt);

  return 0 if (!defined $min);

  if (!defined $max)
  {
    $max = $min;
    $min = 0;
  }

  my $range = 1 + $max - $min;
  my $buckets = floor((2**32-1) / $range);
  my $limit = $buckets * $range;
  # Create equal size buckets all in a row, then fire randomly towards
  # the buckets until you land in one of them. All buckets are equally
  # likely. If you land off the end of the line of buckets, try again.
  my $r;
  do
  {
    $r = $mt->irand();
  } while ($r >= $limit);

  return $min + floor($r / $buckets);
}

sub randomf
{
  my $min = shift();
  my $max = shift();

  $mt = Math::Random::MT->new(time) unless (defined $mt);

  return 0.0 if (!defined $min);

  if (!defined $max)
  {
    $max = $min;
    $min = 0.0;
  }

  return $min + $mt->rand($max-$min);
}


sub readableTime
{
  my $time = shift();
  $time = time() if (!defined $time);

  my $result = "";
  if (floor($time / (86400 * 7)))
  {
    my $val = floor($time / (86400 * 7));
    $result .= "$val week" . ($val > 1 ? "s" : "");
    $time = $time % (86400 * 7)
  }
  if (floor($time / 86400))
  {
    my $val = floor($time / 86400);
    if (length($result))
    {
      $result .= ", ";
    }
    $result .= "$val day" . ($val > 1 ? "s" : "");
    $time = $time % 86400;
  }
  if (floor($time / 3600))
  {
    my $val = floor($time / 3600);
    if (length($result))
    {
      $result .= ", "
    }
    $result .= "$val hour" . ($val > 1 ? "s" : "");
    $time = $time % 3600;
  }
  if (floor($time / 60))
  {
    my $val = floor($time / 60);
    if (length($result))
    {
      $result .= ", "
    }
    $result .= "$val minute" . ($val > 1 ? "s" : "");
    $time = $time % 60;
  }
  if ($time)
  {
    my $val = $time;
    if (length($result))
    {
      $result .= " and "
    }
    $result .= "$val second" . ($val > 1 ? "s" : "");
  }
  return $result;
}

1;
