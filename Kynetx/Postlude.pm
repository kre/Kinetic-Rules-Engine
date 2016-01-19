package Kynetx::Postlude;
# file: Kynetx/Postlude.pm
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
#use warnings;

use Log::Log4perl qw(get_logger :levels);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          eval_post_expr
          get_precondition_test
          get_precondition_vars
          eval_persistent_expr
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use JSON::XS;

use Kynetx::Expressions qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Rids qw/:all/;
use Kynetx::Errors;
use Kynetx::Dispatch;
use Kynetx::Parser qw/mk_expr_node/;
use Kynetx::Log;
use Kynetx::Persistence qw(:all);
use Kynetx::Persistence::SchedEv;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Devel::Size qw(
  size
  total_size
);


sub eval_post_expr {
    my ( $rule, $session, $req_info, $rule_env, $fired, $execenv ) = @_;

    my $js = '';

    my $logger = get_logger();
    $logger->debug( "[post] evaling post expressions with rule ",
                    $fired ? "fired" : "notfired" );

    # set up post block execution
    my ( $cons, $alt );
    if ( ref $rule->{'post'} eq 'HASH' ) {
        my $type = $rule->{'post'}->{'type'};
        if ( $type eq 'fired' ) {
            $cons = $rule->{'post'}->{'cons'};
            $alt  = $rule->{'post'}->{'alt'};
        } elsif ( $type eq 'notfired' ) {    # reverse sense
            $cons = $rule->{'post'}->{'alt'};
            $alt  = $rule->{'post'}->{'cons'};
        } elsif ( $type eq 'always' ) {      # cons is executed on both paths
            $cons = $rule->{'post'}->{'cons'};
            $alt  = $rule->{'post'}->{'cons'};
        }
    }

    # there's only persistent expressions
    if ($fired) {
        $logger->debug("[post] evaling consequent");
        $js .= join(
            " ",
            map {
                eval_post_statement( $_, $session, $req_info, $rule_env,
                                     $rule->{'name'}, $execenv )
              } @{$cons}
        );
    } else {
        $logger->debug("[post] evaling alternate");
        $js .= join(
            " ",
            map {
                eval_post_statement( $_, $session, $req_info, $rule_env,
                                     $rule->{'name'}, $execenv )
              } @{$alt}
        );
    }

}

sub eval_post_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name, $execenv ) = @_;

    my $logger = get_logger();

    #default to true if not present
    my $test = 1;
    if ( defined $expr->{'test'} && 
	 (defined $expr->{'test'}->{'type'} && 
	   $expr->{'test'}->{'type'} eq 'if')
       ) {
        $test =
          Kynetx::Expressions::den_to_exp(
                 Kynetx::Expressions::eval_expr(
                     $expr->{'test'}->{'expr'}, $rule_env, $rule_name, $req_info, $session
                 )
          );

        $logger->debug( "[post] Evaluating statement guard. Result->", $test );
    } elsif ( defined $expr->{'test'} && 
	 (defined $expr->{'test'}->{'type'} && 
	  $expr->{'test'}->{'type'} eq 'on' &&
	  $expr->{'test'}->{'value'} eq 'final' 
	 )
       ) {

      if (Kynetx::Request::get_final_flag($req_info)) {
	$test = 1;
	Kynetx::Request::clr_final_flag($req_info);
      } else {
	$test = 0;
      }
      $logger->debug( "[post] Checking if final; Result->", $test );
    }


    if ( $expr->{'type'} eq 'persistent' && $test ) {
    	my $p_expr = eval_persistent_expr( $expr,     $session, $req_info,
                              $rule_env, $rule_name );
    	if (Kynetx::Errors::mis_error($p_expr)) {
            	Kynetx::Errors::raise_error($req_info, 
					$expr->{'level'} || 'error',
					$p_expr->{'DEBUG'},
					{'rule_name' => $rule_name,
				 	'genus' => 'postlude',
				 	'species' => 'persistent'
					}
			      );
    		
    	} else {
    		return $p_expr;
    	}
        
    } elsif ( $expr->{'type'} eq 'log' && $test ) {
        return
          eval_log_statement( $expr,     $session, $req_info,
                              $rule_env, $rule_name );
    } elsif ( $expr->{'type'} eq 'error' && $test ) {
        return
          eval_error_statement( $expr,     $session, $req_info,
				$rule_env, $rule_name );
    } elsif ( $expr->{'type'} eq 'control' && $test ) {
        return
          eval_control_statement( $expr,     $session, $req_info,
                                  $rule_env, $rule_name );
    } elsif ( $expr->{'type'} eq 'raise' && $test ) {
        return
          eval_raise_statement( $expr,     $session, $req_info,
                                $rule_env, $rule_name );
    } elsif ( $expr->{'type'} eq 'schedule' && $test ) {
        return
          eval_schedule_statement( $expr,     $session, $req_info,
                                $rule_env, $rule_name );
    } else {
        return '';
    }

}

