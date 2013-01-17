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

##################### Actions
sub do_register {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
  my $logger = get_logger();
  my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
  my $v = $vars->[0] || '__dummy';
  
  $logger->debug("Var: ",$v);
  $logger->debug("Mods: ", sub {Dumper($mods)});
  $logger->debug("Config: ", sub {Dumper($config)});
  $logger->debug("Args: ", sub {Dumper($args)});
  my $prefix = $config->{'prefix'} || undef;
  my $uri = $args->[0];
  if (defined $uri) {
    my $new_rid = Kynetx::Persistence::Ruleset::create_rid($ken,$prefix,$uri);
    if (defined $config->{'headers'}) {
      my $headers = $config->{'headers'};
      if (ref $headers eq "HASH") {
        Kynetx::Persistence::Ruleset::put_registry_element($new_rid,['headers'],$headers)
      }
    }
    if (defined $config->{'flush_code'}) {
      Kynetx::Persistence::Ruleset::put_registry_element($new_rid,['flush_code'],$config->{'flush_code'});
    }
    my $rid_object = Kynetx::Persistence::Ruleset::get_rid_info($new_rid);
    $logger->debug("Created this: ", sub {Dumper($rid_object)});
    my $response = response_object($v,$rid_object);
    $rule_env = add_to_env( $response, $rule_env ) unless $v eq '__dummy';
    my $js = raise_response_event($req_info, $rule_env, $session, $config, $response, $v );
    return $js;
    
  }  
  return '';
}

sub do_flush {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
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
}
sub do_delete {
  my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
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
  return "";
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

sub _validate {
  my ($rid) = @_;
  my $logger = get_logger();
  unless ($rid){
    return 0 
  };
  my $rid_info = Kynetx::Persistence::Ruleset::get_rid_info($rid);
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
          my $str = "Ruleset parsing error for $rid";
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
