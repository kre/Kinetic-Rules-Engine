package Kynetx::Persistence::KXDI;
# file: Kynetx/Persistence/KXDI.pm
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
use lib qw(
    /web/lib/perl
);


use Log::Log4perl qw(get_logger :levels);
use DateTime;
use Data::Dumper;
$Data::Dumper::Indent = 1;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Session qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use Kynetx::Errors;
use Kynetx::Persistence::KToken;
use Kynetx::Persistence::KEN;
use Kynetx::Persistence::KPDS;
use Kynetx::Rids qw(get_rid);
use Kynetx::Util qw(ll);
use MongoDB;
use MongoDB::OID;

use XDI;
use XDI::Connection;

use Clone qw(clone);

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
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant PDS => "XDI";

#### Module functions
my $predicates = {
};

my $default_actions = {
    'authorize' => {
        js => <<EOF,
function(uniq, cb, config) {
  \$K.kGrowl.defaults.header = "Authorize XDI Access";
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(KOBJ_xdi_notice);
  cb();
}
EOF
        before => \&authorize
    }
	
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
    $logger->trace("Function:", sub {Dumper($function)});
    my $resp = undef;
    my $f = $funcs->{$function};
    if (defined $f) {
    	eval {
    		$resp = $f->( $req_info,$rule_env,$session,$rule_name,$function,$args );
    	};
    	if ($@) {
    		$logger->warn("XDI error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module XDI");
    }

    return $resp;
}

sub _set_link_contract {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $target = $args->[0];
	return add_link_contract($ken,$rid,$target);
	
}
$funcs->{'set_link_contract'} = \&_set_link_contract;

sub _create_new_graph {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	if (_has_xdi_account($req_info,$rule_env,$session,$rule_name,$function,$args)) {
		$logger->warn("Can not create, XDI account configured");
		return undef;
	}
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	if (ref $args->[0] eq "HASH") {
		my $hash =  $args->[0];
		if (defined $hash and ref $hash eq "HASH") {
			my $iname = $hash->{"iname"};
			my $secret = $hash->{"secret"};
			my $inumber = $hash->{"inumber"};
			my $target = $hash->{'endpoint'};
			if (! $inumber) {
				my $oid = MongoDB::OID->new();
				my $xdi = Kynetx::Configure::get_config('xdi');
				$inumber = $xdi->{'users'}->{'inumber'} . '!'. $oid->to_string();
				$target = $xdi->{'users'}->{'endpoint'} . $inumber;
				$iname = $xdi->{'users'}->{'iname'} . '*' . $iname;
			}
			my $kxdi = {				
				'endpoint' => $target,
				'inumber'  => $inumber,
				'iname'    => $iname,
				'secret'   => $secret
			};
			put_xdi($ken,$kxdi);
		}
	}
	
	my $thing = provision_xdi_for_kynetx($ken);
	if  ($thing) {
		return $thing;
	} else {
		$logger->warn("Failed to create xdi graph for ", get_inumber($ken));
		$logger->debug(sub {Dumper(get_xdi($ken))});
		delete_xdi($ken);
		return undef;
	};
	
}
$funcs->{'create_new_graph'} = \&_create_new_graph;

sub _make_link {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $ken = Kynetx::Persistence::KEN::get_ken($session);
	if (ref $args->[0] eq "HASH") {
		my $hash = $args->[0];
		my $iname = $hash->{"iname"};
		my $secret = $hash->{"secret"};
		my $inumber = $hash->{"inumber"};
		my $target = $hash->{'endpoint'};
		unless (defined $target) {
			# look up the graph information
			my $tuple;
			if (defined $iname) {
				$tuple = XDI::Connection::iname_lookup($iname);
				$inumber = $tuple->[1];
			} elsif (defined $inumber) {
				$tuple = XDI::Connection::inumber_lookup($inumber);
			} else {
				return undef;
			}
			$target = $tuple->[2];
		}
		my $kxdi = {				
			'endpoint' => $target,
			'inumber'  => $inumber,
			'iname'    => $iname,
			'secret'   => $secret
		};
		put_xdi($ken,$kxdi);
		return 1;
	}
	return undef;
	
}
$funcs->{'create_link'} = \&_make_link;



sub _flush_xdi {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $kxdi = get_xdi($ken);
	# Check for inumber
	if ($kxdi) {
		if (check_registry_for_inumber($kxdi->{'inumber'})) {
			if (check_registry_for_iname($kxdi->{'iname'})) {
				delete_registry_entry($kxdi->{'inumber'},$kxdi->{'iname'})
			} else {
				delete_registry_entry($kxdi->{'inumber'})
			}
			
		}
		delete_xdi($ken);
	}
	return _has_xdi_account($req_info,$rule_env,$session,$rule_name,$function,$args);
}

$funcs->{'flush_xdi'} = \&_flush_xdi;

sub _lookup {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	if (ref $args->[0] eq "") {
		my $iname = $args->[0];
		my $local = $args->[1];
		if ($iname && defined $local) {
			my $xdi = Kynetx::Configure::get_config('xdi');
			$iname = $xdi->{'users'}->{'iname'} . '*' . $iname;
			return check_registry_for_iname($iname);
		} else {
			my $ref = XDI::Connection::lookup($iname);
			$logger->debug("Lookup: ", sub {Dumper($ref)});
			return $ref;
		}
	}
	return undef;
	
}
$funcs->{'lookup'} = \&_lookup;

sub _tuple {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger=get_logger();
	if (defined $args->[0] && ref $args->[0] eq 'HASH')	{
		my $graph = $args->[0];
		if (defined $args->[1] && ref $args->[1] eq 'ARRAY') {
			my $tuple = $args->[1];
			#$logger->debug("Tuple: ", sub {Dumper($tuple)});
			my $result = XDI::pick_xdi_tuple($graph,$tuple);
			#$logger->debug("result: ", sub {Dumper($result)});
			return $result;
		}
	} else {
		$logger->debug("arg must be an XDI graph");
	}
	return undef;
}
$funcs->{'tuple'} = \&_tuple;

sub _has_xdi_account {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	if (get_installed($ken)){
		return check_registry_for_inumber(get_inumber($ken));
	};
	return 0;
}
$funcs->{'has_account'} = \&_has_xdi_account;

sub _iname {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	return get_iname($ken);	
}
$funcs->{'iname'} = \&_iname;

sub _inumber {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	return get_inumber($ken);	
	
}
$funcs->{'inumber'} = \&_inumber;

sub _add {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $logger = get_logger();
	if (defined $args->[0] && ref $args->[0] eq 'ARRAY') {
		my $kxdi = Kynetx::Persistence::KXDI::get_xdi($ken);
		my ($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
		#$logger->debug("Link_contract: ", $msg->link_contract);
		#$logger->debug("KXDI: ", sub {Dumper($kxdi)});
		if (ref $args->[0] eq 'ARRAY'){
			foreach my $op (@{$args->[0]}) {
				
				$msg->add('(' . $op . ')');
			}
		} elsif (ref $args->[0] eq '') {
			$msg->add('(' . $args->[0] . ')');
		}
		#$logger->debug("Message: ", $msg->to_string());
		my $result = $c->post($msg);;
		
		#$logger->debug("Result: ", sub {Dumper($result)});
		return $result;
	}	
}
$funcs->{'add'} = \&_add;

sub _get {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $logger = get_logger();
	if (defined $args->[0] ) {
		my $kxdi = Kynetx::Persistence::KXDI::get_xdi($ken);
		my ($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
		if (ref $args->[0] eq 'ARRAY'){
			foreach my $op (@{$args->[0]}) {
				$msg->get( $op );
			}
		} elsif (ref $args->[0] eq '') {
			$msg->get($args->[0]);
		}
		if (defined $args->[1] && $args->[1] eq "textonly") {
			return $msg->to_string();
		} else {
			if (defined $args->[1] && $args->[1] eq "context") {
				$c->context(1);
			}
			my $result = $c->post($msg);
			#$logger->debug("Message: ", $msg->to_string);
			#$logger->debug("Result: ", sub {Dumper($result)});
			return $result;
		}
	}
	
}
$funcs->{'get'} = \&_get;

sub _raw {
	my ($endpoint,$xdistring,$context) = @_;
	my $logger = get_logger();
	my $request = HTTP::Request->new( 'POST', $endpoint);
	my $ua = new LWP::UserAgent;
	my $cheader = 'application/xdi+json';
	if (defined $context) {
		$cheader .= ';contexts=1';
	}
	$request->header('accept' => $cheader);
	$request->content($xdistring);
	my $response = $ua->request($request);
	my $code = $response->code;
	if ($response->is_success()) {
		my $struct;
		eval {
			$struct = JSON::XS::->new->pretty(1)->decode($response->content);
		};
		if ($@ && not defined $struct) {
			return {
				'error' => "Invalid XDI JSON response"
			};
		} else {
			return $struct;
		}
	} else {
		return {
			'code' => $code,
			'status' => $response->status_line
		};
	}
	
}

sub raw {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $logger = get_logger();
	my $endpoint = $args->[0];
	my $xdistring = $args->[1];
	return _raw($endpoint,$xdistring,$args->[2]);
}
$funcs->{'raw'} = \&raw;

sub _mod {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $logger = get_logger();
	if (defined $args->[0] ) {
		my $kxdi = Kynetx::Persistence::KXDI::get_xdi($ken);
		my ($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
		if (ref $args->[0] eq 'ARRAY'){
			foreach my $op (@{$args->[0]}) {
				$msg->mod( $op );
			}
		} elsif (ref $args->[0] eq '') {
			$msg->mod($args->[0]);
		}
		if (defined $args->[1] && $args->[1] eq "textonly") {
			return $msg->to_string();
		} else {
			my $result = $c->post($msg);
			#$logger->debug("Message: ", $msg->to_string);
			#$logger->debug("Result: ", sub {Dumper($result)});
			return $result;
		}
	}
	
}
$funcs->{'mod'} = \&_mod;

sub _del {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $logger = get_logger();
	if (defined $args->[0] ) {
		my $kxdi = Kynetx::Persistence::KXDI::get_xdi($ken);
		my ($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
		if (ref $args->[0] eq 'ARRAY'){
			foreach my $op (@{$args->[0]}) {
				$msg->del( $op );
			}
		} elsif (ref $args->[0] eq '') {
			$msg->del($args->[0]);
		}
		if (defined $args->[1] && $args->[1] eq "textonly") {
			return $msg->to_string();
		} else {
			if (defined $args->[1] && $args->[1] eq "context") {
				$c->context(1);
			}
			my $result = $c->post($msg);
			#$logger->debug("Message: ", $msg->to_string);
			#$logger->debug("Result: ", sub {Dumper($result)});
			return $result;
		}
	}
	
}
$funcs->{'del'} = \&_del;


sub _has_definition {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	if (defined $args->[0] & ref $args->[0] eq "") {
		return get_definition($ken,$args->[0]);
	} else {
		return 0;
	}
	
}
$funcs->{'has_definition'} = \&_has_definition;

sub _set_definition {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	if (defined $args->[0] & ref $args->[0] eq "") {
		my $previous = get_definition($ken,$args->[0]);
		put_definition($ken,$args->[0],1);
		return $previous;
	} else {
		return undef;
	}
}
$funcs->{'set_definition'} = \&_set_definition;

         
sub _clear_definition {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	if (defined $args->[0] & ref $args->[0] eq "") {
		my $previous = get_definition($ken,$args->[0]);
		put_definition($ken,$args->[0],undef);
		return $previous;
	} else {
		return undef;
	}
}
$funcs->{'clear_definition'} = \&_clear_definition;

sub __get_global_definitions {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $kxdi = Kynetx::Configure::get_config('xdi');
	$kxdi->{'endpoint'} = $kxdi->{'registry'};
	#ll("Lookup");
	my ($c,$msg) = xdi_message($kxdi);
	my $logger = get_logger();
	# Need to reset the url to the registry url
	#$c->server($kxdi->{'registry'});
	$c->context(1);
	$msg->get('()');
	my $graph;
	#ll("Query:");
	eval {
		$graph = $c->post($msg);
	};
	if ($@) {
		$logger->debug("Failed to get global definitions $@");
		return undef;
	} else {
		#ll(sub {Dumper($graph)});
	}
	my $tuples = XDI::tuples($graph,[qr"^\+\(\+\w+\)$",'$is+',undef]);
	#ll(sub{Dumper($tuples)});
	my $globals;
	foreach my $definition (@{$tuples}) {
		my $name = $definition->[0];
		my $mult = $definition->[2] eq "+" ? 'entity' : 'attribute'; 
		my $locs = _definition_locales($graph,$name);
		foreach my $locale (@{$locs}) {
			my $defhash;
			my @fields = ();
			my $key = $name . $locale;
			$defhash->{'key'} = $key;
			$defhash->{'label'}  = $name;
			$defhash->{'locale'} = $locale;
			$defhash->{'mtype'}   = $mult;
			if ($mult eq 'attribute') {
				my $field_def = get_field_def($graph,$name,$locale);
				push(@fields,$field_def);
				$defhash->{'fields'} = \@fields;				
			} else {
				#ll("Name: $name");
				my $keys = XDI::get_context($graph,$name);
				$defhash->{'entity_contexts'} = $keys;
				$defhash->{'fields'} = get_entity_fields($graph,$name,$locale);
			}
			$globals->{$key} = $defhash;
		}
	}
	#ll("defs: ", sub{Dumper($globals->{'+(+addr)+en'})});
	#ll("defs: ", sub{Dumper($globals)});
	return $globals;	
}
$funcs->{'global_definitions'} = \&__get_global_definitions;

sub get_entity_fields {
	my ($graph,$key,$locale) = @_;
	my @return = ();
	my $tuples = XDI::tuples($graph,[$key,'()',undef]);
	my @ordinals = ();
	foreach my $ord (@{$tuples->[0]->[2]}) {
		if ($ord =~ m/^\$\*(\d+)$/) {
			push(@ordinals,$1);
		}
	}
	@ordinals = sort @ordinals;
	foreach my $inOrder (@ordinals) {
		my $okey = $key . '$*' . $inOrder;
		my $equiv = XDI::get_equivalent($graph,$okey);
		my $fkey = $equiv->[0];
		my $nkey = $fkey.'$!($*)';
		my $num = XDI::get_literal($graph,$nkey);
		my ($min,$max) = split(/-/,$num);
		my $count = (defined $max) ? $max : $min;
		my $field = substr $fkey, length($key);
		my $isLiteral = XDI::tuples($graph,[$field,'$is+',undef])->[0]->[2];
		if ($isLiteral ne "+") {
			my $def = get_field_def($graph,$field,$locale);
			for(my $i = 0; $i < $count;$i++) {
				my $copy = clone $def;
				if ($i < $min) {
					$copy->{"required"} = 1;
				} else {
					$copy->{"required"} = 0;
				}
				push(@return,$copy);
			}
		}
		
		
	}
	return \@return;
}

sub get_local_definitions {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $kxdi = Kynetx::Persistence::KXDI::get_xdi($ken);
	my $inumber = $kxdi->{"inumber"};
	my ($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
	$c->context(1);
	
	$msg->get('()');
	my $graph = $c->post($msg);
	my $key = "^\+\($inumber)";
	my $tuples = XDI::tuples($graph,[qr/\+\(/,'$is+',undef]);
	my ($name,$locale,$desc,$label);
	my $defs;
	foreach my $defArray (@{$tuples}) {
		my $key = $defArray->[0];
		my $value = $defArray->[2];
		if ($key =~ m/\+\(\+\((\w+)\)\)/) {
			$name->{$1} = 1;
		}
		if ($value =~ m/\+(\w+)\$lang/) {
			$locale->{$1} = 1;
		}
	}
	my @names = keys %{$name};
	my @locales = keys %{$locale};
	foreach my $defname (@names) {
		foreach my $loc (@locales) {
			my $lhash;
			my @fields;
			my $key = $defname . $loc; 
			my $label = $defname . " +" . $loc;
			my $field_def;
			my $tkey = "+($inumber)+(+($defname))/\$is+";
			my $lkey = "label";
			my $l = XDI::tuples($graph,[qr/$defname.+label/,'!',undef]);
			my $d = XDI::tuples($graph,[qr/$defname.+desc/,'!',undef]);
			
			#ll("Label search: ",Dumper $l);
			my $datatype = $graph->{$tkey};
			$field_def->{"field_type"} = $datatype->[0];
			$field_def->{"label"} = $l->[0]->[2];
			$field_def->{"name"} = $defname;
			$field_def->{"description"} = $d->[0]->[2];
			push(@fields,$field_def);
			$lhash->{'fields'} = \@fields;
			$lhash->{'key'} = $key;
			$lhash->{'label'} = $label;
			$lhash->{'locale'} = $loc;
			$defs->{$key} = $lhash;
		}
	}
	return $defs;	
}
$funcs->{'local_definitions'} = \&get_local_definitions;
#	$field_def->{"field_type"} = get_field_type($graph,$name);
#	$field_def->{"description"} = get_field_description($graph,$name,$locale);
#	$field_def->{"contexts"} = get_field_contexts($graph,$name);
#	$field_def->{"label"} = get_field_label($graph,$name,$locale);
#	$field_def->{"name"} = $name;

sub _get_locales {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $kxdi = Kynetx::Configure::get_config('xdi');
	$kxdi->{'endpoint'} = $kxdi->{'registry'};
	my ($c,$msg) = xdi_message($kxdi);
	my $logger = get_logger();
	# Need to reset the url to the registry url
	$c->context(1);
	$msg->get('$(+locale)');
	my $graph;
	eval {
		$graph = $c->post($msg);
	};
	if ($@) {
		$logger->debug("Failed to get global definitions $@");
		return undef;
	} 
	
	my $tuples = XDI::tuples($graph,["\$\(\+locale\)",'()',undef]);
	my @result = ();
	my $indices = $tuples->[0]->[2];
	foreach my $index (@{$indices}) {
		#build the exact key
		my $numkey = '$(+locale)' . $index;
		my $elements =  $graph->{$numkey . '/()'};
		my $lobj;
		foreach my $element (@{$elements}) {
			my $numIndex = $numkey . $element;
			my $i = $graph->{$numIndex . '/()'}->[0];
			my $fkey = $numIndex . $i . '/!';
			$lobj->{$element} = $graph->{$fkey}->[0];
		}
		push(@result,$lobj);
	}
	# sort by the value of the first element
	@result = sort {$a->{(sort keys %{$a})[0]} cmp $b->{(sort keys %{$b})[0]}} @result;
	
	return \@result		
}
$funcs->{'locales'} = \&_get_locales;



sub get_field_def {
	my ($graph,$name,$locale) = @_;
	my $field_def;
	$field_def->{"field_type"} = get_field_type($graph,$name);
	$field_def->{"description"} = get_field_description($graph,$name,$locale);
	$field_def->{"contexts"} = get_field_contexts($graph,$name);
	$field_def->{"label"} = get_field_label($graph,$name,$locale);
	$field_def->{"name"} = $name;
	return $field_def;
}

sub get_field_label {
	my ($graph,$def,$lang) = @_;
	my $subject = $def . $lang . '$lang$!($label)';
	my $keys = XDI::get_equivalent($graph,$subject);
	if (defined $keys) {
		return XDI::get_literal($graph,$keys);		
	}
	return undef;
}


sub get_field_contexts {
	my ($graph,$name) = @_;
	my $contexts = XDI::get_context($graph,$name);
	return $contexts;
}

sub get_field_description {
	my ($graph,$name,$locale) = @_;
	my $subject = $name . $locale .'$lang$!($desc)';
	my $equiv = XDI::get_equivalent($graph,$subject);
	my $key = $equiv->[0];
	if (defined $key)  {
		return XDI::get_literal($graph,$key);		
	}
	return "";
}

sub _get_desc {
	my ($graph,$def,$lang) = @_;
	my $subject = $def . $lang . '$lang$!($desc)';
	my $keys = _get_equivalent($graph,$subject);
	if (defined $keys) {
		return _get_literal($graph,$keys);		
	}
	return undef;
}


sub get_field_type {
	my ($graph,$name) = @_;
	my $tuple = XDI::tuples($graph,[$name,'$is+',undef]);
	# only one type
	my $value = $tuple->[0]->[2];
	$value =~ m/^\+(.+)\!$/;
	return $1;
}




sub _build_def {
	my ($graph,$def,$lang) = @_;
	my $label = _get_label($graph,$def,$lang);
	my $struct;
	if (defined $label) {
		#ll("Label is $label");
		$struct->{'locale'} = $lang;
		$struct->{'label'} = $label;
		$struct->{'description'} = _get_desc($graph,$def,$lang);
		$struct->{'multiplicity'} = _get_multiplicity($graph,$def);
		$struct->{'subject'} = $def;
	}
	
	if (defined $struct) {
		return $struct
	} else {
		return undef;
	}
	
}

sub _get_multiplicity {
	my ($graph,$key) = @_;
	my $values = XDI::tuples($graph,[$key,'$is+',undef]);
	if (defined $values) {
		my $mult = $values->[0]->[2];
		return $mult;
	}
	return undef;
		
}


sub _literal {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $graph = $args->[0];
	my $key = $args->[1];
	$logger->debug("Find eq: $key");
	my @results = ();
	if (ref $graph eq "HASH") {
		my $values = XDI::tuples($graph,[$key,'!',undef]);
		if (defined $values) {
			foreach my $element (@{$values}) {
				
			}
		}
	} else {
		$logger->debug("Required arguments: <xdi hash>,<key>");
		return undef;
	}
}
$funcs->{'literal'} = \&_literal;

sub _all_literals {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $graph = $args->[0];
	my $values = XDI::tuples($graph,[qr/.+/,'!',undef]);
	#$logger->debug("val: ",Dumper($values));
	my @results = ();
	if (defined $values) {
		foreach my $element (@{$values}) {
			
			my $struct = {
				'key' => $element->[0],
				'value' => $element->[2]
			};
			push(@results,$struct);
		}
	}
	#$logger->debug(Dumper(@results));
	return \@results;
}
$funcs->{'all_literals'} = \&_all_literals;


sub _get_equivalent {
	my ($graph,$key) = @_;
	my @results = ();
	my $values = XDI::tuples($graph,[$key,'$is',undef]);
	if (defined $values) {
		foreach my $element (@{$values}) {
			push(@results,$element->[2]);
		}
		return \@results;
	}
	return undef;
}

sub _equivalents {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $graph = $args->[0];
	my $key = $args->[1];
	$logger->debug("Find eq: $key");
	if (ref $graph eq "HASH" and ref $key eq "") {
		return _get_equivalent($graph,$key);
	} else {
		$logger->debug("Required arguments: <xdi hash>,<key>");
		return undef;
	}
}
$funcs->{'equivalents'} = \&_equivalents;

sub _get_property {
	my ($graph,$key) = @_;
	my @results = ();
	my $values = XDI::tuples($graph,[$key,'()',undef]);
	if (defined $values) {
		foreach my $element (@{$values}) {
			push(@results,$element->[2]);
		}
		return \@results;
	}
	return undef;	
}

sub _properties {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $graph = $args->[0];
	my $key = $args->[1];
	$logger->debug("Find eq: $key");
	if (ref $graph eq "HASH" and ref $key eq "") {
		my $result = _get_property($graph,$key);
		return $result;
	} else {
		$logger->debug("Required arguments: <xdi hash>,<key>");
		return undef;
	}
}
$funcs->{'properties'} = \&_properties;


sub _get_class {
	my ($graph,$key) = @_;
	my @results = ();
	my $values = XDI::tuples($graph,[$key,'$is()',undef]);
	if (defined $values) {
		foreach my $element (@{$values}) {
			foreach my $cl (@{$element->[2]}) {
				push(@results,$cl);
				#ll("found class: $cl");
			}
		}
		#ll(Dumper @results);
		return \@results;
	}
	return undef;	
}

sub _classes {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $graph = $args->[0];
	my $key = $args->[1];
	$logger->debug("Find eq: $key");
	if (ref $graph eq "HASH" and ref $key eq "") {
		my $result = _get_class($graph,$key);
		
		#ll((ref $result) . " " . (Dumper $result));
		return $result;
	} else {
		$logger->debug("Required arguments: <xdi hash>,<key>");
		return undef;
	}
}
$funcs->{'classes'} = \&_classes;


# not exposed as module
sub put_iname {
	my ($ken,$iname) = @_;
	if (defined $iname) {
		my $hash_path = [PDS, 'iname'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$iname);		
	}	
}

sub get_iname {
	my ($ken) = @_;
	my $hash_path = [PDS, 'iname'];
	return Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);		
	
}

sub put_inumber {
	my ($ken,$inumber) = @_;
	if (defined $inumber) {
		my $hash_path = [PDS, 'inumber'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$inumber);		
	}
	
}

sub get_inumber {
	my ($ken) = @_;
	my $hash_path = [PDS, 'inumber'];
	return Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);				
}

sub put_endpoint {
	my ($ken,$graph_endpoint) = @_;
	if (defined $graph_endpoint) {
		my $hash_path = [PDS, 'endpoint'];
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$graph_endpoint);		
	}	
	
}

sub get_endpoint {
	my ($ken) = @_;
	my $hash_path = [PDS, 'endpoint'];
	return Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);		
	
}

sub get_link_contract {
	my ($ken,$entity) = @_;
	my 	$hash_path = [PDS, 'link_contracts',$entity];
	return Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);
	
	
}

sub put_link_contract {
	my ($ken,$entity,$lc) = @_;
	my 	$hash_path = [PDS, 'link_contracts',$entity];
	if (defined $entity && defined $lc){
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$lc);
	}
}

sub get_installed {
	my ($ken) = @_;
	my 	$hash_path = [PDS, 'install'];
	return Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);
	
	
}

