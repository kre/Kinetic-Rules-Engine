package Kynetx::Modules::ECI;
# file: Kynetx/Modules/ECI.pm
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
use Kynetx::Util qw(ll);
use Kynetx::Rids qw/:all/;
use Kynetx::Environments qw/:all/;


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
};

my $default_actions = {
	'new' => {
		'js' =>
			'NO_JS',    # this action does not emit JS, used in build_one_action
			'before' => \&do_new_eci,
			'after'  => []
		
	},
	'new_cloud' => {
		'js' =>
			'NO_JS',    # this action does not emit JS, used in build_one_action
			'before' => \&do_new_cloud,
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
    		$logger->warn("ECI error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module ECI");
    }

    return $resp;
}

sub _compare {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $ecilist = $args->[0];
	my $logger = get_logger();
	if (ref $ecilist eq "ARRAY") {
		return Kynetx::Persistence::KToken::compare_token_kens($ecilist);
	}
	return 0;
}
$funcs->{'compare'} = \&_compare;

sub do_new_eci {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
#	$logger->debug("config: ", sub {Dumper($config)});
#	$logger->debug("mods: ", sub {Dumper($mods)});
#	$logger->debug("args: ", sub {Dumper($args)});
#	$logger->debug("vars: ", sub {Dumper($vars)});
	my $nargs = ();
	$nargs->[0] = $args->[0];
	$nargs->[1] = $config;
	my $result = _new_eci($req_info,$rule_env,$session,"_action_","new_eci",$nargs);
	my $v = $vars->[0] || '__dummy';
	my $r_status;
	if ($result) {
		$r_status->{$v} = $result;
	}
	$rule_env = add_to_env( $r_status, $rule_env ) unless $v eq '__dummy';
	return "";
}

sub _new_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $token_name = $args->[0] || "Generic ECI channel";
	my $config =  {};
	if ( defined $args->[1] && ref $args->[1] eq "HASH" ) {
		$config = $args->[1];
	}
	my $type = $config->{'eci_type'} || "ECI";
	my $authenticated = $config->{'authenticated'} || 0;
	my $ken = Kynetx::Persistence::KEN::get_ken($session,"_null_");
	return Kynetx::Persistence::KToken::create_token($ken,"_null_",$type,$authenticated);	
}
$funcs->{'new'} = \&_new_eci;

sub do_new_cloud {
	my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
	my $logger = get_logger();
	$logger->trace("config: ", sub {Dumper($config)});
	$logger->trace("mods: ", sub {Dumper($mods)});
	my $nargs = ();
	$nargs->[0] = $args->[0];
	$nargs->[1] = $config;
	my $result = _new_cloud($req_info,$rule_env,$session,"_action_","new_cloud",$nargs);
	my $v = $vars->[0] || '__dummy';
	my $r_status;
	if ($result) {
		$r_status->{$v} = $result;
	}
	$rule_env = add_to_env( $r_status, $rule_env ) unless $v eq '__dummy';
	return "";
}

sub _new_cloud {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $oid = MongoDB::OID->new();
    my $new_id = $oid->to_string();
    my $username = "_$new_id";
    my $created = DateTime->now->epoch;
    my $dflt = {
        "username" => $username,
        "_id" => $oid,
        "firstname" => "",
        "lastname" => "",
        "password" => "*",
        "created" => $created
    };
    my ($type,$authenticated);
    if (defined $args->[0] && ref $args->[0] eq "HASH") {
    	foreach my $key (keys %{$args->[0]}) {
    		next if ($key eq "_id");
    		$dflt->{$key} = $args->[0]->{$key};
    		if ($key eq "eci_type") {
    			$type = $args->[0]->{$key};
    		} elsif ($key eq "authenticated") {
    			$authenticated = $args->[0]->{$key};
    		}
    	}
    }
	my $ken = Kynetx::Persistence::KEN::new_ken($dflt);
	return Kynetx::Persistence::KToken::create_token($ken,"_null_",$type,$authenticated);
}
$funcs->{'new_cloud'} = \&_new_cloud;

1;
