package Kynetx::Persistence::KToken;
# file: Kynetx/Persistence/KToken.pm
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
use Kynetx::Persistence::KEN qw(
    new_ken
);
use MongoDB;
use MongoDB::OID;
use Digest::MD5 qw(
    md5_base64
);
use Data::UUID;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use constant KTOKEN => "_ktoken";
use constant TOKEN_CACHE_TIME => 20;
use constant COLLECTION => "tokens";

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    session_has_token
    is_valid_token
    store_token_to_apache_session
    delete_token
    get_token
    set_token
    token_query
    KTOKEN
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

sub token_query {
    my ($var) = @_;
    my $logger = get_logger();
    my $parent = (caller(1))[3];
    #$logger->trace("Called from -$parent- with ",sub {Dumper($var)});
    return Kynetx::MongoDB::get_value(COLLECTION,$var);
}

# $var is a query with a regex, returns list
sub get_all_tokens {
    my ($var) = @_;
    my $logger = get_logger();
    my $skip_cache = 1;
    return Kynetx::MongoDB::get_list(COLLECTION,$var,$skip_cache);
}

sub get_token {
    my ($session, $rid,$domain) = @_;
    my $logger = get_logger();
    my $session_id = Kynetx::Session::session_id($session);
    $domain = $domain || "web";
    my $var;
    $logger->debug("Get token for session: ",  sub {$session_id});
    # There might be other ways to find a token for other endpoint domains
    if ($domain eq "web") {
        # Check mongo.tokens for any tokens for a matching sessionid
        $var = {
            "endpoint_id" => $session_id,
        };
    } else {
        # default is to check mongo for session

    }
	return Kynetx::MongoDB::get_singleton(COLLECTION,$var);	
}

sub set_token {
	my ($ktoken,$session_id) = @_;
	my $logger = get_logger();
	my $key = { 'ktoken' => $ktoken };
	my $var = 'endpoint_id';
	my $val = $session_id;
	$logger->trace("Set $ktoken to endpoint $session_id");
	my $find_and_modify = {
		'query' => { 'ktoken' => $ktoken },
		'update' => {'$set' => {$var => $val}},
		'new' => 'true'
	};
	#return Kynetx::MongoDB::atomic_set(COLLECTION,$key,$var,$val);
	return Kynetx::MongoDB::find_and_modify(COLLECTION,$find_and_modify);
}

sub get_token_id {
  my ($token) = @_;
  my $key = {
    'ktoken' => $token
  };
  my $id = undef;
  my $result = Kynetx::MongoDB::get_singleton(COLLECTION,$key);
  if ($result && $result->{'_id'}) {
    $id = $result->{'_id'}->{'value'};    
  }
  return $id;
}

sub get_eci_attributes {
  my ($token) = @_;
#  my $logger = get_logger();
  my $key = {
    'ktoken' => $token
  };
  my $attrs = undef;
  my $result = Kynetx::MongoDB::get_singleton(COLLECTION,$key);
#  $logger->debug("ECI contents for $token", sub {Dumper $result});
  if ($result && $result->{'attributes'}) {
    $attrs = $result->{'attributes'};    
  }
  return $attrs;
}

sub set_eci_attributes {
  my ($token, $attrs) = @_;
#  my $logger = get_logger();
  my $key = {
    'ktoken' => $token
  };

  my $update = {
		'$set' =>{"attributes" => $attrs}
	       };

  my $fnmod = {
	       'query' => $key,
	       'update' => $update,
	       'new' => 'true',
	       'upsert' => 'true',
	      };
#  $logger->trace("query: ", sub {Dumper($fnmod)});

  my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$fnmod);
  my $cachekey = {
    'ktoken' => $token
  };
  Kynetx::MongoDB::clear_cache(COLLECTION,$cachekey);
#  $logger->trace("fnm: ", sub {Dumper($result)});
  return $result;
}

sub get_eci_policy {
  my ($token) = @_;
  my $key = {
    'ktoken' => $token
  };
  my $policy = undef;
  my $result = Kynetx::MongoDB::get_singleton(COLLECTION,$key);
  if ($result && $result->{'policy'}) {
    $policy = $result->{'policy'};    
  }
  return $policy;
}

sub set_eci_policy {
  my ($token, $policy) = @_;
#  my $logger = get_logger();
  my $key = {
    'ktoken' => $token
  };

  my $update = {
		'$set' =>{"policy" => $policy}
	       };

  my $fnmod = {
	       'query' => $key,
	       'update' => $update,
	       'new' => 'true',
	       'upsert' => 'true',
	      };
#  $logger->trace("query: ", sub {Dumper($fnmod)});

  my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$fnmod);
  my $cachekey = {
    'ktoken' => $token
  };
  Kynetx::MongoDB::clear_cache(COLLECTION,$cachekey);
