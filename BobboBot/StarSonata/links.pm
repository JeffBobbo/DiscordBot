#!/usr/bin/perl

package BobboBot::StarSonata::links;

use warnings;
use strict;

my %links = (
  ticket => 'http://support.starsonata.com',
  forum => 'http://forum.starsonata.com',
  wiki => 'http://wiki.starsonata.com',
  map => 'http://starsonata.com/map'
);

sub run
{
  return help() if (index($_[0]->{argv}, '-h') != -1);

  my $arg = $_[0]->{argv};

  if ($links{lc($arg)})
  {
    return $links{lc($arg)};
  }

  return 'Links: <' . join('>, <', values(%links)) . '>.';
}

sub help
{
  return <<END
```
$main::config->{prefix}links - Returns a list of useful links.
```
END
}

BobboBot::Core::module::addCommand('links', \&BobboBot::StarSonata::links::run);

1;
