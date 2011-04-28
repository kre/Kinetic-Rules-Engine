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
use Kynetx::Json;
use Kynetx::Scheduler;
use Kynetx::Response;
use Kynetx::Persistence qw(:all);
use Kynetx::Events::Primitives qw(:all);
use Kynetx::Events::State qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;

# time some thing...
#use Benchmark qw(:hireswallclock :all) ;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          compile_event_expr
          mk_event
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    Kynetx::Util::config_logging($r);

    my $logger = get_logger();

    $r->content_type('text/javascript');

    $logger->debug(
"\n\n------------------------------ begin EVENT evaluation-----------------------------"
    );
    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my ( $domain, $rid, $eventtype );
    my $eid = '';

    ( $domain, $eventtype, $rid, $eid ) = $r->path_info =~
      m!/event/([a-z+_]+)/?([a-z+_]+)?/?([A-Za-z0-9_;]*)/?([A-Z0-9-]*)?/?!;

    # Set to be the same now one.  This will pass back the rid to the runtime
    #$eid = $rid;
    if ($domain eq 'version') {
      $logger->debug("returning version info for event API");
    } else {
      $logger->debug("processing event $domain/$eventtype on rulesets $rid and EID $eid");
    }

    Log::Log4perl::MDC->put( 'site', $rid );
    Log::Log4perl::MDC->put( 'rule', '[global]' );    # no rule for now...

    # store these for later logging
    $r->subprocess_env( DOMAIN    => $domain );
    $r->subprocess_env( EVENTTYPE => $eventtype );
    $r->subprocess_env( RIDS      => $rid );

    # at some point we need a better dispatch function
    if ( $domain eq 'version' ) {
        show_build_num($r);
    } else {
        process_event( $r, $domain, $eventtype, $rid, $eid );
    }

    return Apache2::Const::OK;
}

sub process_event {

    my ( $r, $domain, $eventtype, $rids, $eid ) = @_;

    my $logger = get_logger();
    Log::Log4perl::MDC->put('events', '[global]');

    $logger->debug("processing event $domain/$eventtype on rulesets $rids and EID $eid");

    $r->subprocess_env(START_TIME => Time::HiRes::time);


    if(Kynetx::Configure::get_config('RUN_MODE') eq 'development') {
      # WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
      my $test_ip = Kynetx::Configure::get_config('TEST_IP');
      $r->connection->remote_ip($test_ip);
      $logger->debug("In development mode using IP address ", $r->connection->remote_ip());
    }

    my $req_info =
      Kynetx::Request::build_request_env( $r, $domain, $rids, $eventtype );
    # $req_info->{'benchmarks'} = [];
    # push(@{$req_info->{'benchmarks'}}, {'name' => 'start',
    # 					'time' => Benchmark->new});


    Kynetx::Request::log_request_env( $logger, $req_info );

    # get a session, if _sid param is defined it will override cookie
    $logger->debug("Event cookie? ",$req_info->{'kntx_token'});
    my $session = process_session($r, $req_info->{'kntx_token'});

    # push(@{$req_info->{'benchmarks'}}, {'name' => 'post process_session',
    # 					'time' => Benchmark->new});



    # not clear we need the request env now
    #    my $req_info = Kynetx::Request::build_request_env($r, $domain, $rids);
    $req_info->{'eid'} = $eid || '';

    my $ev = mk_event($req_info);

    $logger->debug("Processing events for $rids with event ", sub {Dumper $ev});

    my $schedule = Kynetx::Scheduler->new();

    foreach my $rid ( split( /;/, $rids ) ) {
      eval {
	process_event_for_rid( $ev, $req_info, $session, $schedule, $rid );
      };
      if ($@) {
	Kynetx::Util::handle_error("Process event failed for rid ($rid):", $@);
      }
    }

    $logger->debug("Schedule complete");

    # push(@{$req_info->{'benchmarks'}}, {'name' => "start processing schedule",
    # 					'time' => Benchmark->new});

    
    my $js = '';
	$js .= eval {
		Kynetx::Rules::process_schedule( $r, $schedule, $session, $eid,$req_info );
	};
    if ($@) {
   		Kynetx::Util::handle_error("Process event schedule failed: ", $@);
    }

    # push(@{$req_info->{'benchmarks'}}, {'name' => "end processing schedule",
    # 					'time' => Benchmark->new});



    # push(@{$req_info->{'benchmarks'}}, {'name' => "start sending response",
    # 					'time' => Benchmark->new});

    Kynetx::Response::respond( $r, $req_info, $session, $js, "Event" );

    # push(@{$req_info->{'benchmarks'}}, {'name' => "end sending response",
    # 					'time' => Benchmark->new});


    # my $pb;
    # my $td;
    # foreach my $b ( @{$req_info->{'benchmarks'}}) {
    #   if (defined $pb) {
    # 	$td = timestr(timediff($b->{'time'},
    # 			       $pb->{'time'}));
    # 	$logger->info($b->{'name'}, ":\t ", $td);# unless $b->{'name'} =~ /^start/;
    #   }
    #   $pb = $b;
    # }


}

