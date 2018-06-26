#!/usr/bin/perl

package BobboBot::Fun::fact;

use warnings;
use strict;

use LWP::Simple;

sub run
{
  return help() if (index($_[0]->{argv}, '-h') != -1);

  my $page = get('http://randomfactgenerator.net/');
  if (!defined $page)
  {
    return 'Couldn\'t get the connect to the generator, maybe the server is down?';
  }
  if ($page =~ /<div id='z'>(.*?)<br\/>/) # this regex could use improving
  {
    return $1;
  }
  return 'Couldn\'t find the fact, maybe the page has changed?';
}

sub help
{
  return <<END
```
$main::config->{prefix}fact - Returns a random fact (of questionable truth), courtesy of http://randomfactgenerator.net/'
```
END
}

BobboBot::Core::module::addCommand('fact', \&BobboBot::Fun::fact::run);

1;
