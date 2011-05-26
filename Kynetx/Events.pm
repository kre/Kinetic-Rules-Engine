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
use Kynetx::Errors;
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
$Data::Dumper::Terse = 1;

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

use constant ANY => {type => ".*",
		     pattern => ".*"};

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

#    ( $domain, $eventtype, $rid, $eid ) = $r->path_info =~
#      m!/event/([A-Za-z+_]+)/?([A-Za-z+_]+)?/?([A-Za-z0-9_;]*)/?([A-Z0-9-]*)?/?!;

    my @path_components = split(/\//,$r->path_info);
#    $logger->debug("Path components for ", $r->path_info, ": ", sub{Dumper @path_components});

    
    $domain = $path_components[2];
    $eventtype = $path_components[3];
    $rid = $path_components[4] || 'any';
    $eid = $path_components[5] || '';


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
    Kynetx::Request::log_request_env( $logger, $req_info );

    # get a session, if _sid param is defined it will override cookie
    $logger->debug("Event cookie? ",$req_info->{'kntx_token'});
    my $session = process_session($r, $req_info->{'kntx_token'});


    # not clear we need the request env now
    #    my $req_info = Kynetx::Request::build_request_env($r, $domain, $rids);
    $req_info->{'eid'} = $eid || '';

    # error checking for event domains and types
    unless ($domain =~ m/[A-Za-z+_]+/) {
	Kynetx::Errors::raise_error($req_info,
				    'error',
				    "malformed event domain $domain; must match [A-Za-z+_]+", 
				    {'genus' => 'system',
				     'species' => 'malformed event'
				    }
				   );
      }

    unless ($eventtype =~ m/[A-Za-z+_]+/) {
	Kynetx::Errors::raise_error($req_info,
				    'error',
				    "malformed event type $eventtype; must match [A-Za-z+_]+", 
				    {'genus' => 'system',
				     'species' => 'malformed event'
				    }
				   );
      }


    my $ev = mk_event($req_info);

    #$logger->debug("Processing events for $rids with event ", sub {Dumper $ev});

    my $schedule = Kynetx::Scheduler->new();

    foreach my $rid ( split( /;/, $rids ) ) {
      eval {
	process_event_for_rid( $ev, $req_info, $session, $schedule, $rid );
      };
      if ($@) {
	# this might lead to circular errors if raising an error causes an error
	# Kynetx::Errors::raise_error($req_info,
	# 			    'error',
	# 			    "Process event failed for rid ($rid): $@", 
	# 			    {'genus' => 'system',
	# 			     'species' => 'unknown'
	# 			    }
	# 			   );
	$logger->error("Process event failed for rid ($rid): $@");
	# special handling follows
	if ($@ =~ m/mongodb/i) {
	  Kynetx::MongoDB::init();
	  $logger->error("Caught MongoDB error, reset connection");
	}

      }
        
    }

    $logger->debug("Schedule complete");
    
    my $js = '';
    $js .= eval {
      Kynetx::Rules::process_schedule( $r, $schedule, $session, $eid,$req_info );
    };
    if ($@) {
      # Kynetx::Errors::raise_error($req_info,
      # 				  'error',
      # 				  "Process event schedule failed: $@",
      # 				    {'genus' => 'system',
      # 				     'species' => 'unknnown'
      # 				    }
      # 				 );
      $logger->error("Process event schedule failed: $@");
      # special handling follows
      if ($@ =~ m/mongodb/i) {
	Kynetx::MongoDB::init();
	$logger->error("Caught MongoDB error, reset connection");
      }
    }

    Kynetx::Response::respond( $r, $req_info, $session, $js, "Event" );

}

