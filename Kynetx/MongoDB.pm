package Kynetx::MongoDB;
# file: Kynetx/MongoDB.pm
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
use LWP::UserAgent;
use Data::Dumper;
use MongoDB qw(:all);


use Kynetx::Configure;
use Kynetx::Json;




use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
init
get_mongo
mongo
get_value
put_value
touch_value
update_value
get_collection
delete_value
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

our $MONGO;
our $MONGO_SERVER = "127.0.0.1";
our $MONGO_PORT = "27017";
our $MONGO_DB = "kynetx";

use constant SAFE => 1;

sub init {
    my $logger = get_logger();

    $MONGO_SERVER = Kynetx::Configure::get_config('MONGO_HOST') || $MONGO_SERVER;
    $MONGO_PORT = Kynetx::Configure::get_config('MONGO_PORT') || $MONGO_PORT;
    $MONGO_DB = Kynetx::Configure::get_config('MONGO_DB') || $MONGO_DB;

    my @hosts = split(",",$MONGO_SERVER);
    my @h_p = map {$_ . ":".$MONGO_PORT} @hosts;
    my $mongo_url = "mongodb://" . join (",",@h_p);



    $logger->debug("Initializing MongoDB connection: $mongo_url");
    $MONGO = MongoDB::Connection->new(host => $mongo_url);

}

sub get_mongo {
    #return $MONGO->kynetx();
    init unless $MONGO;
    my $db = $MONGO->get_database($MONGO_DB);
    return $db;
}

sub get_collection {
    my ($name) = @_;
    my $db = get_mongo();
    return $db->get_collection($name);
}

sub get_value {
    my ($collection,$var) = @_;
    my $logger = get_logger();
    my $c = get_collection($collection);
    if ($c) {
        my $result = $c->find_one($var);

        if ($result->{"serialize"}) {
            my $ast = Kynetx::Json::jsonToAst($result->{"value"});
            $logger->debug("Found a ", ref $ast," to deserialize");
            $result->{"value"} = $ast;
        }

        return $result;

    } else {
        $logger->info("Could not access collection: $collection");
        return undef;
    }
}

sub touch_value {
    my ($collection,$var,$ts) = @_;
    my $logger = get_logger();
    my $timestamp;
    if (defined $ts) {
        $timestamp = $ts->epoch;
    } else {
        $timestamp = DateTime->now->epoch;
    }
    my $result = get_value($collection,$var);
    my $status;
    if (defined $result->{"value"}) {
        my $oid = $result->{"_id"};
        my $c = get_collection($collection);
        $status = $c->update($var,{'$set' => {"created" => $timestamp}});
    } else {
        my $val = {%$var};
        $val->{"value"} =0,
        $status = update_value($collection,$var,$val,1,0);
    }
    $logger->warn("Failed to update timestamp in $collection for: ", sub {Dumper($var)}) unless ($status);
    return get_value($collection,$var);
}

sub update_value {
    my ($collection,$var,$val,$upsert,$multi) = @_;
    my $logger = get_logger();
    my $serialize = 0;
    my $timestamp = DateTime->now->epoch;
    if (ref $val->{"value"} eq "HASH") {
        $serialize = 1;
        my $json = Kynetx::Json::astToJson($val->{"value"});
        $val->{"value"} = $json;
        $logger->debug("Store (serialized): ",$val->{"value"});
    }
    $val->{"serialize"} = $serialize;
    $val->{"created"}   = $timestamp;
    $upsert = ($upsert) ? 1 : 0;
    $multi = ($multi) ? 1 : 0;
    my $c = get_collection($collection);
    my $status = $c->update($var,$val,{"upsert" => $upsert,"multiple" => $multi, "safe" => SAFE});
    $logger->warn("Failed to insert in $collection: ", sub {Dumper($val)}) unless ($status);
    return $status;
}

sub mongo_error {
    my $database = get_mongo();
    return $database->last_error();
}

sub delete_value {
    my ($collection,$var) = @_;
    my $logger = get_logger();
    my $c = get_collection($collection);
    my $success = $c->remove($var,{"safe" => 1});
    if (!$success ) {
        $logger->debug("Delete error: ", mongo_error());
    }
}



1;

