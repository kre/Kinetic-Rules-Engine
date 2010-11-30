package Kynetx::Persistence::Application;
# file: Kynetx/Persistence/Application.pm
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
    get
    put
    get_created
    delete
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

use constant COLLECTION => "appdata";

sub touch {
    my ($rid,$var,$ts) = @_;
    my $logger = get_logger();
    my $key = {
        "rid" => $rid,
        "key" => $var};
    return Kynetx::MongoDB::touch_value(COLLECTION,$key,$ts)->{"value"};
}

sub get {
    my ($rid,$var,$get_ts) = @_;
    my $logger = get_logger();
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $value = Kynetx::MongoDB::get_value(COLLECTION,$key);
    $logger->debug("GET ($var) using (",sub {Dumper($key)},") returns: ", sub {Dumper($value)});
    if ($get_ts) {
        return $value->{"created"};
    } else {
        return $value->{"value"};
    }

}

sub pop {
    my ($rid,$var,$direction) = @_;
    my $logger = get_logger();
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $result = Kynetx::MongoDB::pop_value(COLLECTION,$key,$direction);
    if ($result) {
        return $result;
    } else {
        return undef;
    }
}

sub push {
    my ($rid,$var,$val,$as_trail) = @_;
    my $logger = get_logger();
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $value = {
        "rid"  => $rid,
        "key"  => $var,
        "value"=> $val,
    };
    my $success = Kynetx::MongoDB::push_value(COLLECTION,$key,$value,$as_trail);
    return $success;
}

sub get_created {
    my ($rid,$var) = @_;
    return get($rid,$var,1);
}




sub put {
    my ($rid,$var,$val,$expires) = @_;
    my $logger = get_logger();
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $value = {
        "rid"  => $rid,
        "key"  => $var,
        "value"=> $val,
    };
    $logger->debug("Store to $var: ",sub{Dumper($value)});
    my $success = Kynetx::MongoDB::update_value(COLLECTION,$key,$value,1);
    $logger->debug("Failed to upsert ", sub {Dumper($key)}) unless ($success);
    return $success;
}

sub delete {
    my ($rid,$var) = @_;
    my $logger = get_logger();
    my $key = {
        "rid" => $rid,
        "key" => $var};
    my $success = Kynetx::MongoDB::delete_value(COLLECTION,$key);
    return $success;

}


1;