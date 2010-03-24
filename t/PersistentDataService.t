#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;

use Apache::Session::Memcached;
use Apache2::Const;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use JSON::XS;

use Test::WWW::Mechanize;

use LWP::UserAgent;



# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::PersistentDataService qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';
my $sid = 'e8e618aa6ea06e2c59f8e1f74fecb719';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid, {'sid' => $sid});

my $test_count = 0;

# check the server now

my $dn = "http://127.0.0.1/pds";


my $mech = Test::WWW::Mechanize->new();


my $skippable = 1;

SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "$dn/version/$rid";
#    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", $skippable if (! $response->is_success);

    # test version function
    my $url_version_1 = "$dn/version/$rid";
    #diag "Testing console with $url_version_1";
    $mech->get_ok($url_version_1);
    is($mech->content_type(), 'text/html');

    $mech->title_is('KNS Version');

    $mech->content_like('/number\s+\d+/');
    $test_count += 4;

    # get val
    my $url_version_2 = "$dn/get/$rid/$sid/my_count/";
    diag "Testing console with $url_version_2";
    $mech->get_ok($url_version_2);
    is($mech->content_type(), 'text/javascript');
#    diag "Found ", $mech->content();
    is_deeply(JSON::XS->new->utf8->decode($mech->content()), {'my_count' => 2}, "got a single val");
    $test_count += 3;


    # post #
    my $url_version_3 = "$dn/store/$rid/$sid/a_count/";
#    diag "Testing console with $url_version_3";
    $mech->post_ok($url_version_3, ['val' => 5]);
    is($mech->content_type(), 'text/javascript');
#    diag "Found ", $mech->content();
    is_deeply(JSON::XS->new->utf8->decode($mech->content()), {'a_count' => 5}, "stored a single val");

    $test_count += 3;


    # post different #
    my $url_version_4 = "$dn/store/$rid/$sid/a_count/";
#    diag "Testing console with $url_version_4";
    $mech->post_ok($url_version_4, ['val' => 10]);
    is($mech->content_type(), 'text/javascript');
#    diag "Found ", $mech->content();
    is_deeply(JSON::XS->new->utf8->decode($mech->content()), {'a_count' => 10}, "stored a single val");

    $test_count += 3;

    # post json
    my $url_version_4 = "$dn/store/$rid/$sid/a_count/";
#    diag "Testing console with $url_version_4";
    $mech->post_ok($url_version_4, [val => '{"foo": {"type": "required", "level": "user"}}']);
    is($mech->content_type(), 'text/javascript');

    # renew session
    $session = Kynetx::Test::gen_session($r, $rid, {'sid' => $sid});

    my $a_count = session_get($rid,$session,'a_count');

    is($a_count->{'foo'}->{'type'}, 'required', "We stored it and can get it back");

    $test_count += 3;

  }


session_cleanup($session);
done_testing($test_count);



1;


