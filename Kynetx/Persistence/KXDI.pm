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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant PDS => "XDI";


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
	add_registry_entry($ken) unless (check_registry_for_account($inumber));	
}

sub delete_xdi {
	my ($ken) = @_;
	my $logger = get_logger();
	my $kxdi = get_xdi($ken);
	my $inumber = $kxdi->{'inumber'};
	if (delete_registry_entry($inumber)) {
		$logger->debug("Deleted registry for $inumber");			
		if (delete_xdi_graph($ken)) {
			$logger->debug("Deleted graph for $inumber");
			put_installed($ken,0);
			return 1;
		} else {
			$logger->debug("Failed to delete xdi graph ($inumber)");
		}
	} else {
		$logger->debug("Failed to delete $inumber from registry");
	}
	return 0;
}

# special case xdi query against the XDI account registry
sub check_registry_for_account {
	my ($inumber) = @_;
	my $logger = get_logger();
	my $kxdi = Kynetx::Configure::get_config('xdi');
	$kxdi->{'target'} = $kxdi->{'registry'};
	my ($c,$msg) = xdi_message($kxdi);
	# Need to reset the url to the registry url
	$c->server($kxdi->{'registry'});
	$c->context(1);
	my $str = '(' . $kxdi->{'inumber'} . '/+user/($))';
	$str = '()';
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

sub delete_registry_entry {
	my ($inumber) = @_;
	my $logger=get_logger();
	my $kxdi = Kynetx::Configure::get_config('xdi');
	$kxdi->{'target'} = $kxdi->{'registry'};
	my ($c,$msg) = xdi_message($kxdi);
	# Need to reset the url to the registry url
	$c->server($kxdi->{'registry'});
	$msg->del('('. $inumber . ')');
	my $str = '(' . $kxdi->{'inumber'} . '/+user/(' . $inumber . '))';
	$msg->del($str);
	$str = '(()/()/(' . $inumber . '))';
	$msg->del($str);
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
	
	if (check_registry_for_account($inumber)) {
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
	my $str = '(()/()/(' . $inumber . '))';
	$msg->add($str);
	
	# associate inumber with iname
	$str = '((' .$iname . ')/$is/(' . $inumber . '))';
	$msg->add($str);
	
	# add shared secret for account
	$str = '(' . $inumber . '$secret$!($token)/!/(data:,' . $secret . '))';
	$msg->add($str);
	
	# add an entry for account lookup
	$str = '(' . $kregistry->{'inumber'} . '/+user/(' . $inumber .'))';
	$msg->add($str);
	$logger->debug ("Add to registry: ", $msg->to_string);
	eval {
		$c->post($msg)
	};
	if ($@) {
		$logger->debug("Failed to create account in registry $@");
		return undef;
	} else {
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
		my $status = check_registry_for_account($inumber);
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
				$logger->debug("Add base permissions for Kynetx: ",$msg->to_string);
				eval {
					$c->post($msg);
				};
				if ($@) {
					$logger->warn($@);
					return undef;
				} else {
					put_installed($ken,1);
				}
				
			}
		}		
		return 1;
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
		my $lc = _lc_assign($kxdi->{'inumber'},$rid);
		$msg->add($lc)	;
		my $t = $c->post($msg);	
		if (defined $t) {
			$lc =~ m/^\((.*?)\$do\/\$is\$do\/(.+)\)$/;
			my $lc_target = $1;
			my $lc_entity = $2;
			$logger->debug("Link contract: $lc $1 $2");
			put_link_contract($ken,$lc_entity,$lc_target);
		}
		return $t;
	} else {
		$logger->warn("KEN not configured for XDI");
	}
	
	
}

sub check_link_contract {
	my ($ken,$rid,$lc) = @_;
	my $logger = get_logger();
	my $kxdi = get_xdi($ken);
	if (defined $kxdi) {
		my ($c,$msg) = xdi_message($kxdi);
		$logger->debug("KXDI: ", sub {Dumper($kxdi)});
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
		$logger->debug("Check lc message: ",$msg->to_string());
		my $result = $c->post($msg);
		$logger->debug("Result: ",sub {Dumper($result)});
		if (defined $result) {
			my $lc_from;
			if (defined $rid) {
				$lc_from = Kynetx::Configure::get_config('xdi')->{'inumber'} ."!$rid";
			} else {
				# TODO: Change when meta contracts
				$lc_from = $from;
			}
			my $tuple = XDI::pick_xdi_tuple($result,[$lc_statement,'$is$do']);
			$logger->debug("Result: ",sub {Dumper($tuple)});
			if (defined $tuple) {
				my $is_array = $tuple->[2];
				if (ref $is_array eq 'ARRAY') {			
					foreach my $element (@{$is_array}) {
						$logger->debug("compare: $element $lc_from");
						if ($element eq $lc_from) {
							return 1;
						}
					}
				} elsif (ref $is_array eq '') {
					$logger->debug("compare: $is_array $lc_from");
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


1;