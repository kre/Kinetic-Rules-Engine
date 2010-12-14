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
use Digest::MD5 qw(md5 md5_hex);

use Kynetx::Parser qw(:all);
use Kynetx::PrettyPrinter qw(:all);
use Kynetx::JavaScript;
use Kynetx::Expressions ;
use Kynetx::Json qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Datasets qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Modules qw(:all);
use Kynetx::Actions;
use Kynetx::Authz;
use Kynetx::Events;
use Kynetx::Log qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Repository;
use Kynetx::Environments qw(:all);
use Kynetx::Directives ;
use Kynetx::Postlude;
use Kynetx::Response;

use Kynetx::JavaScript::AST qw/:all/;

use Kynetx::Actions::LetItSnow;
use Kynetx::Actions::JQueryUI;
use Kynetx::Actions::FlippyLoo;

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


    my $req_info = Kynetx::Request::build_request_env($r, $method, $rids);
    $req_info->{'eid'} = $eid;

    # get a session, if _sid param is defined it will override cookie
    my $session = process_session($r, $req_info->{'kntx_token'});

    # initialization
    my $js = '';


    my $rule_env = mk_initial_env();

    my @rids = split(/;/, $rids);
    # if we sort @rids we change ruleset priority
    foreach my $rid (@rids) {
        $logger->debug("-------------------------------------------Schedule $rid");
	Log::Log4perl::MDC->put('site', $rid);
	my $schedule = mk_schedule($req_info, $rid);
	$js .= eval {
	  process_schedule($r, $schedule, $session, $eid);
	};
	if ($@) {
	  $logger->error("Ruleset $rid failed: ", $@);
	}
    }


    Kynetx::Response::respond($r, $req_info, $session, $js, "Ruleset");
}


