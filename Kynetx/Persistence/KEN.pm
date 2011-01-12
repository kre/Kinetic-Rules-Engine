package Kynetx::Persistence::KEN;
# file: Kynetx/Persistence/KEN.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
#
use strict;
use warnings;
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
    my $ken = undef;
    $logger->warn("get_ken called with invalid session: ", sub {Dumper($session)}) unless ($session);
    my $ktoken = Kynetx::Persistence::KToken::get_token($session,$rid,$domain);
    if ($ktoken) {
        $logger->debug("Token found: $ktoken");
        $ken = ken_lookup_by_token($ktoken);
    }
    if ($ken) {
        return $ken;
    } else {
        if ($ktoken) {
            $logger->debug("Token invalid");
            Kynetx::Persistence::KToken::delete_token($ktoken,$session,$rid);
        } else {
            $logger->trace("Token not found");
        }

        $ken = ken_lookup_by_domain($session,$rid,$domain);
    }

    # if we still don't have a KEN, create a new one
    $ken = new_ken() unless ($ken);

    # A new token must be created
    Kynetx::Persistence::KToken::new_token($rid,$session,$ken);
    return $ken;
}

sub ken_lookup_by_domain {
    my ($session,$rid,$domain) = @_;
    my $logger = get_logger();
    $domain = $domain || "web";
    my $token_obj = Kynetx::Persistence::KToken::get_endpoint_token($session,$rid,$domain);
    if ($token_obj) {
    	$logger->debug("Found KEN by domain");
        return $token_obj->{"ken"};
    }
    return undef;
}


sub ken_lookup_by_token {
    my ($ktoken) = @_;
    my $logger = get_logger();
    my $ken = Kynetx::Memcached::check_cache($ktoken);
    if ($ken) {
        $logger->debug("Found KEN in memcache: $ken");
    } else {
        $logger->debug("Check mongo for token: $ktoken");
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

sub get_ken_defaults {
    my $oid = MongoDB::OID->new();
    my $new_id = $oid->to_string();
    my $username = "_$new_id";
    my $dflt = {
        "username" => $username,
        "_id" => $oid,
        "firstname" => "",
        "lastname" => "",
        "password" => "*"
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