package Kynetx::Persistence::KEN;
# file: Kynetx/Persistence/KEN.pm
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
use Kynetx::Persistence::KToken qw(:all);
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use MongoDB;
use MongoDB::OID;
use Digest::MD5 qw(
    md5_base64
);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use constant COLLECTION => "kens";
use constant KCACHETIME => 300;


our $VERSION     = 1.00;
our @ISA         = qw(Exporter);


# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    get_ken
    has_ken
    new_ken
    ken_lookup_by_token
    ken_lookup_by_username
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

sub _ken_query {
    my ($var,$collection) = @_;
    $collection = $collection || COLLECTION;
    #my $result = Kynetx::MongoDB::get_value($collection,$var);
    my $result = Kynetx::MongoDB::get_singleton($collection,$var);
    if ($result) {
        my $mongoId = $result->{'_id'};
        if (defined $mongoId) {
        	return $mongoId->to_string;
        }
    }
    return undef;
}


sub get_ken {
    my ($session,$rid,$domain) = @_;
    my $logger = get_logger();
    $logger->trace("KEN Request");
    my $ken;
#     $ken = get_cached_ken($session);
#     if (defined $ken) {
# #      $logger->debug("Session: ", sub{Dumper $session});
# #      $logger->debug("Returning cached ken", $ken);
#       return $ken;
#     }
    $logger->warn("get_ken called with invalid session: ", sub {Dumper($session)}) unless ($session);
    my $ktoken = Kynetx::Persistence::KToken::get_token($session,$rid,$domain);
    if ($ktoken) {
#        $logger->debug("Token found: ",sub {Dumper($ktoken)});
        # update the KEN so we can do a better job of determining stale KENS
        $ken = $ktoken->{'ken'};
        touch_ken($ken);
#        cache_ken($session,$ken); 
        return $ken;
    }
    $ken = new_ken() unless ($ken);

    # A new token must be created
    Kynetx::Persistence::KToken::new_token($rid,$session,$ken);
#    cache_ken($session,$ken);    
    return $ken;
}

sub ken_lookup_by_username {
	my ($username) = @_;
	if (! defined $username || $username eq "") {
		return undef;
	}
	my $key = {
		'username' => $username
	};
	return Kynetx::Persistence::KEN::_ken_query($key);
}


sub ken_lookup_by_userid {
	my ($userid) = @_;
	if (! defined $userid || $userid eq "") {
		return undef;
	}
	$userid *=1;
	my $key = {
		'user_id' => $userid
	};
	return Kynetx::Persistence::KEN::_ken_query($key);
}

sub ken_lookup_by_email {
	my ($email) = @_;
	if (! defined $email || $email eq "") {
		return undef;
	}
	my $key = {
		'email' => $email
	};
	return Kynetx::Persistence::KEN::_ken_query($key);
}


sub ken_lookup_by_token {
    my ($ktoken) = @_;
    my $logger = get_logger();
#     my $ken = get_cached_ken($ktoken);
#     if ($ken) {
# #        $logger->debug("Found KEN in memcache: $ken");
# 	return $ken;
#     } else {
    $logger->trace("Check mongo for token: $ktoken");
    my $var = {
	       'ktoken' => $ktoken
	      };
    my $result = Kynetx::Persistence::KToken::token_query($var);
    if ($result) {
#     $logger->debug("Seeing ken for $ktoken: ", $result->{"ken"});
#		cache_ken($ktoken,$result->{"ken"});
	return $result->{"ken"};
    } else {
	return undef;
    }
#    }
}

sub mongo_has_ken {
    my ($ken) = @_;
    my $oid = MongoDB::OID->new(value => $ken);
    my $valid = Kynetx::MongoDB::get_singleton(COLLECTION,{"_id" => $oid});
    if (defined $valid && ref $valid eq "HASH") {
    	return $valid->{"_id"}->{'value'};
    }
    return undef;
}
sub set_authorizing_password {
    my ($ken,$password_hash) = @_;
    my $logger = get_logger();
    my $oid = MongoDB::OID->new(value => $ken);
    my $key = {"_id" => $oid};
    my $update = {
		  '$inc' => {'accesses' => 1},
		  '$set' => {'password' => $password_hash}
		 };
    my $fnmod = {
		 'query' => $key,
		 'update' => $update
		};
    my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$fnmod,1);          
    if (defined $result->{"value"}) {
	Kynetx::MongoDB::clear_cache(COLLECTION,$key);
	return 1;
    }
    return 0;
}

