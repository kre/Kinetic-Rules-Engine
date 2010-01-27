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
use Kynetx::Expressions qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Datasets qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Modules qw(:all);
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
    my ($r, $method, $rids, $eid) = @_;

    my $logger = get_logger();

    $r->subprocess_env(START_TIME => Time::HiRes::time);

    if(Kynetx::Configure::get_config('RUN_MODE') eq 'development') {
	# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
	my $test_ip = Kynetx::Configure::get_config('TEST_IP');
	 $r->connection->remote_ip($test_ip);
	$logger->debug("In development mode using IP address ", $r->connection->remote_ip());
    } 



    # get a session
    my $session = process_session($r);

    my $req_info = Kynetx::Request::build_request_env($r, $method, $rids);
    $req_info->{'eid'} = $eid;

    # initialization
    my $js = '';
    my $rule_env = empty_rule_env();
    
    my @rids = split(/;/, $rids);
    # if we sort @rids we change ruleset priority
    foreach my $rid (@rids) {
	Log::Log4perl::MDC->put('site', $rid);
	$js .= process_ruleset($r, $req_info, $rule_env, $session, $rid);
    }

    # put this in the logging DB
    log_rule_fire($r, 
		  $req_info, 
		  $session
	);

    session_cleanup($session);

    # return the JS load to the client
    $logger->info("finished");


    # this is where we return the JS
    print $js;

}


sub process_ruleset {
    my ($r, $req_info, $rule_env, $session, $rid) = @_;

    my $logger = get_logger();

    Log::Log4perl::MDC->put('rule', '[global]');

    $req_info->{'rid'} = $rid; # override with the one we're working on

    $logger->info("Processing rules for site " . $req_info->{'rid'});

    my $ruleset = 
	get_rule_set($req_info);



#    $logger->debug('Env after rule selection: ', Dumper($rule_env));

    Kynetx::Request::log_request_env($logger, $req_info);

    my $js = eval_ruleset($r, $req_info,$rule_env, $session, $ruleset);


    $logger->debug("Finished processing rules for " . $req_info->{'rid'});

    # we're done logging now
    turn_off_logging if($ruleset->{'meta'}->{'logging'} && 
			$ruleset->{'meta'}->{'logging'} eq "on");

    #add verify logging call
    if((Kynetx::Configure::get_config('USE_KVERIFY') || '0') == '1'){
      $js .= "KOBJ.logVerify = KOBJ.logVerify || function(t,a,c){};";
      $js .= "KOBJ.logVerify('" . $req_info->{'txn_id'} . "', '$rid', '" . Kynetx::Configure::get_config('EVAL_HOST') . "');";
    }

    my $eid = $req_info->{'eid'};
    return <<EOF
KOBJ.registerClosure('$rid', function() { $js }, '$eid');
EOF
}

sub eval_ruleset {
  my($r, $req_info, $rule_env, $session, $ruleset) = @_;

  my $logger = get_logger();
    $logger->trace("[eval ruleset] rs: ",Dumper($ruleset));
  # generate JS for meta
  my $mjs = eval_meta($req_info, $ruleset, $rule_env);

  # handle globals, start js build, extend $rule_env
  my $gjs;
  ($gjs, $rule_env) = eval_globals($req_info, $ruleset, $rule_env, $session);
#      $logger->debug("Rule env after globals: ", Dumper $rule_env);
  #    $logger->debug("Global JS: ", $gjs);


  my $js = '';
  $req_info->{'rule_count'} = 0;
  $req_info->{'selected_rules'} = [];
  foreach my $rule ( @{ $ruleset->{'rules'} } ) {
    $logger->trace("[rules] foreach pre: ",Dumper($rule->{'pre'}));
    # set by eval_control_statement in Actions.pm
    last if $req_info->{$req_info->{'rid'}.':last'};

    my $this_rule_env;
    $logger->debug("Rule $rule->{'name'} is " . $rule->{'state'});
    if($rule->{'state'} eq 'active' || 
       ($rule->{'state'} eq 'test' && 
	$req_info->{'mode'} && 
	$req_info->{'mode'} eq 'test' )) {  # optimize??

      $req_info->{'rule_count'}++;


      # test and capture here
      my($selected, $captured_vals) = select_rule($req_info->{'caller'}, $rule);

      if ($selected) {

	$logger->debug("[selected] $rule->{'name'} ");
	$logger->trace("[rules] ",Dumper($rule));

	push @{ $req_info->{'selected_rules'} }, $rule->{'name'};

	my $select_vars = Kynetx::Actions::get_precondition_vars($rule);

	# store the captured values from the precondition to the env
	my $cap = 0;
	my $sjs = '';
	foreach my $var (@{ $select_vars } ) {
	  $var =~ s/^\s*(.+)\s*/$1/;
	  $logger->debug("[select var] $var -> $captured_vals->[$cap]");
	  $this_rule_env->{$var} = $captured_vals->[$cap];
	  $sjs .= gen_js_var($var,
			    gen_js_expr(exp_to_den($captured_vals->[$cap])));

	  $cap++
	}


	$js .= eval_rule($r, 
			 $req_info, 
			 extend_rule_env($this_rule_env, $rule_env),
			 $session, 
			 $rule,
			 $sjs  # pass in the select JS to be inside rule
			);
      } else {
	$logger->debug("[not selected] $rule->{'name'} ");
      }
    }
  }
  $logger->debug("[eval_ruleset] Executed $req_info->{'rule_count'} rules");

  # wrap the rule evals in a try-catch-block
  $js = add_errorstack($ruleset,$js) if $js;

  # put it all together
  $js = $mjs . $gjs . $js;


  return mk_turtle($js) if $js;


}

