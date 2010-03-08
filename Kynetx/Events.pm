package Kynetx::Events;
# file: Kynetx/Events.pm
# file: Kynetx/Predicates/Referers.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
# 
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
# 
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
# 
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
# 
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
# 

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Kynetx::Util qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Configure qw(:all);

use Kynetx::Events::Primitives qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);

    my $logger = get_logger();

    $r->content_type('text/javascript');
    

    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my $method;
    my $rid;
    my $eid = '';

    ($method,$rid,$eid) = $r->path_info =~ m!/([a-z+_]+)/([A-Za-z0-9_;]*)/?(\d+)?!;

    $eid = $eid || 'unknown';
    $logger->debug("processing event $method on rulesets $rid and EID $eid");
    Log::Log4perl::MDC->put('site', $rid);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    # store these for later logging
    $r->subprocess_env(METHOD => $method);
    $r->subprocess_env(RIDS => $rid);

    # at some point we need a better dispatch function
    if($method eq 'version' ) {
      show_build_num($r, $method, $rid);
    } else {
      process_event($r, $method, $rid, $eid);
    }

    return Apache2::Const::OK; 
}


sub process_events {

    my ($r, $method, $rids, $eid) = @_;

    my $logger = get_logger();
    Log::Log4perl::MDC->put('events', '[global]');


    $r->subprocess_env(START_TIME => Time::HiRes::time);

    if(Kynetx::Configure::get_config('RUN_MODE') eq 'development') {
	# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
	my $test_ip = Kynetx::Configure::get_config('TEST_IP');
	 $r->connection->remote_ip($test_ip);
	$logger->debug("In development mode using IP address ", $r->connection->remote_ip());
    } 

    # get a session
    my $session = process_session($r);

    my $req = Apache2::Request->new($r);


# not clear we need the request env now
#    my $req_info = Kynetx::Request::build_request_env($r, $method, $rids);
#    $req_info->{'eid'} = $eid || '';

    my $ev = Kynetx::Events::Primitives->new();
    if ($method eq 'pageview' ) {
      $ev->pageview($r->headers_in->{'Referer'} || $req->param('caller') || '');
    } elsif ($method eq 'click' ) {
      $ev->click($req->param('element'));
    } elsif ($method eq 'change' ) {
      $ev->change($req->param('element'));
    } else {
      $logger->error("Unhandlable event: $method");
    }

    my @rules_to_execute;

    foreach my $rid (@{ $rids }) {
      foreach my $rule (@{$rid->{'rules'}}) {
	
	my $sm_current_name = $rule->{'name'}.':sm_current';

	$rule->{'event_sm'} = make_event_sm($rule) unless $rule->{'event_sm'};

	# reconstitute the object.  
	my $sm = bless $rule->{'event_sm'}, "Kynetx::Events::State";

	my $current_state = session_get($rid, $session, $sm_current_name);

	my $next_state = $sm->next_state($current_state, $ev);

	if ($sm->is_final($next_state)) {
	  push @rules_to_execute, [$rid,$rule];
	  # reset SM
	  session_store($rid, $session, $sm_current_name, $sm->initial_state());
	} else {
	  session_store($rid, $session, $sm_current_name, $next_state);
	}


      }
    }

    


    # finish up
    session_cleanup($session);

    # return the JS load to the client
    $logger->info("Ruleset processing finished");
    $logger->debug("__FLUSH__");


}

1;
