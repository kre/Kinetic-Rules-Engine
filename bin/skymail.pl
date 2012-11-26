#!/usr/bin/perl -w

use lib qw(
  /web/lib/perl
  /web/etc
);
#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc. 
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
use strict;
use Carp;

use Log::Log4perl qw(get_logger :levels);
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;
use MIME::Base64;
use URI::Escape;
use Data::Dumper;
use Getopt::Std;
use Kynetx::Util qw(:all);
use Kynetx::Configure;
use Kynetx::Directives qw(
  set_options
);
use Kynetx::Json qw(
  get_items
);
use Kynetx::Events::Primitives;
use Kynetx::Persistence::KToken;
use Kynetx::MongoDB;
use Kynetx::Environments qw(
	empty_rule_env
	lookup_rule_env
	extend_rule_env
);
use Kynetx::Modules::HTTP qw(mk_http_request);
use DateTime::Format::ISO8601;

Kynetx::Configure::configure();
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

my $run_mode = Kynetx::Configure::get_config('RUN_MODE');
my $event_host = Kynetx::Configure::get_config($run_mode)->{'EVAL_HOST'};

$logger->info("Run mode: $run_mode");
$logger->info("Event host: $event_host");

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

use vars qw(
  %opt
);
use Net::SMTP::Server;
use Net::SMTP::Server::Client;
use Email::MIME;
use POSIX qw(
:sys_wait_h
_exit
);

use constant E_DOM  => "email";
use constant E_NAME => "received";

my $opt_string = 'hv:';
getopts( "$opt_string", \%opt );
&usage() if $opt{'h'};

if ( exists $opt{'v'} && $opt{'v'} eq '2' ) {
    Log::Log4perl->easy_init($TRACE);
    $logger->trace("Verbose output enabled");

} elsif ( exists $opt{'v'} && $opt{'v'} eq '1' ) {
    Log::Log4perl->easy_init($DEBUG);
    $logger->debug("Detailed output enabled: ");
} elsif ( exists $opt{'v'} && $opt{'v'} eq '0' ) {

    # no logging
} elsif ( exists $opt{'v'} ) {
    usage("Requires a log level: $0 -v <0 | 1 | 2>");
}


my $mail_server = new Net::SMTP::Server('localhost',25) ||
	croak("Unable to start mail server: $!\n");

my %children;
sub REAPER {
	my $child;
	while ($child = waitpid(-1,WNOHANG)) {
    	$children{$child} = $?;
    }
	$SIG{CHLD} = \&REAPER;
}
$SIG{CHLD} = \&REAPER;

while (my $conn= $mail_server->accept) {
	my $client = new Net::SMTP::Server::Client($conn) ||
		croak("Unable to create client connection: $!\n");
				
	my $cpid = fork();
	$children{$cpid} = 1;
	unless ($cpid) {
		my $pid = $$;
		$logger->debug("Connection on port 25 ($pid)");
		$client->process();
		my $source = $client->{FROM};
		my $msg = $client->{MSG};
		my $parm = parse_event_mail($msg);
		foreach my $email_token (@{$client->{TO}}) {
			$logger->debug("Parse email: $email_token");
			$email_token =~ s/^<?(.+)>?$/$1/;
			my ($to) = split(/\@/,$email_token);
			my ($namespace,$token,$domain,$name) = split(/\./,$to);
			unless (defined $token && check_token($token)){
				$token |= "";
				$logger->debug("Invalid token ($token)");
				next;
			};
			$logger->debug("verified: $token");
			my $ev = build_event($namespace,$token,$domain,$name,$parm);
			if ($ev) {
				mediate($ev);
			}
		}
		
		_exit(0);
	}
	
	$logger->debug("Connection passed to process: $cpid");
}

sub build_event {
	my ($namespace,$token,$domain,$name,$parm) = @_;
	my $logger = get_logger();
	$logger->debug("Build event from: $namespace,$token,$domain,$name", sub {Dumper($parm)});
	my $event = Kynetx::Events::Primitives->new();
	$domain = $domain || E_DOM;
	$name = $name || E_NAME;
	$event->generic($domain,$name);
	my @vars = ('_namespace_','_token_');
	my @vals = ($namespace,$token);
	if (defined $parm) {
		if (ref $parm eq "HASH") {
			foreach my $key (keys %{$parm}) {
				push(@vals,$parm->{$key});
				push(@vars,$key);
			}
		} elsif (ref $parm eq "ARRAY") {
			my $hash;
			foreach my $struct(@$parm) {
				my ($k,$v) = each(%{$struct});
				if (defined $hash->{$k}) {
					# Assumes strings, will need to flesh out if we start passing complicated multiparts
					$hash->{$k} = $hash->{$k} . $v;
				} else {
					$hash->{$k} = $v;
				}
			}
			push(@vals,values(%{$hash}));
			push(@vars,keys(%{$hash}));
			
		}
	}
	$event->set_vars($event->guid(),\@vars);
	$event->set_vals($event->guid(),\@vals);
	$logger->trace("Created event: ", sub {Dumper($event)});
	return $event;
}

