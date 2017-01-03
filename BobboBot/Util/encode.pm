#!/usr/bin/perl

package BobboBot::Util::encode;

use v5.10;

use warnings;
use strict;

use Digest::MD5 qw(md5_hex);
use Digest::SHA qw(sha256_hex sha512_hex);
use Digest::CRC qw(crc32_hex);
use MIME::Base64;

sub rot13
{
  my $s = shift();
  $s =~ tr[a-zA-Z][n-za-mN-ZA-M];
  return $s;
}
sub caeser
{
  my $s = shift();
  $s =~ tr[a-zA-Z][d-za-cD-ZA-C];
  return $s;
}

my %algorithms = (
  rot13  => \&rot13,
  caeser => \&caeser,
  sha256 => \&sha256,
  sha512 => \&sha512,
  crc    => \&crc32,
  base64 => \&encode_base64
);

sub run
{
  my $hash = shift();
  my $argv = $hash->{argv};
  return help() if (index($argv, '-h') != -1);

  my $alg = substr($argv, 0, index($argv, ' '), '');

  if (!defined $alg || length($alg) == 0)
  {
    return "No algorithm given";
  }
  if ($algorithms{lc($alg)})
  {
    return $algorithms{lc($alg)}->($argv);
  }
  else
  {
    return "Unknown algorithm: $alg";
  }
}

sub help
{
  my $list = join(', ', sort(keys(%algorithms)));
  return <<END
```
$main::config->{prefix}encode ALGORITHM DATA
Encode the given DATA with the provided ALGORITHM
ALGORITHM
  The algorithm to use to encode the supplied data.
  One of the following: $list.
DATA
  The data to encode
```
END
}

BobboBot::Core::module::addCommand('encode', \&BobboBot::Util::encode::run);

1;