sub eval_meta {
    my($req_info,$ruleset, $rule_env) = @_;

    my $logger = get_logger();
    my $js = "";

    my $rid = $req_info->{'rid'};

    $req_info->{"$rid:ruleset_name"} = $ruleset->{'ruleset_name'};
    $req_info->{"$rid:name"} = $ruleset->{'meta'}->{'name'};
    $req_info->{"$rid:author"} = $ruleset->{'meta'}->{'author'};
    $req_info->{"$rid:description"} = $ruleset->{'meta'}->{'description'};

    if($ruleset->{'meta'}->{'keys'}) {

	 $js .= KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) . " =  " . KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) . " || {};\n";

	 $js .= KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) .  ".keys = " . KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) . ".keys || {};\n";

 	$logger->debug("Found keys; generating JS");
 	foreach my $k (keys %{ $ruleset->{'meta'}->{'keys'} }) {
	  if ($k eq 'twitter') {
	    $req_info->{$rid.':key:twitter'} = $ruleset->{'meta'}->{'keys'}->{$k};
	  } else { # googleanalytics, errorstack
	    $js .= KOBJ_ruleset_obj($ruleset->{'ruleset_name'}). ".keys.$k = '" . 
	      $ruleset->{'meta'}->{'keys'}->{$k} . "';\n";
	  }
 	}
     }
    return $js;
}

sub eval_globals {
    my($req_info,$ruleset, $rule_env, $session) = @_;
    my $logger = get_logger();

    my $js = "";
    if($ruleset->{'global'}) {

#    $logger->debug("Here's the globals: ", Dumper $ruleset->{'global'});

      # make this act like let* not let
      my @vars;
      foreach my $g (@{ $ruleset->{'global'} }) {
	$g->{'lhs'} = $g->{'name'} unless(defined $g->{'lhs'});
	if (defined $g->{'lhs'}) {
	  if (defined $g->{'type'} && $g->{'type'} eq 'datasource') {
	    push @vars, 'datasource:'.$g->{'lhs'};
	  } else {
	    push @vars, $g->{'lhs'};
	  }
	}
      }

      my @empty_vals = map {''} @vars;
      $rule_env = extend_rule_env(\@vars, \@empty_vals, $rule_env);

      $logger->debug("Global vars: ", join(", ", @vars));

      foreach my $g (@{ $ruleset->{'global'} }) {
	my $this_js = '';
	my $var = '';
	my $val = 0;
	if($g->{'emit'}) { # emit
	  $this_js = $g->{'emit'} . "\n";
	} elsif(defined $g->{'type'} && $g->{'type'} eq 'dataset') { 
	    my $new_ds = Kynetx::Datasets->new($g);
	  if (! $new_ds->is_global()) {
	      $new_ds->load($req_info);
	      $new_ds->unmarshal();
	      $this_js = $new_ds->make_javascript();
	      $var = $new_ds->name;
	      if (defined $new_ds->json) {
	          $val = $new_ds->json;
	      } else {
	          $val = $new_ds->sourcedata;
	      }
	    #($this_js, $var, $val) = mk_dataset_js($g, $req_info, $rule_env);
	    # yes, this is cheating and breaking the abstraction, but it's fast
	    $rule_env->{$var} = $val;
	  }
	} elsif(defined $g->{'type'} && $g->{'type'} eq 'css') { 
	  $this_js = "KOBJ.css(" . mk_js_str($g->{'content'}) . ");\n";
	} elsif(defined $g->{'type'} && $g->{'type'} eq 'datasource') {
	  $rule_env->{'datasource:'.$g->{'lhs'}} = $g;
	} elsif(defined $g->{'type'} && 
		($g->{'type'} eq 'expr' || $g->{'type'} eq 'here_doc')) {
	  $this_js = eval_one_decl($req_info, $rule_env, $ruleset->{'lhs'}, $session, $g);
	}
	$js .= $this_js;
      }
    }
#    $logger->debug(" rule_env: ", Dumper($rule_env));

    return ($js, $rule_env);
   
}