sub get_authorizing_password {
	my ($ken) = @_;
	my $logger = get_logger();
	my $oid = MongoDB::OID->new(value => $ken);
	my $key = {"_id" => $oid};
	my $obj = Kynetx::MongoDB::get_singleton(COLLECTION,$key);
	if (defined $obj) {
		$logger->trace("KEN: ", sub {Dumper($obj)});
		my $password = $obj->{'password'};
		# unauthorized accounts
		if (! defined $password ||	$password eq "" ||	$password eq "*") {
			my $parent = $obj->{'parent'};
			if ($parent) {
				return get_authorizing_password($parent);
			}
		} else {
			return $password;
		}
		
	}
	return undef;
}


sub _validate_ken {
    my ($ken) = @_;
    my $valid = get_ken_value($ken,"_id");
    if ($valid) {
        return 1;
    } else {
        return 0;
    }
}

sub new_ken {
    my ($struct) = @_;
    my $logger = get_logger();
    $struct = $struct || get_ken_defaults();
    my $kpds = Kynetx::MongoDB::get_collection(COLLECTION);
    my $ken = $kpds->insert($struct,{'safe' => 1});
    $logger->debug("Generated new KEN: $ken");
    return $ken->{"value"};
}

sub get_ken_value {
    my ($ken,$key) = @_;
    my $logger = get_logger();
    my $oid = MongoDB::OID->new(value => $ken);
    my $valid = Kynetx::MongoDB::get_singleton(COLLECTION,{"_id" => $oid});
    $logger->debug("Ken: ", sub {Dumper($valid)});
    return $valid->{$key};
}

sub set_ken_value {
  my ($ken,$vkey,$val) = @_;
  my $logger = get_logger();
	my $oid = MongoDB::OID->new(value => $ken);
	my $key = {"_id" => $oid};
  my $update = {
		'$inc' => {'accesses' => 1},
		'$set' => {$vkey => $val}
	};
	my $fnmod = {
	  'query' => $key,
	  'update' => $update	  
	};
  $logger->debug("Setting ", sub{Dumper $fnmod});
  my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$fnmod,1);          
	if (defined $result->{"value"}) {
	  Kynetx::MongoDB::clear_cache(COLLECTION,$key);
	  return 1;
	}
	return 0;
}

sub touch_ken {
	my ($ken,$ts) = @_;
    my $logger = get_logger();
    my $oid = MongoDB::OID->new(value => $ken);
    Kynetx::MongoDB::get_singleton(COLLECTION,{"_id" => $oid});
}

sub get_ken_defaults {
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
    return $dflt;
}

sub make_ken_cache_keystring {
  my ($session) = @_;
  my $token = $session;
  if (ref $session eq "HASH") {
    $token = Kynetx::Session::session_id($session);
  }
  my $keystring = "_ken_cache_" . $token;
  return $keystring;
}

sub get_cached_ken {
  my ($session) = @_;
  my $key = make_ken_cache_keystring($session);
  my $result = Kynetx::Memcached::check_cache($key);
  if (defined $result) {
      return $result;
  } else {
      return undef;
  }
  
}

sub cache_ken {
  my ($session,$ken) = @_;
  my $key = make_ken_cache_keystring($session);
  Kynetx::Memcached::mset_cache($key,$ken,KCACHETIME);
}


# This is nuculear--primarily for cleaning up after smoke tests
sub delete_ken {
    my ($ken) = @_;
    my $logger = get_logger();
    my $kpds = Kynetx::MongoDB::get_collection(COLLECTION);
    my $oid = MongoDB::OID->new("value" => $ken);
    my $var = {"_id" => $oid};
    $kpds->remove($var,{"safe" => 1});
    Kynetx::MongoDB::clear_cache(COLLECTION,$var);
}


1;
