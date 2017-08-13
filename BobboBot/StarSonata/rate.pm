#!/usr/bin/perl

package BobboBot::StarSonata::rate;

use v5.10;

use warnings;
use strict;

use BobboBot::Core::util;
use Data::Dumper;

use constant {
  EXE_BONUS => 0.22,
  BASE_INTERVAL => 10
};

my %resources = (
  'Metals'        => {factor => 1.0, tier => 0},
  'Silicon'       => {factor => 1.0, tier => 0},
  'Nuclear Waste' => {factor => 0.3, tier => 0},
  'Space Oats'    => {factor => 1.0, tier => 0},
  'Baobabs'       => {factor => 1.0, tier => 0},

  # tier 1
  'Petroleum'   => {factor => 0.000077, tier => 1},
  'Vis'         => {factor => 0.000077, tier => 1},
  'Jelly Beans' => {factor => 0.000077, tier => 1},
  'Copper'      => {factor => 0.000077, tier => 1},
  'Tin'         => {factor => 0.000077, tier => 1},
  'Silver'      => {factor => 0.000077, tier => 1},
  'Titanium'    => {factor => 0.000077, tier => 1},
  'Psion Icicles' => {factor => 0.01, tier => 1},

  # tier 2
  'Diamond'         => {factor => 0.000077, tier => 2},
  'Quantumum'       => {factor => 0.000077, tier => 2},
  'Alien Bacteria'  => {factor => 0.000077, tier => 2},
  'Enriched Nuclear Material'    => {factor => 0.1, tier => 2},
  'Fermium'         =>  {factor => 0.1, tier => 2},
  'Laconia'         =>  {factor => 0.000077, tier => 2},
  'Plasma Crystals' =>   {factor => 0.000077, tier => 2},
  'Gold'            =>  {factor => 0.000077, tier => 2},

  # tier 3
  'Energon'           =>    {factor => 0.000077, tier => 3},
  'Dark Matter'       =>     {factor => 0.000077, tier => 3},
  'Frozen Blob'       =>       {factor => 0.000077, tier => 3},
  'Adamantium'        => {factor => 0.000077, tier => 3},
  'Rubicite'          =>   {factor => 0.000077, tier => 3},
  'Platinum'          =>   {factor => 0.000077, tier => 3},
  'Ablution Crystals' =>   {factor => 0.000077, tier => 3},
  'Bacta'             =>      {factor => 0.000077, tier => 3}
);

my %extractors = (
  'Metal Drill' => {
    item => 'Metals',
    power => 1
  },
  'Advanced Metal Drill' => {
    item => 'Metals',
    power => 1
  },
  'Undead Metal Miners' => {
    item => 'Metals',
    power => 1.5
  },
  'Kikale Mzungu Extractors' => {
    item => 'Metals',
    power => 2
  },
  'Tree Cutter' => {
    item => 'Baobabs',
    power => 1
  },
  'Advanced Tree Cutter' => {
    item => 'Baobabs',
    power => 1
  },
  'Christmas Tree Cutter' => {
    item => 'Baobabs',
    power => 1.5
  },
  'Nuclear Waste Collector' => {
    item => 'Nuclear Waste',
    power => 1
  },
  'Advanced Nuclear Waste Collector' => {
    item => 'Nuclear Waste',
    power => 1
  },
  'Undead Nuclear Waste Miners' => {
    item => 'Nuclear Waste',
    power => 1.5
  },
  'Harvester' => {
    item => 'Space Oats',
    power => 1
  },
  'Advanced Harvester' => {
    item => 'Space Oats',
    power => 1
  },
  'Silicon Extractor' => {
    item => 'Silicon',
    power => 1
  },
  'Advanced Silicon Extractor' => {
    item => 'Silicon',
    power => 1
  },
  'Undead Silicon Miners' => {
    item => 'Silicon',
    power => 1.5
  },

  'Earthforce Automated Titanium Drill' => {
    item => 'Titanium',
    power => 1.15
  },
  'Earthforce Automated Deforestation Machine' => {
    item => 'Baobabs',
    power => 1.15
  },
  'Earthforce Automated Harvester' => {
    item => 'Space Oats',
    power => 1.2
  },
  'Earthforce Automated Fermium Extractor' => {
    item => 'Fermium',
    power => 1.25
  },

  'Junkyard Quantumum Extractor' => {
    item => 'Quantumum',
    power => 0.5
  },
  'Junkyard Diamond Extractor' => {
    item => 'Diamond',
    power => 0.5
  },
  'Junkyard Gold Extractor' => {
    item => 'Gold',
    power => 0.5
  },
  'Junkyard Psion Icicles Extractor' => {
    item => 'Psion Icicles',
    power => 0.5
  },
  'Junkyard Plasma Crystals Extractor' => {
    item => 'Plasma Crystals',
    power => 0.5
  },
  'Junkyard Fermium Extractor' => {
    item => 'Fermium',
    power => 0.5
  },
  'Junkyard Alien Bacteria Extractor' => {
    item => 'Alien Bacteria',
    power => 0.5
  },
  'Junkyard Laconia Extractor' => {
    item => 'Laconia',
    power => 0.5
  },
  'Junkyard Enriched Nuclear Material Extractor' => {
    item => 'Enriched Nuclear Material',
    power => 0.5
  },
  'Junkyard Copper Extractor' => {
    item => 'Copper',
    power => 0.5
  },
  'Junkyard Petroleum Extractor' => {
    item => 'Petroleum',
    power => 0.5
  },
  'Junkyard Tin Extractor' => {
    item => 'Tin',
    power => 0.5
  },
  'Junkyard Titanium Extractor' => {
    item => 'Titanium',
    power => 0.5
  },
  'Junkyard Silver Extractor' => {
    item => 'Silver',
    power => 0.5
  },
  'Junkyard Vis Extractor' => {
    item => 'Vis',
    power => 0.5
  },
  'Junkyard Rubicite Extractor' => {
    item => 'Rubicite',
    power => 0.5
  },
  'Junkyard Dark Matter Extractor' => {
    item => 'Dark Matter',
    power => 0.5
  },
  'Junkyard Platinum Extractor' => {
    item => 'Platinum',
    power => 0.5
  },
  'Junkyard Adamantium Extractor' => {
    item => 'Adamantium',
    power => 0.5
  },
  'Junkyard Energon Extractor' => {
    item => 'Energon',
    power => 0.5
  },
  'Junkyard Bacta Extractor' => {
    item => 'Bacta',
    power => 0.5
  },
  'Junkyard Frozen Blob Extractor' => {
    item => 'Frozen Blob',
    power => 0.5
  }
);

