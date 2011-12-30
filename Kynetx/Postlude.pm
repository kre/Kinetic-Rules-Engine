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
use warnings;

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

use Kynetx::Expressions qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Rids qw/:all/;
use Kynetx::Errors;
use Kynetx::Dispatch;
use Kynetx::Parser qw/mk_expr_node/;
use Kynetx::Log;
use Kynetx::Persistence qw(:all);


use Data::Dumper;
$Data::Dumper::Indent = 1;

sub eval_post_expr {
    my ( $rule, $session, $req_info, $rule_env, $fired ) = @_;

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
                                     $rule->{'name'} )
              } @{$cons}
        );
    } else {
        $logger->debug("[post] evaling alternate");
        $js .= join(
            " ",
            map {
                eval_post_statement( $_, $session, $req_info, $rule_env,
                                     $rule->{'name'} )
              } @{$alt}
        );
    }

}

sub eval_post_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    #default to true if not present
    my $test = 1;
    if ( defined $expr->{'test'} ) {
        $test =
          Kynetx::Expressions::den_to_exp(
                 Kynetx::Expressions::eval_expr(
                     $expr->{'test'}, $rule_env, $rule_name, $req_info, $session
                 )
          );

        $logger->debug( "[post] Evaluating statement test", $test );
    }

    if ( $expr->{'type'} eq 'persistent' && $test ) {
        return
          eval_persistent_expr( $expr,     $session, $req_info,
                                $rule_env, $rule_name );
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
    } else {
        return '';
    }

}

sub eval_persistent_expr {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    #    $logger->debug("[post] ", $expr->{'type'});

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
            save_persistent_var($domain, get_rid($req_info->{'rid'}), $session, $expr->{'name'}, $value );
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
		Kynetx::Persistence::save_persistent_hash_element($domain,
				get_rid($req_info->{'rid'}),
				$session,
				$name,
				$path,
				$value);
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
    $logger->debug( $msg, $log_val );

    # huh?    return $msg . $log_val;
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
    $logger->debug("Explicit user error", $msg_val );

    # huh?    return $msg . $log_val;
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

sub eval_raise_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    my $js = '';

#    $logger->debug("Event Expr: ", sub {Dumper($expr)});

    # event name can be an expression
    my $event_name = Kynetx::Expressions::den_to_exp(
        eval_expr_with_default(
                               $expr->{'event'},
                               'foo',              # default value can't be seen
                               $rule_env,
                               $rule_name,
                               $req_info,
                               $session
        )
    );

    my $allowed = {'explicit' => 1,
		   'http' => 1,
		   'system' => 1,
		   'notification' => 1 ,
		   'error' => 1,
		  };

    unless ( $allowed->{$expr->{'domain'}} ) {
      $expr->{'domain'} = 'explicit';
    }


    my $new_req_info = {
                         'eventtype' => $event_name,
                         'domain'    => $expr->{'domain'}
    };

    foreach my $m ( @{ $expr->{'modifiers'} } ) {
      my $val = Kynetx::Expressions::den_to_exp(
		  Kynetx::Expressions::eval_expr(
                    $m->{'value'}, $rule_env, $rule_name, $req_info, $session
                  )
		);
      $new_req_info->{ $m->{'name'} } = $val;

    }
 
    # use the calculated versions
    my $domain = $new_req_info->{'domain'};
    my $eventtype = $new_req_info->{'eventtype'};

    my $rid_info_list;
    
    # if there was a calculated ridlist, use it. Otherwise get salience
    if (defined $expr->{'ruleset'} ||
	(defined $req_info->{'api'} && 
	 $req_info->{'api'} eq 'blue')  # this is what we do for blue
       ) {

      $logger->debug("Processing postlude with BLUE api");
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
      $logger->debug("Processing postlude with SKY api");
      my $unfiltered_rid_list = Kynetx::Dispatch::calculate_rid_list($req_info);
      $rid_info_list = $unfiltered_rid_list->{$domain}->{$eventtype} || [];
      my $found = 0;
      foreach my $rid( @{ $rid_info_list }) {
	$found = 1 if (get_rid($rid) eq get_rid($req_info->{'rid'}) &&
		       get_version($rid) eq get_version($req_info->{'rid'}));
      }
      unless ( $found ) {
	push(@{ $rid_info_list }, $req_info->{'rid'});
      }
    }


    foreach my $rid_and_ver (  @{$rid_info_list} ) {

      my $rid = get_rid($rid_and_ver);
      my $ver = get_version($rid_and_ver);

      if ( $ver =~ /v\d+/ ) {
	$ver =~ s/v(\d+)/$1/;
      }
      $logger->debug(
               "Raising explicit event $domain:$eventtype for $rid:$ver");

      my $schedule = $req_info->{'schedule'};

        # merge in the incoming request info
      my $this_req_info =
	Kynetx::Request::merge_req_env( $req_info, $new_req_info );

      # make sure this is right
      $this_req_info->{'rid'} = 
	mk_rid_info($this_req_info, 
		    $rid,
		    {'version' => $ver});

      
      my $ev = Kynetx::Events::mk_event($this_req_info);
      $logger->trace("Event is: ", sub {Dumper($ev)});

      # this side-effects the schedule
      #	$logger->debug("Ready to process event...");
      Kynetx::Events::process_event_for_rid( $ev, 
					     $this_req_info, 
					     $session,
					     $schedule, 
					     $this_req_info->{'rid'}
					   );
    }

    return $js;
  }

sub eval_expr_with_default {
    my ( $expr, $default, $rule_env, $rule_name, $req_info, $session ) = @_;
    my $logger = get_logger();

    #  $logger->debug("Raise exp ", sub{ Dumper($expr) });

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

    #  $logger->debug("Raise result ", sub{ Dumper($val) });
    return $val;

}

1;