sub put_installed {
	my ($ken,$status) = @_;
	my 	$hash_path = [PDS, 'install'];
	if (defined $status){
		Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$status);
	}
}
sub get_xdi {
	my ($ken) = @_;
	my $hash_path = [PDS];
	return Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);
}

sub put_xdi {
	my ($ken,$struct) = @_;
	my $hash_path = [PDS];
	Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$struct);
}

sub put_definition {
	my ($ken,$defname,$status) = @_;
	my $hash_path = [PDS, 'definitions', $defname];
	Kynetx::Persistence::KPDS::put_kpds_element($ken,$hash_path,$status);
}

sub get_definition {
	my ($ken,$defname) = @_;
	my $hash_path = [PDS, 'definitions', $defname];
	Kynetx::Persistence::KPDS::get_kpds_element($ken,$hash_path);
}




sub create_xdi_from_iname {
	my ($ken, $iname,$secret) = @_;
	my $logger = get_logger();
	if ($ken && $iname) {
		my $tuple = XDI::Connection::lookup($iname);
		my $iname = $tuple->[0];
		my $inumber= $tuple->[1];
		my $uri = $tuple->[2];
		my $struct = {
			'endpoint' => $uri,
			'inumber'  => $inumber,
			'iname'    => $iname
		};
		if (defined $secret) {
			$struct->{'secret'} = $secret;
		}
		return put_xdi($ken,$struct);
	} else {
		return undef;
	}		
}

