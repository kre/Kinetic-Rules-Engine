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
use lib qw(/web/lib/perl /web/lib/perl/t);
use strict;

no warnings 'recursion';

use Test::More;
use Test::LongString;
use Test::Deep;

use APR::URI qw/:all/;
use APR::Pool ();
use LWP::Simple;
use XML::XPath;
use LWP::UserAgent;
use JSON::XS;
use Cache::Memcached;
use Apache::Session::Memcached;
use DateTime;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

my $logger = get_logger();

use Kynetx::Test qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Persistence::KXDI;

use Kynetx::FakeReq qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Terse = 1;

use ExprTests qw/:all/;

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my $r = new Kynetx::FakeReq();
$r->_delete_session();
my $session = process_session($r);

my $krl_src;
my $rid = 'abcd1234';
my $rule_name = 'foo';
my $test_count=0;
my $result;

# get a random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $secret = $DICTIONARY[rand(@DICTIONARY)];
chop $secret;

$rid = $DICTIONARY[rand(@DICTIONARY)];
chop $rid;

my $random = $DICTIONARY[rand(@DICTIONARY)];
chop $random;

my $isub = $DICTIONARY[rand(@DICTIONARY)];
chop $isub;

# $dken is an anonymous ken that I will clean out after the tests
my $dken = Kynetx::Persistence::KEN::get_ken($session,$rid);

# Configure the XDI account
my $oid = MongoDB::OID->new();
my $xdi = Kynetx::Configure::get_config('xdi');
my $inumber = $xdi->{'users'}->{'inumber'} . '!'. $oid->to_string();
my $endpoint = $xdi->{'users'}->{'endpoint'} . $inumber;
my $iname = $xdi->{'users'}->{'iname'} . '*' . $isub;

my $struct = {
	'endpoint' => $endpoint,
	'inumber'  => $inumber,
	'iname'    => $iname,
	'secret'   => $secret
};

Kynetx::Persistence::KXDI::put_xdi($dken,$struct);
my $kxdi = Kynetx::Persistence::KXDI::get_xdi($dken);

# create the xdi account
Kynetx::Persistence::KXDI::provision_xdi_for_kynetx($dken);



Kynetx::Persistence::KXDI::add_link_contract($dken,$rid);
$result = Kynetx::Persistence::KXDI::check_link_contract($dken,$rid);

$logger->debug("root link contract: $result");
#die;# unless $result;


my ($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
my $subject = "$inumber+secret_phrase";
my $str = "($subject/!/(data:,$random))";
$msg->add($str);
$result = $c->post($msg);

$logger->debug("Add message: ",sub {Dumper($result)});

($c,$msg) = Kynetx::Persistence::KXDI::xdi_message($kxdi);
$msg->get($subject);
$result = $c->post($msg);
$logger->debug("Get message: ",sub {Dumper($result)});

my $my_req_info = Kynetx::Test::gen_req_info($rid,
    {#'ip' => '128.187.16.242', # Utah (BYU)
     'referer' => 'http://www.google.com/search?q=free+mobile+calls&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a',
     'caller' => 'http://www.windley.com/archives/2008/07?q=foo',
     'kvars' => '{"foo": 5, "bar": "fizz", "bizz": [1, 2, 3]}',
     'foozle' => 'Foo',
     "$rid:datasets" => "aaa,aaawa,ebates"
    }
   );
my $rule_env = Kynetx::Test::gen_rule_env();
   


my @expr_testcases;

sub add_expr_testcase {
      my($krl,$type,$js,$expected,$diag) = @_;

      push(@expr_testcases, {'krl' => $krl,
			     'type' => $type,
			     'expected_js' => $js,
			     'expected_val' => $expected,
			     'diag' => $diag,
			    });
    }

$iname = "=mark";

$krl_src = <<_KRL_;
<[$subject]>
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
     undef,
     mk_expr_node('hash', {
    	$subject . '/!' => mk_expr_node('array',[mk_expr_node('str',$random)])
    }),
    0);


$krl_src = <<_KRL_;
<[()]>
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
     undef,
     mk_expr_node('null', '__undef__'),
    0);
################### Above this line
ok(1);
$test_count++;

foreach my $case (@expr_testcases ) {
	diag("KRL = ", Dumper($case->{'krl'})) if $case->{'diag'};
	my ($e,$val);
	if ($case->{'type'} eq 'expr') {
    	$val = Kynetx::Parser::parse_expr($case->{'krl'});
    	diag("AST = ", Dumper($val)) if $case->{'diag'};
	    $e = eval_expr($val,
			   $rule_env,
			   $rule_name,
			   $my_req_info,
			   $session);
	}
	diag("Expr = ", Dumper($e)) if $case->{'diag'};
	my $result = cmp_deeply($e,
		    $case->{'expected_val'},
		    "Evaling " . $case->{'krl'});
	die unless $result;
	$test_count++;
	
}

#goto ENDY;

# Clean up anonymous KENS
my $ken_struct = {
	"ken" => $dken
};
$result = Kynetx::MongoDB::get_singleton('kens',$ken_struct);
if (defined $result && ref $result eq "HASH") {
	my $username = $result->{'username'};
	if ($username =~ m/^_/) {
		$logger->debug("Ken is anonymous");
		Kynetx::Persistence::KEN::delete_ken($dken);
		Kynetx::Persistence::KPDS::delete_kpds($dken);
		Kynetx::Persistence::KXDI::delete_xdi($dken);
	}	
}

ENDY:

session_cleanup($session);


done_testing($test_count);


1;