sub process_schedule {
  my ($r, $schedule, $session, $eid) = @_;

  my $logger = get_logger();

  my $init_rule_env = Kynetx::Rules::mk_initial_env();

  my $ast = Kynetx::JavaScript::AST->new($eid);
  my($req_info, $ruleset, $mjs, $gjs, $rule_env, $rid);

  $rid = '';
  my $current_rid = '';

  #$logger->debug("Schedule: ", Dumper($schedule));

  while (my $task = $schedule->next()) {

#    $logger->debug("[task] ", sub { Dumper($task) });

    $rid = $task-> {'rid'};
    unless ($rid eq $current_rid) {
      #context switch
      # we only do this when there's a new RID

      # save info from last context

      $ast->add_resources($current_rid, $req_info->{'resources'});

      # set up new context

      $req_info = $task->{'req_info'};
      $req_info->{'rid'} = $rid;
      # we use this to modify the schedule on-the-fly
      $req_info->{'schedule'} = $schedule;

#      $ruleset = $task->{'ruleset'};
      $ruleset = Kynetx::Rules::get_rule_set($req_info);
      # store so we don't have to grab it again
      stash_ruleset($req_info, $ruleset);

      if (($ruleset->{'meta'}->{'logging'} &&
	   $ruleset->{'meta'}->{'logging'} eq "on")) {
	turn_on_logging();
      } else {
	turn_off_logging();
      }

      Log::Log4perl::MDC->put('site', $rid);
      $logger->info("Processing rules for site " . $rid);


      # this doesn't work.  We may need to get new session storage in place before it will.
      # If we *could* get te appsession hash defined, app vars would work.
      # # set up app session, the place where app vars store data
      # $req_info->{'appsession'} = eval {
      # 	# since we generate from the RID, we get the same one...
      # 	my $key = Digest::MD5::md5_hex($req_info->{'rid'});
      # 	Kynetx::Session::tie_servers({},$key);
      # };


      # generate JS for meta
      ($mjs, $rule_env) = eval_meta($req_info, $ruleset, $init_rule_env, $session);

      # handle globals, start js build, extend $rule_env
      ($gjs, $rule_env) = eval_globals($req_info, $ruleset, $rule_env, $session);
#      $logger->debug("Rule env after globals: ", Dumper $rule_env);
#    $logger->debug("Global JS: ", $gjs);

      $ast->add_rid_js($rid, $mjs, $gjs, $ruleset, $req_info->{'txn_id'});

      $req_info->{'rule_count'} = 0;
      $req_info->{'selected_rules'} = [];

      $current_rid = $rid;
    } # done with context

    my $rule = $task->{'rule'};
    my $rule_name = $rule->{'name'};

    Log::Log4perl::MDC->put('rule', $rule_name);


    $logger->trace("[rules] foreach pre: ", sub { Dumper($rule->{'pre'}) });
    # set by eval_control_statement in Actions.pm
    last if $req_info->{$req_info->{'rid'}.':__KOBJ_EXEC_LAST'};

    $rule->{'state'} ||= 'active';

    my $this_rule_env;
    $logger->debug("Rule $rule_name is " . $rule->{'state'});
    if($rule->{'state'} eq 'active' ||
       ($rule->{'state'} eq 'test' &&
	$req_info->{'mode'} &&
	$req_info->{'mode'} eq 'test' )) {  # optimize??

      $req_info->{'rule_count'}++;


      $logger->debug("[selected] $rule->{'name'} ");
#      $logger->trace("[rules] ", sub { Dumper($rule) });

      push @{ $req_info->{'selected_rules'} }, $rule->{'name'};

      my $select_vars = $task->{'vars'};
      my $captured_vals = $task->{'vals'};

      # store the captured values from the precondition to the env
      my $cap = 0;
      my $sjs = '';
      foreach my $var (@{ $select_vars } ) {
	$var =~ s/^\s*(.+)\s*/$1/; # trim whitspace
	$logger->debug("[select var] $var -> $captured_vals->[$cap]");
	$this_rule_env->{$var} = $captured_vals->[$cap];
	$sjs .= Kynetx::JavaScript::gen_js_var($var,
  	           Kynetx::JavaScript::gen_js_expr(
		      Kynetx::Expressions::exp_to_den($captured_vals->[$cap])));

	$cap++
      }

      my $new_req_info = Kynetx::Request::merge_req_env($req_info, $task->{'req_info'});

      my $js;
      if (Kynetx::Authz::is_authorized($rid,$ruleset,$session)) {

	$js = eval {eval_rule($r,
			      $req_info,
			      extend_rule_env($this_rule_env, $rule_env),
			      $session,
			      $rule,
			      $sjs  # pass in the select JS to be inside rule
			     );
		 };

	if ($@) {
	  $logger->error("Ruleset $rid failed: ", $@);
	}

      } else {

	$logger->debug("Sending activation notice for $rid");
	$js = eval {
	  Kynetx::Authz::authorize_message($task->{'req_info'}, $session, $ruleset)
	};
	if ($@) {
	  $logger->error("Authorization failed for $rid: ", $@);
	}
	# Since this RID isn't auhtorized yet, skip the rest...
	$schedule->delete_rid($rid);

      }
      $ast->add_rule_js($rid, $js);

    } else {
      $logger->debug("[not selected] $rule->{'name'} ");
    }

  }

  # process for final context
  $ast->add_resources($current_rid, $req_info->{'resources'});

  $logger->debug("Finished processing rules for " . $rid);
  return $ast->generate_js();

}



sub eval_meta {
    my($req_info,$ruleset, $rule_env, $session) = @_;

    my $logger = get_logger();
    my $js = "";

    my $rid = $req_info->{'rid'};

    my $this_js;

    $req_info->{"$rid:ruleset_name"} = $ruleset->{'ruleset_name'};
    $req_info->{"$rid:name"} = $ruleset->{'meta'}->{'name'};
    $req_info->{"$rid:author"} = $ruleset->{'meta'}->{'author'};
    $req_info->{"$rid:description"} = $ruleset->{'meta'}->{'description'};

    # process keys now so that they're available for use in configuring modules
    if($ruleset->{'meta'}->{'keys'}) {
      ($this_js, $rule_env) = 
	Kynetx::Keys::process_keys($req_info, 
				   $rule_env, 
				   $ruleset
				  );
      $js .= $this_js;
    }

    if ($ruleset->{'meta'}->{'use'}) {
      ($this_js, $rule_env) = eval_use($req_info, $ruleset, $rule_env, $session, $ruleset->{'meta'}->{'use'});
      $js .= $this_js;
    }

#    $logger->debug("Rule env: ", sub { Dumper $rule_env} );

    return ($js, $rule_env);

}