sub mediate {
	my ($ev) = @_;
	my $event_env = empty_rule_env();
	$event_env = extend_rule_env($ev->get_vars($ev->guid()),$ev->get_vals($ev->guid()),$event_env);
	my $namespace = lookup_rule_env('_namespace_',$event_env);
	
	# allow mediator to alter behavior based on namespace
	if ($namespace) {
		#$logger->debug("Received event: ", sub { Dumper($ev)});
		to_post($ev,$event_env);			
	}
	
}

#  Maybe after seeing how this is used, I will be able to tell if I want to 
# use the HTTP module to make the request
sub to_post {
	my ($ev,$event_env) = @_;
	my $logger = get_logger();	
	my $domain = $ev->get_domain();
	my $name = $ev->get_type();
	my $token = lookup_rule_env('_token_',$event_env);
	my $uri = mk_uri($domain,$name,$token);
	my $creds = {};
	my $params = get_params_from_event($ev);
	my $headers = {};
	my $response = Kynetx::Modules::HTTP::mk_http_request('POST', $creds,$uri,$params,$headers);
	$logger->trace("Post response: ", sub {Dumper($response)});
}

sub mk_uri {
	my ($domain,$name,$token) = @_;
	my $logger = get_logger();
	my $pid = $$;
	my $uri = join("/",('http:/',$event_host,'sky/event',$token,$pid,$domain,$name));
	$logger->debug("Use URL: $uri");
	return $uri;
}


# in case we want to do some thing if we find a bad token
sub check_token {
	my ($token) = @_;
	my $logger = get_logger();
	$logger->debug("Check ($token)");
	if (! Kynetx::Persistence::KToken::is_valid_token($token)) {
		$logger->debug("Bad token");
		return 0;
	}
	return 1;
}

sub get_params_from_event {
        my ($ev) = @_;
        my $params = {};
        my $keys = $ev->get_vars($ev->guid());
        my $values = $ev->get_vals($ev->guid());

        for (my $i = 0; $i < @$keys; $i++){
                $params->{@$keys[$i]} = @$values[$i];
        }

        return $params;
}



sub parse_event_mail {
	my ($msg) = @_;
	my $email = Email::MIME->new($msg);
	my @p=();
	foreach my $epart ($email->parts()) {
		$logger->debug("Part: ", $epart->content_type);
		my $ct = $epart->content_type || "";
		my $payload = $epart->body;
		if ($ct =~ m/text\/plain/i ) {
			$logger->trace("Text", $epart->body);
			my $pair = {
				$ct => $payload
			};
			push (@p,$pair);
		}elsif ($ct =~ /application\/x-www-form-urlencoded/) {
			my @pairs = split(/&/,$payload);
			foreach my $pair (@pairs) {
				my ($k,$v) = split(/=/,$pair);
				my $dpair = {
					($k) => uri_unescape($v)
				};
				push(@p,$dpair);
			}
		} elsif ($ct =~ /image\/.+/) {
			$logger->debug("Received image: ",$epart->filename);
			$logger->trace("body: ",$epart->body_raw);
			$logger->trace("Part: ", $epart->content_type);
			$logger->trace("Struct: ", $epart->debug_structure());
#			my $b64decode = MIME::Base64::decode_base64($epart->body);
#			open my $tmp, '+>', "/tmp/foo$$";
#			print $tmp $b64decode;
#			close $tmp;
			#my $b64encode = MIME::Base64::encode_base64($epart->body);
			#$logger->debug("Base 64: ",sub {Dumper($b64encode)});
		}
		
		
	}
	return \@p;
}

sub mediator {
	my ($token,$domain,$name,$payload) = @_;
}


sub usage {
    my ($header) = @_;
    print STDERR <<EOF;
$header

Manage Email event handler interface

Options:

    -h                          : display this message

EOF
    exit;
}