#  $logger->trace("fnm: ", sub {Dumper($result)});
  return $result;
}

sub set_ttl {
  my ($token,$ttl_index) = @_;
  my $oid = Kynetx::Persistence::KToken::get_token_id($token);
  Kynetx::MongoDB::set_ttl(COLLECTION,$ttl_index,$oid);
}

# Slightly different format for ECI tokens
sub create_token {
  my ($ken, $label,$type,$session,$attributes,$policy) = @_;
  my $logger = get_logger();
  my $ug = new Data::UUID;
  my $ktoken = $ug->create_str();
  my $oid = MongoDB::OID->new();
  my $e_id;
  if (defined $session && ref $session eq "HASH") {
      $e_id = $session->{"_session_id"};
  } else {
      $e_id = $ktoken;
  }
  my $lastactive = DateTime->now->epoch;
  $type = $type || "KRE";
  my $var = {
	     "ktoken" => $ktoken,
	    };
  my $token = {
	       "ken" => $ken,
	       "ktoken" => $ktoken,
	       "_id" => $oid,
	       "last_active" => $lastactive,
	       "endpoint_id" => $e_id,
	       "token_name" => $label,
	       "attributes" => $attributes,
	       "policy" => $policy,
	       "endpoint_type" => $type,
	      };
  $logger->debug("Var: ", sub {Dumper($var)});
  $logger->debug("Token: ", sub {Dumper($token)});
  my $status = Kynetx::MongoDB::update_value(COLLECTION,$var,$token,1,0,1);
#  $logger->debug("Token status: ", sub {Dumper($status)});
  if (ref $status eq 'HASH' && ($status->{'ok'} == 1)) {
      Kynetx::Persistence::KEN::touch_ken($ken);
      return $ktoken;
  } elsif ($status) {
      Kynetx::Persistence::KEN::touch_ken($ken);
      return $ktoken;
  } else {
      $logger->warn("Token request error: ", mongo_error());
  }
}

# this should be okay for small numbers of tokens
sub compare_token_kens {
	my ($tokens) = @_;
	my $logger = get_logger();
	my $base_ken;
	foreach my $token (@{$tokens}) {
		my $val = Kynetx::Persistence::KEN::ken_lookup_by_token($token);
		if (! defined $base_ken) {
			$base_ken = $val
		} elsif ($base_ken ne $val) {
			return 0;
		}
	}
	return 1;
	
}


sub new_token {
    my ($rid,$session,$ken,$authenticated) = @_;
    my $logger = get_logger();
    $logger->trace("Create new token request for ",Kynetx::Session::session_id($session));
    my $oid = MongoDB::OID->new();
    my $k1 = md5_base64($oid->to_string);
    my $k2 = md5_base64($rid);
    my $ktoken = $k1.$k2;
    my $lastactive = DateTime->now->epoch;
    my $var = {
        "ktoken" => $ktoken,
    };
    my $auth = $authenticated ? 1 :0;
    my $token = {
        "ken" => $ken,
        "ktoken" => $ktoken,
        "_id" => $oid,
        "last_active" => $lastactive,
        "endpoint_id" => Kynetx::Session::session_id($session),
        "authenticated" => $auth,
    };
    my $status = Kynetx::MongoDB::update_value(COLLECTION,$var,$token,1,0);
    if ($status) {
        Kynetx::Persistence::KEN::touch_ken($ken);
        return $ktoken;
    } else {
        $logger->warn("Token request error: ", mongo_error());
    }

}

sub is_authenticated {
    my ($session,$rid,$domain) = @_;
    my $logger = get_logger();
	my $valid = get_token($session,$rid,$domain);
	$logger->trace("Token: ", sub {Dumper($valid)});
	return $valid->{'authenticated'};
}



sub is_valid_token {
    my ($ktoken,$endpoint_id) = @_;
    my $logger = get_logger();
    my $valid = token_query({"ktoken" => $ktoken});
	if ($valid){
        $logger->debug("Token is valid");
        my $ken = $valid->{'ken'};
        return $valid;
    } else {
        return 0;
        $logger->debug("Token is NOT valid");
    }
}


sub delete_token {
    my ($ktoken,$session_id,$rid) = @_;
    my $var;
    my $logger=get_logger();
    if (defined $ktoken) {
    	$var = {"ktoken" => $ktoken};
    } else {
    	$var = {"endpoint_id" => $session_id};
    }
    
    my $result = Kynetx::MongoDB::delete_value(COLLECTION,$var);    
#    $logger->debug("Deleting token $ktoken with result ", sub{ Dumper $result });
    # We store the token in cache to quickly get the ken
    if (defined $session_id) {
    	my $additional_ref = COLLECTION .$session_id;
    	Kynetx::Memcached::flush_cache($additional_ref);
    }   
}

