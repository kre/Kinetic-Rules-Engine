package Kynetx::Persistence::KToken;
# file: Kynetx/Persistence/KToken.pm
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
    KTOKEN
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

sub get_token {
    my ($ktoken,$rid) = @_;
    my $logger = get_logger();
    my $var = {"ktoken" => $ktoken};
    return Kynetx::MongoDB::get_value(COLLECTION,$var);
}

sub get_endpoint_token {
    my ($session, $rid) = @_;
    my $session_id = Kynetx::Session::session_id($session);
    my $var = {
        "endpoint_id" => $session_id,
        "rid" => $rid,
    };
    return Kynetx::MongoDB::get_value(COLLECTION,$var);
}


sub session_has_token {
    my ($session, $rid) = @_;
    my $logger = get_logger();
    my $ktoken = $session->{KTOKEN}->{$rid};
    if ($ktoken) {
        $logger->trace("Token found in session: $ktoken");
        return $ktoken;
    } else {
        my $mongo_query = get_endpoint_token($session,$rid);
        if ($mongo_query) {
            $ktoken = $mongo_query->{"ktoken"};
            store_token_to_apache_session($ktoken,$rid,$session);
            return $ktoken;
        }
        $logger->debug("No token found");
        return undef;
    }
}


sub new_token {
    my ($rid,$session,$ken) = @_;
    my $logger = get_logger();
    my $kpds = Kynetx::MongoDB::get_collection("tokens");
    $ken = Kynetx::Persistence::KEN::new_ken() unless ($ken);
    my $oid = MongoDB::OID->new();
    my $k1 = md5_base64($oid->to_string);
    my $k2 = md5_base64($rid);
    my $ktoken = $k1.$k2;
    my $lastactive = DateTime->now->epoch;
    my $var = {
        "ktoken" => $ktoken,
#        "_id" => $oid,
    };
    my $token = {
        "ken" => $ken,
        "ktoken" => $ktoken,
        "_id" => $oid,
        "rid" => $rid,
        "last_active" => $lastactive,
        "endpoint_id" => Kynetx::Session::session_id($session),
    };
#    my $status = $kpds->insert($token,{"safe" => 1});
    my $status = Kynetx::MongoDB::update_value(COLLECTION,$var,$token,1,0);
    if ($status) {
        return $ktoken;
    } else {
        $logger->warn("Token request error: ", mongo_error());
    }

}

sub store_token_to_apache_session {
    my ($ktoken,$rid,$session) = @_;
    my $logger = get_logger();
    my $test = is_valid_token($ktoken,$rid);
    if ($test) {
        $session->{KTOKEN}->{$rid} = $ktoken;
        return $session->{KTOKEN}->{$rid};
    } else {
        $logger->debug("Can't save ($ktoken) to session");
        return undef;
    }
}


sub is_valid_token {
    my ($ktoken,$rid) = @_;
    my $logger = get_logger();
    my $valid = get_token($ktoken,$rid);
    if ($valid) {
        $logger->trace("Checking $ktoken for ruleset $rid");
        my $oid = $valid->{'_id'}->to_string;
        $ktoken =~ m/^([A-Za-z0-9+\/]{22})([A-Za-z0-9+\/]{22})$/;
        my $m_oid = $1;
        my $m_rid = $2;
        my $m_oid2 = md5_base64($oid);
        my $m_rid2 = md5_base64($rid);
        $logger->trace("$m_oid");
        $logger->trace("$m_oid2");
        $logger->trace("$m_rid");
        $logger->trace("$m_rid2");
        if ($m_oid eq $m_oid2 && $m_rid eq $m_rid2) {
            $logger->trace("Token is valid");
            return 1;
        } else {
            return 0;
            $logger->debug("Token is NOT valid");
        }
    } else {
        return 0;
            $logger->debug("Token is NOT valid");
    }
}

sub delete_token {
    my ($ktoken) = @_;
    my $var = {"ktoken" => $ktoken};
    Kynetx::MongoDB::delete_value(COLLECTION,$var);
#    my $kpds = Kynetx::MongoDB::get_collection("tokens");
#    $kpds->remove({"ktoken" => $ktoken},{"safe" => 1});
#    Kynetx::Memcached::flush_cache($ktoken);
}

sub cache_token {
    my ($ktoken) = @_;

}

1;