sub create_xdi {
	my ($ken) = @_;
	my $logger = get_logger();
	my $kxdi = get_xdi($ken);
	my $inumber = $kxdi->{'inumber'};
	add_registry_entry($ken) unless (check_registry_for_inumber($inumber));	
}

sub delete_xdi {
	my ($ken) = @_;
	my $logger = get_logger();
	my $kxdi = get_xdi($ken);
	my $inumber = $kxdi->{'inumber'};
	my $iname = $kxdi->{'iname'};
	if (delete_registry_entry($inumber,$iname)) {
		$logger->debug("Deleted registry for $inumber");
		put_installed($ken,0);	
		return 1;		
	} else {
		$logger->debug("Failed to delete $inumber from registry");
	}
	return 0;
}

# special case xdi query against the XDI account registry
sub check_registry_for_inumber {
	my ($inumber) = @_;
	my $logger = get_logger();
	my $kxdi = Kynetx::Configure::get_config('xdi');
	$kxdi->{'target'} = $kxdi->{'registry'};
	my ($c,$msg) = xdi_message($kxdi);
	# Need to reset the url to the registry url
	$c->server($kxdi->{'registry'});
	$c->context(1);
	my $str = '()';
	$msg->get($str);
	my $result = $c->post($msg);
	$logger->trace("Check registry: ",sub {Dumper($result)});
	my $tuple = XDI::pick_xdi_tuple($result,[$kxdi->{'inumber'},'+user']);
	my $value = $tuple->[2];
	if ($tuple && ref $value eq 'ARRAY'){
		foreach my $element (@{$tuple->[2]}) {
			if ($element =~ m/\($inumber\)/) {
				return 1;
			}
		}
	} elsif ($value =~ m/\($inumber\)/) {
		return 1;
	}
	return 0;	
}

