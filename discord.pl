#!/usr/bin/perl

use v5.10;

use strict;
use warnings;

use JSON;

#use Net::Discord;
use Mojo::Discord;
use Mojo::IOLoop;

use Data::Dumper;

use BobboBot::Core::module;
use BobboBot::Core::db;
use BobboBot::Core::help;
use BobboBot::Core::list;

$|++;

print "Loading configuration data\n";
our $config = loadConfig('config.json');
if (!$config->{discord}{token} || length($config->{discord}{token}) == 0)
{
  die "No Discord token provided, please add it to config.json\n";
}
if (!$config->{database}{db_driver} || length($config->{database}{db_driver}) == 0)
{
  die "No db driver given, please add it to config.json\n";
}
if (!$config->{database}{db_name} || length($config->{database}{db_name}) == 0)
{
  die "No db name given, please add it to config.json\n";
}


print "Initialising DB\n";
BobboBot::Core::db::init();

# Discord vars
my $discord_callbacks =         # Tell Discord what functions to call for event callbacks. It's not POE, but it works.
{
  READY          => \&on_ready,
  MESSAGE_CREATE => \&on_message_create
};
my %self;   # We'll store some information about ourselves here from the Discord API

# Create a new Mojo::Discord object, passing in the token, application name/url/version, and your callback functions as a hashref
my $discord = Mojo::Discord->new(
  token     => $config->{discord}{token},
  name      => $config->{discord}{name},
  url       => $config->{discord}{url},
  version   => $config->{discord}{version},
  callbacks => $discord_callbacks,
  verbose   => 0,
  reconnect => 1
);

print "Loading modules\n";
BobboBot::Core::module::loadModules();

print "Connecting\n";
# Establish the web socket connection and start the listener
$discord->init();
#$discord->connect();

# start the idle loop
Mojo::IOLoop->start unless (Mojo::IOLoop->is_running);

exit();


sub loadConfig
{
  open(my $fh, '<', $_[0]);
  my @lines = <$fh>;
  close($fh);
  return decode_json(join('', @lines)) || {};
}

# Callback for on_ready event, which contains a bunch of useful information
# We're only going to capture our username and user id for now, but there is a lot of other info in this structure.
sub on_ready
{
  my ($hash) = @_;

  $self{username} = $hash->{user}{username};
  $self{id} = $hash->{user}{id};
  $self{general} = $hash->{guilds}->[0]->{id};

  print "READY\n";

  #$discord->status_update({'game' => ''});
};

# "MESSAGE_CREATE" is the event generated when someone sends a text chat to a channel.
# We'll capture some info about the author, the message contents, and the list of @mentions so we can see if we need to respond to something.
# The incoming structure uses User IDs instead of Names in the content, so we'll swap those around so Hailo can generate a meaningful reply.
# Finally, if we were mentioned at the start of the line, we'll have Hailo generate a reply to the text and send it back to the channel.
sub on_message_create
{
  my $hash = shift;

  # Store a few things from the hash structure
  my $author = $hash->{author};
  my $msg = $hash->{content};
  my $channel = $hash->{channel_id};
  my @mentions = @{$hash->{mentions}};

  BobboBot::Core::db::user($author);

  # Loop through the list of mentions and replace User IDs with Usernames.
  foreach my $mention (@mentions)
  {
    my $id = $mention->{id};
    my $username = $mention->{username};

    # Replace the mention IDs in the message body with the usernames.
    $msg =~ s/\<\@$id\>/$username/g;
  }


  print Dumper($hash) if ($author->{id} != $self{id});
  if (substr($msg, 0, 1) eq $config->{prefix})
  {
    my ($command, $args) = $msg =~ /^$config->{prefix}([^\s]+)\s?(.*)/s;
    $hash->{command} = $command;
    $hash->{argv} = $args;

    if ($command eq 'stop')
    {
      if ($author->{username} eq 'Bobbo')
      {
        $discord->disconnect("Goodbye cruel world!");
      }
      else
      {
        $discord->send_message($channel, "Respect mah authoritah!");
      }
    }
    elsif (!$author->{bot} && $channel != $self{general}) # ignore bots, ignore the general channel for commands
    {
      $discord->start_typing($channel); # this could take some time
      my $reply = BobboBot::Core::module::execute($command, $hash);
      BobboBot::Core::db::command_use($command, $args, $author, $channel);
      $discord->send_message($channel, $reply) if (defined $reply && length($reply));
    }
  }
  else
  {
    BobboBot::Fun::haiku::check($msg, $author, $channel);
  }
}
