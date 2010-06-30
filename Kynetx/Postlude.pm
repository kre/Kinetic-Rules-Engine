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

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
eval_post_expr
get_precondition_test
get_precondition_vars
eval_persistent_expr
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Kynetx::Expressions qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Events;

sub eval_post_expr {
    my($rule, $session, $req_info, $rule_env, $fired) = @_;
    
    my $js = '';

    my $logger = get_logger();
    $logger->debug("[post] evaling post expressions with rule ",
		   $fired ? "fired" : "notfired"
	);


    # set up post block execution
    my($cons,$alt);
    if (ref $rule->{'post'} eq 'HASH') { 
	my $type = $rule->{'post'}->{'type'};
	if($type eq 'fired') {
	    $cons = $rule->{'post'}->{'cons'};
	    $alt = $rule->{'post'}->{'alt'};
	} elsif($type eq 'notfired') { # reverse sense
	    $cons = $rule->{'post'}->{'alt'};
	    $alt = $rule->{'post'}->{'cons'};
	} elsif($type eq 'always') { # cons is executed on both paths
	    $cons = $rule->{'post'}->{'cons'};
	    $alt = $rule->{'post'}->{'cons'};
	}
    }

    # there's only persistent expressions
    if($fired) {
	$logger->debug("[post] evaling consequent");
	$js .= join(" ", 
		    map {eval_post_statement($_, $session, $req_info, $rule_env, $rule->{'name'})} @{ $cons });
    } else {
	$logger->debug("[post] evaling alternate");
	$js .= join(" ", 
		    map {eval_post_statement($_, $session, $req_info, $rule_env, $rule->{'name'})} @{ $alt } );
    }


}

sub eval_post_statement {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

    my $logger = get_logger();

    #default to true if not present
    my $test = 1;
    if (defined $expr->{'test'}) {
      $test = den_to_exp(
	Kynetx::Expressions::eval_expr($expr->{'test'}, 
						  $rule_env, 
						  $rule_name,
						  $req_info, 
						  $session
				      ));

      $logger->debug("[post] Evaluating statement test", $test);
    }


    if ($expr->{'type'} eq 'persistent' && $test) {
      return eval_persistent_expr($expr, $session, $req_info, $rule_env, $rule_name);
    } elsif ($expr->{'type'} eq 'log' && $test) {
      return eval_log_statement($expr, $session, $req_info, $rule_env, $rule_name);
    } elsif ($expr->{'type'} eq 'control' && $test) {
      return eval_control_statement($expr, $session, $req_info, $rule_env, $rule_name);
    } elsif ($expr->{'type'} eq 'raise' && $test) {
      return eval_raise_statement($expr, $session, $req_info, $rule_env, $rule_name);
    } else {
      return '';
    }

  }

sub eval_persistent_expr {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

    my $logger = get_logger();
#    $logger->debug("[post] ", $expr->{'type'});

    my $js = '';

    if ($expr->{'action'} eq 'clear') {
	if($expr->{'domain'} eq 'ent') {
	    session_clear($req_info->{'rid'}, $session, $expr->{'name'});
	}
    } elsif ($expr->{'action'} eq 'set') {
	if($expr->{'domain'} eq 'ent') {
	    session_set($req_info->{'rid'}, $session, $expr->{'name'});
	}
    } elsif ($expr->{'action'} eq 'iterator') {
#	$logger->debug(Dumper($session));
	my $by = 
	    den_to_exp(
		eval_expr($expr->{'value'},
			     $rule_env,
			     $rule_name,
			     $req_info,
			     $session));
	$by = -$by if($expr->{'op'} eq '-=');
	my $from = 
	    den_to_exp(
		eval_expr($expr->{'from'},
			     $rule_env,
			     $rule_name,
			     $req_info,
			     $session));
	if($expr->{'domain'} eq 'ent') {
	    session_inc_by_from($req_info->{'rid'},
				$session,
				$expr->{'name'},
				$by,
				$from
		);
	}
#	$logger->debug(Dumper($session));
    } elsif ($expr->{'action'} eq 'forget') {
	if($expr->{'domain'} eq 'ent') {
	    session_forget($req_info->{'rid'},
			   $session,
			   $expr->{'name'},
			   $expr->{'regexp'});
	}
    } elsif ($expr->{'action'} eq 'mark') {
	if($expr->{'domain'} eq 'ent') {
	    my $url = defined $expr->{'with'} ?
		den_to_exp(
		    eval_expr($expr->{'with'},
				 $rule_env,
				 $rule_name,
				 $req_info,
				 $session)) 
		: $req_info->{'caller'};
#	    $logger->debug("Marking trail $expr->{'name'} with $url");
	    session_push($req_info->{'rid'},
			 $session,
			 $expr->{'name'},
			 $url
			 );
	}
    }

    return $js;
}


sub eval_log_statement {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

#    my $logger = get_logger();

#    $logger->debug("eval_log_statement ", Dumper($expr));

    my $js ='';

    # call the callback server here with a HTTP GET
    $js = explicit_callback($req_info, 
			    $rule_name, 
			    den_to_exp(
				       eval_expr($expr->{'what'},
						    $rule_env,
						    $rule_name,
						    $req_info,
						    $session)));

    return $js;
}


sub eval_control_statement {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

    my $js ='';

    if ($expr->{'statement'} eq 'last') {
      $req_info->{$req_info->{'rid'}.':__KOBJ_EXEC_LAST'} = 1;
    }

    return $js;
}


sub eval_raise_statement {
    my($expr, $session, $req_info, $rule_env, $rule_name) = @_;

    my $logger = get_logger();

    my $js ='';

    my $new_req_info = {'eventtype' => $expr->{'event'},
			'domain' => $expr->{'domain'}};

    foreach my $m (@{ $expr->{'modifiers'}}) {
      $new_req_info->{$expr->{'name'}} =
	  den_to_exp(eval_expr($expr->{'value'},
			       $rule_env,
			       $rule_name,
			       $req_info,
			       $session));

    }

    # merge in the incoming request info
    $new_req_info = Kynetx::Request::merge_req_env($req_info, 
						   $new_req_info);

    
    my $ev = Kynetx::Events::mk_event($new_req_info);

    # this side-effects the schedule
    Kynetx::Events::process_event_for_rid($ev,
					  $new_req_info,
					  $session,
					  $req_info->{'schedule'},
					  $expr->{'rid'} || $req_info->{'rid'},
					 );

    return $js;
}



1;
