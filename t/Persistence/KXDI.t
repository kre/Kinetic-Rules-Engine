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

no warnings ('uninitialized');

use Test::More;
use Test::Deep;
use Data::Dumper;
use MongoDB;
use Apache::Session::Memcached;
use APR::Pool ();

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

use Kynetx::Test qw/:all/;
use Kynetx::Configure;
use Kynetx::Memcached qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::MongoDB;
use Kynetx::Persistence::KEN qw/:all/;
use Kynetx::Persistence::KXDI qw/:all/;
use Kynetx::Persistence::KToken qw(:all);
use Kynetx::Modules;
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

my $rid = "xdi_test";
my $frid = "not_cs_test";
my $static_token = "247fe820-1782-012e-dbbc-525445a0543c";
my $srid = "token_tests";
my $ubx_bad = "TESTTOKEN_NEVERDELETE";
my $ubx_ken = "4d544a412c15431307000001";
my $rule_name = "cr_xdi";
my $temp_token;
my $tsession;
my $from;
my $to_graph;
my $args;

my $r = new Kynetx::FakeReq();
$r->_delete_session();
$logger->debug("r: ", sub {Dumper($r)});

my $session = process_session($r);


# Set the session, find a KEN
$r = new Kynetx::FakeReq();
$r->_set_session($tsession);

my $req_info = Kynetx::Test::gen_req_info($rid);
my $rule_env = Kynetx::Test::gen_rule_env();

# get a random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $frid = $DICTIONARY[rand(@DICTIONARY)];
chop $frid;

my $secret = $DICTIONARY[rand(@DICTIONARY)];
chop $secret;

my $isub = $DICTIONARY[rand(@DICTIONARY)];
chop $isub;

$session = process_session($r);
$description = "Find KEN from session";
my $session_ken = Kynetx::Persistence::KEN::get_ken($session,$frid);
$logger->debug("Ken session: ",$session_ken);
testit($session_ken,re($ken_re),$description,0);

# Configure the XDI account
my $oid = MongoDB::OID->new();
my $xdi = Kynetx::Configure::get_config('xdi');
my $inumber = $xdi->{'users'}->{'inumber'} . '!'. $oid->to_string();
my $endpoint = $xdi->{'users'}->{'endpoint'} . $inumber;
my $iname = $xdi->{'users'}->{'iname'} . '*' . $isub;

my $raw_xdi;
my $raw_response;
my $raw_endpoint;

my $struct = {
	'endpoint' => $endpoint,
	'inumber'  => $inumber,
	'iname'    => $iname,
	'secret'   => $secret
};

Kynetx::Persistence::KXDI::put_xdi($session_ken,$struct);

$description = "Get the XDI record for $session_ken";
my $expected = {
	'endpoint' => re(/https?:/),
	'inumber'  => re(/^!=.+/),
	'iname'    => $iname,
	'secret'   => $secret
};

$result = Kynetx::Persistence::KXDI::get_xdi($session_ken);
testit($result,$expected,$description,0);
$logger->debug("Tester: ", sub {Dumper($result)});

Kynetx::Persistence::KXDI::put_inumber($session_ken,$inumber);

Kynetx::Persistence::KXDI::put_endpoint($session_ken,$endpoint);

$expected->{'inumber'} = $inumber;
$expected->{'endpoint'} = $endpoint; 

$description = "Test put inumber";
$result = Kynetx::Persistence::KXDI::get_inumber($session_ken);
testit($result,$inumber,$description,0);

$description = "Test put endpoint";
$result = Kynetx::Persistence::KXDI::get_endpoint($session_ken);
testit($result,$endpoint,$description,0);

$description = "Test cache busted";
$result = Kynetx::Persistence::KXDI::get_xdi($session_ken);
testit($result,$expected,$description,0);

$description = "Test cache";
my $kxdi = Kynetx::Persistence::KXDI::get_xdi($session_ken);
testit($kxdi,$result,$description,0);

$description = "Check registry";
my $xdi_exists = Kynetx::Persistence::KXDI::check_registry_for_inumber($inumber);
$logger->debug("Check reg: ", sub {Dumper($result)});

SKIP: {
	skip "$inumber already exists in registry", 9 if $xdi_exists;
	
#	$description = "Add a registry entry to /registry";
#	$result = Kynetx::Persistence::KXDI::provision_xdi_for_kynetx($session_ken);
#	testit($result,1,$description,0);
	
####### Use module function call to create an XDI account
	$args = [];
	$description = "Add a registry entry to /registry";
	$result = Kynetx::Expressions::den_to_exp(
		Kynetx::Modules::eval_module(
			$req_info,
			$rule_env,
			$session,
			$rule_name,
			"xdi",
			"create_new_graph",
			$args
		)
	);
	testit($result,1,$description,0);
	
		
	my ($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
	$logger->debug("Message to user xdi: ",$msg->to_string );
	$logger->debug("KXDI: ",sub {Dumper($kxdi)} );
	$msg->get('()');
	$raw_xdi = $msg->to_string;
	$result = $c->post($msg);
	$raw_response = $result;
	$raw_endpoint = $kxdi->{'endpoint'};
	$logger->debug("msg resp: ",sub {Dumper($result)} );
	
	my $not_created = $result ? 0 : 1;
	$description = "Account created";
	testit($not_created,0,$description,0);
	
	$description = "Try raw xdi request";
	$result = Kynetx::Persistence::KXDI::_raw($raw_endpoint,$raw_xdi);
	testit($result,$raw_response,$description,0);
	
	
	SKIP: {
		skip "Account was not created",8 if $not_created;		
		
		$description = "Account created (query response)";
		testit(ref $result, 'HASH',$description,0);
		
		$description = "Account created (correct inumber)";
		testit($result->{'$do/$is$do'},[$inumber],$description,0);

		$description = "check a link contract for root";
		$result = Kynetx::Persistence::KXDI::check_link_contract($session_ken);
		testit($result,1,$description,0);

		$description = "Query for an XDI account that doesn't exist";
		$result = Kynetx::Persistence::KXDI::get_xdi('fakeken');
		testit($result,undef,$description,0);
		
		
		$description = "check a link contract for fake ruleset";
		$result = Kynetx::Persistence::KXDI::check_link_contract($session_ken,$frid);
		testit($result,0,$description,0);
				

		$description = "add a link contract for fake ruleset";
		$args = [];
		$result = Kynetx::Expressions::den_to_exp(
			Kynetx::Modules::eval_module(
				$req_info,
				$rule_env,
				$session,
				$rule_name,
				"xdi",
				"set_link_contract",
				$args
			)
		);
		
		
		$description = "Check that link contract was created";
		$result = Kynetx::Persistence::KXDI::check_link_contract($session_ken,$rid);
		testit($result,1,$description,0);
		
		$description = "Delete xdi graph and registry";
		$result = Kynetx::Persistence::KXDI::delete_xdi($session_ken);
		testit($result,1,$description,0);
		
	}
	
}





# Clean up anonymous KENS
my $ken_struct = {
	"ken" => $session_ken
};
$result = Kynetx::MongoDB::get_singleton('kens',$ken_struct);
if (defined $result && ref $result eq "HASH") {
	my $username = $result->{'username'};
	if ($username =~ m/^_/) {
		$logger->debug("Ken is anonymous");
		#Kynetx::Persistence::KXDI::delete_xdi($session_ken);
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
    my $result = cmp_deeply($got,$expected,$description);
    die unless $result;
}
ENDY:
session_cleanup($session);

plan tests => $num_tests;
1;