sub check_registry_for_iname {
	my ($iname) = @_;
	my $logger = get_logger();
	my $kxdi = Kynetx::Configure::get_config('xdi');
	$kxdi->{'target'} = $kxdi->{'registry'};
	my ($c,$msg) = xdi_message($kxdi);
	$c->server($kxdi->{'registry'});
	$c->context(1);
	my $str = '(' . $iname.  ')';
	$msg->get($str);
	#ll($msg->to_string);
	my $result = $c->post($msg);
	#ll(Dumper $result);
	my $tuple = XDI::pick_xdi_tuple($result,[$str,'$is',undef]);
	if (defined $tuple) {
		return 1;
	} else {
		return 0;
	}
}



sub delete_registry_entry {
	my ($inumber,$iname) = @_;
	my $logger=get_logger();
	my $kxdi = Kynetx::Configure::get_config('xdi');
	$kxdi->{'target'} = $kxdi->{'registry'};
	my ($c,$msg) = xdi_message($kxdi);
	# Need to reset the url to the registry url
	$c->server($kxdi->{'registry'});
	$msg->del('('. $inumber . ')');
	$msg->del( $inumber );
	my $str = '(' . $kxdi->{'inumber'} . '/+user/(' . $inumber . '))';
	$msg->del($str);
#	$str = '' . $inumber . '$($secret)$!($token)';
#	$msg->del($str);
	if ($iname) {
		$str = '(' . $iname .')';
		$msg->del($str);
	}
	$logger->debug("Delete from registry: ", $msg->to_string);
	eval {
		my $result = $c->post($msg);
		$logger->debug("Delete graph: ", sub {Dumper($result)});
	};
	if ($@) {
		$logger->debug("Failed to delete account in registry $@");
		return undef;
	} else {
		return 1;
	}
}

