#!/usr/bin/perl

package BobboBot::StarSonata::galaxy;

use v5.10;

use warnings;
use strict;

use POSIX;
use URI::Encode qw(uri_encode);

use BobboBot::StarSonata::gamedata;

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);

  my $search = lc($hash->{argv});
  my @matches;
  my $t;
  if (length($hash->{argv}))
  {
    foreach my $g (values(%{universe()->{galaxies}}))
    {
      if ((!defined $g->{mapable} || $g->{mapable} == 1) && index(lc($g->{name}), $search) != -1)
      {
        push(@matches, $g->{name});
      }
      $t = $g if (lc($g->{name}) eq $search);
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
      my $link = universe()->{galaxies}{$gid};
      ++$dgCount if (index($link->{name}, "DG") != -1);
      ++$jux if (index($link->{name}, "Juxtaposition") != -1);
      ++$con if (index($link->{name}, "Concourse") != -1);
      ++$sub if (index($link->{name}, "Subspace") != -1);
    }

    my $embed = {
      title => $t->{name},
      type => 'rich',
      description => sector($t) . " $lName, DF $df",
      url => "https://www.starsonata.com/map/index.html?target=" . uri_encode($t->{name}),
      color => galColour($t),
      #timestamp => BobboBot::StarSonata::util::iso8601($t->{lastUpdate}),
      footer => {text => "Last updated: " . BobboBot::StarSonata::util::servertime($t->{lastUpdate})}
    };
    $embed->{thumbnail} = {url => "https://www.starsonata.com/images/team_flags/game/" . $t->{owningTeamID}, width => 20, height => 14} if ($t->{owningTeamID});
    my @fields;
    push(@fields, {name => "Ownership", value => $team, inline => \1}) if ($team);
    push(@fields, {name => "Protected", value => $t->{protected} ? "Yes" : "No", inline => \1}) if ($team);

    push(@fields, {name => "Stations", value => $ai + $user, inline => \0}) if ($ai > 0 || $user > 0);
    push(@fields, {name => "AI", value => $ai, inline => \1}) if ($ai > 0);
    push(@fields, {name => "User", value => $user, inline => \1}) if ($user > 0);

    push(@fields, {name => "Wormholes", value => scalar(@{$t->{links}}), inline => \0});
    push(@fields, {name => "Dungeons", value => $dgCount, inline => \1}) if ($dgCount > 0);
    push(@fields, {name => "Juxtapositions", value => $jux, inline => \1}) if ($jux > 0);
    push(@fields, {name => "Concourses", value => $con, inline => \1}) if ($con > 0);
    push(@fields, {name => "Subspace", value => $sub, inline => \1}) if ($sub > 0);

    $embed->{fields} = \@fields;

    return {content => '', embed => $embed};
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
}

1;