sub process_event_for_rid {
    my $ev       = shift;
    my $req_info = shift;
    my $session  = shift;
    my $schedule = shift;
    my $rid      = shift;

    my $logger = get_logger();

    #  $logger->debug("Req info: ", sub {Dumper $req_info} );
    # push(@{$req_info->{'benchmarks'}}, {'name' => "start processing RID $rid",
    # 					'time' => Benchmark->new});


    $logger->debug("Processing events for $rid");
    Log::Log4perl::MDC->put( 'site', $rid );

    my $ruleset = Kynetx::Rules::get_rule_set($req_info, 1, $rid); # 1 for localparsing

    #      $logger->debug("Ruleset: ", sub {Dumper $ruleset} );

    my $type = $ev->get_type();
    my $domain = $ev->get_domain();

    $logger->debug("Event domain is $domain and type is $type");
#    $logger->debug("Rule list is ", sub{Dumper $ruleset->{'rule_lists'}->{$domain}->{$type}});

    foreach my $d (keys %{$ruleset->{'rule_lists'}}) {
      foreach my $t (keys %{$ruleset->{'rule_lists'}->{$d}}) {
	$logger->debug("$d:$t -> ");
	foreach my $r (@{$ruleset->{'rule_lists'}->{$d}->{$t}} ) {
	  $logger->debug("\t$r->{'name'}");
	}
      }
    }

    $logger->debug("Selection checking for ", scalar @{ $ruleset->{'rule_lists'}->{$domain}->{$type} }, " rules") if $ruleset->{'rule_lists'}->{$domain}->{$type};

    foreach my $rule ( @{ $ruleset->{'rule_lists'}->{$domain}->{$type} } ) {

      $rule->{'state'} ||= 'active';

      Log::Log4perl::MDC->put( 'rule', $rule->{'name'} ); # no rule for now...

      my $sm_current_name = $rule->{'name'} . ':sm_current';
      my $event_list_name = $rule->{'name'} . ':event_list';

      $logger->trace("Rule: ", sub {Kynetx::Json::astToJson($rule)});

      $logger->trace("Op: ", $rule->{'pagetype'}->{'event_expr'}->{'op'});

      next unless defined $rule->{'pagetype'}->{'event_expr'}->{'op'};

      my $sm = $rule->{'event_sm'};
      $logger->trace("State machine: ", sub {Dumper($sm)});

      # States stored in Mongo should be serialized
      my $current_state = get_persistent_var("ent", $rid, $session, $sm_current_name ) || $sm->get_initial();

      my $next_state = $sm->next_state( $current_state, $ev );


#        $logger->debug("Current: ", $current_state );
#        $logger->debug("Next: ", $next_state );

      # when there's a state change, store the event in the event list
      unless ( $current_state eq $next_state ) {
	$logger->debug("State change from $current_state to $next_state");
	my $json = $ev->serialize();
	Kynetx::Persistence::add_persistent_element("ent", $rid, $session, $event_list_name, $json );
      } else {
	$logger->debug("No state change from $current_state");
      }

      if ( $sm->is_final($next_state) ) {

	my $rulename = $rule->{'name'};

	$logger->debug( "Adding to schedule: ", $rid, " & ", $rulename );
	my $task = $schedule->add( $rid, $rule, $ruleset, $req_info );

	# get event list and reset+
	my $event_list_name = $rulename . ':event_list';

	my $var_list = [];
	my $val_list = [];
	$logger->trace("Process sessions");
	while ( my $json =
                    consume_persistent_element("ent", $rid, $session, $event_list_name, 1) )
	  {
	    
	    my $ev = Kynetx::Events::Primitives->unserialize($json);
	    $logger->trace( "Event: ", sub { Dumper $ev} );

                # FIXME: what we're not doing: the event list also
                # includes the req_info that was active when the event
                # came in.  We're not doing anything with it--simply
                # using the req_info from the final req...

                # gather up vars and vals from all the events in the path
	    push @{$var_list}, @{ $ev->get_vars( $sm->get_id() ) };
	    push @{$val_list}, @{ $ev->get_vals( $sm->get_id() ) };
	  }
	$schedule->annotate_task( $rid, $rulename,$task, 'vars', $var_list );
	$schedule->annotate_task( $rid, $rulename,$task, 'vals', $val_list );

	# reset SM
	delete_persistent_var("ent", $rid, $session, $sm_current_name );

	# reset event list for this rule
	delete_persistent_var("ent", $rid, $session, $event_list_name );
	$logger->debug("Complete task for $rulename added to schedule");

      } else {
	$logger->trace("Next state not final");
	$logger->trace("Next state ref: ", ref $next_state);
	if ($next_state ne "") {
	  save_persistent_var("ent", $rid, $session, $sm_current_name, $next_state );
	}

      }

    }

    # push(@{$req_info->{'benchmarks'}}, {'name' => "end processing RID $rid",
    # 					  'time' => Benchmark->new});



}

