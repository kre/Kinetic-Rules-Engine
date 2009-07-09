package Kynetx::Rules;
# file: Kynetx/Rules.pm
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


use Data::UUID;
use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

use Kynetx::Parser qw(:all);
use Kynetx::PrettyPrinter qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Datasets qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Predicates qw(:all);
use Kynetx::Actions qw(:all);
use Kynetx::Log qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Repository qw(:all);
use Kynetx::Environments qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
process_rules
eval_rule
eval_globals
get_rule_set 
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



sub process_rules {
    my ($r, $method, $rids) = @_;

    my $logger = get_logger();

    $r->subprocess_env(START_TIME => Time::HiRes::time);

    if($r->dir_config('run_mode') eq 'development') {
	# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
#        $r->connection->remote_ip('128.122.108.71'); # New York (NYU)
	$r->connection->remote_ip('72.21.203.1'); # Seattle (Amazon)
#        $r->connection->remote_ip('128.187.16.242'); # Utah (BYU)
	$logger->debug("In development mode using IP address ", $r->connection->remote_ip());
    } 



    # get a session hash 
    my $session = process_session($r);

    my $req_info = Kynetx::Request::build_request_env($r, $method, $rids);

    # initialization
    my $js = '';
    my $rule_env = empty_rule_env();
    
    my @rids = split(/;/, $rids);
    # if we sort @rids we change ruleset priority
    foreach my $rid (@rids) {
	Log::Log4perl::MDC->put('site', $rid);
	$js .= eval_ruleset($r, $req_info, $rule_env, $session, $rid);
    }

    # put this in the logging DB
    log_rule_fire($r, 
		  $req_info, 
		  $session
	);

    # return the JS load to the client
    $logger->info("finished");


    # this is where we return the JS
    print $js;

}


sub eval_ruleset {
    my ($r, $req_info, $rule_env, $session, $rid) = @_;

    my $logger = get_logger();

    Log::Log4perl::MDC->put('rule', '[global]');

    $req_info->{'rid'} = $rid; # override with the one we're working on

    $logger->info("Processing rules for site " . $req_info->{'rid'});

    my ($rules, $this_rule_env, $ruleset) = 
	get_rule_set($r->dir_config('svn_conn'),
		     $req_info
	            );

    
    # yes, you need to set the arrays and then use them since "keys" & "values" are context aware
#    my @this_keys = keys %{ $this_rule_env };
#    my @this_values = values %{ $this_rule_env };

#    $logger->debug('Keys after rule selection: ', Dumper());

    # side effects environment with precondition pattern values
    $rule_env = extend_rule_env($this_rule_env, $rule_env);


#    $logger->debug('Env after rule selection: ', Dumper($rule_env));

    Kynetx::Request::log_request_env($logger, $req_info);

    my $js;


    # handle globals, start js build, extend $rule_env
    ($js, $rule_env) = eval_globals($req_info,$ruleset, $rule_env);
#    $logger->debug("Global JS: ", $js);

    $js .= eval_meta($req_info,$ruleset, $rule_env);


    # this loops through the rules ONCE applying all that fire
    foreach my $rule ( @{ $rules } ) {
	$js .= eval_rule($r, 
			 $req_info, 
			 $rule_env,
			 $session, 
			 $rule);
    }

    $logger->debug("Finished processing rules for " . $req_info->{'rid'});
    return "\n(function() { $js } ());\n" ;
}

