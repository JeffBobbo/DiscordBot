#!/usr/bin/perl

package BobboBot::Fun::urbandict;

use v5.10;

use warnings;
use strict;

use WebService::UrbanDictionary;
use WebService::UrbanDictionary::Term;
use WebService::UrbanDictionary::Term::Definition;

use URI::Encode qw(uri_encode);

sub run
{
  my $hash = shift();

  my $phrase = $hash->{argv};
  if (!defined $phrase || length($phrase) == 0)
  {
    return 'Nothing to look up.';
  }

  if (index($phrase, '-h') != -1)
  {
    return help();
  }

  my $ud = WebService::UrbanDictionary->new();
  my $result = $ud->request(uri_encode($phrase, {encode_reserved => 1}));
  my @defs = $result->definition();

  my $best = 0;
  for (my $i = 0; $i < @defs; ++$i)
  {
    my $netThumbs = $defs[$i]->{thumbs_up} - $defs[$i]->{thumbs_down};
    if ($netThumbs > $defs[$best]->{thumbs_up} - $defs[$best]->{thumbs_down})
    {
      $best = $i;
    }
  }

  my $def = $defs[$best];
  if (!defined $def || length($def->{definition}) == 0)
  {
    return 'No definitions found for `' . $phrase . '`.';
  }

  my $ret = "$def->{word}:\n```\n$def->{definition}```";
  $ret .= "+$def->{thumbs_up}/-$def->{thumbs_down}\n";
  $ret .= "Submitted by: $def->{author}\n";
  $ret .= "$def->{permalink}";

  return $ret;
}

sub help
{
  return $main::config->{prefix} . 'urban (word) - Look up a word on urban dictionary';
}

BobboBot::Core::module::addCommand('urban', \&BobboBot::Fun::urbandict::run);

1;
