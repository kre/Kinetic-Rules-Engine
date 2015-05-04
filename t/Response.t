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
use warnings;

use Test::More;
use Test::Deep;
use Test::WWW::Mechanize;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

use Kynetx::Test qw/:all/;
use Kynetx::Response qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Persistence::Ruleset qw/:all/;
use Kynetx::Directives;



use Kynetx::FakeReq qw/:all/;
use Apache2::HookRun ();
use Apache2::RequestUtil ();
use Apache2::RequestRec ();

use Data::Dumper;
$Data::Dumper::Indent = 1;






my $r = Kynetx::Test::configure();
#my $r = Apache2::RequestUtil::request();
$r->the_request("http://foo.com");

#$r = new Apache2::RequestRec;

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);
my $random = int(rand 10000000000);
$my_req_info->{'eid'} = $random;

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');

my $dn = "http://$platform/blue/event";
my $mech = Test::WWW::Mechanize->new(cookie_jar => undef);
my $url;
my $result;
my $response;
my $expected;


my $test_count = 0;

my $realm = 'test';
my $dd = Kynetx::Response->create_directive_doc( $my_req_info->{'eid'} );

my $content = '<h1>Foo</h1><p>the bear</b>';
my $krl_src = <<_KRL_;
send_raw("text/html") with
  content = "$content";
_KRL_

my $krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
my $js = Kynetx::Actions::build_one_action(
	    $krl,
	    $my_req_info, 
	    $dd,
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');

my $description = "Check the action doesn't return JS";    
cmp_deeply($js,'',$description);
$test_count++;

$description = "Set the directive document";
cmp_deeply($dd->{'directives'}->[0]->{'options'}->{'content'},$content,$description);
$test_count++;

$description = "Test send_raw html";
$url = $dn . "/web/pageview/a144x156";
$expected = re(qr/stickman\.gif/);
$response = $mech->get($url);
$result = $mech->content();
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Test send_raw text/plain";
$url = $dn . "/web/pageview/a144x157";
$expected = re(qr/If the foo sits, wear it/);
$response = $mech->get($url);
$result = $mech->content();
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Test send_raw json";
$url = $dn . "/web/pageview/a144x158";
$expected = '
        {
            \'foo\' : [\'a\', 1, 3.14],
            \'bar\' : \'string\',
            \'baz\' : {
                \'sum\' : \'foobarbaz\'   
            }
        }
    ';
$response = $mech->get($url);
$result = $mech->content();
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Test send_raw json";
$url = $dn . "/web/pageview/a144x159";
$expected = '
       myFunc( {
            \'foo\' : [\'a\', 1, 3.14],
            \'bar\' : \'string\',
            \'baz\' : {
                \'sum\' : \'foobarbaz\'   
            }
        })
    ';
$response = $mech->get($url);
$result = $mech->content();
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Test send_raw 404";
$url = $dn . "/web/pageview/a144x161";
$expected = re(qr/Dammit Jim/);
$response = $mech->get($url);
$result = $mech->content();
cmp_deeply($result,$expected,$description);
$test_count++;

$description = "Test send_raw REDIRECT";
$url = $dn . "/web/pageview/a144x160";
$expected = re(qr/<h2>Introducing Social Products<\/h2>/);
$response = $mech->get($url);
$result = $mech->content();
cmp_deeply($result,$expected,$description);
$test_count++;

done_testing($test_count);



1;