sub eval_meta {
    my($req_info,$ruleset, $rule_env) = @_;

    my $logger = get_logger();
    my $js = "";

     if($ruleset->{'meta'}->{'keys'}) {

	 $js .= "KOBJ." . $ruleset->{'ruleset_name'} . "= KOBJ." . $ruleset->{'ruleset_name'} . " || {};\n";

	 $js .= "KOBJ." . $ruleset->{'ruleset_name'} .  ".keys = KOBJ." . $ruleset->{'ruleset_name'} . ".keys || {};\n";

#     my $skip = {
# 	'description' => 1,
# 	'author' => 1,
# 	'name' => 1,
#     };
#     if($ruleset->{'meta'}) {
# 	$logger->debug("Found meta block; generating JS");
# 	foreach my $k (keys %{ $ruleset->{'meta'} }) {
# 	    next if $skip->{$k};
# 	    $js .= "KOBJ." . $ruleset->{'ruleset_name'} . ".meta.$k = '" . 
# 		$ruleset->{'meta'}->{$k} . "';\n";
# 	}
#     }
 	$logger->debug("Found keys; generating JS");
 	foreach my $k (keys %{ $ruleset->{'meta'}->{'keys'} }) {
 	    $js .= "KOBJ." . $ruleset->{'ruleset_name'} . ".keys.$k = '" . 
 		$ruleset->{'meta'}->{'keys'}->{$k} . "';\n";
 	}
     }
    return $js;
}

sub eval_globals {
    my($req_info,$ruleset, $rule_env) = @_;
    my $logger = get_logger();

    my $js = "";
    my @vars;
    my @vals;
    if($ruleset->{'global'}) {
	foreach my $g (@{ $ruleset->{'global'} }) {
	    my $this_js = '';
	    my $var = '';
	    my $val = 0;
	    if($g->{'emit'}) { # emit
		$this_js = $g->{'emit'} . "\n";
	    } elsif(defined $g->{'type'} && $g->{'type'} eq 'dataset') { 
		if (! Kynetx::Datasets::global_dataset($g)) {
		    ($this_js, $var, $val) = mk_dataset_js($g, $req_info, $rule_env);
#		    $logger->debug("Global dataset JS: ", $this_js);
#		    $logger->debug("Global dataset: ", $var, " -> ", sub { Dumper($val) });
		    push(@vars, $var);
		    push(@vals, $val);
		}
	    } elsif(defined $g->{'type'} && $g->{'type'} eq 'css') { 
		$this_js = "KOBJ.css(" . mk_js_str($g->{'content'}) . ");\n";
	    } elsif(defined $g->{'type'} && $g->{'type'} eq 'datasource') {
		push(@vars,'datasource:'.$g->{'name'});
		push(@vals, $g);
	    }
	    $js .= $this_js;
	}
    }

    return ($js, extend_rule_env(\@vars, \@vals, $rule_env));
   
}

sub eval_rule {
    my($r, $req_info, $rule_env, $session, $rule) = @_;

    my $logger = get_logger();


    Log::Log4perl::MDC->put('rule', $rule->{'name'});
    $logger->info("selected ...");


    foreach my $var (keys %{ $session } ) {
	$logger->debug("[Session] $var has value $session->{$var}");
    }

    # this loads the rule_env.  
    $rule_env = Kynetx::JavaScript::eval_js_pre($req_info, $rule_env, $rule->{'name'}, $session, $rule->{'pre'});

#    $logger->debug("[ENV] after prelude ", Dumper($rule_env));
#    foreach my $var (keys %{ $rule_env } ) {
#	$logger->debug("[Env] $var has value $rule_env->{$var}" 
#		       ) if defined $rule_env->{$var};
#    }


    # if the condition is undefined, it's true.  
    $rule->{'cond'} ||= mk_expr_node('bool','true');


    my $pred_value = 
	eval_predicates($req_info, 
			$rule_env, 
			$session, 
			$rule->{'cond'}, 
			$rule->{'name'});


    # set up post block execution
    my($cons,$alt);
    if (ref $rule->{'post'} eq 'HASH') { # it's an array if no post block
	my $type = $rule->{'post'}->{'type'};
	if($type eq 'fired') {
	    $cons = $rule->{'post'}->{'cons'};
	    $alt = $rule->{'post'}->{'alt'};
	} elsif($type eq 'always') { # cons is executed on both paths
	    $cons = $rule->{'post'}->{'cons'};
	    $alt = $rule->{'post'}->{'cons'};
	}

    }

    my $js = '';
    
    # keep track of these for each rule
    $req_info->{'actions'} = [];
    $req_info->{'labels'} = [];
    $req_info->{'tags'} = [];

    if ($pred_value) {

	$logger->info("fired");

	# this is the main event.  The browser has asked for a
	# chunk of Javascrip and this is where we deliver... 
	$js .= Kynetx::Actions::build_js_load($rule, $req_info, $rule_env, $session); 
	
	$js .= Kynetx::Actions::eval_post_expr($cons, $session) if(defined $cons);

	push(@{ $req_info->{'results'} }, 'fired');


    } else {
	$logger->info("did not fire");

	$js .= Kynetx::Actions::eval_post_expr($alt, $session) if(defined $alt);

	# put this in the logging DB
	push(@{ $req_info->{'results'} }, 'notfired');

    }

    # save things for logging
    push(@{ $req_info->{'names'} }, $req_info->{'rid'}.':'.$rule->{'name'});
    push(@{ $req_info->{'all_actions'} }, $req_info->{'actions'});
    push(@{ $req_info->{'all_labels'} }, $req_info->{'labels'});
    push(@{ $req_info->{'all_tags'} }, $req_info->{'tags'});

    return $js; 

}