sub eval_persistent_expr {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    # $logger->debug("[post] ", sub {Dumper($expr)});

    my $js = '';
    my $domain = $expr->{'domain'};

    if ( $expr->{'action'} eq 'clear' ) {
    	#### Persistent destroy
      delete_persistent_var( $domain,get_rid($req_info->{'rid'}), $session, $expr->{'name'} );
    } elsif ( $expr->{'action'} eq 'clear_hash_element' ) {
      $logger->trace("Clear: ", sub {Dumper($expr)});
      my $name = $expr->{'name'};
      my $path_r = $expr->{'hash_element'};
      my $path = Kynetx::Util::normalize_path($req_info, $rule_env, $rule_name, $session, $path_r);
      Kynetx::Persistence::delete_persistent_hash_element($domain,get_rid($req_info->{'rid'}),$session,$name,$path);
    } elsif ( $expr->{'action'} eq 'set' ) {
      #### Persistent setter
      $logger->trace( "expr: ", sub { Dumper($expr) } );
      my $value;
      if ( $expr->{'value'} ) {
	$value =
	  Kynetx::Expressions::den_to_exp(
					  Kynetx::Expressions::eval_expr(
					 $expr->{'value'}, $rule_env, $rule_name,
									 $req_info,        $session
									)
					 );
      }
      if ($value) {
	$logger->trace( "Set value ", $expr->{'name'}, " to $value" );
            if (Kynetx::MongoDB::validate($value)) {
            	save_persistent_var($domain, get_rid($req_info->{'rid'}), $session, $expr->{'name'}, $value );
            } else {
		my $size = Devel::Size::total_size($value);
            	my $msg = $expr->{'name'} . " is too large ($size bytes)";
            	return Kynetx::Errors::merror($msg);
            }
            
        } else {
            $logger->trace( "Set called for ", $expr->{'name'}, " as flag" );
            save_persistent_var($domain, get_rid($req_info->{'rid'}), $session, $expr->{'name'} );
        }
    } elsif ($expr->{'action'} eq 'set_hash') {
    	my $name = $expr->{'name'};
    	my $path_r = $expr->{'hash_element'};
    	my $path = Kynetx::Util::normalize_path($req_info, $rule_env, $rule_name, $session, $path_r);
    	if (! defined $path) {
    		$logger->error("Hash key for $name is undefined");
    		return $js;
    	}
    	my $value = Kynetx::Expressions::den_to_exp(
                    	Kynetx::Expressions::eval_expr(
                        	$expr->{'value'}, $rule_env, $rule_name,
                        	$req_info,        $session
                    ));
        if (! defined $value) {
        	$logger->error("Hash Operation error: $name Value may not be null (use clear to remove key) ");
        	return $js;
        }
        if (Kynetx::MongoDB::validate($value)) {
			Kynetx::Persistence::save_persistent_hash_element($domain,
					get_rid($req_info->{'rid'}),
					$session,
					$name,
					$path,
					$value);
        } else {
	    my $size = Devel::Size::total_size($value);
	    my $msg = $expr->{'name'} . "[". join(",", @{$path}) . "] is too large ($size bytes)";
	    return Kynetx::Errors::merror($msg);        	
        }
    } elsif ( $expr->{'action'} eq 'iterator' ) {
        my $op = $expr->{'op'};
        $op =~ s/^\s+//;
        my $by =
          Kynetx::Expressions::den_to_exp(
                                    Kynetx::Expressions::eval_expr(
                                        $expr->{'value'}, $rule_env, $rule_name,
                                        $req_info,        $session
                                    )
          );
        $by = -$by if ( $op eq '-=' );
        my $from =
          Kynetx::Expressions::den_to_exp(
                 Kynetx::Expressions::eval_expr(
                     $expr->{'from'}, $rule_env, $rule_name, $req_info, $session
                 )
          );
        increment_persistent_var( $domain, get_rid($req_info->{'rid'}), $session, $expr->{'name'}, $by,
                                 $from );
    } elsif ( $expr->{'action'} eq 'forget' ) {
            delete_trail_element($domain, get_rid($req_info->{'rid'}), $session, $expr->{'name'},
                            $expr->{'regexp'} );
    } elsif ( $expr->{'action'} eq 'mark' ) {
        my $url =
          defined $expr->{'with'}
          ? Kynetx::Expressions::den_to_exp(
                                 Kynetx::Expressions::eval_expr(
                                     $expr->{'with'}, $rule_env, $rule_name,
                                     $req_info,       $session
                                 )
          )
          : $req_info->{'caller'};

        #	    $logger->debug("Marking trail $expr->{'name'} with $url");
        add_trail_element($domain, get_rid($req_info->{'rid'}), $session, $expr->{'name'}, $url );
    } else {
        $logger->error(
                      "Bad action in persistent expression: $expr->{'action'}");
    }

    return $js;
}