sub delete_xdi_graph {
	my ($ken) = @_;
	my $logger=get_logger();
	my $kxdi = get_xdi($ken);
	my $inumber = $kxdi->{'inumber'};
	
	if (check_registry_for_inumber($inumber)) {
		$logger->error("Delete XDI registry entry before removing graph");
	} else {
		my ($c,$msg) = xdi_message($kxdi);
		$msg->del('()');
		$logger->debug("Delete from graph: ", $msg->to_string);
		eval {
			my $result = $c->post($msg);
			$logger->debug("Delete graph: ", sub {Dumper($result)});
		};
		if ($@) {
			$logger->debug("Failed to delete account in registry $@");
			return undef;
		} else {
			return 1;
		}
		
		
	}
}

sub add_registry_entry {
	my ($ken) = @_;
	my $logger = get_logger();
	my $kregistry = Kynetx::Configure::get_config('xdi');
	my $kxdi = get_xdi($ken);
	$kregistry->{'target'} = $kregistry->{'registry'};
	my ($c,$msg) = xdi_message($kregistry);
	$c->server($kregistry->{'registry'});
	my $inumber = $kxdi->{'inumber'};
	my $iname = $kxdi->{'iname'};
	my $secret = $kxdi->{'secret'};
	
	# add entry to graph
	my $str;
	
	# associate inumber with iname
	if (defined $iname) {
		$str = '((' . $iname . ')/$is/(' . $inumber . '))';
	} else {
		$str = '(()/()/(' . $inumber . '))';
	}
	$msg->add($str);
	
	# add shared secret for account
	$str = '(' . $inumber . '$secret$!($token)/!/(data:,' . $secret . '))';
	$msg->add($str);
	
	# add an entry for account lookup
	$str = '(' . $kregistry->{'inumber'} . '/+user/(' . $inumber .'))';
	$msg->add($str);
	my $status;
	eval {
		$status = $c->post($msg)
	};
	
	if ($@) {
		$logger->debug("Failed to create account in registry $@");
		return undef;
	} elsif (!defined $status) {
		$logger->debug("Failed to create account in registry $@");
		return undef;
	}else {
		return 1;
	}
}

