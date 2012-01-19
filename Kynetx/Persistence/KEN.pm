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


our $VERSION     = 1.00;
our @ISA         = qw(Exporter);


# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    get_ken
    has_ken
    new_ken
    ken_lookup_by_token
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

sub _ken_query {
    my ($var,$collection) = @_;
    $collection = $collection || COLLECTION;
    my $result = Kynetx::MongoDB::get_value($collection,$var);
    if ($result) {
        return $result->{"ken"};
    }
    return undef;
}


sub get_ken {
    my ($session,$rid,$domain) = @_;
    my $logger = get_logger();
    $logger->trace("KEN Request");
    my $ken = undef;
    $logger->warn("get_ken called with invalid session: ", sub {Dumper($session)}) unless ($session);
    my $ktoken = Kynetx::Persistence::KToken::get_token($session,$rid,$domain);
    if ($ktoken) {
        $logger->trace("Token found: ",sub {Dumper($ktoken)});
        return $ktoken->{'ken'};
    }
    $ken = new_ken() unless ($ken);

    # A new token must be created
    Kynetx::Persistence::KToken::new_token($rid,$session,$ken);
    return $ken;
}


sub ken_lookup_by_token {
    my ($ktoken) = @_;
    my $logger = get_logger();
    my $ken = Kynetx::Memcached::check_cache($ktoken);
    if ($ken) {
        $logger->trace("Found KEN in memcache: $ken");
    } else {
        $logger->trace("Check mongo for token: $ktoken");
        $ken = mongo_has_ken($ktoken);
    }
    return $ken;
}

sub mongo_has_ken {
    my ($ktoken) = @_;
    my $var = {
        'ktoken' => $ktoken
    };
    my $result = Kynetx::Persistence::KToken::token_query($var);
    if ($result) {
        return $result->{"ken"};
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
    my $ken = $kpds->insert($struct);
    $logger->debug("Generated new KEN: $ken");
    return $ken->{"value"};
}

sub get_ken_value {
    my ($ken,$key) = @_;
    my $logger = get_logger();
#    my $KENS = Kynetx::MongoDB::get_collection(COLLECTION);
    my $oid = MongoDB::OID->new(value => $ken);
#    my $valid = $KENS->find_one({"_id" => $oid});
    my $valid = Kynetx::MongoDB::get_value(COLLECTION,{"_id" => $oid});
    return $valid->{$key};
}

sub touch_ken {
	my ($ken,$ts) = @_;
    my $logger = get_logger();
    my $oid = MongoDB::OID->new(value => $ken);
    my $active = $ts || DateTime->now->epoch;
    my $kpds = Kynetx::MongoDB::get_collection(COLLECTION);
    my $touch = $kpds->update({"_id" => $oid},{'$set' => {"last_active" => $active}});
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

# This is nuculear--primarily for cleaning up after smoke tests
sub delete_ken {
    my ($ken) = @_;
    my $kpds = Kynetx::MongoDB::get_collection(COLLECTION);
    my $oid = MongoDB::OID->new("value" => $ken);
    my $var = {"_id" => $oid};
    $kpds->remove($var,{"safe" => 1});
    Kynetx::MongoDB::clear_cache(COLLECTION,$var);
}


1;