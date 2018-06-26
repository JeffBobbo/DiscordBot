#!/usr/bin/perl

package BobboBot::StarSonata::faq;

use v5.10;

use warnings;
use strict;

use Data::Dumper;

use BobboBot::Core::db;
use BobboBot::Core::permissions;

sub run
{
  my $hash = shift();
  return help() if ($hash->{opts}->option_count('h') > 0);
  return count() if ($hash->{opts}->option_count('c') > 0);

  if ($hash->{opts}->option_count('add') || $hash->{opts}->option_count('del'))
  {
    return "Permission denied." if (BobboBot::Core::permissions::access($hash->{author}{id}) < 1);
    
    my $name = $hash->{opts}->option_next('add') || $hash->{opts}->option_next('del');
    if ($hash->{opts}->option_count('add') > 0)
    {
      my $text = join(' ', @{$hash->{opts}->{arguments}});
      $text = substr($text, 1, -1) if ($text =~ /^['"].*['"]$/);

      my $success = BobboBot::Core::db::faq_add($name, $text, $hash->{author}{id});
      if ($success)
      {
        return "Added `$name` to the list of FAQs";
      }
      return "Failed to add $name to the list of FAQs.";
    }
    else
    {
      my $removed = BobboBot::Core::db::faq_del($name);
      if (defined $removed)
      {
        print Dumper($removed->{text});
        return "Successfully removed `$removed->{name}` from the list of FAQs.\n$removed->{text}";
      }
      return "Failed to remove $name fromt he list of FAQs.";
    }
  }
  else
  {
    my $fname = $hash->{opts}->argument_next();
    return 'No FAQ entry found.' if (!defined $fname);

    my $faq = BobboBot::Core::db::faq_get($fname);
    return 'No FAQ entry found.' if (!defined $faq);
    return <<END
$faq->{name}:
$faq->{text}
END
}
}

sub count
{
  my $count = BobboBot::Core::db::faq_count();
  return "I know of $count FAQ" . ($count == 1 ? '' : 's');
}

sub help
{
    return <<END
```
$main::config->{prefix}faq - Produces a tidbit of game advice.
OPTIONS
  -h - prints this help text
  -c - prints how many faqs are known
  --add NAME FAQ - adds a new faq
  --del NAME - deletes a faq
```
END
}

BobboBot::Core::module::addCommand('faq', \&BobboBot::StarSonata::faq::run);

1;