sub eval_log_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    #    $logger->debug("eval_log_statement ", Dumper($expr));

    my $js = '';

    my $log_val =
      Kynetx::Expressions::den_to_exp(
                 Kynetx::Expressions::eval_expr(
                     $expr->{'what'}, $rule_env, $rule_name, $req_info, $session
                 )
      );

    my $msg = "Explicit log value: ";
    if ( $log_val eq ':session_id' ) {
        $msg     = "Session ID: ";
        $log_val = Kynetx::Session::session_id($session);
    }

    # call the callback server here with a HTTP GET
#    $js = Kynetx::Log::explicit_callback( $req_info, $rule_name, $log_val );

    # this puts the statement in the log data for when debug is on
    $logger->info( $msg, Kynetx::Json::perlToJson($log_val) );
    $js = join("", 
               "KOBJ.log('",
	       $msg,
	       $log_val,
	       "');"
	      );
    return $js;
}

sub eval_error_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    #    $logger->debug("eval_log_statement ", Dumper($expr));

    my $js = '';

    my $msg_val =
      Kynetx::Expressions::den_to_exp(
                 Kynetx::Expressions::eval_expr(
                     $expr->{'what'}, $rule_env, $rule_name, $req_info, $session
                 )
      );

    Kynetx::Errors::raise_error($req_info, 
				$expr->{'level'} || 'warn',
				$msg_val,
				{'rule_name' => $rule_name,
				 'genus' => 'user',
				 'species' => 'error'
				}
			       );





    # this puts the statement in the log data for when debug is on
    $logger->info("Explicit user error", Kynetx::Json::perlToJson($msg_val));
#    $logger->debug("Explicit user error", $msg_val );

    return $js;
}

sub eval_control_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $js = '';

    if ( $expr->{'statement'} eq 'last' ) {
        $req_info->{ get_rid($req_info->{'rid'}) . ':__KOBJ_EXEC_LAST' } = 1;
    }

    return $js;
}

sub _eventname {
  my ($expr, $session, $req_info, $rule_env, $rule_name) = @_;
  my $logger = get_logger();
  return Kynetx::Expressions::den_to_exp(
        eval_expr_with_default(
                               $expr->{'event'},
                               'foo',              # default value can't be seen
                               $rule_env,
                               $rule_name,
                               $req_info,
                               $session
        )
    );
  
}

sub _domainname {
  my ($expr) = @_;
  my $allowed = {'explicit' => 1,
	   'http' => 1,
	   'system' => 1,
	   'cloudos' => 1,
	   'notification' => 1 ,
	   'pds' => 1 ,
	   'error' => 1,
	   'gtour' => 1,
	   'test' => 1,
	   'fuse' => 1,
	   'carvoyant' => 1,
  	   'location' => 1,
	   'nano_manager' => 1,
	   'wrangler' => 1,
	  };
  if ($allowed->{$expr->{'domain'}}) {
    return $expr->{'domain'}
  } else {
    return 'explicit'
  }
}

