#!/usr/bin/perl

package BobboBot::Core::module;

use v5.10;

use warnings;
use strict;

use JSON;

my %commands;
my %aliases;

sub loadModules
{
  my $file = shift() || 'modules.json';

  my $text = '';
  if (open(my $fh, '<', $file))
  {
    my @lines = <$fh>;
    close($fh);
    $text = join('', @lines);
  }

  my $json = decode_json($text) || {};
  moduleTree($json);
}

sub moduleTree
{
  my $json = shift();
  my $path = shift() || '';

  if (ref($json) eq 'HASH')
  {
    my @keys = keys %{$json};
    foreach my $key (@keys)
    {
      my $npath = $path . $key;
      moduleTree($json->{$key}, $npath . '/');
    }
  }
  if (ref($json) eq 'ARRAY')
  {
    foreach my $e (@{$json})
    {
      my $mod = $path . $e . '.pm';
      require $mod;
    }
  }
}

sub addCommand
{
  my $name = shift();
  my $function = shift();

  $commands{$name} = $function;
}

sub commandList
{
  return sort(keys(%commands));
}

sub lookup
{
  my $a = shift();
  return $aliases{$a} || $a;
}

sub valid
{
  my $c = shift();

  return 2 if ($aliases{$c});
  return 1 if ($commands{$c});
  return 0;
}

sub execute
{
  my $c = shift();

  if (!valid($c)) # if it's not valid, complain
  {
    return "Unknown command: $c.";
  }

  # look it up now, to resolve the alias
  my $r = lookup($c);

  # punch it
  return $commands{$r}->(@_);
}

1;
