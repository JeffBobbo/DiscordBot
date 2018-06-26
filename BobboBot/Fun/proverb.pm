#!/usr/bin/perl

package BobboBot::Fun::proverb;

use warnings;
use strict;

use LWP::Simple;

sub run
{
  return help() if (index($_[0]->{argv}, '-h') != -1);

  my $page = get('http://www.idefex.net/b3taproverbs/');
  if (!defined $page) {
    return 'Couldn\'t get the connect to the generator, maybe the server is down?';
  }
  if ($page =~ /Your random proverb is:<br\/><br\/><center><h2>((?:.|\r|\n)*?)<\/h2><\/center>/) {
    my $proverb = $1;
    $proverb =~ s/(?:\r|\n)//g;
    return $proverb;
  }
  return 'Couldn\'t find the proverb, maybe the page has changed?';
}

sub help
{
  return <<END
```
$main::config->{prefix}proverb - Returns a random proverb (of questionable sense), courtesy of http://www.idefex.net/b3taproverbs/
```
END
}

BobboBot::Core::module::addCommand('proverb', \&BobboBot::Fun::proverb::run);

1;
