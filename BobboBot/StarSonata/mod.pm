#!/usr/bin/perl

package BobboBot::StarSonata::mod;

use v5.10;

use warnings;
use strict;

use POSIX; # floor

my @MODS = qw(Miniaturized Composite Shielded Extended Scoped Dynamic Amorphous Radioactive Sleek Resonating Docktastic Intelligent Amplified Rewired Workhorse Evil Superconducting Transcendental Overclocked Forceful Gyroscopic Buffered Superintelligent Reinforced Angelic);
my $HIGH = 0;
for (my $i = 0; $i < @MODS; ++$i)
{
  $HIGH |= (1 << $i);
}

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my $flag = $hash->{argv};

  return 'Invalid flag: ' . $flag . '.' if ($flag !~ /^\d+$/);
  return 'Flag must be greater than 0.' if ($flag <= 0);
  return 'Flag exceeds the highest possible value, `' . $HIGH . '`.' if ($flag > $HIGH);

  my $result = '';
  for (my $i = 0; $i < @MODS; ++$i)
  {
    my $name = $MODS[$i];
    if ($flag & (1 << $i))
    {
      $result .= ", " if (length($result) > 0);
      $result .= $name;
    }
  }
  if (length($result) > 0)
  {
    return "Your item has the following mods: $result";
  }
  return "Your item doesn't seem to have any mods";
}

sub help
{
  return $main::config->{prefix} . 'mod (flag) - Calculates the mods on an item from the flag saved in the inventory XML under the `m` attribute.';
}

BobboBot::Core::module::addCommand('mod', \&BobboBot::StarSonata::mod::run);

1;
