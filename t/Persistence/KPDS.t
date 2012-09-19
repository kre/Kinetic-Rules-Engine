#!/usr/bin/perl -w
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
use lib qw(/web/lib/perl);
use strict;
use utf8;

use Test::More;
use Test::Deep;
use Data::Dumper;
use MongoDB;
use Apache::Session::Memcached;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
Log::Log4perl->easy_init($TRACE);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Persistence::KEN qw/:all/;
use Kynetx::Persistence::KPDS qw/:all/;
use Kynetx::Persistence::KToken qw(:all);
my $logger = get_logger();
my $num_tests = 0;
my $result;


# configure KNS
Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();
my $ken_re = qr([0-9|a-f]{16});
my $ken;
my $description;

my $rid = "cs_test";
my $frid = "not_cs_test";
my $static_token = "247fe820-1782-012e-dbbc-525445a0543c";
my $srid = "token_tests";
my $ubx_bad = "TESTTOKEN_NEVERDELETE";
my $ubx_ken = "4d544a412c15431307000001";
my $temp_token;
my $tsession;
my $result;

my $r = new Kynetx::FakeReq();
$r->_delete_session();
$logger->debug("r: ", sub {Dumper($r)});

my $session = process_session($r);


# Set the session, find a KEN
$r = new Kynetx::FakeReq();
$r->_set_session($tsession);

$session = process_session($r);
$description = "Find KEN from session";
my $session_ken = Kynetx::Persistence::KEN::get_ken($session,$frid);
$logger->debug("Ken session: ",$session_ken);
testit($session_ken,re($ken_re),$description,0);

$description = "Insert a KPDS value";
my $hash_path = ['pds_type'];
my $value = 'xdi';
$result = Kynetx::Persistence::KPDS::put_kpds_element($session_ken,$hash_path,$value);
testit($result,1,$description,0);

$description = "Get a KPDS value";
$result = Kynetx::Persistence::KPDS::get_kpds_element($session_ken,$hash_path);
testit($result,$value,$description,0);
$logger->debug("Got: ", sub {Dumper($result)});

$description = "Delete a KPDS value";
$result = Kynetx::Persistence::KPDS::delete_kpds_element($session_ken,$hash_path);


$description = "Check database for deleted value";
$result = Kynetx::Persistence::KPDS::get_kpds_element($session_ken,$hash_path);
testit($result,undef,$description,0);
$logger->debug("Got: ", sub {Dumper($result)});


# Clean up anonymous KENS
my $ken_struct = {
	"ken" => $session_ken
};
$result = Kynetx::MongoDB::get_singleton('kens',$ken_struct);
if (defined $result && ref $result eq "HASH") {
	my $username = $result->{'username'};
	if ($username =~ m/^_/) {
		$logger->debug("Ken is anonymous");
		Kynetx::Persistence::KEN::delete_ken($session_ken);
		Kynetx::Persistence::KPDS::delete_kpds($session_ken);
	}
	
}


$logger->debug("Ken struct: ", sub {Dumper($result)});

sub testit {
    my ($got,$expected,$description,$debug) = @_;
    if ($debug) {
        $logger->debug("$description : ",sub {Dumper($got)});
    }
    $num_tests++;
    cmp_deeply($got,$expected,$description);
}
ENDY:
session_cleanup($session);

plan tests => $num_tests;
1;
