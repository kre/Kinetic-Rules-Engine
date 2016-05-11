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
  'is_owner' => sub {
    my ($req_info, $rule_env, $args) = @_;
  	my $logger = get_logger();
    my $eci = $args->[0];
    my $rid = $args->[1];
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
    my $rid_info = Kynetx::Persistence::Ruleset::get_ruleset_info($rid);
    if (defined $ken && defined $rid_info) {
      if ($rid_info->{'owner'} eq $ken) {
        return 1;
      } 
    }
    return 0;    
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
	'fork' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_fork,
		'after'  => []
	},
	'create' => {
		'js' =>
		  'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&do_create,
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

sub is_valid {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger = get_logger();
    $logger->debug("Arg to is_valid: $args->[0]");
    my $val = _validate($args->[0]) == 1;
    return Kynetx::Expressions::boolify($val || 0);

};
$funcs->{'is_valid'} = \&is_valid;


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


sub owner_rulesets {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
  my $eci = $args->[0];
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
  my $result = Kynetx::Persistence::Ruleset::get_rulesets_by_owner($ken);
  return $result;
}
$funcs->{'list_rulesets'} = \&owner_rulesets;

sub get_ruleset {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $fqrid = $args->[0];
    my $logger = get_logger();
#    $logger->debug("[get_ruleset] ", sub{Dumper $fqrid});
    my $result = _sanitize_ruleset(Kynetx::Persistence::Ruleset::get_ruleset_info($fqrid));
    return $result;    
}
$funcs->{'get_ruleset'} = \&get_ruleset;


##################### Actions
sub do_register {
    my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
    my $logger = get_logger();
    my $rid = get_rid($req_info->{'rid'});
    my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    my $v = $vars->[0] || '__dummy';

    # if userid not defined then we're not in a root pico and shouldn't register
    my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');

    my $prefix = $config->{'prefix'} || undef;
    my $uri = $args->[0];
    my ($ruleset, $error);
    if (defined $uri && defined $userid) {
	my $new_rid = Kynetx::Persistence::Ruleset::create_rid($ken,$prefix,$uri);

	my $dev_uri = $config->{"dev_uri"} || $uri;

	# Immediately create a fork for a *dev* ruleset
	my $fork = Kynetx::Persistence::Ruleset::fork_rid($ken,$new_rid,'dev',$dev_uri);
	$logger->debug("Rid created: $new_rid");
	$logger->debug("Production: ", sub{Dumper $new_rid});
	$logger->debug("Development: ", sub{Dumper $fork});
	for my $key (keys %{$config}) {
	    if ($key eq 'headers') {
		my $headers = $config->{'headers'};
		if (ref $headers eq "HASH") {
		    Kynetx::Persistence::Ruleset::put_registry_element($new_rid,['headers'],$headers);
		    Kynetx::Persistence::Ruleset::put_registry_element($fork,['headers'],$headers);
		}
	    } else {
		if ($key eq 'rule_name' ||
		    $key eq 'rid' ||
		    $key eq 'txn_id' ||
		    $key eq 'target' ||
                    $key eq 'dev_uri' || 
		    $key eq 'autoraise') {
		    next;
		} else {
		    Kynetx::Persistence::Ruleset::put_registry_element($new_rid,[$key],$config->{$key});
		    Kynetx::Persistence::Ruleset::put_registry_element($fork,[$key],$config->{$key});
		}
	    }
	}
	$ruleset = _sanitize_ruleset(Kynetx::Persistence::Ruleset::get_ruleset_info($new_rid));
    } else {
	my $msg = ! defined $uri    ? "Must supply URI to register ruleset"
	        : ! defined $userid ? "Rulesets can only be registered in root pico"
	        :                     "";
	$error = {"error" => $msg};
    }
    
    my $response = response_object($v,$ruleset, $error);
    $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
    my $js = raise_response_event('register',$req_info, $rule_env, $session, $config, $response, $v );
    return $js;
}

sub do_create {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';  
  my $rid_root = $args->[0];
  return '' if ($rid_root =~ m/\./);
  my $fqrid = $rid_root . '.' . Kynetx::Rids::default_version();
  my $exists = Kynetx::Persistence::Ruleset::get_ruleset_info($fqrid);
  my $err_str;
  if (defined $exists) {
    $err_str = "Ruleset $fqrid already exists, use update or fork to modify";
  }elsif (Kynetx::Modules::PCI::pci_authorized($req_info, $rule_env, $session) )  {
    my $owner;
    my $uri;
    my $headers;
    my $ruleset;
    for my $key (keys %{$config}) {
      next if ($key eq 'rule_name' ||
            $key eq 'rid' ||
            $key eq 'txn_id' ||
            $key eq 'target' ||
            $key eq 'autoraise');
      # Special Cases
      if ($key eq 'owner') {
        my $eci = $config->{$key};
        $owner = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
      } elsif ($key eq 'uri') {
        $uri = $config->{$key};
      } elsif ($key eq 'headers') {
        $headers = $config->{$key};
      } else {
        $ruleset->{$key} = $config->{$key};
      }
    } 
    if (defined $owner && defined $uri) {
      $ruleset->{'owner'} = $owner;
      $ruleset->{'uri'} = $uri;
      if (ref $headers eq "HASH") {
        $ruleset->{'headers'} = $headers;
      }
      Kynetx::Persistence::Ruleset::put_registry_element($fqrid,[],$ruleset);
      my $_ruleset = _sanitize_ruleset(Kynetx::Persistence::Ruleset::get_ruleset_info($fqrid));
      my $response = response_object($v,$_ruleset);
      $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
      my $js = raise_response_event('register',$req_info, $rule_env, $session, $config, $response, $v );
      return $js;
    } else {
      $err_str = "Create action requires 'owner' and 'uri'";
    }  
  } else {
    $err_str = "Not authorized to create $rid_root";
  }
  if (defined $err_str) {
    $logger->warn($err_str);
  }
  return '';
}


sub do_flush {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $flush_rid = $args->[0];
  
  my $ruleset = Kynetx::Persistence::Ruleset::get_ruleset_info($flush_rid);
  
  # Accounts allowed to modify a ruleset
  #  root
  #  developer
  #  provides ruleset pin
  my $pin = $config->{'flush_code'};
  my $rpin = $ruleset->{'flush_code'};
  my $owner = $ruleset->{'owner'};
  my $response;
  if (
    Kynetx::Modules::PCI::pci_authorized($req_info, $rule_env, $session) ||
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
  
  my $ruleset = Kynetx::Persistence::Ruleset::get_ruleset_info($mod_rid);
  
  # Accounts allowed to modify a ruleset
  #  root
  #  developer
  #  provides ruleset pin
  my $pin = $config->{'flush_code'};
  my $rpin = $ruleset->{'flush_code'};
  my $owner = $ruleset->{'owner'};
  my $response;
  if (
    Kynetx::Modules::PCI::pci_authorized($req_info, $rule_env, $session) ||
    (Kynetx::Modules::PCI::developer_authorized($req_info,$rule_env,$session,['ruleset','create']) && $ken eq $owner) ||
    $pin eq $rpin    
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
  
  my $ruleset = Kynetx::Persistence::Ruleset::get_ruleset_info($flush_rid);
  
  # Accounts allowed to modify a ruleset
  #  root
  #  developer
  #  provides ruleset pin
  my $pin = $config->{'flush_code'};
  my $rpin = $ruleset->{'flush_code'};
  my $owner = $ruleset->{'owner'};
  my $response;
  if (
    Kynetx::Modules::PCI::pci_authorized($req_info, $rule_env, $session) ||
    (Kynetx::Modules::PCI::developer_authorized($req_info,$rule_env,$session,['ruleset','create']) && $ken eq $owner)
  ) {
    Kynetx::Persistence::Ruleset::delete_registry($flush_rid);
    _flush($flush_rid);

  }
}

sub do_fork {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';
  my $fqrid = $args->[0];
  my $ruleset = Kynetx::Persistence::Ruleset::get_ruleset_info($fqrid);  
  return undef unless (defined $ruleset); 
  # Accounts allowed to modify a ruleset
  #  root
  #  developer
  #  provides ruleset pin
  my $pin = $config->{'flush_code'};
  my $rpin = $ruleset->{'flush_code'};
  my $owner = $ruleset->{'owner'};
  my $rid_root = Kynetx::Rids::strip_version($fqrid);
  my $response;
  if (
    Kynetx::Modules::PCI::pci_authorized($req_info, $rule_env, $session) ||
    (Kynetx::Modules::PCI::developer_authorized($req_info,$rule_env,$session,['ruleset','create']) && $ken eq $owner) ||
    $pin eq $rpin    
  ) {
    $logger->debug("Allow fork of $fqrid");
    my $uri = $config->{'uri'};
    my $branch = $config->{'branch'};
    
    $logger->debug("Uri: $uri");
    $logger->debug("Branch: $branch");
    return undef unless (defined $uri && defined $branch);
    if ($config->{'owner'}) {
      my $o_eci = $config->{'owner'};
      $owner = Kynetx::Persistence::KEN::ken_lookup_by_token($o_eci);
      
    }
    return undef unless (defined $owner);
    my $valid = Kynetx::Persistence::Ruleset::fork_rid($owner,$rid_root,$branch,$uri);
    $response = {
      $v => $valid
    };    
  } else {
    my $str = "Not authorized to fork $fqrid";
    $response = {
      $v => $str
    };
    $logger->warn($str);
  }
  $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
  my $js = raise_response_event($req_info, $rule_env, $session, $config, $response, $v );
  return $js;
}


sub do_import {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
  #$logger->debug("Rid: $rid");
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';
  if (Kynetx::Modules::PCI::pci_authorized($req_info, $rule_env, $session)|| $rid eq "may_delete") {
    my ($rid_to_import,$version,$app_version);
    $rid_to_import = $args->[0];
    $version = $config->{'version'} || 0;
    $app_version = $config->{'kinetic_app_version'} || 'prod';
    my $dummy_ri = Kynetx::Util::dummy_req_info($rid_to_import);
    my $rid_info = Kynetx::Rids::mk_rid_info($dummy_ri,$rid_to_import,{'version' => $app_version});
    $rid_info->{'version'} = $version;
    my $list = Kynetx::Persistence::Ruleset::import_legacy_ruleset($ken,$rid_info);
    my $response = {
      $v => $list
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
  my ($event_var,$rid_object, $error_object) = @_;
  my $logger = get_logger();
  my $ro;
  my $thing;
  if (defined $rid_object) {
      $thing = {
		'rid' => $rid_object->{'rid'},
		'obj' => $rid_object
	       };
  } else {
      $thing = $error_object
  }
  $ro->{$event_var} = $thing;
#  $logger->debug("Response object: ", sub {Dumper($ro)});
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
  my ($rid_string) = @_;
  my $logger = get_logger();
  unless ($rid_string){
    return 0 
  };

  # Create a dummy req_info object for the RuleEnv.pm methods
  my $req_info = Kynetx::Util::dummy_req_info($rid_string);

  my $rid_info_list = Kynetx::Rids::parse_rid_list($req_info, $rid_string);

  my $rid = Kynetx::Rids::get_rid($rid_info_list->[0]);
  my $version = Kynetx::Rids::get_version($rid_info_list->[0]);
  my $memd = get_memd();
  my $rid_key = Kynetx::Repository::make_ruleset_key($rid, $version);
  $logger->debug("[flush] flushing rules for $rid (version $version) for key $rid_key");
  $memd->delete($rid_key);  
  Kynetx::Modules::RuleEnv::delete_module_caches($req_info,$memd);
  Kynetx::Persistence::Ruleset::touch_ruleset($rid_string);
}

sub _validate {
  my ($rid) = @_;
  my $logger = get_logger();
  unless ($rid){
    return 0 
  };
  my $_ruleset = _sanitize_ruleset(Kynetx::Persistence::Ruleset::get_ruleset_info($rid));
  my $ruleset = Kynetx::Repository::get_ruleset_krl($_ruleset);
  eval {
    $ruleset = Kynetx::Parser::parse_ruleset($ruleset);
  };
  if ($@) {
    $logger->debug("Failed to validate ($@): ", sub {Dumper($_ruleset)});
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

sub _sanitize_ruleset {
  my ($ruleset) = @_;
  delete $ruleset->{'owner'};
  delete $ruleset->{'password'};
  return $ruleset;
}

1;