sub eval_rule {
    my($r, $req_info, $rule_env, $session, $rule, $initial_js) = @_;

    my $logger = get_logger();


    my $js = '';

    Log::Log4perl::MDC->put('rule', $rule->{'name'});
#    $logger->info($rule->{'name'}, " selected...");


    foreach my $var (@{ session_keys($req_info->{'rid'}, $session) } ) {
	next if($var =~ m/_created$/);
	$logger->debug("[Session] $var has value ". 
		       session_get($req_info->{'rid'}, $session, $var));
    }

    # keep track of these for each rule
    $req_info->{'actions'} = [];
    $req_info->{'labels'} = [];
    $req_info->{'tags'} = [];
    
    # assume the rule doesn't fire.  We will change this if it EVER fires in this eval
    $req_info->{$rule->{'name'}.'_result'} = 'notfired';

    if ($rule->{'pre'} &&
	! ($rule->{'inner_pre'} || $rule->{'outer_pre'})) {
	  $logger->debug("Rule not pre optimized...");
	  optimize_pre($rule);
    }

    my $outer_tentative_js = '';


    # this loads the rule_env.  
    ($outer_tentative_js,$rule_env) = 
      Kynetx::Expressions::eval_prelude($req_info, 
					$rule_env, 
					$rule->{'name'}, 
					$session, 
					$rule->{'outer_pre'});

    $rule->{'pagetype'}->{'foreach'} = [] 
      unless defined $rule->{'pagetype'}->{'foreach'};

    $js .= eval_foreach($r, 
			$req_info, 
			$rule_env, 
			$session, 
			$rule,
			@{ $rule->{'pagetype'}->{'foreach'} });

    # save things for logging
    push(@{ $req_info->{'results'} }, $req_info->{$rule->{'name'}.'_result'});
    push(@{ $req_info->{'names'} }, $req_info->{'rid'}.':'.$rule->{'name'});
    push(@{ $req_info->{'all_actions'} }, $req_info->{'actions'});
    push(@{ $req_info->{'all_labels'} }, $req_info->{'labels'});
    push(@{ $req_info->{'all_tags'} }, $req_info->{'tags'});

    # combine JS and wrap in a closure if rule fired
    $js = mk_turtle($initial_js . $outer_tentative_js . $js) if $js;

    return $js;

}

# recursive function on foreach list.
sub eval_foreach {
  my($r, $req_info, $rule_env, $session, $rule, @foreach_list) = @_;

  my $logger = get_logger();

  my $fjs = '';

  # $logger->debug("In foreach with " . Dumper(@foreach_list));

  if (@foreach_list == 0) {

    $fjs =  eval_rule_body($r, 
			    $req_info, 
			    $rule_env, 
			    $session, 
			    $rule);

  } else {

    # expr has to result in array of prims
    my $valarray = 
         eval_expr($foreach_list[0]->{'expr'}, 
		      $rule_env, 
		      $rule->{'name'}, 
		      $req_info, 
		      $session);

    $logger->warn("Foreach expression does not yield array") unless
      $valarray->{'type'} eq 'array';
    my $var = $foreach_list[0]->{'var'};

    foreach my $val (@{ $valarray->{'val'} }) {

      $val = typed_value($val);

#      $logger->debug("Evaluating rule body with " . Dumper($val));

      # we recurse in side this loop to handle nested foreach statements
      $fjs .= mk_turtle(
		gen_js_var($var, gen_js_expr($val)) .
  	        eval_foreach($r, 
			     $req_info, 
			     extend_rule_env({$var,den_to_exp($val)},
					     $rule_env), 
			     $session, 
			     $rule,
			     cdr(@foreach_list)
			    ));
    }
  }

  return $fjs;
}

