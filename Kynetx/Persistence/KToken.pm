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
    set_token
    token_query
    KTOKEN
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

sub token_query {
    my ($var) = @_;
    my $logger = get_logger();
    my $parent = (caller(1))[3];
    $logger->trace("Called from -$parent- with ",sub {Dumper($var)});
    return Kynetx::MongoDB::get_value(COLLECTION,$var);
}

sub get_token {
    my ($session, $rid,$domain) = @_;
    my $logger = get_logger();
    my $session_id = Kynetx::Session::session_id($session);
    $domain = $domain || "web";
    my $var;
    $logger->trace("Get token for session: $session_id");
    # There might be other ways to find a token for other endpoint domains
    if ($domain eq "web") {
        # Check mongo.tokens for any tokens for a matching sessionid
        $var = {
            "endpoint_id" => $session_id,
        };
    } else {
        # default is to check mongo for session

    }
    return token_query($var);
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
        $logger->trace("Token is valid");
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
    $logger->info("Deleting token $ktoken");
    # We store the token in cache to quickly get the ken
    if (defined $session_id) {
    	my $additional_ref = COLLECTION .$session_id;
    	Kynetx::Memcached::flush_cache($additional_ref);
    }
   
}


1;