package Kynetx::Events;
# file: Kynetx/Events.pm
# file: Kynetx/Predicates/Referers.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Errors;
use Kynetx::Request;
use Kynetx::Rids qw/:all/;
use Kynetx::Rules;
use Kynetx::Json;
use Kynetx::Scheduler;
use Kynetx::Response;
use Kynetx::Persistence qw(:all);
use Kynetx::Persistence::UserState qw(
	get_current_state
	set_current_state
	delete_current_state
);
use Kynetx::Events::Primitives qw(:all);
use Kynetx::Events::State qw(:all);
use Kynetx::Util qw(:all);

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

    # 0 = "blue"
    # 1 = "event|flush"
    $domain = $path_components[2];
    $eventtype = $path_components[3];
    $rid = $path_components[4] || 'any';
    $eid = $path_components[5] || '';


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

    my ( $r, $domain, $eventtype, $rids, $eid, $version ) = @_;

    my $logger = get_logger();
    
    # APR::Tables require a key (no 'keys' function)
    my $request_rec_notes = $r->pnotes('K');
    
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
      Kynetx::Request::build_request_env($r, 
					 $domain, 
					 $rids, 
					 $eventtype, 
					 $eid,  
					 {'api' => 'blue'
					 });


    Kynetx::Request::log_request_env( $logger, $req_info );
    
    # Extend $req_info if we have any extra information passed in through the pnotes
    # Add the data as params
    if (defined $request_rec_notes) {
    	my @keys = keys (%$request_rec_notes);
    	foreach my $key (@keys) {
    		$req_info->{$key} = $request_rec_notes->{$key};
    		$logger->trace("PNOTES: $key ", $request_rec_notes->{$key});
    	}
    	push(@{$req_info->{'param_names'}}, @keys);
    }

    # get a session, if _sid param is defined it will override cookie
    $logger->trace("KBX cookie? ",$req_info->{'kntx_token'});
    my $session = process_session($r, $req_info->{'kntx_token'});
    
    if (defined $version) {
    	$req_info->{'kynetx_app_version'} = $version;
    }


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

      my $rid_info = mk_rid_info($req_info, $rid);

      eval {
	process_event_for_rid( $ev, $req_info, $session, $schedule, $rid_info );
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
    my $dd = Kynetx::Response->create_directive_doc($req_info->{'eid'});
    my $js = '';
    $js .= eval {
      Kynetx::Rules::process_schedule( $r, $schedule, $session, $eid,$req_info, $dd );
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

    Kynetx::Response::respond( $r, $req_info, $session, $js, $dd, "Event" );

}

sub process_event_for_rid {
    my $ev       = shift;
    my $req_info = shift;
    my $session  = shift;
    my $schedule = shift;
    my $rid_info = shift;

    my $logger = get_logger();

    my $rid = get_rid($rid_info);

   #  $logger->debug("Req info: ", sub {Dumper $req_info} );

    $logger->debug("Processing events for $rid");
    Log::Log4perl::MDC->put( 'site', $rid );

    my $ruleset = Kynetx::Rules::get_rule_set($req_info, 1, $rid, get_version($rid_info)); # 1 for localparsing

    my $type = $ev->get_type();
    my $domain = $ev->get_domain();

    $logger->debug("Event domain is $domain and type is $type");
    $logger->trace("Rule list is ", sub{Dumper $ruleset->{'rule_lists'}->{$domain}->{$type}});

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
    $logger->trace("Schedule: ", sub {Dumper($schedule)});
    foreach my $rule ( @{ $ruleset->{'rule_lists'}->{$domain}->{$type}->{'rulelist'} } ) {

      $logger->debug("Processing rule $rule->{'name'}");

    	$rule->{'state'} ||= 'active';

        Log::Log4perl::MDC->put( 'rule', $rule->{'name'} ); # no rule for now...

        my $sm_current_name = $rule->{'name'} . ':sm_current';
        my $event_list_name = $rule->{'name'} . ':event_list';

    	$logger->trace("Rule: ", sub {Dumper $rule});

    	$logger->trace("Op: ", $rule->{'pagetype'}->{'event_expr'}->{'op'});
	
    	next unless defined $rule->{'pagetype'}->{'event_expr'}->{'op'};

    	my $sm = $rule->{'event_sm'};
    	$logger->trace("State machine: ", sub {Dumper($sm)});

        # States stored in Mongo should be serialized
        my $current_state = get_current_state($rid, $session, $rule->{'name'} ) || $sm->get_initial();

        my $next_state = $sm->next_state( $current_state, $ev,$rid, $session, $rule->{'name'} );

        $logger->trace("Current: ", $current_state );
        $logger->trace("Next: ", $next_state );

        # when there's a state change, store the event in the event list
        unless ( $current_state eq $next_state ) {
	  my $json = $ev->serialize();
	  Kynetx::Persistence::add_trail_element("ent", $rid, $session, $event_list_name, $json );
	  $logger->trace("State change for $rule->{'name'}");
	}

        if ( $sm->is_final($next_state) ) {

            my $rulename = $rule->{'name'};

            $logger->debug( "Adding to schedule: ", Kynetx::Rids::print_rid_info($rid_info), " & ", $rulename );
            my $task = $schedule->add( $rid, $rule, $ruleset, $req_info, {'ridver' => get_version($rid_info)} );

            # get event list and reset+
            my $event_list_name = $rulename . ':event_list';

            my $var_list = [];
            my $val_list = [];
            $logger->trace("Process sessions");
            while ( my $json =
                    consume_trail_element("ent", $rid, $session, $event_list_name, 1) )
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
            $sm->reset_state($rid, $session, $rule->{'name'},$event_list_name,$current_state,$next_state);
#            delete_current_state($rid, $session, $rule->{'name'} );
#
#            # reset event list for this rule
#            delete_persistent_var("ent", $rid, $session, $event_list_name );

        } else {
            $logger->trace("Next state not final");
            $logger->trace("Next state ref: ", ref $next_state);
            if ($next_state ne "") {
                set_current_state($rid, $session, $rule->{'name'}, $next_state );
            }

        }

    }
}

sub mk_event {
    my ($req_info) = @_;

    my $logger = get_logger();
	$logger->debug("Make event for ",$req_info->{'domain'},"/",$req_info->{'eventtype'} );
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
	$logger->trace("Event: ", sub {Dumper($ev)});
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
    $logger->trace("Rule: ", sub {Dumper($rule->{'name'})});
    $rule_lists->{$domain} = {} 
      unless $rule_lists->{$domain};
    $rule_lists->{$domain}->{$op} = {"rulelist" => [],
				     "filters" => [],
				    }
      unless $rule_lists->{$domain}->{$op};
    # put the rule in the array unless it's already there
    unless (grep {$_ eq $rule} @{$rule_lists->{$domain}->{$op}->{"rulelist"}}) {
      no warnings 'uninitialized';
      $logger->debug("Putting $rule->{'name'} on the list");
      push(@{$rule_lists->{$domain}->{$op}->{"rulelist"}}, $rule) 
	unless (defined $rule->{'state'} && $rule->{'state'} eq 'inactive');
    }

    my $filter;
    if ( $op eq 'pageview' ) {
    	$logger->trace("Pageview expression: ", sub {Dumper($eexpr)});
    	if ($eexpr->{'pattern'} || $eexpr->{'legacy'}) {
    		$logger->debug("Old form pageview");
	      $sm = mk_pageview_prim( $eexpr->{'pattern'}, $eexpr->{'vars'} );
	      $filter = [{type => "url",
			  pattern => $eexpr->{'pattern'} || ".*"
			 }];
	      add_filter($filter, $rule_lists, $domain, $op, $rule);    		
    	} elsif (defined $eexpr->{'filters'}) {
    		$logger->trace("Pageview filter request: ", sub {Dumper($eexpr->{'filters'})});
    		my $num = @{$eexpr->{'filters'}};
    		$logger->trace("Num filters: $num");
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
    			$logger->trace("Generic primitive");
    			$sm = mk_gen_prim($domain,$op, $eexpr->{'vars'},$eexpr->{'filters'});
    			add_filter($eexpr->{'filters'}, $rule_lists, $domain, $op, $rule);    			
    		}
    		$logger->trace("Created: ", sub {Dumper($sm)});
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
      $logger->trace(
		     "Creating Expression event for $domain:$op"
		    );
      $logger->trace("Eexpr: ", sub {Dumper($eexpr)});
      $sm = mk_expr_prim( $domain, $op,
			  $eexpr->{'vars'},   $eexpr->{'exp'} );        	

      add_filter([ANY], $rule_lists, $domain, $op, $rule);
        
    } else {
      $logger->trace(
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
	} elsif ( $eexpr->{'op'} eq 'after' ) {
	  $sm = mk_before( $sm1, $sm0 );
	} elsif ( $eexpr->{'op'} eq 'then' ) {
	  $sm = mk_then( $sm0, $sm1 );
	}
      }
  } elsif ($eexpr->{'type'} eq 'group_event') {
  	my $op_num = Kynetx::Expressions::den_to_exp($eexpr->{'op_num'});
  	my $agg_vars = $eexpr->{'agg_var'};
  	if ($eexpr->{'op'} eq 'repeat') {
  		my $sm0 = compile_event_expr( $eexpr->{'args'}->[0], $rule_lists, $rule );  		
  		$sm = mk_repeat($sm0,$op_num,$agg_vars);
  	} elsif ($eexpr->{'op'} eq 'count') {
  		my $sm0 = compile_event_expr( $eexpr->{'args'}->[0], $rule_lists, $rule );
  		$sm = mk_count($sm0,$op_num,$agg_vars);
  	} elsif ($eexpr->{'op'} eq 'any') {
  		$logger->trace("Event Expression: ", sub {Dumper($eexpr->{'args'})});
  		if (ref $eexpr->{'args'} eq "ARRAY") {
  			my @event_array = ();
  			my $num = Kynetx::Expressions::den_to_exp($eexpr->{'op_num'});
  			foreach my $sm_element (@{$eexpr->{'args'}}) {
  				$logger->trace("Eventex: ", sub {Dumper($sm_element)});
  				my $tsm = compile_event_expr( $sm_element, $rule_lists, $rule );
  				push(@event_array,$tsm);
  			}
  			$sm = mk_any(\@event_array,$num,$agg_vars);
  		}
	  	} else {
	  		$logger->warn("Unknown event operation: ", $eexpr->{'op'});
	  	}
  } elsif ($eexpr->{'type'} eq 'arity_event') {
  	  $logger->debug("E.expression: ", sub {Dumper($eexpr)});
		my @event_array = ();
		foreach my $sm_element (@{$eexpr->{'args'}}) {
			my $tsm = compile_event_expr( $sm_element, $rule_lists, $rule );
			push(@event_array,$tsm);
		}
		if ( $eexpr->{'op'} eq 'and' ) {
			$sm = mk_and_n(\@event_array);
		} elsif ($eexpr->{'op'} eq 'or') {
			$sm = mk_or_n(\@event_array);
		} elsif ($eexpr->{'op'} eq 'before') {
			$sm = mk_before_n(\@event_array);
		} elsif ($eexpr->{'op'} eq 'after') {
			$sm = mk_after_n(\@event_array);
		} elsif ($eexpr->{'op'} eq 'then') {
			$sm = mk_then_n(\@event_array);
		}
  } else {
    $logger->warn("Attempt to compile malformed event expression");
    $logger->trace("E.expression: ", sub {Dumper($eexpr)});
  }
  return $sm;

}

sub add_filter {
  my ($filters, $rule_lists, $domain, $op, $rule) = @_;

  my $filter_array = $rule_lists->{$domain}->{$op}->{"filters"};

  my $logger = get_logger();
  $logger->trace("Filters: ", sub {Dumper $filters});

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
