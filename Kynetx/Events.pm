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
use Kynetx::Request;
use Kynetx::Rules;
use Kynetx::Actions;
use Kynetx::Json;

use Kynetx::Events::Primitives qw(:all);
use Kynetx::Events::State qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
compile_event_expr
mk_event
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);

    my $logger = get_logger();

    $r->content_type('text/javascript');
    

    $logger->debug("------------------------------ begin ruleset execution-----------------------------");
    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my ($domain,$rid,$eventtype);
    my $eid = '';

    ($domain,$eventtype,$rid,$eid) = $r->path_info =~ m!/event/([a-z+_]+)/?([a-z+_]+)?/?([A-Za-z0-9_;]*)/?([A-Z0-9-]*)?/?!;


 # Set to be the same now one.  This will pass back the rid to the runtime
    #$eid = $rid;
    $logger->debug("processing event $domain/$eventtype on rulesets $rid and EID $eid");

    Log::Log4perl::MDC->put('site', $rid);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    # store these for later logging
    $r->subprocess_env(DOMAIN => $domain);
    $r->subprocess_env(EVENTTYPE => $eventtype);
    $r->subprocess_env(RIDS => $rid);

    # at some point we need a better dispatch function
    if($domain eq 'version' ) {
      show_build_num($r);
    } else {
      process_event($r, $domain, $eventtype, $rid, $eid);
    }

    return Apache2::Const::OK; 
}


sub process_event {

    my ($r, $domain, $eventtype, $rids, $eid) = @_;

    my $logger = get_logger();
    Log::Log4perl::MDC->put('events', '[global]');

    $logger->debug("processing event $domain/$eventtype on rulesets $rids and EID $eid");

    $r->subprocess_env(START_TIME => Time::HiRes::time);

#     if(Kynetx::Configure::get_config('RUN_MODE') eq 'development') {
# 	# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
# 	my $test_ip = Kynetx::Configure::get_config('TEST_IP');
# 	 $r->connection->remote_ip($test_ip);
# 	$logger->debug("In development mode using IP address ", $r->connection->remote_ip());
#     } 

    # get a session
    my $session = process_session($r);

    my $req_info = Kynetx::Request::build_request_env($r, $domain, $rids, $eventtype);

    Kynetx::Request::log_request_env($logger, $req_info);

# not clear we need the request env now
#    my $req_info = Kynetx::Request::build_request_env($r, $domain, $rids);
    $req_info->{'eid'} = $eid || '';

    my $ev = mk_event($req_info);

    my $rules_to_execute;

#    $logger->debug("Processing events for $rids with event ", sub {Dumper $ev});

    foreach my $rid (split(/;/, $rids)) {

      $logger->debug("Processing events for $rid");
      Log::Log4perl::MDC->put('site', $rid);

      $req_info->{'rid'} = $rid;

      my $ruleset = Kynetx::Rules::get_rule_set($req_info);

#      $logger->debug("Ruleset: ", sub {Dumper $ruleset} );

      foreach my $rule (@{$ruleset->{'rules'}}) {

	next if $rule->{'state'} eq 'inactive';

	Log::Log4perl::MDC->put('rule', $rule->{'name'});  # no rule for now...

	my $sm_current_name = $rule->{'name'}.':sm_current';
	my $event_list_name = $rule->{'name'}.':event_list';

#	$logger->debug("Rule: ", Kynetx::Json::astToJson($rule));
	
#	$logger->debug("Op: ", $rule->{'pagetype'}->{'event_expr'}->{'op'});

	next unless defined $rule->{'pagetype'}->{'event_expr'}->{'op'};

	my $sm = $rule->{'event_sm'};

#	$logger->debug("Event SM: ", sub { Dumper $sm });

	my $current_state = session_get($rid, $session, $sm_current_name) || 
	                    $sm->get_initial();

	$logger->debug("Initial: ", $current_state );


	my $next_state = $sm->next_state($current_state, $ev);
	
	# when there's a state change, store the event in the event list
	unless ($current_state eq $next_state) {
	  session_push($rid, $session, $event_list_name, $ev);
#	  $logger->debug("Event list ($event_list_name): ", sub { Dumper session_get($rid, $session, $event_list_name)});
	}


	$logger->debug("Next: ", $next_state );

	if ($sm->is_final($next_state)) {

	  # sm vars and vals are namespace by sm id.
	  $rules_to_execute->{$rid}->{$rule->{'name'}}->{'sm_id'} = $sm->get_id();

	  push @{$rules_to_execute->{$rid}->{'rules'}}, $rule;
	  $rules_to_execute->{$rid}->{'ruleset'} = $ruleset;
	  $logger->debug("Pushing " , $rid, " & ",  $rule->{'name'});

	  # reset SM
	  session_delete($rid, $session, $sm_current_name);

	} else {
	  session_store($rid, $session, $sm_current_name, $next_state);
	}

      }
    }

    my $rule_env = Kynetx::Rules::mk_initial_env();

    my $js = '';

# {ruleset => 
#  rules => [...]
#  rule_name => {req_info =>
#                vars =>
#                vals =>
#               }
#  req_info =>
# }


    foreach my $rid (keys %{$rules_to_execute}) {

      $rules_to_execute->{$rid}->{'req_info'} = $req_info;
      Log::Log4perl::MDC->put('site', $rid);
      $req_info->{'rid'} = $rid;

      foreach my $rule (@{ $rules_to_execute->{$rid}->{'rules'} }) {

	Log::Log4perl::MDC->put('rule', $rule->{'name'}); 

	my $rule_name = $rule->{'name'};

	# get event list and reset+
	my $event_list_name = $rule->{'name'}.':event_list';

	my @req_list;
	while (my $ev = session_next($rid, $session, $event_list_name)) {

#	  $logger->debug("Event: ", sub {Dumper $ev});

	  push @req_list, $ev->get_req_info();
	  push @{$rules_to_execute->{$rid}->{$rule_name}->{'vars'}}, 
	       @{$ev->get_vars($rules_to_execute->{$rid}->{$rule_name}->{'sm_id'})};
	  push @{$rules_to_execute->{$rid}->{$rule_name}->{'vals'}}, 
	       @{$ev->get_vals($rules_to_execute->{$rid}->{$rule_name}->{'sm_id'})};
	}

# merging the req_info this way mods it in unpredictable ways
#	$rules_to_execute->{$rid}->{$rule_name}->{'req_info'} = 
#	    Kynetx::Request::merge_req_env(@req_list);

	session_delete($rid, $session, $event_list_name);

	

      }

#      $logger->debug("RL: ", sub { Dumper $rules_to_execute->{$rid} });

      $js .= eval {
	      Kynetx::Rules::process_ruleset($r, 
					     $rules_to_execute->{$rid},
					     $rule_env,
					     $session,
					     $rid)
      };
      if ($@) {
	$logger->error("Ruleset $rid failed: ", $@);
      }

    }

    # put this in the logging DB
    Kynetx::Log::log_rule_fire($r, 
			       $req_info, 
			       $session
			      );


    # finish up
    session_cleanup($session);

    # return the JS load to the client
    $logger->info("Event processing finished");
    $logger->debug("__FLUSH__");



    # this is where we return the JS
    if ($req_info->{'understands_javascript'}) {
      $logger->debug("Returning javascript from evaluation");
      print Kynetx::Actions::mk_registered_resource_js($req_info) . $js;
    } else {
      $logger->debug("Returning directives from evaluation");

      my @directive_doc = map {$_->to_directive()} @{$req_info->{'directives'}};
#      $logger->debug("Directives ", sub {Dumper @directive_doc });
      print JSON::XS::->new->convert_blessed(1)->utf8(1)->pretty(0)->encode(
	   \@directive_doc
        );

    }

}