sub provision_xdi_for_kynetx {
	my ($ken) = @_;
	my $logger = get_logger();
	my $kxdi = get_xdi($ken);
	my $inumber = $kxdi->{'inumber'};
	if (get_installed($ken)) {
		$logger->debug("KPDS reports XDI already installed");
		return 0;
	}
	if (defined $kxdi) {
		my $status = check_registry_for_inumber($inumber);
		if ($status) {
			$logger->warn("Account for ", $kxdi->{'iname'}, " already exists in registry");
			return undef;
		} else {
			$status = add_registry_entry($ken);
			
			if ($status) {
				my $kynetx = Kynetx::Configure::get_config('xdi')->{'inumber'};
				my $lc = get_link_contract($ken,$kynetx) || $inumber;
				put_link_contract($ken,$kynetx,$lc);
				my ($c,$msg) = xdi_message($kxdi);
				$msg->add(_lc_do($lc));
				$msg->add(_lc_permission($lc,'$all'));
				#$logger->debug("Add base permissions for Kynetx: ",$msg->to_string);
				eval {
					$c->post($msg);
				};
				if ($@) {
					$logger->warn($@);
					return undef;
				} else {
					put_installed($ken,1);
					return 1;
				}				
			} else {
				return undef;
			}
		}		
		
	} else {
		$logger->warn("KEN not configured for XDI");
		return undef;
	}
}

