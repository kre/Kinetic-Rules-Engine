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

sub get_ken {
    my ($session,$rid,$count) = @_;
    my $logger = get_logger();
    $logger->warn("get_ken called with invalid session: ", sub {Dumper($session)}) unless ($session);
    $count = $count || 1;
    #$logger->debug("KEN session_id: ",Kynetx::Session::session_id($session));
    my $ken = has_ken($session,$rid);
    if ($ken) {
        return $ken;
    } else {
        $count++;
        my $token = Kynetx::Persistence::KToken::new_token($rid);
        Kynetx::Persistence::KToken::store_token_to_apache_session($token,$rid,$session);
        if ($count > 3) {
            Kynetx::Session::session_cleanup($session);
            die;
        }
        return get_ken($session,$rid,$count);
    }

}

sub has_ken {
    my ($session,$rid) = @_;
    my $logger = get_logger();
    my $ken;
    my $token = session_has_token($session,$rid);
    if ($token) {
        $logger->trace("Has token for $rid ($token)");
        $ken = Kynetx::Memcached::check_cache($token);
        $logger->trace("[has_ken] found KEN: $ken for Token: $token");
        if (is_valid_token($token,$rid)) {
            my $token_obj = get_token($token,$rid);
            if ($token_obj) {
                return $token_obj->{"ken"};
            } else {
                return undef;
            }
        } else {
            $logger->warn("Invalid token ($token) found");
            return undef;
            die;
        }
    } else {
        $logger->debug("No token found for $rid");
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
    my $kpds = Kynetx::MongoDB::get_collection(COLLECTION);
    my $ken = $kpds->insert($struct);
    $logger->debug("Generated new KEN: $ken");
    return $ken->{"value"};
}

sub get_ken_value {
    my ($ken,$key) = @_;
    my $logger = get_logger();
    my $KENS = Kynetx::MongoDB::get_collection(COLLECTION);
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

# This is nuculear--primarily for cleaning up after smoke tests
sub delete_ken {
    my ($ken) = @_;
    my $kpds = Kynetx::MongoDB::get_collection(COLLECTION);
    my $oid = MongoDB::OID->new("value" => $ken);
    $kpds->remove({"_id" => $oid},{"safe" => 1});
}


1;