sub mk_event {
   my($req_info) = @_;

   my $logger = get_logger();

   my $ev = Kynetx::Events::Primitives->new();
   $ev->set_req_info($req_info);
   if ($req_info->{'eventtype'} eq 'pageview' ) {
     $ev->pageview($req_info->{'caller'});
   } elsif ($req_info->{'eventtype'} eq 'click' ) {
     $ev->click($req_info->{'element'});
   } elsif ($req_info->{'eventtype'} eq 'submit' ) {
     $ev->submit($req_info->{'element'});
   } elsif ($req_info->{'eventtype'} eq 'change' ) {
     $ev->change($req_info->{'element'});
   } else {
     $logger->error("Event: $req_info->{'domain'} $req_info->{'eventtype'}");

     $ev->generic("$req_info->{'domain'}:$req_info->{'eventtype'}");
   }

   return $ev;
}

sub compile_event_expr {

  my($eexpr) = @_;

  my $logger = get_logger();

  my $sm;

  if ($eexpr->{'type'} eq 'prim_event') {
    if ($eexpr->{'op'} eq 'pageview') {
      $sm = mk_pageview_prim($eexpr->{'pattern'}, $eexpr->{'vars'});
    } elsif ($eexpr->{'op'} eq 'submit' ||
	     $eexpr->{'op'} eq 'click' ||
	     $eexpr->{'op'} eq 'dblclick' ||
	     $eexpr->{'op'} eq 'change' ||
	     $eexpr->{'op'} eq 'update'
	    ) {
      $sm = mk_dom_prim($eexpr->{'element'}, $eexpr->{'pattern'}, $eexpr->{'vars'}, $eexpr->{'op'});
    } else {
      $logger->debug("Creating primitive event for $eexpr->{'domain'}:$eexpr->{'op'}");
      $sm = mk_gen_prim($eexpr->{'domain'}, $eexpr->{'op'}, $eexpr->{'vars'}, $eexpr->{'filters'});
    }
  } elsif ($eexpr->{'type'} eq 'complex_event') {
    if ($eexpr->{'op'} eq 'between' ||
        $eexpr->{'op'} eq 'notbetween') {
      my $mid = compile_event_expr($eexpr->{'mid'});
      my $first = compile_event_expr($eexpr->{'first'});
      my $last = compile_event_expr($eexpr->{'last'});

      if ($eexpr->{'op'} eq 'between') {
	$sm = mk_between($mid, $first, $last);
      } elsif ($eexpr->{'op'} eq 'notbetween') {
	$sm = mk_not_between($mid, $first, $last);
      }
      
    } else { # other complex event
      my $sm0 = compile_event_expr($eexpr->{'args'}->[0]);
      my $sm1 = compile_event_expr($eexpr->{'args'}->[1]);
      if ($eexpr->{'op'} eq 'and') {
	$sm = mk_and($sm0, $sm1);
      } elsif ($eexpr->{'op'} eq 'or') {
	$sm = mk_or($sm0, $sm1);
      } elsif ($eexpr->{'op'} eq 'before') {
	$sm = mk_before($sm0, $sm1);
      } elsif ($eexpr->{'op'} eq 'then') {
	$sm = mk_then($sm0, $sm1);
      } 
    }

  } else {
    $logger->warn("Attempt to compile malformed event expression");
  }

  return $sm;

}

1;