# This function assumes that you have already verified that 
# the link contract exists, but needs to be amended to add rid
sub add_link_contract {
	my ($ken,$rid,$target) = @_;
	my $logger = get_logger();
	my $kxdi = get_xdi($ken);
	if (defined $kxdi) {
		my ($c,$msg) = xdi_message($kxdi);
		$target = $target || $kxdi->{'inumber'};
		my $lc = _lc_assign($target,$rid);
		$msg->add($lc)	;
		my $t = $c->post($msg);	
		if (defined $t) {
			$lc =~ m/^\((.*?)\$do\/\$is\$do\/(.+)\)$/;
			my $lc_target = $1;
			my $lc_entity = $2;
			#$logger->debug("Link contract: $lc $1 $2");
			put_link_contract($ken,$lc_entity,$lc_target);
		}
		return $t;
	} else {
		$logger->warn("KEN not configured for XDI");
	}
	return undef;
}

sub check_link_contract {
	my ($ken,$rid,$lc) = @_;
	my $logger = get_logger();
	my $kxdi = get_xdi($ken);
	if (defined $kxdi) {
		my ($c,$msg) = xdi_message($kxdi);
		#$logger->debug("KXDI: ", sub {Dumper($kxdi)});
		my $lc_statement;
		# until meta link contracts are enabled messages are going
		# to be sent as the graph owner (target)
		my $from = $kxdi->{'inumber'};
		if (defined $kxdi->{'link_contracts'} &&
				defined $kxdi->{'link_contracts'}->{$from}	) {
			$lc_statement = $kxdi->{'link_contracts'}->{$from};		
		} elsif (defined $rid) {
			$lc_statement = $kxdi->{'inumber'} . '$do';
		} else {
			$lc_statement = '$do';
		}
		$msg->get($lc_statement);
		#$logger->debug("Check lc message: ",$msg->to_string());
		my $result = $c->post($msg);
		#$logger->debug("Result: ",sub {Dumper($result)});
		if (defined $result) {
			my $lc_from;
			if (defined $rid) {
				$lc_from = Kynetx::Configure::get_config('xdi')->{'inumber'} ."!$rid";
			} else {
				# TODO: Change when meta contracts
				$lc_from = $from;
			}
			my $tuple = XDI::pick_xdi_tuple($result,[$lc_statement,'$is$do']);
			#$logger->debug("Result: ",sub {Dumper($tuple)});
			if (defined $tuple) {
				my $is_array = $tuple->[2];
				if (ref $is_array eq 'ARRAY') {			
					foreach my $element (@{$is_array}) {
						#$logger->debug("compare: $element $lc_from");
						if ($element eq $lc_from) {
							return 1;
						}
					}
				} elsif (ref $is_array eq '') {
					#$logger->debug("compare: $is_array $lc_from");
					if ($is_array eq $lc_from) {
						return 1;
					}
				}
				return 0;
			}
			return 0;
		} 
	} else {
		$logger->debug("KEN not configured for XDI");
	}
	return -1;
	
}