sub eval_rule_body {
  my($r, $req_info, $rule_env, $session, $rule) = @_;

  my $logger = get_logger();

  my $inner_tentative_js;
  ($inner_tentative_js,$rule_env) = 
    Kynetx::Expressions::eval_prelude($req_info, 
				      $rule_env, $rule->{'name'}, 
				      $session, $rule->{'inner_pre'});



  # if the condition is undefined, it's true.  
  $rule->{'cond'} ||= mk_expr_node('bool','true');


  my $pred_value = 
    den_to_exp(
       eval_expr ($rule->{'cond'}, $rule_env, $rule->{'name'},$req_info, $session));


  my $js = '';

    
  my $fired = 0;
  if ($pred_value) {

    $logger->info("fired");

    # this is the main event.  The browser has asked for a
    # chunk of Javascrip and this is where we deliver... 

    # combine the inner_tentive JS, with the generated JS and wrap in a closure
    $js = $inner_tentative_js .
          Kynetx::Actions::build_js_load($rule, 
					 $req_info, 
					 $rule_env, 
					 $session);
	
    $fired = 1;
    # change the 'fired' flag to indicate this rule fired.  
    $req_info->{$rule->{'name'}.'_result'} = 'fired';
#    push(@{ $req_info->{'results'} }, 'fired');


  } else {
    $logger->info("did not fire");

    $fired = 0;

# don't do anything since we already assume no fire; 
#    $req_info->{$rule->{'name'}.'_result'} = 'notfired';
#    push(@{ $req_info->{'results'} }, 'notfired');

  }

  $js .= Kynetx::Actions::eval_post_expr($rule, $session, $req_info, $rule_env, $fired);

  return $js;
}


# this returns the right rules for the caller and site
# this is a point where things could be optimized in the future
sub get_rule_set {
    my ($req_info) = @_;

    my $caller = $req_info->{'caller'};
    my $site = $req_info->{'rid'};
    
    my $logger = get_logger();
    $logger->debug("Getting ruleset for $caller");

    my $ruleset = get_rules_from_repository($site, $req_info);

    # FIXME: store optimized RS in cache???
    $ruleset = optimize_ruleset($ruleset);

    turn_on_logging() if($ruleset->{'meta'}->{'logging'} && 
			 $ruleset->{'meta'}->{'logging'} eq "on");
    
    $logger->debug("Found " . @{ $ruleset->{'rules'} } . " rules for site $site" );

    
    return $ruleset;

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


sub optimize_ruleset {
    my ($ruleset) = @_;

    my $logger = get_logger();

    $logger->debug("Optimizing rules for ", $ruleset->{'ruleset_name'});

    foreach my $rule ( @{ $ruleset->{'rules'} } ) {
      optimize_rule($rule);
    }

    return $ruleset;
}


sub optimize_rule {
  my ($rule) = @_;

  my $logger = get_logger();

  # precompile pattern regexp
  $rule->{'pagetype'}->{'pattern'} = 
    qr!$rule->{'pagetype'}->{'pattern'}!;

  # break up pre, if needed
  optimize_pre($rule);

  return $rule;
}

sub optimize_pre {
  my ($rule) = @_;
  my $logger = get_logger();
    my @vars = map {$_->{'var'}} @{ $rule->{'pagetype'}->{'foreach'} };
    $logger->trace("[rules::optimize_pre] foreach vars: ", Dumper(@vars));
# don't need this, but I love it.
# 	  my %is_var;
# 	  # create a hash for testing whether a var is defined or not
# 	  @is_var{@vars} = (1) x @vars;


    foreach my $decl (@{$rule->{'pre'}}) {
      # check if any of the vars occur free in the rhs
      $logger->trace("[rules::optimize_pre] decl: ", Dumper($decl));
      my $dependent = 0;
      foreach my $v (@vars) {
	if ($decl->{'type'} eq 'expr' &&
	    var_free_in_expr($v, $decl->{'rhs'})) {
	  $dependent = 1;
	} elsif ($decl->{'type'} eq 'here_doc' &&
	    var_free_in_expr($v, $decl)) {
	  $dependent = 1;
	}
      }
      if ($dependent) {
	push(@{$rule->{'inner_pre'}}, $decl);
	push(@vars, $decl->{'lhs'}); # collect new var
      } else {
	push(@{$rule->{'outer_pre'}}, $decl);
      }
    }
#    $logger->debug("Dependent vars in optimization: ", @vars);

}


sub mk_turtle {
  my($js) = @_;
  return '(function(){' . $js . "}());\n";
}

sub add_errorstack {
  my($ruleset, $js) = @_;
  my $kobj_rs = KOBJ_ruleset_obj($ruleset->{'ruleset_name'});
  my $r = <<_JS_;
try { $js } catch (e) { 
KOBJ.errorstack_submit($kobj_rs.keys.errorstack, e);
};
_JS_
  if($ruleset->{'meta'}->{'keys'}->{'errorstack'}) {
    return $r;
  } else {
    return $js;
  }
}

sub KOBJ_ruleset_obj {
  my($ruleset_name) = @_;
  return "KOBJ['" . $ruleset_name . "']";
}

1;
