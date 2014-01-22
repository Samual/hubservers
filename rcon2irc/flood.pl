# Nexuiz rcon2irc plugin by Merlijn Hofstra licensed under GPL - flood.pl
# Place this file inside the same directory as rcon2irc.pl and add the full filename to the plugins.
# Don't forget to edit the options below to suit your needs.

{ my %fl = (
	suppress_start => 3, # after how many repeats should messages be suppressed
	flood_time => 120, # amount of seconds when messages are discarded, 0 to disable
	show_repeats => 1, # periodically send messages stating how many times a message was repeated
	repeat_echo_interval => 30, # seconds after a flood to schedule a irc notification
	mute_threshold => 0, # after how many lines will the client be muted, 0 to disable
	mute_command => "mute $id",
);

$store{plugin_flood} = \%fl; }

sub out($$@);
sub schedule($$);

sub playername_to_slot {
	my $name = shift;
	for (1 .. $store{slots_max}) {
		my $id = $store{"playerid_byslot_$_"};
		next unless $id;
		return $_ if ($name eq $store{"playernickraw_byid_$id"});
	}
	return undef;
}

[ dp => q{\001(.*?)\^7: (.*)} => sub {
	my ($nickraw, $message) = @_;
	my $nick = color_dp2irc $nickraw;
	$message = color_dp2irc $message;
	my $fl = $store{plugin_flood};
	
	if ($message eq $fl->{lastmessage}->{$nick}) { # repeated message
		if (!$fl->{flood_time} || (time() - $fl->{msgtime}->{$nick}->{$message}) <= $fl->{flood_time}) {
			$fl->{msgcount}->{$nick}->{$message}++;
		} else {
			$fl->{msgtime}->{$nick}->{$message} = time();
			return 0;
		}
		
		if ($fl->{msgcount}->{$nick} >= $fl->{suppress_start}) {
			if ($fl->{show_repeats}) {
				if (!$fl->{scheduled}->{$nick}->{$message}) {
					$fl->{scheduled}->{$nick}->{$message} = 1;
					
					# use time as a reference to obtain the right data, this isn't very secure - but it should work.
					my $time = time() + $fl->{repeat_echo_interval};
					$fl->{announce}->{int($time)} = ($nick, $message);
					
					schedule sub {
						my $fl = $store{plugin_flood};
						my @announces = sort {$a <=> $b} keys %{ $fl->{announce} };
						my ($nick, $message) = @{ $fl->{announce}->{$announces[0]} };
						
						my $count = $fl->{msgcount}->{$nick}->{$message} - $fl->{suppress_start};
						return if ($count < 2);
						out irc => 0, "PRIVMSG $config{irc_channel} :\00303* suppressed \00304$count\017 messages from $nick\017: $message";
						
						# clear this announce
						delete $fl->{announce}->{$announces[0]};
					} => $fl->{repeat_echo_interval};
				}
			}
			
			if ($fl->{mute_threshold} > 0 && $fl->{msgcount}->{$nick}->{$message} >= $fl->{mute_threshold}) {
				my $id = playername_to_slot($nickraw);
				out dp => 0, $fl->{mute_command} if (defined $id);
			}
			return -1; # do not let main rcon2irc echo
		}
		
	} else { # new message recieved
		$fl->{msgcount}->{$nick}->{$message} = 1;
		$fl->{msgtime}->{$nick}->{$message} = time();
	}
	
	$fl->{lastmessage}->{$nick} = $message;
	
	return 0;
} ],