sub eval_use {
  my($req_info,$ruleset, $rule_env, $session) = @_;

  my $logger = get_logger();
  my $js = "";

  my $use = $ruleset->{'meta'}->{'use'};

  my $rid = $req_info->{'rid'};

  my $this_js;

  foreach my $u (@{$use}) {
    # just put resources in $req_info and mk_registered_resources will grab them
    if ($u->{'type'} eq 'resource') {
      $req_info->{'resources'}->{$u->{'resource'}->{'location'}} =
		  {'type' => $u->{'resource_type'}};
    } elsif ($u->{'type'} eq 'module') {
      # side effects the rule env.
      ($this_js, $rule_env) = eval_use_module($req_info, $rule_env, $session, $u->{'name'}, $u->{'alias'}, $u->{'modifiers'});
      # don't include the module JS in the results.  
      # $js .= $this_js;
    } else {
      $logger->error("Unknown type for 'use': ", $u->{'type'});
    }


  }

# $logger->debug("Calculated env ", Dumper $rule_env);


 return ($js, $rule_env);
}

sub eval_use_module {
 my($req_info, $rule_env, $session, $name, $alias, $modifiers) = @_;

 my $logger = get_logger();

 my $use_ruleset = Kynetx::Rules::get_rule_set($req_info, 1, $name);

# $logger->debug("Using ", Dumper $use_ruleset);


 my $provided_array = $use_ruleset->{'meta'}->{'provide'}->{'names'} || [];

 my $provided = {};
 foreach my $name (@{ $provided_array }) {
   $provided->{$name} = 1;
 }
 
 my $js = '';
 my $this_js;

 my $namespace_name = $Kynetx::Modules::name_prefix . ($alias || $name);

 my $configuration = $use_ruleset->{'meta'}->{'configure'}->{'configuration'} || [];

 # create the module rule_env by extending an empty env with the config
 my $module_rule_env = set_module_configuration($req_info, 
						$rule_env,
						$session,
						empty_rule_env(), 
						$configuration, 
						$modifiers || []
					       );
				      


 # put any keys in the module rule_env *before* evaling the globals
 if($use_ruleset->{'meta'}->{'keys'}) {
   ($this_js, $module_rule_env) = 
     Kynetx::Keys::process_keys($req_info, 
				$module_rule_env, 
				$use_ruleset
			       );
   $js .= $this_js;
 }

 # eval the module's global block
 if ($use_ruleset->{'global'}) {
   ($js, $module_rule_env) =
     process_one_global_block($req_info,$use_ruleset->{'global'}, $module_rule_env, $session, $namespace_name, $provided);
 }

 $rule_env = extend_rule_env($namespace_name, $module_rule_env, 
	      extend_rule_env($namespace_name.'_provided', $provided, 
               $rule_env));

# $logger->debug("Calculated env ", Dumper $rule_env);

 return ($js, $rule_env); # ignore this for modules...

}

sub set_module_configuration {
  my ($req_info, $rule_env, $session, 
      $mod_rule_env, $config_array, $modifiers ) = @_;

  my $logger = get_logger();

  my $configuration = {};

#  $logger->debug("Config and modifiers: ", sub {Dumper $config_array}, sub {Dumper $modifiers});

  foreach my $conf ( @{ $config_array } ) {

    # config values are executed in module's rule env (empty)
    $configuration->{$conf->{'name'}} = 
      Kynetx::Expressions::den_to_exp(
        Kynetx::Expressions::eval_expr($conf->{'value'},
				       $mod_rule_env,
				       'module_config',
				       $req_info,
				       $session
				      ));
    
  }

  foreach my $mod ( @{ $modifiers } ) {

    # only insert names that are already there (honor config)
    if ($configuration->{$mod->{'name'}}) {
      # modifiers are executed in rule's environment
      $configuration->{$mod->{'name'}} = 
        Kynetx::Expressions::den_to_exp(
  	  Kynetx::Expressions::eval_expr($mod->{'value'},
					 $rule_env,
					 'module_config',
					 $req_info,
					 $session
					));
    }
    
  }

#  $logger->debug("Configuration ", sub {Dumper $configuration});

  $mod_rule_env = extend_rule_env($configuration, $mod_rule_env);
  
#  $logger->debug("Resulting env ", sub {Dumper $mod_rule_env});


  return $mod_rule_env;

}
		

