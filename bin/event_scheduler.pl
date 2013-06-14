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
use POSIX qw(
:sys_wait_h
_exit
);
use Proc::PID::File;
use Proc::Daemon;
use File::Spec;
use AnyEvent;



use constant LOG_DIR => '/web/logs/scheduler';
use constant LOG_FILE => 'scheduler.log';
#use constant PIDDIR => LOG_DIR;
use constant LOOKAHEAD => 5;
use constant TIMEOUT => 60 * LOOKAHEAD * 2;
use constant SKIP => 10;
use constant JOB_MAX => 100;

our $ME = $0; $ME =~ s|.*/||; $ME =~ s|\.pl||;

sub dienice ($);
sub main ();
Kynetx::Configure::configure();
our $KOBJ_ROOT = Kynetx::Configure::get_config('KOBJ_ROOT');
our $PIDDIR = "/var/run";
our $PIDFILE = "$PIDDIR/$ME.pid";
our $CRONDIR = "$PIDDIR/scron";

### check to see if host is configured for the scheduler
unless (-d $CRONDIR && -d LOG_DIR) {
  dienice("Host is not configured for scheduler")
}

startDaemon();

my $logger = get_log();
my $pid = $$;
$logger->debug("Pid: $pid");

Kynetx::MongoDB::init();
Kynetx::Memcached->init();

# This is a new cron job, so clear out all of the cron_ids
my $result = Kynetx::Persistence::SchedEv::clear_cron_ids();
$logger->debug("Clear: ", sub {Dumper($result)});



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
$SIG{USR1} = \&consolidate_cron_processes;

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

main();

$logger->debug("Stopping $ME");

safeExit(0);

sub main() {
  while ($run) {
    cron_loop();
    once_loop();
    
    sleep 5;  
  }  
}

sub consolidate_cron_processes {
  my $logger = get_log();
  $logger->warn("CRON event consolidation requested");
  my $result = Kynetx::Persistence::SchedEv::count_by_cron_id();
  my $num_jobs = scalar keys %{$result};
  if ($num_jobs > 1) {
    for my $cron_id (keys %{$result}) {
      my $count = $result->{$cron_id};
      if ($count < JOB_MAX) {
        $logger->debug("Flush $cron_id");
        if (kill QUIT => $cron_id) {
          my $key = {
          'cron_id' => $cron_id
          };
          Kynetx::Persistence::SchedEv::clear_cron_ids($key);          
        }
      }
    }
    
  } else {
    $logger->debug("Only $num_jobs cron process to clear");
  }
  
  $cron_num=0;
  $once_num=0;
}


sub sighup {
  my $logger = get_log();
  $logger->warn("Caught SIGHUP:  exiting gracefully");
  foreach my $c (@child) {
    $logger->debug("Exit Cron child: $c");
    my $cpid = get_pid($c);
    if ($cpid) {
      chop $cpid;
      $logger->debug("\t$cpid");
      if (kill QUIT => $cpid){
        unlink($c);
      };      
    }
  }
  safeExit();
}


sub safeExit {
  my ($exit_code) = @_;
  my $logger = get_log();
  my $pid = $$;
  $logger->debug("Pid: $pid releasing $0");
  Proc::PID::File->release({
      debug => 0,
      #name => $ME 
      name => $0 
  });
  $exit_code = $exit_code || 0;
  _exit(0);
}

sub get_pid {
  my $in;open($in, shift ) && return scalar <$in>;
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
    child_STDERR => '+>>/tmp/error.txt',
    child_STDOUT => '+>>/tmp/error.txt',
  });};
  if ($@) {
    dienice("Unable to start $ME daemon: $@");
  } 
  
  
  
}

