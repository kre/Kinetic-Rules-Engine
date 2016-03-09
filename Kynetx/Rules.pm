package Kynetx::Rules;

# file: Kynetx/Rules.pm
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
no warnings qw(uninitialized);

use Data::UUID;
use Log::Log4perl qw(get_logger :levels);
use JSON::XS;
use Digest::MD5 qw(md5 md5_hex);
use AnyEvent;
use Storable qw/freeze/;

use Kynetx::Parser qw(:all);
use Kynetx::PrettyPrinter qw(:all);
use Kynetx::JavaScript;
use Kynetx::Expressions;
use Kynetx::Json qw(:all);
use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Datasets qw(:all);
use Kynetx::Session qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Modules qw(:all);
use Kynetx::Actions;
use Kynetx::Authz;
use Kynetx::Events;
use Kynetx::Log qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Repository;
use Kynetx::Environments qw(:all);
use Kynetx::Directives;
use Kynetx::Postlude;
use Kynetx::Response;
use Kynetx::ExecEnv;

use Cache::Memcached::Semaphore;


use Kynetx::JavaScript::AST qw/:all/;

use Kynetx::Modules::System qw/:all/;
use Kynetx::Modules::RuleEnv qw/:all/;

use Kynetx::Actions::LetItSnow;
use Kynetx::Actions::JQueryUI;
use Kynetx::Actions::FlippyLoo;

use Kynetx::Metrics::Datapoint;

use Storable qw(dclone);

use Data::Dumper;
$Data::Dumper::Indent = 1;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

