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
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use MongoDB;
use MongoDB::OID;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    get_ken
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });


sub get_ken {
    my ($session,$endpoint_domain) = @_;
    my $logger = get_logger();
    my $ken = has_ken($session,$endpoint_domain);
    if ($ken) {
        $logger->debug("Found KEN $ken");
        return $ken;
    } else {
        $ken = new_ken();
        return (_peg_ken_to_session($session,$ken,$endpoint_domain));
    }
}

sub is_anonymous {
    my ($session,$endpoint_domain) = @_;
    my $logger = get_logger();
    $endpoint_domain = 'default' unless ($endpoint_domain);
    my $ken = has_ken($session,$endpoint_domain);
    my $username = get_ken_value($ken,"username");
    $logger->debug("Anonymous username: $username");
    if ($username eq "_$ken") {
        return 1;
    } else {
        return 0;
    }

}

sub has_ken {
    my ($session,$endpoint_domain) = @_;
    my $logger = get_logger();
    my $session_id = Kynetx::Session::session_id($session);
    my $ken;
    $endpoint_domain = 'default' unless ($endpoint_domain);
    # Check memcached for a cached KEN first
    my $cache_key = "KEN:" . $endpoint_domain . ":" . $session_id;
    $ken = Kynetx::Memcached::check_cache($cache_key);
    if ($ken) {
        return $ken;
    }
    my $session_link = Kynetx::MongoDB::get_collection("sessions");
    $logger->debug("KEN lookup using session id: ", $session_id);
    my $result = $session_link->find_one({"endpoint_session_id" => $session_id,
        "etype" => $endpoint_domain,
    });
    $logger->debug("Ken lookup: ",sub {Dumper($result)});
    $ken = $result->{"ken"};
    if ($ken) {
        $logger->debug("Set the KEN in memcached for default period");
        Kynetx::Memcached::mset_cache($cache_key,$ken,0);
        return $ken;
    } else {
        return undef;

    }
}

sub _peg_ken_to_session {
    my ($session, $ken, $etype) = @_;
    my $session_id = Kynetx::Session::session_id($session);
    $etype = "default" unless ($etype);
    if ($session_id and _validate_ken($ken)) {
        my $session_link = Kynetx::MongoDB::get_collection("sessions");
        my $oid = $session_link->insert({"etype" => $etype,
            "endpoint_session_id" => $session_id,
            "ken" => $ken});
        return $oid->{"value"};
    } else {
        return undef;
    }
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
    $logger->debug("KEN struct: ",sub {Dumper($struct)});
    my $kpds = Kynetx::MongoDB::get_collection("kens");
    my $ken = $kpds->insert($struct);
    $logger->debug("KEN oid: ",sub {Dumper($ken)});
    return $ken->{"value"};
}

sub get_ken_value {
    my ($ken,$key) = @_;
    my $logger = get_logger();
    my $KENS = Kynetx::MongoDB::get_collection("kens");
    my $oid = MongoDB::OID->new(value => $ken);
    my $valid = $KENS->find_one({"_id" => $oid});
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

1;