sub eval_globals {
    my($req_info,$ruleset, $rule_env, $session) = @_;
    my $logger = get_logger();

    my $js = "";

    my $temp_js ='';
    if($ruleset->{'global'}) {
      ($temp_js, $rule_env) =
	process_one_global_block($req_info,$ruleset->{'global'}, $rule_env, $session);
      $js .= $temp_js;
    }


    return ($js, $rule_env);

}

sub process_one_global_block {
    my($req_info, $globals, $rule_env, $session, $namespace) = @_;
    my $logger = get_logger();

    my $js = "";

    # make this act like let* not let
    my @vars;
    foreach my $g (@{ $globals }) {
      $g->{'lhs'} = $g->{'name'} unless(defined $g->{'lhs'});
      if (defined $g->{'lhs'} ) {
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

    foreach my $g (@{ $globals }) {
      my $this_js = '';
      my $var = '';
      my $val = 0;
      if (!defined $namespace) {
	# only want these when we're not loading a module
	if ($g->{'emit'}) {	# emit
	  $this_js = Kynetx::Expressions::eval_emit($g->{'emit'}) . "\n";
	} elsif (defined $g->{'type'} && $g->{'type'} eq 'css') {
	  $this_js = "KOBJ.css(" . Kynetx::JavaScript::mk_js_str($g->{'content'}) . ");\n";
	}
      }
      if (defined $g->{'type'} &&
	  ($g->{'type'} eq 'expr' || $g->{'type'} eq 'here_doc')) {
	# side-effects the rule-env
	$this_js = Kynetx::Expressions::eval_one_decl($req_info, $rule_env, 'global', $session, $g);
      } elsif (defined $g->{'type'} && $g->{'type'} eq 'datasource') {
	$rule_env->{'datasource:'.$g->{'lhs'}} = $g;
      } elsif (defined $g->{'type'} && $g->{'type'} eq 'dataset') {
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
	} 
      $js .= $this_js;
    }
    $logger->trace(" rule_env: ", Dumper($rule_env));

    return ($js, $rule_env);
}

sub eval_rule {
    my($r, $req_info, $rule_env, $session, $rule, $initial_js) = @_;

    Log::Log4perl::MDC->put('rule', $rule->{'name'});

    my $logger = get_logger();

    $logger->debug("\n------------------- begin rule execution: $rule->{'name'} ------------------------\n");

    my $js = '';

#    $logger->info($rule->{'name'}, " selected...");

# uncomment to print out all the session keys.  With events there's a lot
#     foreach my $var (@{ session_keys($req_info->{'rid'}, $session) } ) {
# 	next if($var =~ m/_created$/);
# 	$logger->debug("[Session] $var has value ".
# 		       session_get($req_info->{'rid'}, $session, $var));
#     }

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
         Kynetx::Expressions::eval_expr($foreach_list[0]->{'expr'},
					$rule_env,
					$rule->{'name'},
					$req_info,
					$session);

#    $logger->debug("Foreach ", sub { Dumper $foreach_list[0] });

    my $vars = $foreach_list[0]->{'var'};
    # FIXME: not sure why we have to do this.
    unless (ref $vars eq 'ARRAY') {
      $vars = [$vars];
    }

    # loop below expects array of arrays
    if ($valarray->{'type'} eq 'array') {
      # array of single value arrays
      $valarray = [map {[Kynetx::Expressions::den_to_exp($_)]} @{$valarray->{'val'}}];
    } elsif ($valarray->{'type'} eq 'hash') {
      # turn hash into array of two element arrays
      my @va;
      foreach my $k (keys %{$valarray->{'val'}}) {
	push @va, [$k, Kynetx::Expressions::den_to_exp($valarray->{'val'}->{$k})];
      }
      $valarray = \@va;
#      $logger->debug("Valarray ", sub {Dumper $valarray});
    } else {
      $logger->debug("Foreach expression does not yield array or hash; creating array from singleton") ;
      # make an array of arrays
      $valarray = [[Kynetx::Expressions::den_to_exp($valarray)]];
    }

#    $logger->debug("Valarray ", sub {Dumper $valarray});


    my $i = 0;
    foreach my $val (@{ $valarray}) {

#      $logger->debug("Evaluating rule body with " . Dumper($val));

      $logger->debug("----------- foreach iteration ". $i++ ." -------------\n");

      my $vjs =
	Kynetx::JavaScript::gen_js_var_list($vars,
		[map {Kynetx::JavaScript::gen_js_expr(
		       Kynetx::Expressions::typed_value($_))} @{$val}]);


#      $logger->debug("Vars ", sub {Dumper $vars});
#      $logger->debug("Vals ", sub {Dumper $val});

      # we recurse in side this loop to handle nested foreach statements
      $fjs .= mk_turtle(
		$vjs .
  	        eval_foreach($r,
			     $req_info,
			     extend_rule_env($vars,
					     $val,
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
    Kynetx::Expressions::den_to_exp(
       Kynetx::Expressions::eval_expr ($rule->{'cond'}, $rule_env, $rule->{'name'},$req_info, $session));

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

  $js .= Kynetx::Postlude::eval_post_expr($rule, $session, $req_info, $rule_env, $fired) if (defined $rule->{'post'});

  return $js;
}


# this returns the right rules for the caller and site
sub get_rule_set {
    my ($req_info, $localparsing, $rid) = @_;

    my $caller = $req_info->{'caller'};
    $rid ||= $req_info->{'rid'};



    my $logger = get_logger();
    $logger->debug("Getting ruleset $rid for $caller");

    my $ruleset;
    if (is_ruleset_stashed($req_info, $rid)) {
      $ruleset  = grab_ruleset($req_info, $rid);
    } else {
      $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $req_info, $localparsing);
      # do not store ruleset in the request info here
      # or it ends up in the session for the user
    }

    if (($ruleset->{'meta'}->{'logging'} &&
	 $ruleset->{'meta'}->{'logging'} eq "on")) {
      turn_on_logging();
    } else {
      turn_off_logging();
    }

    $ruleset->{'rules'} ||= [];

    $logger->debug("Found " . @{ $ruleset->{'rules'} } . " rules for RID $rid" );

    return $ruleset;

}

sub stash_ruleset {
  my ($req_info, $ruleset) = @_;
  my $rid = $req_info->{'rid'};
  $req_info->{$rid}->{'ruleset'} = $ruleset;
}

sub grab_ruleset {
  my ($req_info, $rid) = @_;
  return $req_info->{$rid}->{'ruleset'};
}

sub is_ruleset_stashed {
  my ($req_info, $rid) = @_;
  return defined $req_info->{$rid} &&
         defined $req_info->{$rid}->{'ruleset'};
}

sub select_rule {
    my($caller, $rule) = @_;

    my $logger = get_logger();

    # test the pattern, captured values are stored in @captures

    my $pattern_regexp = Kynetx::Actions::get_precondition_test($rule);
    $logger->debug("Selection pattern: $rule->{'name'} ", $pattern_regexp);

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

    $ruleset->{'optimization_version'} = get_optimization_version();

#    $logger->debug("Optimized ruleset ", sub { Dumper $ruleset });

    return $ruleset;
}

# incrementing the number here will force cache reloads of rulesets with lower #'s
sub get_optimization_version {
  my $version = 7;
  return $version;
}


sub optimize_rule {
  my ($rule) = @_;

  my $logger = get_logger();

  # fix up old syntax, if needed
  if ($rule->{'pagetype'}->{'pattern'}) {
    $logger->debug("Fixing select for ", $rule->{'name'});

    $rule->{'pagetype'}->{'event_expr'}->{'pattern'}  =
      $rule->{'pagetype'}->{'pattern'} ;
    $rule->{'pagetype'}->{'event_expr'}->{'vars'}  =
      $rule->{'pagetype'}->{'vars'} ;
    $rule->{'pagetype'}->{'event_expr'}->{'op'}  = 'pageview';
    $rule->{'pagetype'}->{'event_expr'}->{'type'}  = 'prim_event';
    $rule->{'pagetype'}->{'event_expr'}->{'legacy'}  = 1;
  }

  # precompile pattern regexp
  if (defined $rule->{'pagetype'}->{'event_expr'}->{'op'}) {
    $logger->debug("Optimizing ", $rule->{'name'});
    $rule->{'event_sm'} = Kynetx::Events::compile_event_expr($rule->{'pagetype'}->{'event_expr'});
#     $rule->{'pagetype'}->{'event_expr'}->{'pattern'} =
#       qr!$rule->{'pagetype'}->{'event_expr'}->{'pattern'}!;
  } else { # deprecated syntax...
#     $rule->{'pagetype'}->{'pattern'} =
#       qr!$rule->{'pagetype'}->{'pattern'}!;
  }

  # break up pre, if needed
  optimize_pre($rule);

  return $rule;
}

sub optimize_pre {
  my ($rule) = @_;
  my $logger = get_logger();
  my @varlist = map {$_->{'var'}} @{ $rule->{'pagetype'}->{'foreach'} };
# don't need this, but I love it.
# 	  my %is_var;
# 	  # create a hash for testing whether a var is defined or not
# 	  @is_var{@vars} = (1) x @vars;

  my @vars;
  foreach my $v (@varlist) {
    if (ref $v eq 'ARRAY') {
      push @vars, @{$v};
    } else {
      push @vars, $v;
    }
  }

  $logger->debug("[rules::optimize_pre] foreach vars: ", sub {Dumper(@vars)});

    foreach my $decl (@{$rule->{'pre'}}) {
      # check if any of the vars occur free in the rhs
      $logger->trace("[rules::optimize_pre] decl: ", sub {Dumper($decl)});
      my $dependent = 0;
      foreach my $v (@vars) {
#	$logger->debug("Checking if $v is free in expr");
	if ($decl->{'type'} eq 'expr' &&
	    Kynetx::Expressions::var_free_in_expr($v, $decl->{'rhs'})) {
	  $dependent = 1;
	} elsif ($decl->{'type'} eq 'here_doc' &&
	    Kynetx::Expressions::var_free_in_expr($v, $decl)) {
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




sub mk_initial_env {
 my $rule_env = empty_rule_env();

 # define initial environment to have a truth function
 $rule_env = extend_rule_env({'truth' =>
			      Kynetx::Expressions::mk_closure({'vars' => [],
							       'decls' => [],
							       'expr' => mk_expr_node('num', 1),
							      },
							      $rule_env)},
			     $rule_env);
 return $rule_env;
}

# sub mk_rule_list {
#   # third param is optional and not used in production--testing
#   my ($req_info, $rid, $ruleset) = @_;

#   my $logger = get_logger();

#   $req_info->{'rid'} = $rid; # override with the one we're working on

#   $logger->info("Processing rules for site " . $req_info->{'rid'});

#   $ruleset = get_rule_set($req_info) unless defined $ruleset;

#   my $rl = {'ruleset' => $ruleset,
# 	    'rules' => [],
# 	    'req_info' => $req_info
# 	   };


#   foreach my $rule (@{$ruleset->{'rules'}}) {

#     # test and capture here
#     my($selected, $vals) = select_rule($req_info->{'caller'}, $rule);


#     if ($selected) {

# 	push @{$rl->{'rules'}}, $rule;

# 	my $vars = Kynetx::Actions::get_precondition_vars($rule);
# 	$rl->{$rule->{'name'}} = {'req_info' => {},
# 				  'vars' => $vars,
# 				  'vals' => $vals
# 				 };
#     }
#   }

#  $logger->debug("Rule List: ", sub {Dumper $rl->{'rules'}});


#   return $rl;

# }

sub mk_schedule {
  # third param is optional and not used in production--testing
  my ($req_info, $rid, $ruleset) = @_;

  my $logger = get_logger();

  my $schedule = Kynetx::Scheduler->new();

  $req_info->{'rid'} = $rid; # override with the one we're working on

  $logger->info("Processing rules for site " . $req_info->{'rid'});

  $ruleset = get_rule_set($req_info) unless defined $ruleset;


  foreach my $rule (@{$ruleset->{'rules'}}) {


    # test and capture here
    my($selected, $vals) = select_rule($req_info->{'caller'}, $rule);

    if ($selected) {

      my $rulename = $rule->{'name'};
        $logger->debug("Rule $rulename is selected");
      $schedule->add($rid,$rule,$ruleset,$req_info);

      my $vars = Kynetx::Actions::get_precondition_vars($rule);

      $schedule->annotate_task($rid,$rulename,'vars',$vars);
      $schedule->annotate_task($rid,$rulename,'vals',$vals);


    }
  }

#  $logger->debug("Schedule: ", sub {Dumper $schedule});


  return $schedule;

}


1;
