#!/usr/bin/perl

package BobboBot::StarSonata::boss;

use v5.10;

use warnings;
use strict;

use BobboBot::StarSonata::gamedata;

use JSON;
use DateTime;

my $bosslist = {
"Barbe Noire" => 1,
"Black Bart" => 1,
"Captain Albatross" => 1,
"Cardinal Bellarmine from Hell" => 1,
"Dark Curse" => 1,
"Georg Ohm" => 1,
"Iggy Bang" => 1,
"James Watt" => 1,
"Marco Columbus" => 1,
"Nathaniel Courthope" => 1,
"Sputty Nutty" => 1,
"UrQa'qa Qu'ishi" => 1
};
my $bosses = {};

sub load
{
  open(my $fh, '<', 'bosses.json') or return;
  my $src = join('', <$fh>);
  close($fh);

  $bosses = decode_json($src);
  return undef;
}

sub save
{
  open(my $fh, '>', 'bosses.json') or die "Failed to open bosses.json for writing: $!\n";
  print $fh encode_json($bosses);
  close($fh);
}

sub list
{
  return join("\n", keys(%{$bosslist}));
}

sub output
{
  my $name = shift();
  my $boss = shift();
  my $base = universe()->{galaxies}{$boss->{galaxy}};
  my $entrance = substr(universe()->{galaxies}{$boss->{stages}[0]}->{name}, 4 + length($base->{name}));
  my $str = "```\n$name\n  Location: $base->{name}\n  Dungeon: $entrance\n";

  if ($boss->{stages} && @{$boss->{stages}})
  {
    my @splits;
    foreach (1..scalar(@{$boss->{stages}}-1))
    {
      my $stage = $boss->{stages}[$_];
      my $g = universe()->{galaxies}{$stage};
      $g->{name} =~ / (\d+\.\d+[A-Z]?)$/;
      push(@splits, $1);
    }
    $str .= '  Splits: ' . join(', ', @splits);
  }
  return $str . "\n```";
}

sub run
{
  my $hash = shift();
  my $opts = $hash->{opts};
  return help() if ($opts->has('h'));
  return list() if ($opts->has('list'));

  my $name = $opts->argument_next();

  my $server = server('live');
  if (!defined $name)
  {
    my $str = '';
    foreach my $name (sort(keys(%{$bosslist})))
    {
      if (exists($bosses->{$name}{confirmed}) && $server->{universe_creation_time} > $bosses->{$name}{confirmed}{when})
      {
        delete($bosses->{$name}{confirmed});
      }
      if (exists($bosses->{$name}{unconfirmed}) && $server->{universe_creation_time} > $bosses->{$name}{unconfirmed}{when})
      {
        delete($bosses->{$name}{unconfired});
      }
      if (exists($bosses->{$name}) && exists($bosses->{$name}{confirmed}))
      {
        $ret .= output($name, $bosses->{$name}{confirmed});
      }
      if (exists($bosses->{$name}) && exists($bosses->{$name}{unconfirmed}))
      {
        $ret .= "Unconfirmed location:\n" . output($name, $bosses->{$name}{unconfirmed});
      }
        my $g = universe()->{galaxies}{$bosses->{$_}{confirmed}{stages}[-1]};
        $str .= $_ . " - " . $g->{name} . "\n";
      }
    }
    return $str;
  }

  return "Unknown boss, pass `--list` for a list" if (!defined $name || !exists($bosslist->{$name}));

  if ($opts->has('update'))
  {
    my $loc = $opts->option_next('update');

    my $gal = findGalaxy($loc);
    return "Unable to find galaxy. Expected the exact name of the boss galaxy, e.g., `DG Sol 0.3A`. If it was recently discovered it may take some time for me learn about it." if (!defined $gal);
    return "This galaxy is not a DG." if (substr($gal->{name}, 0, 2) ne 'DG');
    return "This galaxy is not a DG boss room." if ($gal->{name} !~ /^DG .* 0\./);

    # now build the galaxy list
    my ($base) = $gal->{name} =~ /DG (.*) 0\./;
    my ($dgid) = $gal->{name} =~ /0\.(\d+)/;
    my ($fork) = $gal->{name} =~ /([A-Z])$/;

    my $n = 0;
    my $stage = $gal;
    my @splits = (undef, $gal);
    while ($n >= 0)
    {
      # jump up a stage
      for my $l (@{$stage->{links}})
      {
        my $g2 = universe()->{galaxies}{$l};
        if ($g2->{name} eq $base)
        {
          $n = -1;
          last;
        }
        if (defined $g2 && $g2->{name} =~ /DG $base (\d+)\.$dgid/)
        {
          next if ($1 < $n);
          $n = $1;
          my $s = substr($stage->{name}, -1);
          if ($s =~ /^[A-Z]$/ && $s ne substr($g2->{name}, -1))
          {
            unshift(@splits, $g2);
          }
          else
          {
            $splits[0] = $g2;
          }
          $stage = $g2;           
          last;
        }
      }
    }

    # we've got our list, now build json
    $bosses->{$name}{unconfirmed}{stages} = [];
    $bosses->{$name}{unconfirmed}{user} = $hash->{author}{id};
    $bosses->{$name}{unconfirmed}{when} = DateTime->now(time_zone => 'America/New_York')->epoch();
    push(@{$bosses->{$name}{unconfirmed}{stages}}, $_->{ID}) foreach (@splits);
    $bosses->{$name}{unconfirmed}{galaxy} = findGalaxy($base)->{ID};

    save();
    return "Provisionally updated boss location, pending confirmation.";
  }
  elsif ($opts->has('confirm'))
  {
    return "No new location to confirm for this boss." if (!defined $bosses->{$name}{unconfirmed});
    return "You can't confirm this submission." if ($hash->{author}{id} != 167028110255063041);

    $bosses->{$name}{confirmed} = $bosses->{$name}{unconfirmed};
    delete($bosses->{$name}{unconfirmed});
    save();
    return "Confirmed boss location.";
  }
  elsif ($opts->has('reject'))
  {
    return "No new location to reject for this boss." if (!exists($bosses->{$name}{unconfirmed}));
    return "You can't reject this submission." if ($hash->{author}{id} != 167028110255063041);

    delete($bosses->{$name}{unconfirmed});
    save();
    return "Submission rejected.";
  }
}

sub help
{
  return <<END
```
$main::config->{prefix}boss [BOSS OPTIONS] - Provides all known locations of DG bosses.
The locations given are user provided, using the `--update` flag, and require confirmation. Old locations are automatically disposed of when a new universe is formed.

Arguments:
  BOSS
    Name of the boss to act on.
Options:
  list
    Returns a list of all bosses. Does not require the BOSS argument
  update LOCATION
    Updates the location of BOSS to the new LOCATION. LOCATION must be the full name of the boss's galaxy (e.g., `DG Sol 0.4C`).
  confirm
    Confirms a new location for BOSS.
  reject
    Rejects a new location for BOSS.
    
```
END
}

if ($INC{'BobboBot/Core/event.pm'})
{
  BobboBot::Core::event::add('LOAD', \&BobboBot::StarSonata::boss::load);
}
if ($INC{'BobboBot/Core/module.pm'})
{
  BobboBot::Core::module::addCommand('boss', \&BobboBot::StarSonata::boss::run);
}

1;