sub sortRes
{
  return -1 if ($resources{$a}->{tier} < $resources{$b}->{tier});
  return  1 if ($resources{$a}->{tier} > $resources{$b}->{tier});
  return -1 if ($a lt $b);
  return  1 if ($a gt $b);
  return  0;
}

sub resList
{
  my @res = sort sortRes keys(%resources);
  my $i = 0;
  my $added = 0;
  my $str = '';
  do
  {
    $added = 0;
    foreach (@res)
    {
      next if ($resources{$_}->{tier} != $i);
      $str .= "\nTier $i\n" if ($added == 0);
      $str .= $_ . "\n";
      ++$added;
    }
    ++$i;
  }
  while ($added > 0);

  return "```$str```";
}

sub sortExt
{
  my $ai = $extractors{$a}->{item};
  my $bi = $extractors{$b}->{item};

  return -1 if ($resources{$ai}->{tier} < $resources{$bi}->{tier});
  return  1 if ($resources{$ai}->{tier} > $resources{$bi}->{tier});
  return -1 if ($ai lt $bi);
  return  1 if ($ai gt $bi);

  return $a cmp $b; # sort by extractor name
}

sub extList
{
  my @ext = sort sortExt keys(%extractors);
  my $i = 0;
  my $added = 0;
  my $str = '';
  do
  {
    $added = 0;
    foreach (@ext)
    {
      next if ($resources{$extractors{$_}->{item}}->{tier} != $i);
      $str .= "\nTier $i\n" if ($added == 0);
      $str .= $_ . "\n";
      ++$added;
    }
    ++$i;
  }
  while ($added > 0);

  return "```$str```";
}

sub run
{
  my $hash = shift();
  return help() if (index($hash->{argv}, '-h') != -1);
  my $argv = $hash->{argv};

  return resList() if (index($hash->{argv}, '--r-list') != -1);
  return extList() if (index($hash->{argv}, '--e-list') != -1);

  my ($res) = $argv =~ /-r ?(\w+(?: \w+)*)(?: -)?/;
  my ($num) = $argv =~ /-n ?(\d+)/;
  my ($lvl) = $argv =~ /-l ?(\d+)/;
  my ($ext) = $argv =~ /-e ?(\w+(?: \w+)*)(?: -)?/;

  if (!defined $res || !$resources{$res})
  {
    return "Couldn't find the `$res` resource";
  }

  if (!defined $num || $num < 0)
  {
    return "You need some extractors to extract";
  }

  $lvl = 0 if (!defined $lvl);
  if ($lvl < 0)
  {
    return "You can't have negative Extraction Expert skill";
  }
  if ($lvl > 30)
  {
    return "Extraction Expert max: 30";
  }
  my $bonus = 1.0 + $lvl * EXE_BONUS;

  if (defined $ext)
  {
    if (!$extractors{$ext})
    {
      return "Unknown extractor item: `$ext`";
    }
    if (lc($extractors{$ext}->{item}) ne lc($res))
    {
      return "`$ext` doesn't extract `$res`";
    }
  }

  # extract exper effects the rate
  my $rate = (BASE_INTERVAL / $bonus);

  # resource factor and number of extractors effect the amount
  my $amt = $resources{$res}->{factor} * $num;
  if (defined $ext)
  {
    # power effects the amount
    $amt *= $extractors{$ext}->{power};
  }

  # total mined per hour is then:
  $amt = (1.0 / $rate) * $amt * 3600;

  my $extStr = ($ext ? $ext : "extractor") . ($num != 1 ? 's' : '');
  my $amtStr = sprintf("%.1f", $amt);
  if ($lvl > 0)
  {
    return sprintf("%d %s with ExE %d will extract %s %s per hour", $num, $extStr, $lvl, commify($amtStr), $res);
  }
  return sprintf("%d %s will extract %s %s per hour", $num, $extStr, commify($amtStr), $res);
}

sub help
{
  return <<END
```
$main::config->{prefix}rate -r RESOURCE -n NUMBER [[-l EXE] [-e EXTRACTOR]]
Calculates the base extraction rate of a resource for a given Extraction Expert level
-r RESOURCE
  The resource being extracted, full list of resources can be obtained from `~rate --r-list`

-n NUMBER
  Number of extractors being used

-l EXE
  Extraction Expert level of the owner of the station.

-e EXTRACTOR
  The extractor being used, should be your highest powered extractor.
  Not all extractors are included, the missing ones have no extra power. Full list of extractors can be obtained from `~rate --e-list`
```
END
}

BobboBot::Core::module::addCommand('rate', \&BobboBot::StarSonata::rate::run);

1;
