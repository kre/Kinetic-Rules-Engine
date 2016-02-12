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
  get_ruleset_info
  get_registry
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });
our @EXPORT = qw(&get_ruleset_info);

use constant COLLECTION => "ruleset";

sub get_registry_element {
	my ($rid,$hkey) = @_;
	my $logger = get_logger();
	if (defined $rid) {
		my $key = {
			"rid" => $rid
		};
#		my $cache = Kynetx::MongoDB::get_cache_for_hash(COLLECTION,$key,$hkey);
#		if (defined $cache) {
#			return $cache;
#		} 
		my $result = Kynetx::MongoDB::get_hash_element(COLLECTION,$key,$hkey);
		if (defined $result && ref $result eq "HASH") {
			#Kynetx::MongoDB::set_cache_for_hash(COLLECTION,$key,$hkey,$result->{"value"});
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
	$logger->trace("Hash: ", sub {Dumper($hkey)});
	my $success = Kynetx::MongoDB::put_hash_element(COLLECTION,$key,$hkey,$value);
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
	my $cachekey = {
	  'rid' => $rid
	};
	Kynetx::MongoDB::clear_cache(COLLECTION,$cachekey);
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
	my $cachekey = {
	  'rid' => $rid
	};
	Kynetx::MongoDB::clear_cache(COLLECTION,$cachekey);
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
#	my $logger = get_logger();
	if (defined $rid) {
		my $key = {
			"rid" => $rid
		};
		my $hkey = [];
#		$logger->debug("[get_registry]", sub{Dumper $key});
		return Kynetx::MongoDB::get_value(COLLECTION,$key);
	}
	return undef;
}

sub to_rid_info {
  my ($ruleset) = @_;
  my $logger = get_logger();
  my $rid_info;
  if (defined $ruleset && ref $ruleset eq "") {
    my $rid_info = get_ruleset_info($ruleset);
    if ($rid_info) {
      $ruleset = $rid_info;
    } else {
      return Kynetx::Rids::normalize($ruleset)
    }
  }
  if (defined $ruleset && ref $ruleset eq "HASH") {
    my $rid_info = Kynetx::Rids::normalize($ruleset->{'rid'});
    if ($ruleset->{'last_modified'}) {
      $rid_info->{'last_modified'} = $ruleset->{'last_modified'};
    }
    if ($ruleset->{'owner'}) {
      $rid_info->{'owner'} = $ruleset->{'owner'};
    }
    return $rid_info;
  } 
  return undef;
}
sub signature {
  my ($rid) = @_;
	my $logger = get_logger();
	my $rid_info = to_rid_info($rid);
	my @fields = ();
	push(@fields, Kynetx::Rids::get_rid($rid_info)|| "") ;
	push(@fields, Kynetx::Rids::get_version($rid_info) || "") ;
	push(@fields, Kynetx::Rids::get_last_modified($rid_info) || "") ;
	push(@fields, Kynetx::Rids::get_owner($rid_info)  || "");
	my $sig_str = join("-",@fields);
	$logger->trace("rid sig: $sig_str");
	return Digest::MD5::md5_hex( $sig_str );
}

sub get_ruleset_info {
  my ($rid) = @_;
  my $logger = get_logger();
  my $ruleset;
  my $result = get_registry($rid);
  if (defined $result) {
    $ruleset = $result->{'value'};
    $ruleset->{'rid'} = $result->{'rid'};
    return $ruleset;
  }
  return undef;
  
}

sub get_rid_index {
  my ($ken,$userid,$prefix) = @_;
  my $logger = get_logger();
  my $rid;
  my $rid_index = 0;
  my $match = {"rid" => {'$regex' => "^$prefix"},'hashkey'=> {'$in' => ['rid_index']}};
  my $group = {'_id' => 'value',
      'max' => {'$max' => '$value'}
  };
  my $result = Kynetx::MongoDB::aggregate_group(COLLECTION,$match,$group);
  if (defined $result && ref $result eq "ARRAY" && scalar @{$result} > 0) {
    $logger->debug("rid index: ",sub {Dumper($result)});
    my $element = $result->[0];
    $rid_index = $element->{'max'} + 1;
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
    $prefix = 'b' . $userid;
  };
  my $rid_index = get_rid_index($ken,$userid,$prefix); 
  my $rid = $prefix . "x" . $rid_index;
  # new rids are always .prod versions
  $rid .= '.prod';
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

sub fork_rid {
  my ($ken,$fqrid,$branch,$uri) = @_;
  my $logger = get_logger();
  $logger->debug("Fork KEN: $ken");
  $logger->debug("Fork RID: $fqrid");
  $logger->debug("Fork Branch: $branch");
  $logger->debug("Fork URI: $uri");
  my $ruleset = get_ruleset_info($fqrid);
  $logger->debug("Ruleset info for main ", sub{Dumper $ruleset});
  my $root = Kynetx::Rids::strip_version($fqrid);
  my $nq_rid = $root . '.' . $branch;
  my $exists = get_registry($nq_rid);
  if (defined $exists) {
    return undef;
  }
  my $default = {
    'uri' => $uri,
    'owner' => $ken,
    'rid_index' => $ruleset->{"rid_index"}, # w/o index and prefix, this won't be seen by get_rid_index();
    'prefix'    => $ruleset->{"prefix"},
  };
  put_registry_element($nq_rid,[],$default);
  return $nq_rid;
}

#################### Utility functions

sub import_legacy_ruleset {
  my ($ken,$rid_info) = @_;
  my $logger = get_logger();
  my $rid = Kynetx::Rids::get_rid($rid_info);
  if (get_registry($rid)) {
    return undef;
  }
  my @ridlist = ('prod', 'dev');
  my @rids = ();
  my $repo = Kynetx::Configure::get_config('RULE_REPOSITORY');
  my ($base_url,$username,$password) = split(/\|/, $repo);
  my $d_url = join('/', ($base_url, $rid, 'prod', 'krl/'));
  my $default = {
    'uri' => $d_url,
    'username' => $username,
    'password' => $password
  };
  if (defined $ken) {
    $default->{'owner'} = $ken,      
  }
  #put_registry_element($rid,[],$default);
  for my $version (@ridlist) {
    my $fqrid = $rid;
      $fqrid .= '.' . $version;
    my $rs_url = join('/', ($base_url, $rid, $version, 'krl/'));
    my $registry = {
      'uri' => $rs_url,
      'username' => $username,
      'password' => $password
    };
    if (defined $ken) {
      $registry->{'owner'} = $ken,      
    }
    put_registry_element($fqrid,[],$registry);   
    push(@rids,$fqrid); 
  }    
  return \@rids;
}

sub increment_version {
  my ($rid) =@_;
	my $logger = get_logger();
  my $hkey = ['version'];
	my $query = {
		"rid" => $rid,
		"hashkey" => $hkey
	};
	my $update ={
	  '$inc' =>{"value" => 1}
  };
	 
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
	return $result;
  
} 

sub touch_ruleset {
  my ($rid) = @_;
  my $logger = get_logger();
  my $exists = get_registry($rid);
  return undef unless ($exists);
  my $hkey = ['last_modified'];
  my $query = {
    "rid" => $rid,
    "hashkey" => $hkey
  };
  my $timestamp = DateTime->now->epoch;
  my $update = {
    '$set' => {"value" => $timestamp}
  };
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
	my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$fnmod);
	$logger->trace("Touched ruleset: ", sub {Dumper($result)});
	my $cachekey = {
	  'rid' => $rid
	};
	Kynetx::MongoDB::clear_cache(COLLECTION,$cachekey);
	if ($result && ref $result eq "HASH") {
	  return $result->{'value'};
	} else {
	  return undef;
	}
}

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
  # $logger->debug("list: ", sub {Dumper($result)});
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