sub mk_event {
    my ($req_info) = @_;

    my $logger = get_logger();
	$logger->debug("Make event for eventtype: ",$req_info->{'eventtype'} );
	$logger->trace("Request info is: ", sub {Dumper($req_info)});
    my $ev = Kynetx::Events::Primitives->new();
    $ev->set_req_info($req_info);
    if ( $req_info->{'eventtype'} eq 'pageview' ) {
        $ev->pageview( $req_info->{'caller'} );
    } elsif ( $req_info->{'eventtype'} eq 'click' ) {
        $ev->click( $req_info->{'element'} );
    } elsif ( $req_info->{'eventtype'} eq 'submit' ) {
        $ev->submit( $req_info->{'element'} );
    } elsif ( $req_info->{'eventtype'} eq 'change' ) {
        $ev->change( $req_info->{'element'} );
    } else {
        $ev->generic($req_info->{'domain'},$req_info->{'eventtype'});
    }

    return $ev;
}

sub compile_event_expr {

  my ($eexpr, $rule_lists, $rule) = @_;

  my $logger = get_logger();

  my $sm;

  if ( $eexpr->{'type'} eq 'prim_event' ) {

    # the rule list for each domain and op is stored in the parse tree
    # for optimizing rule selection
    my $domain = $eexpr->{'domain'} || 'web';
    $rule_lists->{$domain} = {} 
      unless $rule_lists->{$domain};
    $rule_lists->{$domain}->{$eexpr->{'op'}} = [] 
      unless $rule_lists->{$domain}->{$eexpr->{'op'}};
    # put the rule in the array unless it's already there
    push(@{$rule_lists->{$domain}->{$eexpr->{'op'}}}, $rule) 
      unless (grep {$_ eq $rule} @{$rule_lists->{$domain}->{$eexpr->{'op'}}});
    
    if ( $eexpr->{'op'} eq 'pageview' ) {
      $sm = mk_pageview_prim( $eexpr->{'pattern'}, $eexpr->{'vars'} );
    } elsif (    $eexpr->{'op'} eq 'submit'
		 || $eexpr->{'op'} eq 'click'
		 || $eexpr->{'op'} eq 'dblclick'
		 || $eexpr->{'op'} eq 'change'
		 || $eexpr->{'op'} eq 'update' )
      {
	$sm = mk_dom_prim( $eexpr->{'element'}, $eexpr->{'pattern'},
                               $eexpr->{'vars'},    $eexpr->{'op'} );
      } elsif ($eexpr->{'op'} eq 'expression') {
	$logger->debug(
		       "Creating Expression event for $eexpr->{'domain'}:$eexpr->{'op'}"
		      );
	$logger->trace("Eexpr: ", sub {Dumper($eexpr)});
	$sm = mk_expr_prim( $eexpr->{'domain'}, $eexpr->{'op'},
			    $eexpr->{'vars'},   $eexpr->{'exp'} );        	
        
      } else {
	$logger->debug(
	   "Creating primitive event for $eexpr->{'domain'}:$eexpr->{'op'}"
		      );
	$logger->trace("Eexpr: ", sub {Dumper($eexpr)});
	$sm = mk_gen_prim( $eexpr->{'domain'}, $eexpr->{'op'},
			   $eexpr->{'vars'},   $eexpr->{'filters'} );
      }
  } elsif ( $eexpr->{'type'} eq 'complex_event' ) {
    if (    $eexpr->{'op'} eq 'between'
	    || $eexpr->{'op'} eq 'notbetween' )
      {
	my $mid   = compile_event_expr( $eexpr->{'mid'}, $rule_lists, $rule );
	my $first = compile_event_expr( $eexpr->{'first'}, $rule_lists, $rule );
	my $last  = compile_event_expr( $eexpr->{'last'}, $rule_lists, $rule );

	if ( $eexpr->{'op'} eq 'between' ) {
	  $sm = mk_between( $mid, $first, $last );
	} elsif ( $eexpr->{'op'} eq 'notbetween' ) {
	  $sm = mk_not_between( $mid, $first, $last );
	}

      } else {			# other complex event
	my $sm0 = compile_event_expr( $eexpr->{'args'}->[0], $rule_lists, $rule );
	my $sm1 = compile_event_expr( $eexpr->{'args'}->[1], $rule_lists, $rule );
	if ( $eexpr->{'op'} eq 'and' ) {
	  $sm = mk_and( $sm0, $sm1 );
	} elsif ( $eexpr->{'op'} eq 'or' ) {
	  $sm = mk_or( $sm0, $sm1 );
	} elsif ( $eexpr->{'op'} eq 'before' ) {
	  $sm = mk_before( $sm0, $sm1 );
	} elsif ( $eexpr->{'op'} eq 'then' ) {
	  $sm = mk_then( $sm0, $sm1 );
	}
      }

  } else {
    $logger->warn("Attempt to compile malformed event expression");
  }
  return $sm;

}

1;
