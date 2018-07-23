#!/usr/bin/perl

package BobboBot::StarSonata::galaxy;

use v5.10;

use warnings;
use strict;

use POSIX;
use LWP::Simple;
use JSON;

use BobboBot::StarSonata::util;

my $universe;
my $teams;

sub update
{
  my $uni = get('https://jbobbo.net/ss/galaxies.json');
  if (defined $uni)
  {
    $universe = decode_json($uni);
  }

  my $uts = get('https://jbobbo.net/ss/teams.json');
  if (defined $uts)
  {
    $teams = decode_json($uts);
  }
  return undef;
}

sub layerName
{
  my $id = shift();

  return "Earthforce" if ($id == 0);
  return "Wild Space" if ($id == 3);
  return "Perilous Space" if ($id == 4);
  return "Subspace" if ($id == 5);
  return "Kalthi Depths" if ($id == 6);
  return "The Nexus" if ($id == 10);
  return "Color Empires" if ($id == 11);
  return "The Serengeti" if ($id == 12);
  return "Nihilite" if ($id == 13);
  return "Absolution" if ($id == 15);
  return "Enigmatic Sector" if ($id == 16);
  return "Iq' Bana" if ($id == 17);
  return "Olympus" if ($id == 18);
  return "Liberty" if ($id == 19);
  return "Subspace instances" if ($id == 20);
  return "Arctia" if ($id == 21);
  return "Vulcan" if ($id == 22);
  return "Suqq' Bana" if ($id == 23);
  return "Jungle" if ($id == 24);
  return "Captain Kidd" if ($id == 35);
  return "Holiday" if ($id == 36);

  return "Unknown layer";
}

sub sector
{
  my $g = shift();

  my $a = atan2($g->{y}, $g->{x});
  my $d = ($g->{x} ** 2.0 + $g->{y} ** 2.0) ** 0.5;

  return "central" if ($d < 0.75);

  my $PI = atan2(0, -1);
  return "west" if ($a > $PI / 8 * 7);
  return "south west" if ($a > $PI / 8 * 5);
  return "south" if ($a > $PI / 8 * 3);
  return "south east" if ($a > $PI / 8);
  return "east" if ($a > -$PI / 8);
  return "north east" if ($a > -$PI / 8 * 3);
  return "north" if ($a > -$PI / 8 * 5);
  return "north west" if ($a > $PI / 8 * 7);
  return "west";
}

sub getTeam
{
  my $g = shift();

  return $g->{owningTeam} if ($g->{owningTeam});

  return undef if (!$g->{owningTeamID});
  return $teams->{teams}{$g->{owningTeamID}}{name};
}


sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my @matches;
  my $t;
  if (length($hash->{argv}))
  {
    foreach my $g (values(%{$universe->{galaxies}}))
    {
      if ((!defined $g->{mapable} || $g->{mapable} == 1) && index($g->{name}, $hash->{argv}) != -1)
      {
        push(@matches, $g->{name});
      }
      $t = $g if ($g->{name} eq $hash->{argv});
    }
    return "No galaxies found" if (!@matches);

    if (!defined $t)
    {
      my $str = "Found " . scalar(@matches) . " matches:\n\"";
      $str .= join("\", \"", splice(@matches, 0, 10));
      if (@matches)
      {
        $str .= "\", and " . scalar(@matches) . " more.";
      }
      else
      {
        $str .= "\"";
      }
      return $str;
    }

    my $df = floor($t->{df} * 1000) / 10;
    my $team = getTeam($t);
    my $lName = layerName($t->{layer});
    my $dgCount = 0;
    my $jux = 0;
    my $con = 0;
    my $sub = 0;
    my $ai = $t->{aibases} || 0;
    my $user = $t->{userbases} || 0;
    foreach my $gid (@{$t->{links}})
    {
      my $link = $universe->{galaxies}{$gid};
      ++$dgCount if (index($link->{name}, "DG") != -1);
      ++$jux if (index($link->{name}, "Juxtaposition") != -1);
      ++$con if (index($link->{name}, "Concourse") != -1);
      ++$sub if (index($link->{name}, "Subspace") != -1);
    }
    my $str = "$t->{name} in " . sector($t) . " $lName at DF$df.\n";
    $str .= ($t->{protected} ? "Protected by " : "Owned by ") . $team . "\n" if ($team);
    $str .= "Stations:\n" if ($ai > 0 || $user > 0);
    $str .= "  AI: $ai\n" if ($ai > 0);
    $str .= "  User: $user\n" if ($user > 0);
    $str .= scalar(@{$t->{links}}) . " wormholes\n";
    $str .= "  $dgCount DGs\n" if ($dgCount > 0);
    $str .= "  $jux Juxtaposition shortcuts\n" if ($jux > 0);
    $str .= "  $con Concourse shortcuts\n" if ($con > 0);
    $str .= "  $sub Subspace shortcuts\n" if ($sub > 0);
    $str .= "Last updated: " . BobboBot::StarSonata::util::servertime($t->{lastUpdate}) . "\n";
    return $str;
  }
  return "No galaxy name provided";
}

sub help
{
  return <<END
```
$main::config->{prefix}galaxy NAME - Retrives information about a galaxy.
```
END
}

if ($INC{'BobboBot/Core/module.pm'})
{
  BobboBot::Core::module::addCommand('galaxy', \&BobboBot::StarSonata::galaxy::run);
  BobboBot::Core::event::add('PERIODIC', \&BobboBot::StarSonata::galaxy::update, 600);
}

1;