sub delete_ken_tokens {
  my ($ken) = @_;
  my $logger = get_logger();
  my $list = list_tokens($ken);
  my $count = 0;
  foreach my $element (@{$list}) {
    my $token = $element->{'cid'};
    delete_token($token);
    $count++;
  }
  $logger->debug("Deleted ($count) tokens for $ken");
}

sub list_tokens {
	my ($ken) = @_;
	my $logger = get_logger();
	my $tquery = {'ken' => $ken};
	my $c = Kynetx::MongoDB::get_collection(COLLECTION);
	$logger->trace("Query: ", sub {Dumper($tquery)});
	my $cursor = $c->find($tquery);
	if ($cursor->has_next()) {
		$logger->trace("Found some");
		my @tokens_array = ();
		while (my $obj = $cursor->next) {
			my $eci = $obj->{'ktoken'};
#			$logger->trace("Found: ", sub {Dumper($obj)});
#			$logger->trace("Found: $eci");
			my $label = $obj->{'token_name'};
			push(@tokens_array,{"name" => $label,
					    "cid" => $eci,
					    "attributes" => $obj->{"attributes"},
					    "type" => $obj->{"endpoint_type"},
					    "last_active" => $obj->{"last_active"}
					   });
		}
		return \@tokens_array; 
	}
	return undef;
}

sub get_default_token {
  my ($ken) = @_;
  my $key = {
    'ken' => $ken,
    'token_name' => '_LOGIN'    
  };
  my $result = Kynetx::MongoDB::get_value(COLLECTION,$key);
  if (defined $result) {
    return $result->{'ktoken'};
  }
  return undef;
}

sub get_token_by_token_name {
  my ($name) = @_;
  my $key = {
    'token_name' => $name
  };
  my $result = Kynetx::MongoDB::get_value(COLLECTION,$key);
  if (defined $result) {
    return $result->{'ktoken'};
  }
  return undef;
}

sub get_token_by_endpoint_id {
  my ($eid) = @_;
  my $key = {
    'endpoint_id' => $eid
  };
  my $result = Kynetx::MongoDB::get_value(COLLECTION,$key);
  if (defined $result) {
    return $result->{'ktoken'};
  }
  return undef;
}


sub get_token_by_token_type {
	my ($type) = @_;
	my $logger = get_logger();
	my $tquery = {'endpoint_type' => $type};
	my $c = Kynetx::MongoDB::get_collection(COLLECTION);
	$logger->trace("Query: ", sub {Dumper($tquery)});
	my $cursor = $c->find($tquery);
	if ($cursor->has_next()) {
		$logger->trace("Found some");
		my @tokens_array = ();
		while (my $obj = $cursor->next) {
			my $eci = $obj->{'ktoken'};
			push(@tokens_array,$eci);
		}
		return \@tokens_array; 
	}
	return undef;
}
  
sub get_token_by_ken_and_label {
	my ($ken,$name) = @_;
	my $logger = get_logger();
	my $tquery = {
	  'ken' => $ken,
	  'token_name' => $name
	};
	my $c = Kynetx::MongoDB::get_collection(COLLECTION);
	$logger->trace("Query: ", sub {Dumper($tquery)});
	my $cursor = $c->find($tquery);
	if ($cursor->has_next()) {
		$logger->trace("Found some");
		my @tokens_array = ();
		while (my $obj = $cursor->next) {
			my $eci = $obj->{'ktoken'};
			push(@tokens_array,$eci);
		}
		return \@tokens_array; 
	}
	return undef;  
}

sub update_token_name {
  my ($ken,$token_name,$endpoint_type) = @_;
  my $logger = get_logger();
  my $findnmod = {
    'query' => {'ken' => $ken,'endpoint_type' => $endpoint_type},
    'update' => {'$set' => {'token_name' => $token_name}},
    'upsert' => 1,
    'new' => 1
  };
  my $result;
  my $exists = Kynetx::MongoDB::get_value(COLLECTION,$findnmod->{'query'});
  if ($exists) {
    $logger->debug("Update $token_name ");
    $result =  Kynetx::MongoDB::find_and_modify(COLLECTION,$findnmod,1);
    if ($result && ref $result eq "HASH") {
      my $token = $result->{'value'};
      return $token;
    }
    
  } else {    
    $result = create_token($ken,$token_name,$endpoint_type);
  }
  return $result;
}

sub get_oldest_token {
  my ($ken) = @_;
  my $key = {
    'ken' => $ken
  };
  my $tokens = Kynetx::MongoDB::get_matches(COLLECTION,$key);
  my @sorted = sort _cmp_token @{$tokens};
  return $sorted[0]->{'ktoken'};
}

sub _cmp_token {
  return  ($a->{'ken'} cmp $b->{'ken'} || $a->{'created'} <=> $b->{'created'});
}

1;
