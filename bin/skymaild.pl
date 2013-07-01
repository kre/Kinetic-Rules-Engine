#!/usr/bin/perl -w
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
use lib qw(
  /web/lib/perl
  /web/etc
);
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
use DateTime;
use Cache::Memcached;
use Schedule::Cron;

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
use Kynetx::Persistence::SchedEv;
use Kynetx::MongoDB;
use Kynetx::Memcached;
use Kynetx::Environments qw(
	empty_rule_env
	lookup_rule_env
	extend_rule_env
);
use Kynetx::Modules::HTTP qw(mk_http_request);
use Kynetx::Predicates::Time;
use DateTime::Format::ISO8601;

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
use Proc::PID::File;
use Proc::Daemon;
use File::Spec;


use constant E_DOM  => "email";
use constant E_NAME => "received";

use constant LOG_DIR => '/var/log/skymail';
use constant LOG_FILE => 'skymail.log';
use constant PIDDIR => "/var/run";

our $ME = $0; $ME =~ s|.*/||; $ME =~ s|\.pl||;

sub dienice ($);
sub main ();
Kynetx::Configure::configure();
our $KOBJ_ROOT = Kynetx::Configure::get_config('KOBJ_ROOT');
our $PIDDIR = "/var/run";
our $PIDFILE = PIDDIR . "/$ME.pid";

### check to see if host is configured for the scheduler
unless (-d LOG_DIR) {
  dienice("Host is not configured for scheduler")
}

if ($ARGV[0] eq "status") {
  my $status = isRunning();
  print "Running: $status\n";
  exit ($status);
}

startDaemon();

my $logger = get_log();
my $pid = $$;
$logger->debug("Pid: $pid");

Kynetx::MongoDB::init();
Kynetx::Memcached->init();

my $run_mode = Kynetx::Configure::get_config('RUN_MODE');
my $event_host = Kynetx::Configure::get_config($run_mode)->{'EVAL_HOST'};
$logger->info("Run mode: $run_mode");
$logger->info("Event host: $event_host");


my $opt_string = 'hv:';
getopts( "$opt_string", \%opt );
&usage() if $opt{'h'};


################################
my %children;
$SIG{CHLD} = 'IGNORE';	

$SIG{INT}  = sub { my $logger = get_log();$logger->warn("Caught SIGINT:  exiting gracefully");safeExit() };
$SIG{QUIT} = sub { my $logger = get_log();$logger->warn("Caught SIGQUIT:  exiting gracefully");safeExit() };
$SIG{HUP}  = \&sighup;

my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
$platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');
our $dn = "http://$platform";


my $run = 1;
my $jobs = 0;
my @child = ();
my $cron_num = 0;
my $once_num = 0;

my $mail_server = new Net::SMTP::Server('localhost',25) ||
	$logger->fatal("Unable to start mail server: $!\n");

while (my $conn= $mail_server->accept) {
 my $client = new Net::SMTP::Server::Client($conn) ||
	  dienice("Unable to create client connection: $!\n");   
 my $cpid = fork();
 $logger->debug("CPID: $cpid");
 $children{$cpid} = 1;  
 
	unless ($cpid) {
	  my $line;
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
		waitpid($pid,0);
		_exit(0);
	}
	$logger->debug("Connection passed to process: $cpid");	 
}  


safeExit(1);

sub sighup {
  my $logger = get_log();
  $logger->warn("Caught SIGHUP:  exiting gracefully");
  safeExit();
}


sub safeExit {
  my ($exit_code) = @_;
  my $logger = get_log();
  my $pid = $$;
  $logger->debug("Pid: $pid releasing $0");  
  eval {
    Proc::PID::File->release({
        debug => 0,
        name => $0 
    });    
  };
  if ($@) {
    dienice("Problem releasing $0: $@");
  } 
  
  $exit_code = $exit_code || 0;
  _exit(0);
}

sub get_pid {
  my $in;open($in, shift ) && return scalar <$in>;
}

sub isRunning {
  return Proc::PID::File->running({debug => 0,name => $ME})
}

sub startDaemon {
  my $nlogger = get_log();
  
  $nlogger->debug("Check for pid"); 
  if (Proc::PID::File->running({debug => 0,name => $ME})) {
    dienice("$ME already running") 
  } else {
    $nlogger->debug("Initializing $ME")
  }
  
  eval {Proc::Daemon::Init({
    work_dir => Kynetx::Configure::get_config('KOBJ_ROOT'),
    pid_file => $PIDFILE,
    child_STDERR => '+>>' .LOG_DIR. '/error.log',
    child_STDOUT => '+>>' .LOG_DIR. '/stndout.log',
  });};
  if ($@) {
    dienice("Unable to start $ME daemon: $@");
  }   
}

sub dienice ($){
  my ($package, $filename, $line) = caller;
  my $logger = get_log();
  $logger->fatal("$_[0] at line $line in $filename");
  #croak($_[0]);
  die $_[0];
}


sub get_log {
    my $log_config = {
      "log4perl.rootLogger"       => "DEBUG, LOGFILE",
      "log4perl.appender.LOGFILE" => "Log::Log4perl::Appender::File",
      "log4perl.appender.LOGFILE.filename" => File::Spec->catfile(LOG_DIR,LOG_FILE),
      "log4perl.appender.LOGFILE.mode"     => "append",
      "log4perl.appender.LOGFILE.layout"  => "Log::Log4perl::Layout::PatternLayout",
      "log4perl.appender.LOGFILE.layout.ConversionPattern"  => "%d %m %n"
    };
    Log::Log4perl->init( $log_config );
    return get_logger();
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
		}
		
		
	}
	return \@p;
}

sub mediator {
	my ($token,$domain,$name,$payload) = @_;
}

sub REAPER { 1 until waitpid(-1 , WNOHANG) == -1 };


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
