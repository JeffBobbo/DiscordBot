#!/usr/bin/perl

package BobboBot::StarSonata::gamedata;

use v5.10;

use warnings;
use strict;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(layerName sector getTeam galColour universe findGalaxy server);

use JSON;
use LWP::Simple;

my $uni;
my $teams;
my $status;

sub update
{
  my $uData = get('https://jbobbo.net/ss/galaxies.json');
  if (defined $uData)
  {
    $uni = decode_json($uData);
  }

  my $uts = get('https://jbobbo.net/ss/teams.json');
  if (defined $uts)
  {
    $teams = decode_json($uts);
  }

  my $sts = get('https://www.starsonata.com/webapi/v1/server_status');
  if (defined $sts)
  {
    $status = decode_json($sts);
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

  return "Central" if ($d < 0.75);

  my $PI = atan2(0, -1);
  return "West" if ($a > $PI / 8 * 7);
  return "South west" if ($a > $PI / 8 * 5);
  return "South" if ($a > $PI / 8 * 3);
  return "South east" if ($a > $PI / 8);
  return "East" if ($a > -$PI / 8);
  return "North east" if ($a > -$PI / 8 * 3);
  return "North" if ($a > -$PI / 8 * 5);
  return "North west" if ($a > $PI / 8 * 7);
  return "West";
}

sub getTeam
{
  my $g = shift();

  return $g->{owningTeam} if ($g->{owningTeam});

  return undef if (!$g->{owningTeamID});
  return $teams->{teams}{$g->{owningTeamID}}{name};
}

sub galColour
{
  my $g = shift();
  return 0xBA2D6C if ($g->{layer} == 6);
  return 0xFF0000 if (index($g->{name}, "DG") != -1);
  return 0x00FF00 if (index($g->{name}, "Juxtaposition") != -1);
  return 0x007FFF if (index($g->{name}, "Concourse") != -1);
  return 0xCFCFCF if (index($g->{name}, "Subspace") != -1);
  return 0x00FF00 if ($g->{df} < 0.3);
  return 0x0000FF if ($g->{df} < 0.8);
  return 0xFF0000 if ($g->{df} < 1.3);
  return 0xBA2DB5 if ($g->{df} < 4.0);
  return 0xFFFFFF;
}

sub universe
{
  return $uni;
}

sub findGalaxy
{
  my $name = shift();
  foreach my $g (values(%{$uni->{galaxies}}))
  {
    return $g if ($g->{name} eq $name);
  }
  return undef;
}

sub server
{
  return $status->{server_status}{shift()};
}

if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::event::add('PERIODIC', \&BobboBot::StarSonata::gamedata::update, 600);
}

1;
