package Kynetx::Modules::RSM;
# file: Kynetx/Modules/RSM.pm
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
use Data::Dumper;
use Kynetx::Rids qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Persistence::Ruleset qw/:all/;
use Kynetx::Memcached qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Util;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	get_predicates
	get_resources
	get_actions
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
  'is_valid' => sub {
    my ($req_info, $rule_env, $args) = @_;
    my $logger = get_logger();
    $logger->debug("Arg to is_valid: $args->[0]");
    return _validate($args->[0]) == 1;
  }
};

my $default_actions = {
	'register' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_register,
		'after'  => []
	},
	'flush' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_flush,
		'after'  => []
	},
	'validate' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_validate,
		'after'  => []
	},
	'update' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_update,
		'after'  => []
	},
	'delete' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_delete,
		'after'  => []
	},
	'import' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_import,
		'after'  => []
	},
	
};


sub get_resources {
    return {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}

my $funcs = {};



sub run_function {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;

    my $logger = get_logger();
    my $resp = undef;
    my $f = $funcs->{$function};
    if (defined $f) {
    	eval {
    		$resp = $f->( $req_info,$rule_env,$session,$rule_name,$function,$args );
    	};
    	if ($@) {
    		$logger->warn("RSM error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module RSM");
    }

    return $resp;
}


##################### Methods

sub appkeys {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
	my $rid = get_rid($req_info->{'rid'});
	return _appkeys($rid);
}
$funcs->{'app_keys'} = \&appkeys;

sub make_ruleset_id {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
  my $prefix = $args->[0];
  my $rid = get_rid($req_info->{'rid'});
  my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  if (defined $prefix) {
    return Kynetx::Persistence::Ruleset::create_rid($ken,$prefix);
  } else {
    return Kynetx::Persistence::Ruleset::create_rid($ken);
  }
}
$funcs->{'new_ruleset'} = \&make_ruleset_id;

sub entkeys {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
	my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	return _entkeys($ken,$rid);
}
$funcs->{'entity_keys'} = \&entkeys;

sub is_owner {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
	my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  if ( Kynetx::Modules::PCI::system_authorized($req_info, $rule_env, $session) ) {
      
  }
	
}
$funcs->{'is_owner'} = \&is_owner;


##################### Actions
sub do_register {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';
  
  my $prefix = $config->{'prefix'} || undef;
  my $uri = $args->[0];
  if (defined $uri) {
    my $new_rid = Kynetx::Persistence::Ruleset::create_rid($ken,$prefix,$uri);
    for my $key (keys %{$config}) {
      if ($key eq 'headers') {
        my $headers = $config->{'headers'};
        if (ref $headers eq "HASH") {
          Kynetx::Persistence::Ruleset::put_registry_element($new_rid,['headers'],$headers)
        }
      } else {
        if ($key eq 'rule_name' ||
            $key eq 'rid' ||
            $key eq 'txn_id' ||
            $key eq 'target' ||
            $key eq 'autoraise') {
          next;
        } else {
          Kynetx::Persistence::Ruleset::put_registry_element($new_rid,[$key],$config->{$key});
        }
      }
    }
    
    my $rid_object = Kynetx::Persistence::Ruleset::rid_from_ruleset($new_rid);
    my $response = response_object($v,$rid_object);
    $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
    my $js = raise_response_event('register',$req_info, $rule_env, $session, $config, $response, $v );
    return $js;
    
  }  
  return '';
}

sub do_flush {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $flush_rid = $args->[0];
  
  my $rid_info = Kynetx::Persistence::Ruleset::rid_from_ruleset($flush_rid);
  
  # Accounts allowed to modify a ruleset
  #  root
  #  developer
  #  provides ruleset pin
  my $pin = $config->{'flush_code'};
  my $rpin = $rid_info->{'flush_code'};
  my $owner = $rid_info->{'owner'};
  my $response;
  if (
    Kynetx::Modules::PCI::system_authorized($req_info, $rule_env, $session) ||
    (Kynetx::Modules::PCI::developer_authorized($req_info,$rule_env,$session,['ruleset','create']) && $ken eq $owner) ||
    $pin eq $pin    
  ) {
    _flush($flush_rid);
  }else {
    my $str = "Not authorized to modify $flush_rid";
    $logger->warn($str);
  }
}


sub do_validate {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';
  my $valid = _validate($args->[0]);
  my $response = {
      $v => $valid
  };
  $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
  my $js = raise_response_event($req_info, $rule_env, $session, $config, $response, $v );
  return $js;
}
sub do_update {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';
  my $mod_rid = $args->[0];
  
  my $rid_info = Kynetx::Persistence::Ruleset::rid_from_ruleset($mod_rid);
  
  # Accounts allowed to modify a ruleset
  #  root
  #  developer
  #  provides ruleset pin
  my $pin = $config->{'flush_code'};
  my $rpin = $rid_info->{'flush_code'};
  my $owner = $rid_info->{'owner'};
  my $response;
  if (
    Kynetx::Modules::PCI::system_authorized($req_info, $rule_env, $session) ||
    (Kynetx::Modules::PCI::developer_authorized($req_info,$rule_env,$session,['ruleset','create']) && $ken eq $owner) ||
    $pin eq $pin    
  ) {
    for my $key (keys %{$mods}) {
      # Can't change these values
      next if (
        $key eq "owner" ||
        $key eq "rid_index" ||
        $key eq "rid" || 
        $key eq "prefix"
      );
      # Ignore default action modifiers
      next if (
        $key eq "effect" ||
        $key eq "delay" ||
        $key eq "draggable" ||
        $key eq "scrollable"
      );
      if ($mods->{$key} eq "") {
      #if ($config->{$key} eq "") {
        Kynetx::Persistence::Ruleset::delete_registry_element($mod_rid, [$key]);
      } else {
        Kynetx::Persistence::Ruleset::put_registry_element($mod_rid,[$key],$config->{$key})
      }
    }
    Kynetx::Persistence::Ruleset::increment_version($mod_rid); 
    # Now try to validate the ruleset
    my $valid = _validate($mod_rid);
    $response = {
      $v => $valid
    };
    if ( $valid == 1) {
      # Flush the ruleset
      _flush($mod_rid);
    }
    
  } else {
    my $str = "Not authorized to modify $mod_rid";
    $response = {
      $v => $str
    };
    $logger->warn($str);
  }
  $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
  my $js = raise_response_event($req_info, $rule_env, $session, $config, $response, $v );
  return $js;
  
}
sub do_delete {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $flush_rid = $args->[0];
  
  my $rid_info = Kynetx::Persistence::Ruleset::rid_from_ruleset($flush_rid);
  
  # Accounts allowed to modify a ruleset
  #  root
  #  developer
  #  provides ruleset pin
  my $pin = $config->{'flush_code'};
  my $rpin = $rid_info->{'flush_code'};
  my $owner = $rid_info->{'owner'};
  my $response;
  if (
    Kynetx::Modules::PCI::system_authorized($req_info, $rule_env, $session) ||
    (Kynetx::Modules::PCI::developer_authorized($req_info,$rule_env,$session,['ruleset','create']) && $ken eq $owner)
  ) {
    Kynetx::Persistence::Ruleset::delete_registry($flush_rid);
  }
}

sub do_import {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
  #$logger->debug("Rid: $rid");
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';
  if (Kynetx::Modules::PCI::system_authorized($req_info, $rule_env, $session)|| $rid eq "may_delete") {
    my ($rid_to_import,$version,$app_version);
    $rid_to_import = $args->[0];
    $version = $config->{'version'} || 0;
    $app_version = $config->{'kinetic_app_version'} || 'prod';
    my $dummy_ri = Kynetx::Util::dummy_req_info($rid_to_import);
    my $rid_info = Kynetx::Rids::mk_rid_info($dummy_ri,$rid_to_import,{'version' => $app_version});
    $rid_info->{'version'} = $version;
    my $registry = Kynetx::Persistence::Ruleset::import_legacy_ruleset($ken,$rid_info);
    $logger->debug("registry: ", sub {Dumper($registry)});
    my $response = {
      $v => $registry->{'value'}->{'uri'}
    };
    if ($config->{'force'}) {
      my $valid = _validate($rid_to_import);
      $response = {
        $v => $valid
      };
      if ( $valid == 1) {
        # Flush the ruleset
        _flush($rid_to_import);
      } else {
        Kynetx::Persistence::Ruleset::delete_registry($rid_to_import);
      }
      
    }
    $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
    my $js = raise_response_event($req_info, $rule_env, $session, $config, $response, $v );
    return $js;
  } else {
    $logger->warn("Only root can import rulesets");
    return '';
  }
}

##################### Private
sub _appkeys {
	my ($rid) = @_;
	my $collection = 'appdata';
	my $key = {
		'rid' => $rid
	};
	return Kynetx::MongoDB::type_data($collection,$key);
}

sub response_object {
  my ($event_var,$rid_object) = @_;
  my $logger = get_logger();
  my $ro;
  my $thing = {
    'rid' => $rid_object->{'rid'},
    'obj' => $rid_object
  };
  $ro->{$event_var} = $thing;
  return $ro;
}

sub raise_response_event {
  my ($method, $req_info, $rule_env, $session, $config, $resp, $ro_name ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
  my $js = '';
  if ( defined $config->{'autoraise'} ) {
    $logger->debug(
		   "RSM module autoraising event with label $config->{'autoraise'}");

    # make modifiers in right form for raise expr
    my $ms = [];
    foreach my $k ( keys %{ $resp->{$ro_name} } ) {
      push( @{$ms}, {
	     'name' => $k,
	     'value' =>
	       Kynetx::Expressions::mk_den_str( $resp->{$ro_name}->{$k} ),
	     }
	    );
    }
  
    # create an expression to pass to eval_raise_statement
    my $expr = {
    	'type'      => 'raise',
    	'domain'    => 'rsm',
    	'ruleset'   => $config->{'target'} || $rid,
    	'event'     => mk_expr_node( 'str', lc($method) ),
    	'modifiers' => $ms,
    };
    $js .= Kynetx::Postlude::eval_raise_statement( $expr, $session, $req_info,
  				   $rule_env, $config->{'rule_name'} );
  }
  return $js;
}

sub _entkeys {
	my ($ken,$rid) = @_;
	my $collection = 'edata';
	my $key = {
		'rid' => $rid,
		'ken' => $ken
	};
	return Kynetx::MongoDB::type_data($collection,$key);
}

sub _flush {
  my ($rid) = @_;
  my $logger = get_logger();
  unless ($rid){
    return 0 
  };
  # Create a dummy req_info object for the RuleEnv.pm methods
  my $req_info = Kynetx::Util::dummy_req_info($rid);
  my $version = Kynetx::Rids::get_version(Kynetx::Rids::get_current_rid_info($req_info));
  my $memd = get_memd();
  $logger->debug("[flush] flushing rules for $rid (version $version)");
  $memd->delete(Kynetx::Repository::make_ruleset_key($rid, $version));  
  Kynetx::Modules::RuleEnv::delete_module_caches($req_info,$memd);
}

sub _validate {
  my ($rid) = @_;
  my $logger = get_logger();
  unless ($rid){
    return 0 
  };
  my $rid_info = Kynetx::Persistence::Ruleset::rid_from_ruleset($rid);
  my $ruleset = Kynetx::Repository::get_ruleset_krl($rid_info);
  eval {
    $ruleset = Kynetx::Parser::parse_ruleset($ruleset);
  };
  if ($@) {
    $logger->debug("Failed to validate ($@): ", sub {Dumper($rid_info)});
    return 0;
  } elsif ($ruleset->{'ruleset_name'} eq 'norulesetbythatappid' || 
      defined $ruleset->{'error'}) {
        my @errors = ();
        if ($ruleset->{'ruleset_name'} eq 'norulesetbythatappid') {
          my $str = "Ruleset $rid not found";
          push(@errors,$str);
          $logger->error($str);
        } elsif (defined $ruleset->{'error'}) {
          my $str = "Ruleset parsing error for $rid: ";
          push(@errors,$str);
          $logger->error($str);
            if (ref $ruleset->{'error'} eq "ARRAY") {
              for my $err (@{$ruleset->{'error'}}) {
                push(@errors,$err);
              }
            }
        } else {
          my $str = "Unspecified ruleset repository error for $rid";
          push(@errors,$str);
          $logger->error($str);
        }
        return \@errors;
   } else {
     return 1;
   }
}


1;