sub eval_schedule_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;
    my $logger = get_logger();
    my $js = '';
    my $rid = get_rid($req_info->{'rid'});
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    my $event_name = _eventname($expr, $session, $req_info, $rule_env, $rule_name);
    my $domain = _domainname($expr);
    
    #get modifiers
    my $mods;
    foreach my $m ( @{ $expr->{'modifiers'} } ) {
      my $val = Kynetx::Expressions::den_to_exp(
		    Kynetx::Expressions::eval_expr($m->{'value'}, $rule_env, $rule_name, $req_info, $session )
		  );
		  $mods->{$m->{'name'}} = $val;
    }
    
    # attributes clause
    if ( defined $expr->{'attributes'}) {
      my $attrs = Kynetx::Expressions::den_to_exp(
  		    Kynetx::Expressions::eval_expr(
            $expr->{'attributes'}, 
  		      $rule_env, 
  		      $rule_name, 
            $req_info, 
            $session));
      foreach my $k ( keys %{ $attrs } ) {
	       $mods->{$k} = $attrs->{$k};
      }
    }
    
    # Choose singleton or repeating event
    my $sched_id;
    my $timespec = $expr->{'timespec'};
    if ($timespec->{'repeat'}) {
      my $val = Kynetx::Expressions::den_to_exp(
                  Kynetx::Expressions::eval_expr(
                    $timespec->{'repeat'}, 
                    $rule_env, 
                    $rule_name, 
                    $req_info, 
                    $session 
                  )
                );
      $sched_id =   Kynetx::Persistence::SchedEv::repeating_event($ken,$rid,$domain,$event_name,$val,$mods);  
      if ($sched_id) {
        $logger->debug("Create repeating event $domain / $event_name, first occurance $val")
      }      
    } else {
      my $once;
      my $val = Kynetx::Expressions::den_to_exp(
            Kynetx::Expressions::eval_expr(
              $timespec->{'once'}, 
              $rule_env, 
              $rule_name, 
              $req_info, 
              $session 
            )
          );
      if ($val) {
        $once = $val;
      } else {
        $once = Kynetx::Predicates::Time::now();
      }
      $sched_id = Kynetx::Persistence::SchedEv::single_event($ken,$rid,$domain,$event_name,$val,$mods);
      if ($sched_id) {
        $logger->debug("Create single event $domain / $event_name at $val")
      }      
    }
    if ($sched_id && defined $expr->{"setting"}) { # store the ID
      my $var = $expr->{"setting"}->[0];
      $logger->debug("Storing ID $sched_id for ", $var);
      Kynetx::Environments::add_to_env({$var => $sched_id}, $rule_env);
      $logger->debug("Looking up ", $var, " -> ", Kynetx::Environments::lookup_rule_env($var, $rule_env) );
    }      
    $logger->debug("Created scheduled event ($sched_id)"); 
    return $js;
}

sub eval_raise_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    my $js = '';

#    $logger->debug("Event Expr: ", sub {Dumper($expr)});

    # event name can be an expression
    my $event_name = _eventname($expr, $session, $req_info, $rule_env, $rule_name);
    $expr->{'domain'} = _domainname($expr);

    # build a new request
    my $new_req_info = {
                         'eventtype' => $event_name,
                         'domain'    => $expr->{'domain'}
    };


    Kynetx::Request::add_event_attr($new_req_info,  
     				    '_generatedby', 
     				    Kynetx::Rids::print_rid_info($req_info->{'rid'}));

    # with clause
    foreach my $m ( @{ $expr->{'modifiers'} } ) {
      my $val = Kynetx::Expressions::den_to_exp(
		  Kynetx::Expressions::eval_expr(
                    $m->{'value'}, $rule_env, $rule_name, $req_info, $session
                  )
		);
      Kynetx::Request::add_event_attr($new_req_info,  $m->{'name'}, $val);
#      $new_req_info->{ $m->{'name'} } = $val;

    }
 
    # attributes clause
    if ( defined $expr->{'attributes'}) {
      my $attrs = Kynetx::Expressions::den_to_exp(
  		    Kynetx::Expressions::eval_expr(
                      $expr->{'attributes'}, 
		      $rule_env, 
		      $rule_name, 
                      $req_info, 
                      $session
                    ));
      foreach my $k ( keys %{ $attrs } ) {
	Kynetx::Request::add_event_attr($new_req_info, $k, $attrs->{$k})
#        $new_req_info->{ $k } =  $attrs->{$k};
      }
    }
 
    # use the calculated versions
    my $domain = $new_req_info->{'domain'};
    my $eventtype = $new_req_info->{'eventtype'};

    #$logger->debug("New req env: ", sub{Dumper $new_req_info});

    # merge in the incoming request info
    my $this_req_info =
	Kynetx::Request::merge_req_env( $req_info, $new_req_info );


