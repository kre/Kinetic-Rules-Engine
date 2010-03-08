#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;

use Data::UUID;



# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Events::Primitives qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);


my $test_count = 0;

my $pe1 = Kynetx::Events::Primitives->new();

sleep 1; # that $pe2 has a different timestamp

my $pe2 = Kynetx::Events::Primitives->new();


like($pe1->timestamp(), qr/\d+/, "timestamp is a number");
$test_count++;


ok($pe2->timestamp() > $pe1->timestamp(), "timestamp monotonic");
$test_count++;

like($pe1->guid(), qr/[A-F0-9-]+/, "GUID has correct characters");
$test_count++;

ok($pe1->happened_before($pe2), "$pe1 happened before $pe2");
$test_count++;

ok($pe1->different_than($pe2), '$pe1 not the same as $pe2');
$test_count++;

ok(! $pe1->different_than($pe1), '$pe1 the same as $pe1');
$test_count++;

my $pe3 = $pe1;
ok(! $pe1->different_than($pe3), '$pe1 the same as $pe3');
$test_count++;

ok(! $pe1->isa('pageview'), '$pe1 not a pageview');
$test_count++;

$pe1->set_type('pageview');

ok($pe1->isa('pageview'), '$pe1 is a pageview');
$test_count++;

$pe2->pageview('http://www.windley.com/foo/bar.html');

ok($pe2->isa('pageview'), '$pe2 is a pageview');
$test_count++;

is($pe2->url, 'http://www.windley.com/foo/bar.html', 'paaeview url is correct');
$test_count++;

my $pe4 = Kynetx::Events::Primitives->new();
$pe4->click('foo_id');

ok($pe4->isa('click'), '$pe4 is a click');
$test_count++;

is($pe4->element, 'foo_id', 'click element is correct');
$test_count++;


my $pe5 = Kynetx::Events::Primitives->new();
$pe5->change('foo_id');

ok($pe5->isa('change'), '$pe5 is a change');
$test_count++;

is($pe5->element, 'foo_id', 'change element is correct');
$test_count++;



done_testing($test_count);


1;


