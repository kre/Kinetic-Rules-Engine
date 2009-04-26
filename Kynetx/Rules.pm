package Kynetx::Rules;
# file: Kynetx/Rules.pm

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

    my $js = '';
    my @rids = split(/;/, $rids);
    # if we sort @rids we change ruleset priority
    foreach my $rid (@rids) {
	Log::Log4perl::MDC->put('site', $rid);
	$js .= eval_ruleset($r, $req_info, $session, $rid);
    }

    return $js;

}


sub eval_ruleset {
    my ($r, $req_info, $session, $rid) = @_;

    my $logger = get_logger();

    Log::Log4perl::MDC->put('rule', '[global]');

    $logger->info("Processing rules for site " . $req_info->{'rid'});

    $req_info->{'rid'} = $rid;
    # side effects environment with precondition pattern values
    my ($rules, $rule_env, $ruleset) = 
	get_rule_set($r->dir_config('svn_conn'),
		     $req_info
	            );

    Kynetx::Request::log_request_env($logger, $req_info);

    my $js = '';



    # handle globals
    $js .= eval_globals($req_info,$ruleset, $rule_env);


    # this loops through the rules ONCE applying all that fire
    foreach my $rule ( @{ $rules } ) {
	$js .= eval_rule($r, $req_info, $rule_env, $session, $rule);
    }

    $logger->debug("Finished processing rules for " . $req_info->{'rid'});
    print "\n(function() { $js } ());\n" ;
}


sub eval_globals {
    my($request_info,$ruleset, $rule_env) = @_;
    my $js = "";
    if($ruleset->{'global'}) {
	foreach my $g (@{ $ruleset->{'global'} }) {
	    if($g->{'emit'}) { # emit
		$js .= $g->{'emit'} . "\n";
	    } elsif(defined $g->{'type'} && $g->{'type'} eq 'dataset') { 
		$js .= mk_dataset_js($g, $request_info, $rule_env) 
		    unless Kynetx::Datasets::global_dataset($g);
	    } elsif(defined $g->{'type'} && $g->{'type'} eq 'css') { 
		$js .= "KOBJ.css(" . mk_js_str($g->{'content'}) . ");\n";
	    } elsif(defined $g->{'type'} && $g->{'type'} eq 'datasource') {
		$rule_env->{'datasource:'.$g->{'name'}} = $g;
	    }
	}
    }

    return $js;
   
}

sub eval_rule {
    my($r, $request_info, $rule_env, $session, $rule) = @_;

    my $logger = get_logger();


    Log::Log4perl::MDC->put('rule', $rule->{'name'});
    $logger->info("selected ...");


    foreach my $var (keys %{ $session } ) {
	$logger->debug("[Session] $var has value $session->{$var}");
    }

    # this loads the rule_env.  
    Kynetx::JavaScript::eval_js_pre($request_info, $rule_env, $rule->{'name'}, $session, $rule->{'pre'});

    foreach my $var (keys %{ $rule_env } ) {
	$logger->debug("[Env] $var has value $rule_env->{$var}" 
		       ) if defined $rule_env->{$var};
    }

    # if the condition is undefined, it's true.  
    $rule->{'cond'} ||= mk_expr_node('bool','true');


    my $pred_value = 
	eval_predicates($request_info, $rule_env, $session, 
			$rule->{'cond'}, $rule->{'name'});


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
    if ($pred_value) {

	$logger->info("fired");

	# this is the main event.  The browser has asked for a
	# chunk of Javascrip and this is where we deliver... 
	$js .= Kynetx::Actions::build_js_load($rule, $request_info, $rule_env, $session); 
	
	$js .= Kynetx::Actions::eval_post_expr($cons, $session) if(defined $cons);

	# save things for logging
	push(@{ $rule_env->{'names'} }, $rule->{'name'});
	push(@{ $rule_env->{'results'} }, 'fired');
	push(@{ $rule_env->{'all_actions'} }, $rule_env->{'actions'});
	$rule_env->{'actions'} = ();
	push(@{ $rule_env->{'all_labels'} }, $rule_env->{'labels'});
	$rule_env->{'labels'} = ();
	push(@{ $rule_env->{'all_tags'} }, $rule_env->{'tags'});
	$rule_env->{'tags'} = ();



    } else {
	$logger->info("did not fire");

	$js .= Kynetx::Actions::eval_post_expr($alt, $session) if(defined $alt);

	# put this in the logging DB
	push(@{ $rule_env->{'names'} }, $rule->{'name'});
	push(@{ $rule_env->{'results'} }, 'notfired');
	push(@{ $rule_env->{'all_actions'} }, []);
	$rule_env->{'actions'} = ();
	push(@{ $rule_env->{'all_labels'} }, []);
	$rule_env->{'labels'} = ();
	push(@{ $rule_env->{'all_tags'} }, []);
	$rule_env->{'tags'} = ();


    }

    # put this in the logging DB
    log_rule_fire($r, 
		  $request_info, 
		  $rule_env,
		  $session
	);

    # return the JS load to the client
    $logger->info("finished");
    return $js; 

}



# this returns the right rules for the caller and site
# this is a point where things could be optimixed in the future
sub get_rule_set {
    my ($svn_conn, $request_info) = @_;

    my $caller = $request_info->{'caller'};
    my $site = $request_info->{'rid'};
    
    my $logger = get_logger();
    $logger->debug("Getting ruleset for $caller");

    my $ruleset = get_rules_from_repository($site, $svn_conn, $request_info);

    $ruleset = optimize_rules($ruleset);

    turn_on_logging() if($ruleset->{'meta'}->{'logging'} && 
			 $ruleset->{'meta'}->{'logging'} eq "on");
    
    $logger->debug("Found " . @{ $ruleset->{'rules'} } . " rules for site $site" );

    my @new_set;
    my %new_env;

    $request_info->{'rule_count'} = 0;
    $request_info->{'selected_rules'} = [];
    foreach my $rule ( @{ $ruleset->{'rules'} } ) {
# 	$logger->debug("Rule $rule->{'name'} is " . $rule->{'state'});
	if($rule->{'state'} eq 'active' || 
	   ($rule->{'state'} eq 'test' && 
	    $request_info->{'mode'} && 
	    $request_info->{'mode'} eq 'test' )) {  # optimize??

	    $request_info->{'rule_count'}++;
	
	    # test the pattern, captured values are stored in @captures
	    if(my @captures = $caller =~ Kynetx::Actions::get_precondition_test($rule)) {

		$logger->debug("[selected] $rule->{'name'} ");

		push @new_set, $rule;
		push @{ $request_info->{'selected_rules'} }, $rule->{'name'};

		# store the captured values from the precondition to the env
		my $cap = 0;
		foreach my $var ( @{ Kynetx::Actions::get_precondition_vars($rule)}) {

		    $var =~ s/^\s*(.+)\s*/$1/;

		    $logger->debug("[select var] $var -> $captures[$cap]");

		    $new_env{"$rule->{'name'}:$var"} = $captures[$cap++];
		    push(@{$new_env{$rule->{'name'}."_vars"}}, $var);
		}
	    } else {
		$logger->debug("[not selected] $rule->{'name'} ");
	    }
	}
    }
    
    return (\@new_set, \%new_env, $ruleset);

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