#    $logger->debug("[eval_raise] req_info: ", sub { Dumper $this_req_info} );

    my ($rid_info_list, $unfiltered_rid_list);
    
    # if there was a calculated ridlist, use it. Otherwise get salience
    if (defined $expr->{'ruleset'}            ||
	(defined $new_req_info->{'_api'} &&   # allow us to force sky
	 $new_req_info->{'_api'} eq 'blue')
       ) {   # this is what we do for blue

      $logger->debug("Processing raise with BLUE api");
      # rid list can be an expression
      my $rids = Kynetx::Expressions::den_to_exp(
    		    eval_expr_with_default(
			$expr->{'ruleset'},
 		        # default value is current ruleset
			get_rid($req_info->{'rid'}).".".get_version($req_info->{'rid'}),    
			$rule_env,
			$rule_name,
			$req_info,
			$session
		       )
		);

      $rid_info_list = Kynetx::Rids::parse_rid_list($req_info, $rids);
      $logger->debug("RID List to raise event for: ", sub {Dumper $rid_info_list} );

      # # normalize, if it's not an array, make it one
      # unless ( ref $rids eq 'ARRAY' ) {
      #   $rids = [$rids];
      # }
      # foreach my $rid_and_ver (map { split( /\./, $_, 2 ) } @{$rids}) {
      # 	my ( $rid, $ver );
      # 	if ( ref $rid_and_ver eq 'ARRAY' ) {
      # 	  ( $rid, $ver ) = @{$rid_and_ver};
      # 	} else {
      # 	  ( $rid, $ver ) = ( $rid_and_ver, 0 );
      # 	}
      # 	push(@{ $rid_info_list }, 
      # 	     mk_rid_info($req_info, $rid, {'version' => $ver})
      # 	    );
	
      # }
      
    } else {
      $logger->debug("Processing raise with SKY api");
      $unfiltered_rid_list = Kynetx::Dispatch::calculate_rid_list($this_req_info, $session);

#      $logger->debug("Looking at rid_list ", sub { Dumper $unfiltered_rid_list} );
      $rid_info_list = $unfiltered_rid_list->{$domain}->{$eventtype} || [];

      # this needs to be done better; 
      # ensure that the current RID.ver is on the list. restar
      my $found = 0;
      foreach my $rid ( @{ $rid_info_list }) {
       	$found = 1 if (get_rid($rid) eq get_rid($this_req_info->{'rid'}) &&
       		       get_version($rid) eq get_version($this_req_info->{'rid'}));
      }
      unless ( $found ) {
      	push(@{ $rid_info_list }, $this_req_info->{'rid'});
      }
    }


    my $saved_rid = $req_info->{'rid'};

    foreach my $rid_and_ver (  @{$rid_info_list} ) {


      my $rid = get_rid($rid_and_ver);
      my $ver = get_version($rid_and_ver);

      # trying to track down the version becoming the rid
      # I think this is solved...[PJW]
      # if ($rid eq 'prod' || $rid eq 'dev') {

      # 	$logger->info("rid_info_list: ", sub { Dumper $rid_info_list },
      # 		      "\nunfiltered_rid_list: ", sub { Dumper $unfiltered_rid_list },
      # 		      "\nrid_and_ver: ", sub {Dumper $rid_and_ver},
      # 		      "\nreq_info: ", sub {Dumper $req_info }
      # 		     );
      # 	next;
      # }


      if ( $ver =~ /v\d+/ ) {
	$ver =~ s/v(\d+)/$1/;
      }
      $logger->debug(
               "Raising explicit event $domain:$eventtype for $rid:$ver");

      my $schedule = $req_info->{'schedule'};

      # make sure this is right
      $this_req_info->{'rid'} = 
	mk_rid_info($this_req_info, 
		    $rid,
		    {'version' => $ver});

      
      my $ev = Kynetx::Events::mk_event($this_req_info);
      $logger->trace("Event is: ", sub {Dumper($ev)});

#    $logger->debug("Using req env: ", sub{Dumper $this_req_info});

      # this side-effects the schedule
      #	$logger->debug("Ready to process event...");
      Kynetx::Events::process_event_for_rid( $ev, 
					     $this_req_info, 
					     $session,
					     $schedule, 
					     $this_req_info->{'rid'}
					   );
    }

    # something seems to be side-effecting $req_info even tho we don't pass it in...
    # this is a hack. What else is being changed? 
    $req_info->{'rid'} = $saved_rid;

    # this we know about...
    Log::Log4perl::MDC->put( 'site', Kynetx::Rids::get_rid($saved_rid) );


    return $js;
  }

sub eval_expr_with_default {
    my ( $expr, $default, $rule_env, $rule_name, $req_info, $session ) = @_;
    my $logger = get_logger();

#      $logger->debug("Raise exp ", sub{ Dumper($expr) });

    my $val;
    if ( defined $expr ) {
        $val = Kynetx::Expressions::eval_expr( $expr,
                                        $rule_env,
                                        $rule_name,
                                        $req_info,
                                        $session );

        if ((! defined $val ||
             ( ref $val eq 'HASH' && !defined $val->{'val'} )) &&
             $expr->{'type'} eq 'var') {    # not really a var
                # use variable name as the result
            #      $logger->debug("Using var name as result");
            $val = mk_expr_node( 'str', $expr->{'val'} );
        }
    } else {
        $val =
          mk_expr_node( Kynetx::Expressions::infer_type($default), $default );
    }

#      $logger->debug("Raise result ", sub{ Dumper($val) });
    return $val;

}

1;
