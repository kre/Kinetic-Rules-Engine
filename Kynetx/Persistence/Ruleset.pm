package Kynetx::Persistence::Ruleset;
# file: Kynetx/Persistence/Ruleset.pm
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
use Kynetx::Rules;
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
  rid_from_ruleset
  get_registry
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });
our @EXPORT = qw(&rid_from_ruleset);

use constant COLLECTION => "ruleset";

sub get_registry_element {
	my ($rid,$hkey) = @_;
	my $logger = get_logger();
	if (defined $rid) {
		my $key = {
			"rid" => $rid
		};
		my $c_key = Kynetx::MongoDB::map_key($rid,$hkey);
		my $cache = Kynetx::MongoDB::get_cache_for_map($rid,COLLECTION,$c_key);
		if (defined $cache) {
			$logger->trace("Cached value (",sub {Dumper($c_key)},"): ", sub {Dumper($cache)});
			return $cache;
		} else {
			$logger->trace("Cached miss (",sub {Dumper($c_key)},"): ");
		}
		my $result = Kynetx::MongoDB::get_hash_element(COLLECTION,$key,$hkey);
		if (defined $result && ref $result eq "HASH") {
			Kynetx::MongoDB::set_cache_for_map($rid,COLLECTION,$c_key,$result->{"value"});
			return $result->{"value"};
		} else {
			return undef;
		}
	} else {
		$logger->warn("rid undefined in ruleset registry request");
 		return undef;		
	}
	
}

sub put_registry_element {
	my ($rid,$hkey,$val) = @_;
	my $logger = get_logger();
	my $key = {
		'rid' => $rid
	};
	my $value = {
		'value' => $val
	};
	my $success = Kynetx::MongoDB::put_hash_element(COLLECTION,$key,$hkey,$value);
	Kynetx::MongoDB::clear_cache_for_map($rid,COLLECTION,Kynetx::MongoDB::map_key($rid,$hkey));
	if ($hkey > 1) {
		$logger->trace("Flush upstream");
		Kynetx::MongoDB::clear_cache_for_map($rid,COLLECTION,Kynetx::MongoDB::map_key($rid,[$hkey->[0]]));
	}
	return $success;
	
}


sub push_registry_set_element {
	my ($rid,$hkey,$val) = @_;
	my $logger = get_logger();
	my $query = {
		"rid" => $rid,
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
	Kynetx::MongoDB::clear_cache_for_map($rid,COLLECTION,Kynetx::MongoDB::map_key($rid,$hkey));
	$logger->trace("fnm: ", sub {Dumper($result)});
	return $result;
}

sub remove_registry_set_element {
	my ($rid,$hkey,$val) = @_;
	my $logger = get_logger();
	my $query = {
		"rid" => $rid,
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
	Kynetx::MongoDB::clear_cache_for_map($rid,COLLECTION,Kynetx::MongoDB::map_key($rid,$hkey));
	$logger->trace("fnm: ", sub {Dumper($result)});
	return $result;
}



sub delete_registry_element {
	my ($rid,$hkey) = @_;
	my $logger = get_logger();
	if (defined $rid) {
		my $key = {
			"rid" => $rid
		};
		if (defined $hkey) {
			$logger->trace("Delete element: ", sub {Dumper($hkey)});
			Kynetx::MongoDB::delete_hash_element(COLLECTION,$key,$hkey);
			Kynetx::MongoDB::clear_cache_for_map($rid,COLLECTION,Kynetx::MongoDB::map_key($rid,$hkey));
			if ($hkey > 1) {
				$logger->trace("Flush upstream ", sub {Dumper(Kynetx::MongoDB::map_key($rid,[$hkey->[0]]))});
				Kynetx::MongoDB::clear_cache_for_map($rid,COLLECTION,Kynetx::MongoDB::map_key($rid,[$hkey->[0]]));
			}
		} else {
			$logger->warn("Attempted to delete $rid in ", COLLECTION, " (use delete_registry(<rid>) )");
		}
	}
	
}

sub delete_registry {
	my ($rid) = @_;
	my $logger = get_logger();
	if (defined $rid) {
		my $key = {
			"rid" => $rid
		};
		Kynetx::MongoDB::delete_value(COLLECTION,$key);
	}
}

sub get_registry {
	my ($rid) = @_;
	my $logger = get_logger();
	if (defined $rid) {
		my $key = {
			"rid" => $rid
		};
		return Kynetx::MongoDB::get_value(COLLECTION,$key);
	}
	return undef;
}

sub rid_from_ruleset {
  my ($rid) = @_;
  my $logger = get_logger();
  my $rid_info;
  my $result = get_registry($rid);
  if (defined $result) {
    $logger->info("Rid info: ",sub {Dumper($result)});
    $rid_info = $result->{'value'};
    $rid_info->{'rid'} = $result->{'rid'};
    return $rid_info;
  }
  return undef;
  
}

sub get_rid_index {
  my ($ken,$userid,$prefix) = @_;
  my $logger = get_logger();
  my $rid;
  my $rid_index = 0;
  my $query = {"rid" => {'$regex' => "^$prefix"}};
  my $result = Kynetx::MongoDB::get_hash_element(COLLECTION,$query,['rid_index']);
  if (defined $result) {
    $rid_index = $result->{'value'} + 1;
  }  
  return $rid_index;
}

sub create_rid {
  my ($ken,$prefix,$uri) = @_;
  my $logger = get_logger();
  my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');
  if (defined $prefix && $prefix ne ""){
    $prefix .= $userid
  } else {
    $prefix = 'a' . $userid;
  };
  my $rid_index = get_rid_index($ken,$userid,$prefix); 
  my $rid = $prefix . "x" . $rid_index;
  my $registry = {
    'owner' => $ken,
    'rid_index' => $rid_index,
    'prefix' => $prefix
  };
  if (defined $uri && ref $uri eq "") {
    $registry->{'uri'} = $uri;
  }
  put_registry_element($rid,[],$registry);
  return $rid;   
}

#################### Utility functions

sub get_rulesets_by_owner {
  my ($ken) = @_;
  my $logger = get_logger();
  my $key = {
    '$and' => [
      {'hashkey' => ['owner']},
      {'value' => $ken}
    ]
  };
  my $result = Kynetx::MongoDB::get_list(COLLECTION,$key);
  $logger->trace("list: ", sub {Dumper($result)});
  my @rids = ();
  if (ref $result eq "ARRAY") {
    for my $rs (@{$result}) {
      if (ref $rs eq "HASH"){
        my $rid = $rs->{'rid'};
        push(@rids,$rid);
      }
    }
  }
  return \@rids;
}

1;