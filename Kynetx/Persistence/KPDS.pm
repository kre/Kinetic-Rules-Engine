package Kynetx::Persistence::KPDS;
# file: Kynetx/Persistence/KPDS.pm
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
use Kynetx::MongoDB qw(:all $CACHETIME);
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use Kynetx::Errors;
use Kynetx::Persistence::KToken;
use Kynetx::Persistence::KEN;
use MongoDB;
use MongoDB::OID;

use Clone qw(clone);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
get_kpds_record
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant COLLECTION => "kpds";
use constant DEV => "credentials";
use constant RID => "ridlist";

sub get_kpds_element {
	my ($ken,$hkey) = @_;
	my $logger = get_logger();
	if (defined $ken) {
		my $key = {
			"ken" => $ken
		};
		my $c_key = Kynetx::MongoDB::map_key($ken,$hkey);
		$logger->trace("Map key: ", sub {Dumper($c_key)});
		my $cache = Kynetx::MongoDB::get_cache_for_map($ken,COLLECTION,$c_key);
		if (defined $cache) {
			$logger->trace("Cached value (",sub {Dumper($c_key)},"): ", sub {Dumper($cache)});
			return $cache;
		} else {
			$logger->trace("Cached miss (",sub {Dumper($c_key)},"): ");
		}
		my $result = Kynetx::MongoDB::get_hash_element(COLLECTION,$key,$hkey);
		if (defined $result && ref $result eq "HASH") {
			Kynetx::MongoDB::set_cache_for_map($ken,COLLECTION,$c_key,$result->{"value"});
			return $result->{"value"};
		} else {
			return undef;
		}
	} else {
		$logger->warn("KEN undefined in KPDS information request");
 		return undef;		
	}
	
}

sub put_kpds_element {
	my ($ken,$hkey,$val) = @_;
	my $logger = get_logger();
	my $key = {
		'ken' => $ken
	};
	my $value = {
		'value' => $val
	};
	my $success = Kynetx::MongoDB::put_hash_element(COLLECTION,$key,$hkey,$value);
	Kynetx::MongoDB::clear_cache_for_map($ken,COLLECTION,Kynetx::MongoDB::map_key($ken,$hkey));
	if ($hkey > 1) {
		$logger->trace("Flush upstream");
		Kynetx::MongoDB::clear_cache_for_map($ken,COLLECTION,Kynetx::MongoDB::map_key($ken,[$hkey->[0]]));
	}
	return $success;
	
}

sub push_kpds_set_element {
	my ($ken,$hkey,$val) = @_;
	my $logger = get_logger();
	my $query = {
		"ken" => $ken,
		"hashkey" => $hkey
	};
	my $update;
	if (ref $val eq "ARRAY") {
		$update = {
			'$addToSet' => {'value' => {'$each' => $val}}
		}
	} else {
		$update = {
			'$addToSet' =>{"value" => $val}
		};
	}
	 
	my $new = 'true';
	my $upsert = 'true';
	my $fields = { "value"=>1, "_id" => 0};
	my $fnmod = {
		'query' => $query,
		'update' => $update,
		'new' => $new,
		'upsert' => $upsert,
		#'fields' => $fields
	};
	$logger->trace("query: ", sub {Dumper($fnmod)});
	my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$fnmod);
	Kynetx::MongoDB::clear_cache_for_map($ken,COLLECTION,Kynetx::MongoDB::map_key($ken,$hkey));
	$logger->trace("fnm: ", sub {Dumper($result)});
	return $result;
}

sub remove_kpds_set_element {
	my ($ken,$hkey,$val) = @_;
	my $logger = get_logger();
	my $query = {
		"ken" => $ken,
		"hashkey" => $hkey
	};
	my $update;
	if (ref $val eq "ARRAY") {
		$update = {
			'$pullAll' => {'value' =>  $val}
		}
	} else {
		$update = {
			'$pull' =>{"value" => $val}
		};
	}
	 
	my $new = 'true';
	my $upsert = 'true';
	my $fields = { "value"=>1, "_id" => 0};
	my $fnmod = {
		'query' => $query,
		'update' => $update,
		'new' => $new,
		'upsert' => $upsert,
		#'fields' => $fields
	};
	$logger->trace("query: ", sub {Dumper($fnmod)});
	my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$fnmod);
	Kynetx::MongoDB::clear_cache_for_map($ken,COLLECTION,Kynetx::MongoDB::map_key($ken,$hkey));
	$logger->trace("fnm: ", sub {Dumper($result)});
	return $result;
}