our %EXPORT_TAGS = (
	all => [
		qw(
		  process_rules
		  eval_rule
		  eval_globals
		  get_rule_set
		  )
	]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

sub process_rules {
	my ( $r, $method, $rids, $eid ) = @_;

	my $logger = get_logger();

	$r->subprocess_env( START_TIME => Time::HiRes::time );

	if ( Kynetx::Configure::get_config('RUN_MODE') eq 'development' ) {

		# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
		my $test_ip = Kynetx::Configure::get_config('TEST_IP');
		$r->connection->remote_ip($test_ip);
		$logger->debug( "In development mode using IP address ",
			$r->connection->remote_ip() );
	}

	my $req_info = Kynetx::Request::build_request_env( $r, $method, $rids );
	$req_info->{'eid'} = $eid;

	# get a session, if _sid param is defined it will override cookie
	my $session = process_session( $r, $req_info->{'id_token'} );

	# initialization
	my $js       = '';
	my $dd       = Kynetx::Response->create_directive_doc( $req_info->{'eid'} );
	my $rule_env = mk_initial_env();

	#	my @rids = split( /;/, $rids );

	# if we sort @rids we change ruleset priority
	foreach my $rid_info ( @{ $req_info->{'rids'} } ) {

		my $rid = get_rid($rid_info);
		$logger->debug(
			"-------------------------------------------Schedule $rid");
		Log::Log4perl::MDC->put( 'site', $rid );
		my $schedule = mk_schedule( $req_info, $rid_info );
		$js .= eval {
			process_schedule( $r, $schedule, $session, $eid, $req_info, $dd );
		};
		if ($@) {
			Kynetx::Errors::raise_error( $req_info, $session, 'error',
				"Ruleset $rid failed: $@" );
		}
	}

	Kynetx::Response::respond( $r, $req_info, $session, $js, $dd, "Ruleset" );
}

# added $req_info to args because the $req_info from task is now a copy
# so it doesn't have all_actions built up with all of the actions in the request
sub process_schedule {
	my ( $r, $schedule, $session, $eid, $req_info, $dd, $overmetric ) = @_;

	my $logger = get_logger();

	my $ast = Kynetx::JavaScript::AST->new($eid);
	my ( $ruleset, $rule_env, $rid );

	$rid = '';
	my $current_rid = '';

	my $env_stash = {}; 

	#$logger->debug( "Schedule: ", Dumper($schedule) );
	my $ktoken = Kynetx::Persistence::KToken::get_token($session);
	my $ken = $ktoken->{"ken"};
        my $memd = get_memd();
#	$logger->debug("Kens:", sub {Dumper $ken, $ktoken});
	
	my $lock_name =  "eval-" . $ken;
	$logger->debug("Using lock named $lock_name");

	# try to acquire semaphore
	my $evallock;
        $evallock->{$lock_name} = Cache::Memcached::Semaphore::wait_acquire(
                memd => $memd, 
                name => $lock_name,
                max_wait        => 1200,
                poll_time       => 0.1,
		force_after_timeout => 1
        );

	if (! defined $evallock->{$lock_name}) {
	    $logger->debug("Failed to acquire lock for evaluation; exiting schedule evaluation.");
	    return $ast->generate_js();

	}

	while ( my $task = $schedule->next() ) {
		if (defined $overmetric) {
			my $c = $overmetric->count;
			$overmetric->count(++$c);
		}
		my $task_metric =
		  new Kynetx::Metrics::Datapoint( { 'series' => 'ps-task' } );
		
		$task_metric->start_timer();
		$task_metric->push($task->{'vars'},$task->{'vals'});

		#$logger->debug( "[task] ", sub { Dumper($task) } );

		# set up new context for this task
		if ($req_info) {
		    $logger->info("Context switch to ", 
				  $task->{"rid"}, ":",  $task->{"rule"}->{"name"},
				  " for event ",
				  $task->{"req_info"}->{"domain"}, ":",  $task->{"req_info"}->{"eventtype"}
				 );

		    my $task_req_info = {};
		    Kynetx::Request::set_event_domain($task_req_info, 
						      Kynetx::Request::get_event_domain($task->{'req_info'})
						     );
		    Kynetx::Request::set_event_type($task_req_info, 
						    Kynetx::Request::get_event_type($task->{'req_info'})
						   );
		    
		    foreach my $n (@{ Kynetx::Request::get_attr_names($task->{'req_info'}) }) {
			$logger->debug("Adding name ", $n);
			Kynetx::Request::add_event_attr($task_req_info, 
							$n, 
							Kynetx::Request::get_attr($task->{'req_info'}, $n)
						       );
		    }
#		    $logger->debug("Task attributes ", sub {Dumper $task_req_info});
		    Kynetx::Request::merge_req_env( $req_info, $task_req_info );
		}
		else {
		    $logger->warn("Warning: We are processing a schedule with no request info object!!!");
		    $req_info = $task->{'req_info'};
		}

		$rid = $task->{'rid'};
		my $rid_version =  $task->{'ver'};
		$req_info->{'rid'} =
		  mk_rid_info( $req_info, $rid, { 'version' => $rid_version } );
		$logger->debug( "Using RID ",
			Kynetx::Rids::print_rid_info( $req_info->{'rid'} ) );
			
		$task_metric->rid(get_rid( $req_info->{'rid'} ));
		$task_metric->token($ktoken->{'ktoken'});
	
		unless ( $rid eq $current_rid ) {
			my $r_metric =
	  			new Kynetx::Metrics::Datapoint( { 'series' => 'ps-task-contextswitch' } );
			$r_metric->start_timer();
			$r_metric->rid($rid);
			$r_metric->token($ktoken->{'ktoken'});
			$r_metric->eid($req_info->{'eid'});

			#context switch
			# we only do this when there's a new RID

			# save info from last context
			$ast->add_resources( $current_rid, $req_info->{'resources'} );

			# for each context switch, we need a new place to put the JS
			# that is generated for the rules in that context so that we
			# can create JS in the order in which the rules execute. At the
			# same time, we want to avoid re-executing and re-generating
			# the JS for meta and global blocks.
			# updated context counter
			$ast->update_context($rid);

			#      $logger->debug("Task request: ", Dumper $task->{'req_info'});

			# we use this to modify the schedule on-the-fly
			$req_info->{'schedule'} = $schedule;

			#      $ruleset = $task->{'ruleset'};
			$ruleset = Kynetx::Rules::get_rule_set($req_info);

			# rid to raise errors to
			$req_info->{'errorsto'} = $ruleset->{'meta'}->{'errors'};

			# store so we don't have to grab it again
			stash_ruleset( $req_info, $ruleset );

			if (
				(
					   $ruleset->{'meta'}->{'logging'}
					&& $ruleset->{'meta'}->{'logging'} eq "on"
				)
			  )
			{
				$logger->debug("Turning on logging for $rid");
				Kynetx::Util::turn_on_logging();
			}
			else {
				$logger->debug("Turning off logging for $rid");
				Kynetx::Util::turn_off_logging();
			}

			Log::Log4perl::MDC->put( 'site', $rid );
			$logger->debug( "Processing rules for RID " . $rid );

			my $r_metric5 =
	  			new Kynetx::Metrics::Datapoint( { 'series' => 'ps-task-contextswitch-get-rule-env' } );
			$r_metric5->start_timer();
			$r_metric5->rid($rid);
			$r_metric5->token($ktoken->{'ktoken'});
			$r_metric5->eid($req_info->{'eid'});
			$rule_env =
			  get_rule_env( $req_info, $ruleset, $session, $ast, $env_stash );
			$r_metric5->stop_and_store();

			$req_info->{'rule_count'}     = 0;
			$req_info->{'selected_rules'} = [];

			$current_rid = $rid;
			$logger->debug("Context switch complete; processing $current_rid");
			$r_metric->stop_and_store();
			
		}    # done with context

		$req_info->{"error_count"} = 0; # reset for each rule

		my $rule      = $task->{'rule'};
		my $rule_name = $rule->{'name'};
		$task_metric->rulename($rule_name);
		$task_metric->eid($req_info->{'eid'});

		Log::Log4perl::MDC->put( 'rule', $rule_name);

		$logger->trace( "[rules] foreach pre: ",
			sub { Dumper( $rule->{'pre'} ) } );

		# set by eval_control_statement in Actions.pm
		if ($req_info->{ get_rid( $req_info->{'rid'} ) . ':__KOBJ_EXEC_LAST' }) {
			$task_metric->stop_and_store();
			last;
		}

		$rule->{'state'} ||= 'active';

		my $this_rule_env;
		$logger->debug( "Rule $rule_name is " . $rule->{'state'} );
		if (
			$rule->{'state'} eq 'active'
			|| (   $rule->{'state'} eq 'test'
				&& $req_info->{'mode'}
				&& $req_info->{'mode'} eq 'test' )
		  )
		{    # optimize??

			$req_info->{'rule_count'}++;

			$logger->debug("[selected] $rule->{'name'} ");

			#      $logger->trace("[rules] ", sub { Dumper($rule) });

			push @{ $req_info->{'selected_rules'} }, $rule->{'name'};

			my $select_vars   = $task->{'vars'};
			my $captured_vals = $task->{'vals'};

			# store the captured values from the precondition to the env
			my $cap = 0;
			my $sjs = '';
			foreach my $var ( @{$select_vars} ) {
				$var =~ s/^\s*(.+)\s*/$1/;    # trim whitspace
				$logger->debug("[select var] $var -> $captured_vals->[$cap]");
				$this_rule_env->{$var} = $captured_vals->[$cap];
				$sjs .= Kynetx::JavaScript::gen_js_var(
					$var,
					Kynetx::JavaScript::gen_js_expr(
						Kynetx::Expressions::exp_to_den(
							$captured_vals->[$cap]
						)
					)
				);

				$cap++;
			}

			my $new_req_info =
			  Kynetx::Request::merge_req_env( $task->{'req_info'}, $req_info );

			my $js;
			if (
				Kynetx::Authz::is_authorized(
					get_rid( $req_info->{'rid'} ),
					$ruleset, $session
				)
			  )
			{
			my $er_metric =
	  			new Kynetx::Metrics::Datapoint( { 'series' => 'ps-task-evalrule' } );
			$er_metric->start_timer();
			$er_metric->rid(get_rid( $req_info->{'rid'} ));
			$er_metric->token($ktoken->{'ktoken'});
			$er_metric->eid($req_info->{'eid'});

				$js = eval {
					eval_rule(
						$r,

						#$new_req_info,
						$req_info,
						extend_rule_env( $this_rule_env, $rule_env ),
						$session,
						$rule,
						$sjs,    # pass in the select JS to be inside rule
						$dd
					);
				};

				if ($@) {
					$logger->error( "Ruleset $rid failed: ", $@ );
				}
			$er_metric->stop_and_store();

			}
			else {
				$logger->debug("Sending activation notice for $rid");
				$js = eval {
					Kynetx::Authz::authorize_message( $task->{'req_info'},
						$session, $ruleset );
				};
				if ($@) {
					$logger->error( "Authorization failed for $rid: ", $@ );
				}

				# Since this RID isn't auhtorized yet, skip the rest...
				$schedule->delete_rid($rid);

			}
			$ast->add_rule_js( $rid, $js );

		}
		else {
			$logger->debug("[not selected] $rule->{'name'} ");
		}
		$task_metric->stop_and_store();
	}
	
	# release evaluation lock
	$evallock->{$lock_name} = undef;

	# process for final context
	$ast->add_resources( $current_rid, $req_info->{'resources'} );

	$logger->debug( "Finished processing rules for " . $rid );
	return $ast->generate_js();

}

sub eval_meta {
	my ( $req_info, $ruleset, $rule_env, $session, $env_stash ) = @_;

	my $logger = get_logger();
	$logger->trace("META BLOCK EVALUATION");
	my $js = "";

	my $rid = get_rid( $req_info->{'rid'} );

	my $this_js;

	$req_info->{"meta:$rid:ruleset_name"} = $ruleset->{'ruleset_name'};
	$req_info->{"meta:$rid:name"}         = $ruleset->{'meta'}->{'name'};
	$req_info->{"meta:$rid:author"}       = $ruleset->{'meta'}->{'author'};
	$req_info->{"meta:$rid:description"}  = $ruleset->{'meta'}->{'description'};

	# process keys now so that they're available for use in configuring modules
	if ( $ruleset->{'meta'}->{'keys'} ) {
		( $this_js, $rule_env ) =
		  Kynetx::Keys::process_keys( $req_info, $rule_env, $ruleset );
		$js .= $this_js;
	}

	if ( $ruleset->{'meta'}->{'use'} ) {
		( $this_js, $rule_env ) =
		  eval_use( $req_info, $ruleset, $rule_env, $session, $env_stash, undef);
		$js .= $this_js;
	}

	#    $logger->debug("Rule env: ", sub { Dumper $rule_env} );

	return ( $js, $rule_env );

}

sub eval_use {
	my ( $req_info, $ruleset, $rule_env, $session, $env_stash, $using_rid) = @_;

	my $logger = get_logger();
	my $js     = "";

	my $use = $ruleset->{'meta'}->{'use'};

	my $rid = get_rid( $req_info->{'rid'} );

	$using_rid ||= $rid;  # current rid if not set
	
	my $this_js;

	foreach my $u ( @{$use} ) {

	# just put resources in $req_info and mk_registered_resources will grab them
		if ( $u->{'type'} eq 'resource' ) {
			$req_info->{'resources'}->{ $u->{'resource'}->{'location'} } =
			  { 'type' => $u->{'resource_type'} };
		}
		elsif ( $u->{'type'} eq 'module' ) {
			$logger->trace( "module struct: ", sub { Dumper($u) } );
			#			$logger->debug("Doing module ", sub {Dumper $env_stash});
			# side effects the rule env.
			( $this_js, $rule_env ) =
			  eval_use_module( $req_info, $rule_env, $session, $u->{'name'},
					   $u->{'alias'}, $u->{'modifiers'}, $u->{'version'}, $env_stash, 
					   $using_rid
					 );

			# don't include the module JS in the results.
			# $js .= $this_js;
		}
		else {
			$logger->error( "Unknown type for 'use': ", $u->{'type'} );
		}

	}

	# $logger->debug("Calculated env ", Dumper $rule_env);

	return ( $js, $rule_env );
}

sub _module_sig {
  my ($name,$alias,    $modifiers, $mversion) = @_;
  return md5_hex( $name . $mversion . $alias . freeze $modifiers);      
}

sub eval_use_module {
  my (
      $req_info, $rule_env,  $session,  $name,
      $alias,    $modifiers, $mversion, $env_stash, $using_rid
     ) = @_;

  my $logger = get_logger();
  my $ktoken = Kynetx::Persistence::KToken::get_token($session);
  my $metric =
    new Kynetx::Metrics::Datapoint( { 'series' => 'use-module' } );
  $metric->start_timer();
  $metric->rid(get_rid( $req_info->{'rid'} ));
  $metric->token($ktoken->{'ktoken'});
  $metric->eid($req_info->{'eid'});

  $mversion ||= 'prod';
  my $module_sig = _module_sig($name,$alias,$modifiers, $mversion);
  
  #md5_hex( $name . $mversion . $alias . freeze $modifiers);
	
  my $memd = get_memd();
  
  my $self_rid = get_rid( $req_info->{'rid'} );
  my $mod_rid = $name;
  
  $logger->trace("$self_rid uses $mod_rid");

  my($module_cache, $module_rule_env, $provided, $js, $export_keys);
  if (Kynetx::Request::module_loaded($module_sig, $req_info)) {
      my $module_data = Kynetx::Request::get_module($module_sig, $req_info);
      $module_rule_env = $module_data->{"module_env"};
      $provided = $module_data->{"provides"} || {};
      $js = $module_data->{"js"} || '';
      $export_keys = $module_data->{"export_keys"} || {};
  } else {
      $module_cache = Kynetx::Modules::RuleEnv::get_module_cache($module_sig, $memd);
      $module_rule_env = $module_cache->{Kynetx::Modules::RuleEnv::get_re_key($module_sig)};
      $provided = $module_cache->{Kynetx::Modules::RuleEnv::get_pr_key($module_sig)} || {};
      $js = $module_cache->{Kynetx::Modules::RuleEnv::get_js_key($module_sig)} || '';
      $export_keys = $module_cache->{Kynetx::Modules::RuleEnv::get_export_keys_key($module_sig)} || {};
  }

  

  # build a list of module sigs associated with a calling rid/version
  my $msig_list = Kynetx::Modules::RuleEnv::get_msig_list($req_info, $memd);
			   

  my $namespace_name = $Kynetx::Modules::name_prefix . ( $alias || $name );

  if (! (defined $module_rule_env && $msig_list->{$module_sig})) {


    #  $logger->debug("Module sig $module_sig", sub {Dumper $env_stash});

    # if (! defined $env_stash->{$module_sig}) {

    $logger->debug("----- Loading Module $name.$mversion as $alias -------");

    my $js = '';
    my $this_js;

    #  module hierarchy can look like this:
    #
    #  a -> b
    #  |
    #  +--> b
    #
    # but not this
    #
    # a -> b -> b ...
    #
    # or this
    #
    # a -> b -> c -> ... -> b
    #
    
    # sanity check, we're not in a big loop
#    $logger->debug(">>>>>> Module list: ", sub{Dumper lookup_rule_env( '_module_list', $rule_env ) });
    foreach my $module_name (
	    @{ lookup_rule_env( '_module_list', $rule_env ) || [] } )
      {
	$logger->debug("Seeing module $module_name for $name");
	if ( $module_name eq $name ) {
	  $logger->debug("$name has already been used as a module");
	  return ( $js, $rule_env );
	}
      }

    # Default to the production version of modules
    my $use_ruleset =
      Kynetx::Rules::get_rule_set( $req_info, 1, $name, $mversion,
				   { 'in_module' => 1 } );
    
#    $logger->trace( "Using ", sub { Dumper $use_ruleset} );

    my $provided_array = $use_ruleset->{'meta'}->{'provide'}->{'names'} || [];

    foreach my $name ( @{$provided_array} ) {
      $provided->{$name} = 1;
    }
# replaced with...
#    $provided = {map {$_ => 1} @{$use_ruleset->{'meta'}->{'provide'}->{'names'} || []}};

    if (scalar @{$provided_array} < 1) {
      $logger->debug("WARNING: module $name provides no functions" );
    }

    my $configuration = $use_ruleset->{'meta'}->{'configure'}->{'configuration'}
      || [];
#    $logger->trace( "conf ", sub { Dumper $configuration} );
    $logger->debug( "Module provides: ",
		    sub { join( ",", @{$use_ruleset->{'meta'}->{'provide'}->{'names'} || []} ) } );

    # create the module rule_env by extending an empty env with the config
    
    my @mod_list = @{ lookup_rule_env( '_module_list', $rule_env ) || [] };
    push( @mod_list, $name );
#    $logger->debug(">>>>>> Augmented module list: ", sub{ Dumper \@mod_list });

    my $init_mod_env = extend_rule_env(
            {
#			'_callingRID'     => get_rid( $req_info->{'rid'} ),
#			'_callingVersion' => $req_info->{'rule_version'},
			'_moduleRID'      => $name,
			'_moduleVersion'  => $mversion,
			'_inModule'       => 'true',
			'_module_list'    => \@mod_list,
            },
            empty_rule_env()
      );

    $module_rule_env =
      set_module_configuration( $req_info, $rule_env, $session, $init_mod_env,
				$configuration, $modifiers || [] );

    
    # put any keys in the module rule_env *before* evaling the globals
    if ( $use_ruleset->{'meta'}->{'keys'} ) {
      ( $this_js, $module_rule_env ) =
	Kynetx::Keys::process_keys( $req_info, $module_rule_env,
				    $use_ruleset );
      $js .= $this_js;
    }

    my $is_cachable;

    # Check to see if this module exposes any keys to external ruleset
    if ($use_ruleset->{'meta'}->{'provides_keys'}) {
      my $key_permissions = $use_ruleset->{'meta'}->{'provides_keys'};
#      $logger->debug("Exposing keys to parent rid: $using_rid for $name ", sub {Dumper $key_permissions});
      my $permitted;

      foreach my $k (keys %{ $key_permissions }) {
	  foreach my $r (@{ $key_permissions->{$k}}) {
	      if ($r eq $using_rid){
		  $logger->debug("Storing key $k for rid $using_rid");
		  push (@{$permitted}, $k);
	      }
	  }
      }

      if (defined $permitted ) {
	  foreach my $obj (@{$permitted}) {
	      my $tuple = ();
	      push(@{$tuple},$name);
	      push (@{$tuple},Kynetx::Keys::get_key($req_info,$module_rule_env,$obj));
	      $export_keys->{$obj} = $tuple;
	  }
      } else {
	  $logger->debug("Ruleset $using_rid is NOT permitted by $name allowed: ", sub{Dumper $key_permissions});
      }
    }
    

    if ( $use_ruleset->{'meta'}->{'use'} ) {
      ( $this_js, $module_rule_env ) =
	eval_use( $req_info, $use_ruleset, $module_rule_env, $session,
		  $env_stash, $name);
      $js .= $this_js;
    }

#    $logger->debug("Module env ", Dumper $module_rule_env);


    # eval the module's global block
    if ( $use_ruleset->{'global'} ) {
      ( $js, $module_rule_env, $is_cachable ) =
	process_one_global_block( $req_info, $use_ruleset->{'global'},
				  $module_rule_env, $session, $namespace_name, $provided );

    }


    if ($is_cachable) {
      $logger->debug("Caching module $name.$mversion...");

      Kynetx::Modules::RuleEnv::set_module_cache($module_sig, $req_info, $memd,
						 $js, $provided, $module_rule_env, $export_keys, $name, $mversion);

    } else {
       $logger->debug("Module $name.$mversion is not cachable...");
    }


  } else {

#    $logger->debug("Cached module env ", sub {Dumper $module_rule_env});
#    $logger->debug("Cached provided hash ", sub{Dumper $provided});
 
    $logger->debug("Using cached rule env for module $name.$mversion with signature $module_sig");
  }

  # just put sig in where env was before
  $rule_env = extend_rule_env( $namespace_name, $module_sig, $rule_env);

  # put the module_env in the $req_info
  $req_info = Kynetx::Request::put_module_in_request_info($module_sig,
							  $name,
							  $mversion,
							  $provided,
							  $module_rule_env,
							  $js,
							  $export_keys,
							  $req_info
							 );
  

  # $rule_env = extend_rule_env( $namespace_name, $module_rule_env,
  # 			       extend_rule_env( $namespace_name . '_provided', $provided, $rule_env )
  # 			     );
			     
  # Place the exported keys in the current key environment		     
  foreach my $kkey (keys %{$export_keys}) {
    my $tuple = $export_keys->{$kkey};
    my $source = $tuple->[0];
    my $val = $tuple->[1];
    my $this_js;
    $logger->debug("Module $name exports key $kkey");
    ($this_js, $rule_env) = Kynetx::Keys::insert_key($req_info, 
					$rule_env, 
					$kkey, 
					$val);
    $js .= $this_js;
  }

  $metric->stop_and_store();

  return ( $js, $rule_env );

}

# set_module_configuration is used by eval_use_module and build_composed_action
sub set_module_configuration {
	my ( $req_info, $rule_env, $session, $mod_rule_env, $config_array,
		$modifiers )
	  = @_;

	my $logger = get_logger();

	my $configuration = {};

	$logger->trace(
		"Config and modifiers: ",
		sub { Dumper $config_array},
		sub { Dumper $modifiers}
	);

	foreach my $conf ( @{$config_array} ) {

		# config values are executed in module's rule env (empty)
		$configuration->{ $conf->{'name'} } = Kynetx::Expressions::den_to_exp(
			Kynetx::Expressions::eval_expr(
				$conf->{'value'}, $mod_rule_env, 'module_config',
				$req_info,        $session
			)
		);

	}

	foreach my $mod ( @{$modifiers} ) {

		# only insert names that are already there (honor config)
		if ( defined $configuration->{ $mod->{'name'} } ) {

			# modifiers are executed in rule's environment
			$configuration->{ $mod->{'name'} } =
			  Kynetx::Expressions::den_to_exp(
				Kynetx::Expressions::eval_expr(
					$mod->{'value'}, $rule_env, 'module_config',
					$req_info,       $session
				)
			  );
		}

	}

	$logger->trace( "Configuration ", sub { Dumper $configuration} );

	$mod_rule_env = extend_rule_env( $configuration, $mod_rule_env );

	return $mod_rule_env;

}

sub eval_globals {
	my ( $req_info, $ruleset, $rule_env, $session ) = @_;
	my $logger = get_logger();
	$logger->trace("GLOBAL BLOCK EVALUATION");

	my $js = "";

	my $temp_js = '';
	my $is_cachable; 
	if ( $ruleset->{'global'} ) {
		( $temp_js, $rule_env, $is_cachable ) =
		  process_one_global_block( $req_info, $ruleset->{'global'}, $rule_env,
			$session );
		$js .= $temp_js;
	}

	return ( $js, $rule_env, $is_cachable );

}

sub process_one_global_block {
  my ( $req_info, $globals, $rule_env, $session, $namespace ) = @_;
  my $logger = get_logger();

  my $js = "";

  my $cachable = 1;

  # make this act like let* not let
  my @vars;
  foreach my $g ( @{$globals} ) {
    $g->{'lhs'} = $g->{'name'} unless ( defined $g->{'lhs'} );
    if ( defined $g->{'lhs'} ) {
      if ( defined $g->{'type'} && $g->{'type'} eq 'datasource' ) {
	push @vars, 'datasource:' . $g->{'lhs'};
      }
      else {
	push @vars, $g->{'lhs'};
      }
    }
  }

  my @empty_vals = map { '' } @vars;
  $rule_env = extend_rule_env( \@vars, \@empty_vals, $rule_env );

  my $ns = $namespace || "";
  $logger->debug("Namespaced: $ns");
  $logger->debug( "Global vars: ", join( ", ", @vars ) );

  foreach my $g ( @{$globals} ) {
    my $this_js = '';
    my $var     = '';
    my $val     = 0;
    if ( !defined $namespace ) {
      
      # only want these when we're not loading a module
      if ( $g->{'emit'} ) {    # emit
	$this_js =
	  Kynetx::Expressions::eval_emit( $g->{'emit'} ) . "\n";
      }
      elsif ( defined $g->{'type'} && $g->{'type'} eq 'css' ) {
	$this_js = "KOBJ.css("
	  . Kynetx::JavaScript::mk_js_str( $g->{'content'} ) . ");\n";

	$cachable &&= 1


      }
    }
    if ( defined $g->{'type'}
	 && ( $g->{'type'} eq 'expr' || $g->{'type'} eq 'here_doc' ) )
      {
	$logger->trace("Must be a decl: Expr: $g->{'type'}");
	
	# side-effects the rule-env
	$this_js = Kynetx::Expressions::eval_one_decl( $req_info, $rule_env,
						       'global', $session, $g );


	$cachable &&= Kynetx::Expressions::cachable_decl($g);


	$logger->trace( "Show rule_env side effects: ",
			sub { Dumper($rule_env) } );
	
      }
    elsif ( defined $g->{'type'} && $g->{'type'} eq 'datasource' ) {
      $rule_env->{ 'datasource:' . $g->{'lhs'} } = $g;

      $cachable &&= 1

    }
    elsif ( defined $g->{'type'} && $g->{'type'} eq 'dataset' ) {
      my $new_ds = Kynetx::Datasets->new($g);
# by commenting this test out, we put the JS for the dataset directly in the generate JS
      if ( !$new_ds->is_global() ) {
	$new_ds->load($req_info);
	$new_ds->unmarshal();
	$this_js = $new_ds->make_javascript();
#      $logger->debug("Javascript for dataset declaration ", $new_ds->name, " -> ", $this_js);
	$var     = $new_ds->name;
	if ( defined $new_ds->json ) {
	  $val = $new_ds->json;
	}
	else {
	  $val = $new_ds->sourcedata;
	}
	
	#($this_js, $var, $val) = mk_dataset_js($g, $req_info, $rule_env);
	# yes, this is cheating and breaking the abstraction, but it's fast
	$rule_env->{$var} = $val;
     }
    }
    else {
      $logger->debug( "Fell through: Expr: ", $g->{'type'} || "" );
    }
    $js .= $this_js;
  }
  $logger->trace( " rule_env: ", sub {Dumper($rule_env)} );

  return ( $js, $rule_env, $cachable );
}

sub eval_rule {
	my ( $r, $req_info, $rule_env, $session, $rule, $initial_js, $dd ) = @_;

	Log::Log4perl::MDC->put( 'rule', $rule->{'name'} );

	my $logger = get_logger();

	$logger->info("-----***---- begin rule execution: $rule->{'name'} ----***-----");

	my $js = '';
	my $rule_metric = new Kynetx::Metrics::Datapoint( {
	  	'eid' => $req_info->{'eid'},
	  	'series' => 'rule-eval'
	  });
	  
	$rule_metric->start_timer();
	
	$rule_metric->rid(get_rid( $req_info->{'rid'}));
	$rule_metric->rulename($rule->{'name'});
	my $ktoken = Kynetx::Persistence::KToken::get_token($session);
	$rule_metric->token($ktoken->{'ktoken'});
	# keep track of these for each rule
	$req_info->{'actions'} = [];
	$req_info->{'labels'}  = [];
	$req_info->{'tags'}    = [];

# assume the rule doesn't fire.  We will change this if it EVER fires in this eval
	$req_info->{ $rule->{'name'} . '_result' } = 'notfired';

	#	$logger->debug("Rule pre ", sub {Dumper $rule->{'pre'}});

	if (   $rule->{'pre'}
		&& scalar @{ $rule->{'pre'} } > 0
		&& !( $rule->{'inner_pre'} || $rule->{'outer_pre'} ) )
	{

		# $logger->debug(
		# 	"Pre optimization ",
		# 	sub { Dumper $rule->{'pre'} },
		# 	sub { Dumper $rule->{'inner_pre'} },
		# 	sub { Dumper $rule->{'outer_pre'} }
		# );

		$logger->debug("Rule not pre optimized...");
		optimize_pre($rule);
	}

	my $outer_tentative_js = '';

	# this loads the rule_env.
	( $outer_tentative_js, $rule_env ) =
	  Kynetx::Expressions::eval_prelude( $req_info, $rule_env, $rule->{'name'},
		$session, $rule->{'outer_pre'} );

	$rule->{'pagetype'}->{'foreach'} = []
	  unless defined $rule->{'pagetype'}->{'foreach'};

	# clear the final flag before we get started...
	Kynetx::Request::clr_final_flag($req_info);

	my $execenv = Kynetx::ExecEnv::build_exec_env();

	# set condition var for AnyEvent, check after loop...
	my $cv = AnyEvent->condvar();
	$execenv->set_condvar($cv);
	AnyEvent->now_update();

	$cv->begin( sub { shift->send("All threads complete") } );

	$js .= eval_foreach(
		$r,
		$req_info,
		$rule_env,
		$session,
		$rule,
		$dd,
		scalar @{ $rule->{'pagetype'}->{'foreach'} },    # final_count
		$execenv,
		@{ $rule->{'pagetype'}->{'foreach'} },
	);

	# handle possible asynchronous calls
	$cv->end;
	$logger->debug( $cv->recv );
	my $thread_results = $execenv->get_results();
	if ( scalar @{$thread_results} > 0 ) {
	  $logger->debug("All threads complete; sending system:send_complete");
		Kynetx::Modules::System::raise_system_event(
			$req_info,
			$rule->{'name'},
			'send_complete',
			[
				{
					'name'  => 'send_results',
					'value' => $thread_results
				}
			]
		);
	}

	# save things for logging
	push(
		@{ $req_info->{'results'} },
		$req_info->{ $rule->{'name'} . '_result' }
	);
	push(
		@{ $req_info->{'names'} },
		get_rid( $req_info->{'rid'} ) . ':' . $rule->{'name'}
	);
	push( @{ $req_info->{'all_actions'} }, $req_info->{'actions'} );
	push( @{ $req_info->{'all_labels'} },  $req_info->{'labels'} );
	push( @{ $req_info->{'all_tags'} },    $req_info->{'tags'} );
	
	$logger->debug("Actions: ", sub {Dumper($req_info->{'actions'})});
	foreach my $action (@{$req_info->{'actions'}}) {
		$rule_metric->tag($action);
	}

	# combine JS and wrap in a closure if rule fired
	$js = mk_turtle( $initial_js . $outer_tentative_js . $js ) if $js;
	
	$rule_metric->stop_and_store();

	return $js;

}

# recursive function on foreach list.
sub eval_foreach {
	my (
		$r,
		$req_info,
		$rule_env,
		$session,
		$rule,
		$dd,
		$final_count,
		$execenv,
		@foreach_list    # this needs to be last
	) = @_;

	my $logger = get_logger();

	my $fjs = '';

 #  $logger->debug("In foreach with " . Dumper(@foreach_list)) if @foreach_list;

	if ( @foreach_list == 0 ) {

		# test for final time through loop
		# To understand how final works, imagine this foreach structure:
		#   foreach [1,2,4] setting (x)
		#     foreach [5,6] setting (y)
		#
		# $final_count will start with the value 2
		#
		# The following table shows what happens to $final_count
		#
		#   x  y  final x?  final y?  sum  $final_count - sum
		# ------------------------------------------------------
		#   1  5     0        0        0            2
		#   1  6     0        1        1            1
		#   2  5     0        0        0            2
		#   2  6     0        1        1            1
		#   4  5     1        0        1            1
		#   4  6     1        1        2            0
		#
		# this is what makes "on final" work in postlude

		if ( $final_count == 0 ) {
			Kynetx::Request::set_final_flag($req_info);
		}

		$fjs = eval_rule_body( $r, $req_info, $rule_env, $session, $rule, $dd,
			$execenv );

	}
	else {

		# expr has to result in array of prims
		my $valarray =
		  Kynetx::Expressions::eval_expr( $foreach_list[0]->{'expr'},
			$rule_env, $rule->{'name'}, $req_info, $session );

		my $vars = $foreach_list[0]->{'var'};

		# FIXME: not sure why we have to do this.
		unless ( ref $vars eq 'ARRAY' ) {
			$vars = [$vars];
		}

		# loop below expects array of arrays
		if ( $valarray->{'type'} eq 'array' ) {

			# array of single value arrays
			$valarray =
			  [ map { [ Kynetx::Expressions::exp_to_den($_) ] }
				  @{ $valarray->{'val'} } ];
		}
		elsif ( $valarray->{'type'} eq 'hash' ) {

			# turn hash into array of two element arrays
			my @va;
			foreach my $k ( keys %{ $valarray->{'val'} } ) {
				push @va,
				  [
					Kynetx::Expressions::exp_to_den($k),
					Kynetx::Expressions::exp_to_den( $valarray->{'val'}->{$k} )
				  ];
			}
			$valarray = \@va;

		}
		else {
			$logger->debug(
"Foreach expression does not yield array or hash; creating array from singleton"
			);

			# make an array of arrays
			$valarray = [ [ Kynetx::Expressions::exp_to_den($valarray) ] ];
		}

		my $i = 0;
		foreach my $val ( @{$valarray} ) {

			$logger->trace( "Evaluating rule body with " . Dumper($val) );

			$logger->info( "----------- foreach iteration " . $i++ . " \n" );

			my $vjs =
			  Kynetx::JavaScript::gen_js_var_list( $vars,
				[ map { Kynetx::JavaScript::gen_js_expr($_) } @{$val} ] );

			my $dvals = [ map { Kynetx::Expressions::den_to_exp($_) } @{$val} ];
			$logger->trace( "Vals: ",  sub { Dumper($val) } );
			$logger->trace( "dvals: ", sub { Dumper($dvals) } );

			my $new_count = $final_count;
			if ( $i == scalar( @{$valarray} ) ) {

				# this will only get to 0 when we're final
				$new_count--;
			}

			# we recurse in side this loop to handle nested foreach statements
			$fjs .= mk_turtle(
				$vjs
				  . eval_foreach(
					$r, $req_info,
					extend_rule_env( $vars, $dvals, $rule_env ), $session,
					$rule,      $dd,
					$new_count, $execenv,
					cdr(@foreach_list),
				  )
			);
		}
	}

	return $fjs;
}

sub eval_rule_body {
	my ( $r, $req_info, $rule_env, $session, $rule, $dd, $execenv ) = @_;

	my $logger = get_logger();

	my $inner_tentative_js;
	( $inner_tentative_js, $rule_env ) =
	  Kynetx::Expressions::eval_prelude( $req_info, $rule_env, $rule->{'name'},
		$session, $rule->{'inner_pre'} );

	# if the condition is undefined, it's true.
	$rule->{'cond'} ||= mk_expr_node( 'bool', 'true' );

	my $pred_value = Kynetx::Expressions::true_value(
		Kynetx::Expressions::eval_expr(
			$rule->{'cond'}, $rule_env, $rule->{'name'},
			$req_info,       $session
		)
	);

	my $js = '';

	my $fired = 0;
	if ($pred_value) {

		$logger->info("rule fired");

		# this is the main event.  The browser has asked for a
		# chunk of Javascrip and this is where we deliver...

	 # combine the inner_tentive JS, with the generated JS and wrap in a closure
		$js = $inner_tentative_js
		  . Kynetx::Actions::build_js_load( $rule, $req_info, $dd, $rule_env,
			$session, $execenv );

		$fired = 1;

		# change the 'fired' flag to indicate this rule fired.
		$req_info->{ $rule->{'name'} . '_result' } = 'fired';

		#    push(@{ $req_info->{'results'} }, 'fired');

	}
	else {
		$logger->info("rule did not fire");

		$fired = 0;

		# don't do anything since we already assume no fire;
		#    $req_info->{$rule->{'name'}.'_result'} = 'notfired';
		#    push(@{ $req_info->{'results'} }, 'notfired');

	}

	$js .=
	  Kynetx::Postlude::eval_post_expr( $rule, $session, $req_info, $rule_env,
		$fired, $execenv )
	  if ( defined $rule->{'post'} );

	return $js;
}

# this returns the right rules for the caller and site
sub get_rule_set {
	my ( $req_info, $localparsing, $rid, $ver, $options ) = @_;

	my $caller = $req_info->{'caller'} || 'unknown';
	$rid ||= get_rid( $req_info->{'rid'} );
	$ver ||= get_version( $req_info->{'rid'} );

	# don't do this. We rely on $ver being undefined later
	#	$ver ||= 'prod';

	my $logger = get_logger();
	$logger->debug("Getting ruleset $rid.$ver for $caller");

	my $ruleset;
	if ( is_ruleset_stashed( $req_info, $rid, $ver ) ) {
	    $logger->debug("Ruleset $rid.$ver stashed");
		$ruleset = grab_ruleset( $req_info, $rid, $ver );
	}
	else {
	    # remake incase the rid and ver were passed in
	    my $rid_info = mk_rid_info( $req_info, $rid, {"version" => $ver} );
	    $ruleset =
	      Kynetx::Repository::get_rules_from_repository( $rid_info, $req_info,
							     $ver, $localparsing, 0 );

	    # do not store ruleset in the request info here
	    # or it ends up in the session for the user
	}

	# if we're not in a module, set up logging
	if ( !$options->{'in_module'} ) {
		if (
			(
				   $ruleset->{'meta'}->{'logging'}
				&& $ruleset->{'meta'}->{'logging'} eq "on"
			)
		  )
		{
			Kynetx::Util::turn_on_logging();
		}
		else {
			Kynetx::Util::turn_off_logging();
		}
	}

	$ruleset->{'rules'} ||= [];

	$logger->debug(
		"Found " . @{ $ruleset->{'rules'} } . " rules for RID $rid.$ver" );

	$logger->trace( "Ruleset: ", sub { Dumper($ruleset) } );
	return $ruleset;

}

sub stash_ruleset {
	my ( $req_info, $ruleset ) = @_;
	my $rid = get_rid( $req_info->{'rid'} );
	my $ver = get_version( $req_info->{'rid'} ) || 'prod';
	$req_info->{"$rid.$ver"}->{'ruleset'} = $ruleset;
}

sub grab_ruleset {
	my ( $req_info, $rid, $ver ) = @_;
	return $req_info->{"$rid.$ver"}->{'ruleset'};
}

sub is_ruleset_stashed {
	my ( $req_info, $rid, $ver ) = @_;
	my $logger = get_logger();
#	$logger->debug("Stashed ($rid.$ver)? ", sub {Dumper $req_info}); 
	return defined $req_info->{"$rid.$ver"}
	  && defined $req_info->{"$rid.$ver"}->{'ruleset'};
}

sub get_rule_env {
	my ( $req_info, $ruleset, $session, $ast, $env_stash ) = @_;

	my $logger = get_logger();

	my $rid = get_rid( $req_info->{'rid'} );
	my $ver = get_version( $req_info->{'rid'} ) || 'prod';
	
	
	if ( !defined $env_stash->{ $rid . $ver } ) {

		$logger->debug("No rule env found for $rid...generating");

		my ( $mjs, $gjs, $rule_env );

		my $init_rule_env = Kynetx::Rules::mk_initial_env();

		$init_rule_env->{'ruleset_name'} = $rid;

		# generate JS for meta
		( $mjs, $rule_env ) =
		  eval_meta( $req_info, $ruleset, $init_rule_env, $session,
			$env_stash, undef, $init_rule_env );

		$logger->debug("Processing globals for ruleset $rid");

		# handle globals, start js build, extend $rule_env
		( $gjs, $rule_env ) =
		  eval_globals( $req_info, $ruleset, $rule_env, $session );

		#      $logger->debug("Rule env after globals: ", Dumper $rule_env);
		#    $logger->debug("Global JS: ", $gjs);

		$ast->add_rid_js( $rid, $mjs, $gjs, $ruleset, $req_info->{'txn_id'} );

		$env_stash->{ $rid . $ver } = $rule_env;

	}

	$logger->debug("Returning rule env for $rid");

	return $env_stash->{ $rid . $ver };

}

sub select_rule {
	my ( $caller, $rule ) = @_;

	my $logger = get_logger();

	# test the pattern, captured values are stored in @captures

#	$logger->debug("Rule ", sub {Dumper $rule});
	my $pattern_regexp = Kynetx::Actions::get_precondition_test($rule);
	$logger->debug( "Selection pattern for $rule->{'name'}: ", $pattern_regexp );

	my $captures = [];
	if ( $pattern_regexp && ( @{$captures} = $caller =~ $pattern_regexp ) ) {
		return ( 1, $captures );
	}
	else {
		return ( 0, $captures );
	}
}

sub optimize_ruleset {
	my ($ruleset) = @_;

	my $logger = get_logger();

	$logger->debug( "Optimizing rules for ", $ruleset->{'ruleset_name'} );

	$ruleset->{'rule_lists'} = {};
	foreach my $rule ( @{ $ruleset->{'rules'} } ) {
		optimize_rule( $rule, $ruleset->{'rule_lists'} );
	}

	$ruleset->{'optimization_version'} = get_optimization_version();

	#	$logger->debug("Optimized ruleset ", sub { Dumper $ruleset });

	return $ruleset;
}

# incrementing the number here will force cache reloads of rulesets with lower #'s
sub get_optimization_version {
	my $version = 11;
	return $version;
}

sub optimize_rule {
	my ( $rule, $rule_lists ) = @_;

	my $logger = get_logger();
#	$logger->debug( "Optimizing ", $rule->{'name'} );

	# fix up old syntax, if needed
	if ( $rule->{'pagetype'}->{'pattern'} ) {
		$logger->debug( "Fixing select for ", $rule->{'name'} );

		$rule->{'pagetype'}->{'event_expr'}->{'pattern'} =
		  $rule->{'pagetype'}->{'pattern'};
		$rule->{'pagetype'}->{'event_expr'}->{'vars'} =
		  $rule->{'pagetype'}->{'vars'};
		$rule->{'pagetype'}->{'event_expr'}->{'op'}     = 'pageview';
		$rule->{'pagetype'}->{'event_expr'}->{'type'}   = 'prim_event';
		$rule->{'pagetype'}->{'event_expr'}->{'legacy'} = 1;
	}

	# precompile pattern regexp
	if ( defined $rule->{'pagetype'}->{'event_expr'}->{'op'} ) {
		$logger->debug( "Optimizing ", $rule->{'name'} );

	   #		$logger->debug("With rule salience list ", sub {Dumper $rule_lists} );
		$rule->{'event_sm'} = Kynetx::Events::compile_event_expr(
			$rule->{'pagetype'}->{'event_expr'},
			$rule_lists, $rule );

		#     $rule->{'pagetype'}->{'event_expr'}->{'pattern'} =
		#       qr!$rule->{'pagetype'}->{'event_expr'}->{'pattern'}!;
	}
	else {    # deprecated syntax...

		#     $rule->{'pagetype'}->{'pattern'} =
		#       qr!$rule->{'pagetype'}->{'pattern'}!;
	}

	# break up pre, if needed
	optimize_pre($rule);

#	$logger->debug("Optimized rule ", sub {Dumper $rule });

	return $rule;
}

sub optimize_pre {
	my ($rule) = @_;
	my $logger = get_logger();
	my @varlist = map { $_->{'var'} } @{ $rule->{'pagetype'}->{'foreach'} };

	my @vars;
	foreach my $v (@varlist) {
		if ( ref $v eq 'ARRAY' ) {
			push @vars, @{$v};
		}
		else {
			push @vars, $v;
		}
	}

	$logger->trace( "[rules::optimize_pre] foreach vars: ",
		sub { Dumper(@vars) } );

	foreach my $decl ( @{ $rule->{'pre'} } ) {

		$logger->trace( "[rules::optimize_pre] decl: ", sub { Dumper($decl) } );
		# optimize here_docs
		if ( $decl->{'type'} eq 'here_doc') {
		  my ($string_array, $expr_array) = Kynetx::Expressions::optimize_here_doc($decl->{'rhs'});
		  $decl->{'string_array'} = $string_array;
		  $decl->{'expr_array'} = $expr_array;
		}

		# check if any of the vars occur free in the rhs
		my $dependent = 0;
		foreach my $v (@vars) {

			#	$logger->debug("Checking if $v is free in expr");
			if ( $decl->{'type'} eq 'expr'
				&& Kynetx::Expressions::var_free_in_expr( $v, $decl->{'rhs'} ) )
			{
				$dependent = 1;
			}
			elsif ( $decl->{'type'} eq 'here_doc' 
				&& Kynetx::Expressions::var_free_in_expr( $v, $decl ) )
			{
				$dependent = 1;
			}
		      }
		if ($dependent) {
			push( @{ $rule->{'inner_pre'} }, $decl );
			push( @vars,                     $decl->{'lhs'} ); # collect new var
		}
		else {
			push( @{ $rule->{'outer_pre'} }, $decl );
		}
	}

	#    $logger->debug("Dependent vars in optimization: ", @vars);

}

sub mk_initial_env {
	my $rule_env = empty_rule_env();

	# define initial environment to have a truth function
	# $rule_env = extend_rule_env(
	# 	{
	# 		'truth' => Kynetx::Expressions::mk_closure(
	# 			{
	# 				'vars'  => [],
	# 				'decls' => [],
	# 				'expr'  => mk_expr_node( 'num', 1 ),
	# 			},
	# 			$rule_env
	# 		)
	# 	},
	# 	$rule_env
	# );
	return $rule_env;
}



# fakes a schedule for old style processing.
sub mk_schedule {

	# third param is optional and not used in production--testing
	my ( $req_info, $rid_info, $ruleset ) = @_;
	my $metric =
		new Kynetx::Metrics::Datapoint( { 'series' => 'make-schedule' } );
	$metric->start_timer();
	$metric->rid(get_rid( $req_info->{'rid'} ));
	$metric->eid($req_info->{'eid'});

	my $rid = get_rid($rid_info);

	my $logger = get_logger();

	my $schedule = Kynetx::Scheduler->new();

	$req_info->{'rid'} = $rid_info;    # override with the one we're working on

	$logger->debug( "Processing rules for RID ",
		Kynetx::Rids::print_rid_info($rid_info) );

	$ruleset = get_rule_set($req_info) unless defined $ruleset;

	foreach my $rule ( @{ $ruleset->{'rules'} } ) {

#	  $logger->debug("req_info: ", sub { Dumper $req_info });

		# test and capture here
		my ( $selected, $vals ) = select_rule( $req_info->{'caller'}, $rule );

		if ($selected) {

			my $rulename = $rule->{'name'};
			$logger->debug("Rule $rulename is selected");
			my $task =
			  $schedule->add( $rid, $rule, $ruleset, $req_info,
				{ 'ridver' => get_version($rid_info) } );

			my $vars = Kynetx::Actions::get_precondition_vars($rule);

			$schedule->annotate_task( $rid, $rulename, $task, 'vars', $vars );
			$schedule->annotate_task( $rid, $rulename, $task, 'vals', $vals );

		}
	}

	#  $logger->debug("Schedule: ", sub {Dumper $schedule});
#	$logger->debug("Req_info at end of mk_schedule(): ", sub {Dumper $req_info});
	$metric->stop_and_store();
	return $schedule;

}

1;