# this returns the right rules for the caller and site
# this is a point where things could be optimixed in the future
sub get_rule_set {
    my ($svn_conn, $req_info) = @_;

    my $caller = $req_info->{'caller'};
    my $site = $req_info->{'rid'};
    
    my $logger = get_logger();
    $logger->debug("Getting ruleset for $caller");

    my $ruleset = get_rules_from_repository($site, $svn_conn, $req_info);

    $ruleset = optimize_rules($ruleset);

    turn_on_logging() if($ruleset->{'meta'}->{'logging'} && 
			 $ruleset->{'meta'}->{'logging'} eq "on");
    
    $logger->debug("Found " . @{ $ruleset->{'rules'} } . " rules for site $site" );

    my @new_set;
    my %new_env;

    $req_info->{'rule_count'} = 0;
    $req_info->{'selected_rules'} = [];
    foreach my $rule ( @{ $ruleset->{'rules'} } ) {
# 	$logger->debug("Rule $rule->{'name'} is " . $rule->{'state'});
	if($rule->{'state'} eq 'active' || 
	   ($rule->{'state'} eq 'test' && 
	    $req_info->{'mode'} && 
	    $req_info->{'mode'} eq 'test' )) {  # optimize??

	    $req_info->{'rule_count'}++;

	    # test and capture here
	    my($selected, $captured_vals) = select_rule($caller, $rule);

	    if ($selected) {

		$logger->debug("[selected] $rule->{'name'} ");

		push @new_set, $rule;
		push @{ $req_info->{'selected_rules'} }, $rule->{'name'};

		my $select_vars = Kynetx::Actions::get_precondition_vars($rule);


		# store the captured values from the precondition to the env
		my $cap = 0;
		foreach my $var (@{ $select_vars } ) {

		    $var =~ s/^\s*(.+)\s*/$1/;

		    $logger->debug("[select var] $var -> $captured_vals->[$cap]");

		    $new_env{$var} = $captured_vals->[$cap++];

		}
	    } else {
		$logger->debug("[not selected] $rule->{'name'} ");
	    }
	}
    }
    
    return (\@new_set, \%new_env, $ruleset);

}

sub select_rule {
    my($caller, $rule) = @_;

    my $logger = get_logger();

    # test the pattern, captured values are stored in @captures

    my $pattern_regexp = Kynetx::Actions::get_precondition_test($rule);
    $logger->debug("Selection pattern: ", $pattern_regexp);

    my $captures = [];
    if(@{$captures} = $caller =~ $pattern_regexp) {
	return (1, $captures);
    } else {
	return (0, $captures);
    }
}

sub optimize_rules {
    my ($ruleset) = @_;

    foreach my $rule ( @{ $ruleset->{'rules'} } ) {

	# precompile pattern regexp
	$rule->{'pagetype'}->{'pattern'} = 
	    qr!$rule->{'pagetype'}->{'pattern'}!;

    }

    return $ruleset;
}





1;