sub xdi_message {
	my ($kxdi,$rid) = @_;
	my $logger = get_logger();
	if (defined $kxdi) {
		my $from_graph = Kynetx::Configure::get_config('xdi')->{'inumber'};	
		my $from;
		my $link_contract;
		my $target = $kxdi->{'inumber'};
		
		# ruleset call or kynetx infrastructure call
		if (defined $rid) {
			$from = "$from_graph!$rid";
			
			$link_contract = $kxdi->{'link_contracts'}->{$from} || $target;
		} else {
			#$from = $from_graph;
			$from = $target;
			$link_contract = '';
		}
		my $endpoint = $kxdi->{'endpoint'};
		my $secret = $kxdi->{'secret'};
		my $xdi = new XDI ( {
			'from' => $from,
			'from_graph' => $from_graph
		});
		#ll("Connect: t-$target s-$endpoint");
		my $c = $xdi->connect({
			'target' => $target,
			'secret' => $secret,
			'server' => $endpoint
		});
		my $msg = $c->message();
		$msg->link_contract($link_contract);
		return ($c,$msg);	
	} else {
		return undef;
	}
	
}


sub _lc_assign {
	my ($target,$rid) = @_;
	my $kid = Kynetx::Configure::get_config('xdi')->{'inumber'};
	my $xdi_rid =  $kid . '!' . $rid;
	my $string = '(' . $target . '$do/$is$do/' . $xdi_rid . ")";
	return $string;	
}

sub _lc_do {
	my ($target) = @_;
	#(=!626D.C20C.74EB.BAEA/=!626D.C20C.74EB.BAEA/=!626D.C20C.74EB.BAEA$do)
	my $string = "($target/$target/$target\$do)";
	return $string;
}

sub _lc_permission {
	my ($target,$permission) = @_;
	#(=!626D.C20C.74EB.BAEA$do/$get/=!626D.C20C.74EB.BAEA)
	my $string = "($target\$do/\$get/$target)";
	return $string
}


sub _get_tuples {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger=get_logger();
	if (defined $args->[0] && ref $args->[0] eq 'HASH')	{
		my $graph = $args->[0];
		if (defined $args->[1] && ref $args->[1] eq 'ARRAY') {
			my $tuple = $args->[1];
			my $result = XDI::tuples($graph,$tuple);
			return $result;
		}
	} else {
		$logger->debug("arg must be an XDI graph");
	}
	return undef;
}
$funcs->{'tuples'} = \&_get_tuples;



sub _definition_locales {
	my ($graph) = @_;
	my $tups = XDI::tuples($graph,[qr(^\+[a-z]+),'()','$lang']);
	my $lang;
	foreach my $element (@{$tups}) {			
		$lang->{$element->[0]} = 1;
	}
	my @keys = keys %{$lang};
	return \@keys;	
}

sub _xdi_message {
    my ( $req_info, $iname ) = @_;
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $ruleset_name = $req_info->{"$rid:ruleset_name"};
    my $name         = $req_info->{"$rid:name"};
    my $author       = $req_info->{"$rid:author"};
    my $description  = $req_info->{"$rid:description"};
	my $divId = "KOBJ_xdi_notice";
	my $msg = <<EOF;
<div id="$divId">
<p>The application</p>
<p>$name ($rid)</p>
<p> from $author is requesting that you authorize your XDI server to share your personal information with it.  </p>
<blockquote><b>Description:</b>$description</blockquote>
<p>
The application will not have access to your XDI security information.  Please enter your XDI password so Kynetx can verify your ownership and create a link contract for <strong>$rid</strong>.  
You can cancel now by clicking "No Thanks" below.  Note: if you cancel, this application may not work properly.
</p>
<div>
	<label>Secret</label>
	<input type="password" id="xdiPassword" placeholder="XDI password">
</div>
<div style="color: #000; background-color: #FFF; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"">
<button type="button" onclick="return false;">Share my personal cloud</a></div>

<div style="color: #FFF; background-color: #F33; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"" onclick="javascript:KOBJ.close_notification('#$divId')">No Thanks!</div>
</div>
EOF

    return ( $divId, $msg );
}

sub authorize {
    my ( $req_info, $rule_env, $session, $config, $mods, $args ) = @_;
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
	my $kxdi = Kynetx::Configure::get_config('xdi');
	my $iname = $kxdi->{'iname'};
    my $logger  = get_logger();
    
    my ( $divId, $msg ) =
    	_xdi_message( $req_info, $iname );
    my $js =
      Kynetx::JavaScript::gen_js_var( $divId,Kynetx::JavaScript::mk_js_str($msg) );
      
    return $js;
		
}


1;