sub process_event_for_rid {
    my $ev       = shift;
    my $req_info = shift;
    my $session  = shift;
    my $schedule = shift;
    my $rid      = shift;

    my $logger = get_logger();

   #  $logger->debug("Req info: ", sub {Dumper $req_info} );

    $logger->debug("Processing events for $rid");
    Log::Log4perl::MDC->put( 'site', $rid );

  my $ruleset = Kynetx::Rules::get_rule_set($req_info, 1, $rid); # 1 for localparsing

    my $type = $ev->get_type();
    my $domain = $ev->get_domain();

    $logger->debug("Event domain is $domain and type is $type");
#    $logger->debug("Rule list is ", sub{Dumper $ruleset->{'rule_lists'}->{$domain}->{$type}});

    # prints out detailed info on rule_lists
    # foreach my $d (keys %{$ruleset->{'rule_lists'}}) {
    #   foreach my $t (keys %{$ruleset->{'rule_lists'}->{$d}}) {

    # 	$logger->debug("$d:$t -> ");
    # 	$logger->debug("\tFilters:", sub {Dumper $ruleset->{'rule_lists'}->{$d}->{$t}->{"filters"}});

    # 	my $i = 0;
    # 	foreach my $r (@{$ruleset->{'rule_lists'}->{$d}->{$t}->{"rulelist"}} ) {
	  
    # 	  $logger->debug("\t$r->{'name'}");
    # 	}
    #   }
    # }

    $logger->debug("Selection checking for ", scalar @{ $ruleset->{'rule_lists'}->{$domain}->{$type}->{'rulelist'} }, " rules") if $ruleset->{'rule_lists'}->{$domain}->{$type};

    foreach my $rule ( @{ $ruleset->{'rule_lists'}->{$domain}->{$type}->{'rulelist'} } ) {

      $logger->debug("Processing rule $rule->{'name'}");

    	$rule->{'state'} ||= 'active';

        Log::Log4perl::MDC->put( 'rule', $rule->{'name'} ); # no rule for now...

        my $sm_current_name = $rule->{'name'} . ':sm_current';
        my $event_list_name = $rule->{'name'} . ':event_list';

#    	$logger->trace("Rule: ", sub {Dumper $rule});

    	$logger->debug("Op: ", $rule->{'pagetype'}->{'event_expr'}->{'op'});
	
    	next unless defined $rule->{'pagetype'}->{'event_expr'}->{'op'};

    	my $sm = $rule->{'event_sm'};
    	$logger->debug("State machine: ", sub {Dumper($sm)});

        # States stored in Mongo should be serialized
        my $current_state = get_persistent_var("ent", $rid, $session, $sm_current_name ) || $sm->get_initial();

        my $next_state = $sm->next_state( $current_state, $ev );

        $logger->debug("Current: ", $current_state );
        $logger->debug("Next: ", $next_state );

        # when there's a state change, store the event in the event list
        unless ( $current_state eq $next_state ) {
	  my $json = $ev->serialize();
	  Kynetx::Persistence::add_persistent_element("ent", $rid, $session, $event_list_name, $json );
	  $logger->debug("State change for $rule->{'name'}");
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

        } else {
            $logger->trace("Next state not final");
            $logger->trace("Next state ref: ", ref $next_state);
            if ($next_state ne "") {
                save_persistent_var("ent", $rid, $session, $sm_current_name, $next_state );
            }

        }

    }
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
	$logger->debug("Event: ", sub {Dumper($ev)});
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
    my $op = $eexpr->{'op'};
    $logger->debug("Rule: ", sub {Dumper($rule->{'name'})});
    $rule_lists->{$domain} = {} 
      unless $rule_lists->{$domain};
    $rule_lists->{$domain}->{$op} = {"rulelist" => [],
				     "filters" => [],
				    }
      unless $rule_lists->{$domain}->{$op};
    # put the rule in the array unless it's already there
    unless (grep {$_ eq $rule} @{$rule_lists->{$domain}->{$op}->{"rulelist"}}) {
      $logger->debug("Putting $rule->{'name'} on the list");
      push(@{$rule_lists->{$domain}->{$op}->{"rulelist"}}, $rule) 
	unless (defined $rule->{'state'} && $rule->{'state'} eq 'inactive');
    }

    my $filter;
    if ( $op eq 'pageview' ) {
    	$logger->debug("Pageview expression: ", sub {Dumper($eexpr)});
    	if ($eexpr->{'pattern'} || $eexpr->{'legacy'}) {
    		$logger->debug("Old form pageview");
	      $sm = mk_pageview_prim( $eexpr->{'pattern'}, $eexpr->{'vars'} );
	      $filter = [{type => "url",
			  pattern => $eexpr->{'pattern'} || ".*"
			 }];
	      add_filter($filter, $rule_lists, $domain, $op, $rule);    		
    	} elsif (defined $eexpr->{'filters'}) {
    		$logger->debug("Pageview filter request: ", sub {Dumper($eexpr->{'filters'})});
    		my $num = @{$eexpr->{'filters'}};
    		$logger->debug("Num filters: $num");
    		#
    		# To clean up.  
    		# select when pageview #foop# is now a special case of
    		# select when pageview url #foop#
    		#
    		if ($num == 0) {
    			my $pattern = $eexpr->{'filters'}->[0]->{'pattern'};
    			$sm = mk_pageview_prim($pattern,$eexpr->{'vars'});
    			$filter = [{type => "url",
			  		pattern => $pattern || ".*"
    			}];
	      		add_filter($filter, $rule_lists, $domain, $op, $rule);
    		} else {
    			$logger->debug("Generic primitive");
    			$sm = mk_gen_prim($domain,$op, $eexpr->{'vars'},$eexpr->{'filters'});
    			add_filter($eexpr->{'filters'}, $rule_lists, $domain, $op, $rule);    			
    		}
    		$logger->debug("Created: ", sub {Dumper($sm)});
    	} else {
    		$logger->warn("Unknown event expression format: ", sub {Dumper($eexpr)});
    	}
    } elsif ($op eq 'submit'
	     || $op eq 'click'
	     || $op eq 'dblclick'
	     || $op eq 'change'
	     || $op eq 'update' )  {
      $sm = mk_dom_prim( $eexpr->{'element'}, $eexpr->{'pattern'},
			 $eexpr->{'vars'},    $op );

      $filter = [{type => "element",
		  pattern => $eexpr->{'element'}
		 }];
      add_filter($filter, $rule_lists, $domain, $op, $rule);


    } elsif ($op eq 'expression') {
      $logger->debug(
		     "Creating Expression event for $domain:$op"
		    );
      $logger->trace("Eexpr: ", sub {Dumper($eexpr)});
      $sm = mk_expr_prim( $domain, $op,
			  $eexpr->{'vars'},   $eexpr->{'exp'} );        	

      add_filter([ANY], $rule_lists, $domain, $op, $rule);
        
    } else {
      $logger->debug(
		     "Creating primitive event for $domain:$op"
		      );
      $logger->trace("Eexpr: ", sub {Dumper($eexpr)});
      $sm = mk_gen_prim( $domain, $op,
			 $eexpr->{'vars'},   $eexpr->{'filters'} );


      add_filter($eexpr->{'filters'}, $rule_lists, $domain, $op, $rule);

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

sub add_filter {
  my ($filters, $rule_lists, $domain, $op, $rule) = @_;

  my $filter_array = $rule_lists->{$domain}->{$op}->{"filters"};

  my $logger = get_logger();
  $logger->debug("Filters: ", sub {Dumper $filters});

  if (! defined $filters || scalar @{$filters} == 0) {
    $rule_lists->{$domain}->{$op}->{"filters"} = [ANY];
  }

  # $logger->debug("Filters after: ", sub {Dumper $filters}); 

  foreach my $filter ( @{$filters} ) {

    # if the filter is ANY, you only need that
    if ($filter eq ANY) {
      $rule_lists->{$domain}->{$op}->{"filters"} = [ANY];
#      $logger->debug("Filter array for ANY: ", sub {Dumper $filter_array});
      last;
    } else {
      # if the array already has ANY on it, no reason to add anything else
      # don't add filters twice
      # don't add filters for inactive rules
      unless ((defined $filter_array->[0] && $filter_array->[0] eq ANY)
            || grep 
	         {$_ eq $filter} 
	         @{$rule_lists->{$domain}->{$op}->{"filters"}}  
            || (defined $rule->{'state'} && $rule->{'state'} eq 'inactive')
	     ) {
	push(@{$filter_array}, $filter) ;
      }
    }
  }
}

1;