sub delete_kpds_element {
	my ($ken,$hkey) = @_;
	my $logger = get_logger();
	if (defined $ken) {
		my $key = {
			"ken" => $ken
		};
		if (defined $hkey) {
			$logger->trace("Delete element: ", sub {Dumper($hkey)});
			Kynetx::MongoDB::delete_hash_element(COLLECTION,$key,$hkey);
			Kynetx::MongoDB::clear_cache_for_map($ken,COLLECTION,Kynetx::MongoDB::map_key($ken,$hkey));
			if ($hkey > 1) {
				$logger->trace("Flush upstream ", sub {Dumper(Kynetx::MongoDB::map_key($ken,[$hkey->[0]]))});
				Kynetx::MongoDB::clear_cache_for_map($ken,COLLECTION,Kynetx::MongoDB::map_key($ken,[$hkey->[0]]));
			}
		} else {
			$logger->warn("Attempted to delete $key in ", COLLECTION, " (use delete_kpds(<KEN>) )");
		}
	}
	
}

sub delete_kpds {
	my ($ken) = @_;
	my $logger = get_logger();
	if (defined $ken) {
		my $key = {
			"ken" => $ken
		};
		Kynetx::MongoDB::delete_value(COLLECTION,$key);
	}
}


########################### Account Management Methods
sub delete_cloud {
	my ($ken,$cascade) = @_;
	my $logger = get_logger();
	if ($cascade) {
		my $dependents = Kynetx::Persistence::KPDS::get_kpds_element($ken,['dependents']);	
		foreach my $depnd (@{$dependents}) {
	    	delete_cloud($depnd,$cascade);
		}		
	}
	$logger->trace("Delete: $ken");
	Kynetx::Persistence::KEN::delete_ken($ken);
	Kynetx::Persistence::KPDS::delete_kpds($ken);
	Kynetx::Persistence::KToken::delete_ken_tokens($ken);
}

sub link_dependent_cloud {
	my ($ken,$dependent) = @_;
	my $hkey = ['dependents'];
	Kynetx::Persistence::KPDS::push_kpds_set_element($ken,$hkey,$dependent);	
}


########################### KPDS Ruleset Methods
sub add_ruleset {
	my ($ken,$ridlist) = @_;
	my $logger=get_logger();
	# Take list of rid_info and transform into fqrid
	my @fqrid_list = ();
	if (ref $ridlist eq "ARRAY") {
	  for my $element (@{$ridlist}) {
	    push (@fqrid_list,Kynetx::Rids::get_fqrid($element))
	  }	  
	} elsif (ref $ridlist eq "") {
	  push(@fqrid_list,Kynetx::Rids::get_fqrid($ridlist))
	}	
	my $keypath = [RID];
	my $result = push_kpds_set_element($ken,$keypath,\@fqrid_list);
	$logger->trace("Set: ", sub {Dumper($result)});
	return $result;
}



sub get_rulesets {
	my ($ken) = @_;
	my $logger=get_logger();
	my $keypath = [RID];
	my $result = get_kpds_element($ken,$keypath);
	$logger->trace("list: ", sub {Dumper($result)});
	return $result;		
}

sub remove_ruleset {
	my ($ken,$ridlist) = @_;
	my $logger=get_logger();
	my $keypath = [RID];
	my $result = remove_kpds_set_element($ken,$keypath,$ridlist);
	$logger->trace("remove: ", sub {Dumper($result)});
	return $result;
}

########################### KPDS Developer Methods
sub get_developer_permissions {
	my ($ken,$devkey,$permkey) = @_;
	my $keypath = [DEV,$devkey, @{$permkey}];
	my $logger = get_logger();
	$logger->trace("Hash path: ", sub {Dumper($keypath)});
	my $val = Kynetx::Persistence::KPDS::get_kpds_element($ken,$keypath) || 0;
	return $val;
}

sub set_developer_permissions {
	my ($ken,$devkey,$permkey,$value) = @_;
	my $keypath = [DEV,$devkey, @{$permkey}];
	my $logger = get_logger();
	$logger->trace("Hash path: ", sub {Dumper($keypath)});
	my $result = Kynetx::Persistence::KPDS::put_kpds_element($ken,$keypath,$value);
	my $check = Kynetx::Persistence::KPDS::get_kpds_element($ken,$keypath);
	return $result;
}

sub revoke_developer_key {
	my ($ken,$devkey) = @_;
	my $logger = get_logger();
	my $keypath = [DEV,$devkey];
	Kynetx::Persistence::KPDS::delete_kpds_element($ken,$keypath);
}


1;