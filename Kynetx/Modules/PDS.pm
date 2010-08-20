package Kynetx::Modules::PDS;
# file: Kynetx/PDS.pm
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
use MongoDB;
use MongoDB::OID;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    get_pds_session
    pds_get
    eval_pds

) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

my $funcs = {};

my %predicates = (
    'true' => sub {
        my ($req_info,$session,$path,$args) =@_;
        return 1;
    },
    'false' => sub {
        my ($req_info,$session,$path,$args) =@_;
        return 0;
    }
);

sub get_predicates {
    return \%predicates;
}

sub _get_value {
    my ( $req_info, $session, $function, $args) = @_;
    my $logger = get_logger();
    $logger->debug("PDS function ($function)");
    return 1;
}
$funcs->{"get"} = \&_get_value;

sub get_pds_session {
    my ($session, $ken,$endpoint_type) = @_;
    my $endpoint_session_id = Kynetx::Session::session_id($session);
    my $session_link = Kynetx::MongoDB::get_collection("sessions");
    my $etype = $endpoint_type || "default";
    if ($ken) {
        my $psession = $session_link->find_one({"endpoint_session_id" => $endpoint_session_id});
        if ($psession) {
            return $psession->{'_id'}->to_string();
        } else {
            # We have a ken, but no pds_session so make one
            return new_pds_session($endpoint_session_id, $etype, $ken);
        }
    }

}

sub new_pds_session {
    my ($esid,$etype,$ken) = @_;
    my $logger = get_logger();
    my $struct = {
        "endpoint_session_id" => $esid,
        "etype" => $etype,
        "ken" => $ken
    };
    $logger->debug("Make new PDS session for ($esid)");
    my $session_link = Kynetx::MongoDB::get_collection("sessions");
    my $oid = $session_link->insert($struct);
    return $oid->{"value"};

}

sub pds_get {
    my ($session,$r,$rule_env) = @_;
    my $logger = get_logger();
    my $ken = Kynetx::Modules::PDS::KEN::get_ken($session,$r,$rule_env);
    if ($ken) {
        my $oid = MongoDB::OID->new("value" => $ken);
        my $kpds = Kynetx::MongoDB::get_pds()->find_one({"_id" => $oid});
        $logger->debug("KPDS for ($ken): ", sub {Dumper($kpds)});
    } else {
        my $session_id = Kynetx::Session::session_id($session);
        return merror("No KEN associated to $session_id");
    }
}

sub run_function {
    my ($req_info,$session,$function,$args) =@_;
    my $logger = get_logger();
    $logger->debug("PDS request: $function");
    my $f = $funcs->{$function};
    if ( defined $f ) {
        return $f->( $req_info, $session, $function, $args);
    } else {
        $logger->debug("Function $function not defined");
    }
    return 1;
}
1;