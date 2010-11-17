package Kynetx::Postlude;
# file: Kynetx/Postlude.pm
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
use Kynetx::Events;
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
        delete_persistent_var( $domain,$req_info->{'rid'}, $session, $expr->{'name'} );
    } elsif ( $expr->{'action'} eq 'set' ) {
        $logger->debug( "expr: ", sub { Dumper($expr) } );
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
            $logger->debug( "Set value ", $expr->{'name'}, " to $value" );
            save_persistent_var($domain, $req_info->{'rid'}, $session, $expr->{'name'}, $value );
        } else {
            $logger->debug( "Set called for ", $expr->{'name'}, " as flag" );
            save_persistent_var($domain, $req_info->{'rid'}, $session, $expr->{'name'} );
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
        increment_persistent_var( $domain, $req_info->{'rid'}, $session, $expr->{'name'}, $by,
                                 $from );
    } elsif ( $expr->{'action'} eq 'forget' ) {
            delete_persistent_element($domain, $req_info->{'rid'}, $session, $expr->{'name'},
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
        add_persistent_element($domain, $req_info->{'rid'}, $session, $expr->{'name'}, $url );
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
    $js = Kynetx::Log::explicit_callback( $req_info, $rule_name, $log_val );

    # this puts the statement in the log data for when debug is on
    $logger->debug( $msg, $log_val );

    # huh?    return $msg . $log_val;
    return $js;
}

sub eval_control_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $js = '';

    if ( $expr->{'statement'} eq 'last' ) {
        $req_info->{ $req_info->{'rid'} . ':__KOBJ_EXEC_LAST' } = 1;
    }

    return $js;
}

sub eval_raise_statement {
    my ( $expr, $session, $req_info, $rule_env, $rule_name ) = @_;

    my $logger = get_logger();

    my $js = '';

#    $logger->debug("Event Expr: ", sub {Dumper($expr)});
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

    my $new_req_info = {
                         'eventtype' => $event_name,
                         'domain'    => $expr->{'domain'}
    };

    foreach my $m ( @{ $expr->{'modifiers'} } ) {
        $new_req_info->{ $m->{'name'} } =
          Kynetx::Expressions::den_to_exp(
                   Kynetx::Expressions::eval_expr(
                       $m->{'value'}, $rule_env, $rule_name, $req_info, $session
                   )
          );

    }

    #    my $rid = $expr->{'ruleset'}->{'rid'} || $req_info->{'rid'}
    my $rids = Kynetx::Expressions::den_to_exp(
        eval_expr_with_default(
                                $expr->{'ruleset'},
                                $req_info->{'rid'},    # default value
                                $rule_env,
                                $rule_name,
                                $req_info,
                                $session
        )
    );

    # normalize
    unless ( ref $rids eq 'ARRAY' ) {
        $rids = [$rids];
    }

    foreach my $rid_and_ver ( map { split( /\./, $_, 2 ) } @{$rids} ) {

        my ( $rid, $ver );
        if ( ref $rid_and_ver eq 'ARRAY' ) {
            ( $rid, $ver ) = @{$rid_and_ver};
        } else {
            ( $rid, $ver ) = ( $rid_and_ver, 0 );
        }

        $logger->debug(
               "Raising explicit event $expr->{'domain'}:$event_name for $rid");

        my $schedule = $req_info->{'schedule'};

        # merge in the incoming request info
        my $this_req_info =
          Kynetx::Request::merge_req_env( $req_info, $new_req_info );

        if ($ver) {

            # remove the v from numeric version numbers
            if ( $ver =~ /v\d+/ ) {
                $ver =~ s/v(\d+)/$1/;
            }
            $this_req_info->{ $rid . ':kynetx_app_version' } = $ver;
        } else {

# if we're raising an event on a new RID and we don't have a version ensure it's in the same mode (dev or production)
            if ( $req_info->{ $req_info->{'rid'} . ':kynetx_app_version' } ) {
                $this_req_info->{ $rid . ':kynetx_app_version' } =
                  $req_info->{ $req_info->{'rid'} . ':kynetx_app_version' };
            }
        }
        $logger->debug( "Raising explicit event for RID $rid, version "
                        . $this_req_info->{ $rid . ':kynetx_app_version' } )
          if $rid && $this_req_info->{ $rid . ':kynetx_app_version' };

        my $ev = Kynetx::Events::mk_event($this_req_info);

        # this side-effects the schedule
        Kynetx::Events::process_event_for_rid( $ev, $this_req_info, $session,
                                               $schedule, $rid, );
    }

    return $js;
}

sub eval_expr_with_default {
    my ( $expr, $default, $rule_env, $rule_name, $req_info, $session ) = @_;
    my $logger = get_logger();

    #  $logger->debug("Raise exp ", sub{ Dumper($expr) });

    my $val;
    if ( defined $expr ) {
        $val = Kynetx::Expressions::eval_expr( $expr, $default, $rule_env,
                                              $rule_name, $req_info, $session );

        if (
            (
               !defined $val || ( ref $val eq 'HASH' && !defined $val->{'val'} )
            )
            && $expr->{'type'} eq 'var'
          )
        {    # not really a var
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