sub dienice ($){
  my ($package, $filename, $line) = caller;
  my $logger = get_log();
  $logger->fatal("$_[0] at line $line in $filename");
  croak($_[0]);
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

sub rtmin_h { 
  my $logger = get_log();$logger->warn("Caught SIGRTMIN"); 
};	
sub rtmin1_h { 
  my $logger = get_log();$logger->warn("Caught SIGRTMIN+1"); 
};	

sub REAPER { 1 until waitpid(-1 , WNOHANG) == -1 };

sub cron_dispatcher {
  my ($id,@args) = @_;
  my $logger = get_log();
  my $url = "$dn/sky/schedule/$id";
  $logger->debug("Call: ",$url);
  my $ua = LWP::UserAgent->new();
  my $req = new HTTP::Request 'POST', $url;
  my $response = $ua->request($req);
  $logger->debug("Args: ",join(" ",@args));
  $logger->debug("Code: ",$response->code());
  $logger->debug("Status: ",$response->status_line());
  
  
}

sub once_loop {
  my $logger = get_logger();
  my $num_events;
  my $plus_five = time + (LOOKAHEAD * 60);
  my $once_key = {'$and' =>
      [
      {"cron_id" => {
        '$exists' => 0
       }},
       {"once" => {
         '$exists' => 1
       }},
       {"next_schedule" => {
         '$lte' => $plus_five
       }},
       {"expired"=> {
         '$exists' => 0
       }}
      ]   
  };
  my $once_list = Kynetx::Persistence::SchedEv::get_schedev_list($once_key);
  $num_events = scalar(@{$once_list});
  if ($num_events == 0) {
    $once_num++;
    if ($once_num % SKIP == 0) {
      $logger->debug("Once loop ($once_num)");
    }
  } else {
    $logger->debug("Found $num_events once events");
    $once_num = 0;
  }
  
  if ($num_events > 0) {    
    my $cpid = fork();
    push(@child,$cpid);
    unless ($cpid) {
      $0 = 'perl_once';
      my $logger = get_log();
      my $spid = $$;
      my $map;
      for my $sched_id (@{$once_list}) {
        my $schedEv = Kynetx::Persistence::SchedEv::get_and_lock($sched_id,$spid);
        $map->{$sched_id} = $schedEv;
      }
      #my $consume = time + TIMEOUT;
      local $SIG{ALRM} = sub {die "timeout"};
      eval {
        alarm(TIMEOUT);
        while (1) {
          my $sleep_until;
          my $now = time;
          my $events = scalar keys %{$map};
          $logger->debug("Once events left to process ($events)");
          for my $test_id (keys %{$map}) {
            my $obj = $map->{$test_id};
            my $o_epoch = _get_scheduled_time($obj,'once');
            if ($o_epoch <= $now) {
              $logger->debug("Launch $test_id");
              cron_dispatcher($test_id,'type' => 'send once');
              delete $map->{$test_id};
            } else {
              if (! defined $sleep_until){
                $sleep_until = $o_epoch;
              } elsif ($o_epoch < $sleep_until) {
                $sleep_until = $o_epoch;
              }
            }
          }        
          my $sleep_time = $sleep_until - $now;
          if ($events == 0) {
            last;
          } elsif ($sleep_time > 0) {
            $logger->debug("Sleeping for $sleep_time s");
            $0 = prog_name('once',$sleep_until);
            sleep($sleep_time);            
          }
        }
        alarm(0);
      };
      if ($@) {
          if ($@ =~ /timeout/) {
             $logger->debug("Once process $spid timed out")                     
          } else {
              alarm(0);           # clear the still-pending alarm
              die;                # propagate unexpected exception
          } 
      }

      waitpid($spid,0);
      $logger->debug("Wait Pid");
      safeExit(0);      
    }
    $logger->debug("Passed $num_events events to once process $cpid");
  }
   
}

sub cron_loop {
  ################################
  # Get all entries that haven't been assigned to a cron job in
  my $cron_key = {      
      "cron_id" => {
        '$exists' => 0
       },
       "timespec" => {
         '$exists' => 1
       }
  };
  
  my $cron_list = Kynetx::Persistence::SchedEv::get_schedev_list($cron_key);
  my $num_events = scalar (@{$cron_list});
  if ($num_events == 0) {
    $cron_num++;
    if ($cron_num % SKIP == 0) {
      $logger->debug("Cron loop ($cron_num)");
    }
  } else {
    $logger->debug("Found $num_events cron events");
    $cron_num = 0;
  }
  
  if ($num_events > 0) {
    my $cron = new Schedule::Cron(\&cron_dispatcher,processprefix => "perl_cron");  
    foreach my $sched_id (@{$cron_list}) {
      my $schedEv = Kynetx::Persistence::SchedEv::get_and_lock($sched_id,$pid);
      #$logger->debug("Event: ",sub {Dumper($schedEv)});
      if (ref $schedEv eq "HASH") {
        my $next = $schedEv->{'next_schedule'};
        my $schedId = $schedEv->{'_id'};
        if ($schedEv->{'timespec'}) {      
          my $timespec = $schedEv->{'timespec'};
          $logger->trace("Cron: ",$timespec);          
          $cron->add_entry($timespec,$schedId => $next);
        } 
      }  
    }
    # Fork the cron process so it starts 
    my $cronpid = "$CRONDIR/cron-$pid-$jobs.pid";
    if ($cron->list_entries()) {
      $cron->run(detach => 1,pid_file => $cronpid);
      my $cpid = get_pid($cronpid);
      chomp($cpid);
      $logger->debug("Started cron batch ",$jobs++, " as process $cpid");
      foreach my $sched_id (@{$cron_list}) {
        Kynetx::Persistence::SchedEv::update_lock($sched_id,$pid,$cpid);
      }
      push(@child,$cronpid);
    } else {
      $logger->debug("No cron jobs to run")
    }
    
  }  
}

sub prog_name {
  my ($subp,$epoch) = @_;
  my $progname = 'perl_' . $subp;
  my $next = scalar(localtime($epoch));
  return "$progname - next: $next";
}

sub _get_scheduled_time{
  my ($schedEv_obj,$stype) = @_;
  my $next_scheduled = $schedEv_obj->{'next_schedule'};
  my $epoch;
  if ($stype eq "once") {
    my $once = $schedEv_obj->{$stype};
    my $dt = Kynetx::Predicates::Time::ISO8601($once);
    $epoch = $dt->epoch;
  }  
  if ($epoch != $next_scheduled) {
    my $variance = $epoch - $next_scheduled;
    $logger->debug("Schedule variance: $variance");
  }
  return $epoch;
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
