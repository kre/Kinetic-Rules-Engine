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
use Test::LongString;
use Test::Deep;

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


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $json;
my $deserialized;
my $logger = get_logger();


my $test_count = 0;

my $pe1 = Kynetx::Events::Primitives->new();

sleep 1; # that $pe2 has a different timestamp

my $pe2 = Kynetx::Events::Primitives->new();
#Log::Log4perl->easy_init($DEBUG);

$json = JSON::XS::->new->convert_blessed(1)->utf8(1)->encode($pe1);

$logger->debug("PE1: $json");

$deserialized = Kynetx::Events::Primitives->unserialize($json);

cmp_deeply($deserialized,$pe1,"To JSON and Back");
$test_count++;

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

ok(! $pe1->isa('pageview', 'web'), '$pe1 not a pageview');
$test_count++;

$pe1->set_type('pageview');
$pe1->set_domain('web');

ok($pe1->isa('pageview', 'web'), '$pe1 is a pageview');
$test_count++;

$json = $pe1->serialize();
$logger->debug("After \$pe1 serialize: $json");
$deserialized = Kynetx::Events::Primitives->unserialize($json);
is_deeply($deserialized,$pe1,'$pe1 serialized and back');
$test_count++;


$pe2->pageview('http://www.windley.com/foo/bar.html');

ok($pe2->isa('pageview', 'web'), '$pe2 is a pageview');
$test_count++;

is($pe2->url, 'http://www.windley.com/foo/bar.html', 'pageview url is correct');
$test_count++;


$json = $pe2->serialize();
$deserialized = Kynetx::Events::Primitives->unserialize($json);
is_deeply($deserialized,$pe2,'$pe2 serialized and back');
$test_count++;

my $pe4 = Kynetx::Events::Primitives->new();
$pe4->click('foo_id');

ok($pe4->isa('click', 'web'), '$pe4 is a click');
$test_count++;

is($pe4->element, 'foo_id', 'click element is correct');
$test_count++;

$json = $pe4->serialize();
$deserialized = Kynetx::Events::Primitives->unserialize($json);
is_deeply($deserialized,$pe4,'$pe4 serialized and back');
$test_count++;


my $pe5 = Kynetx::Events::Primitives->new();
$pe5->change('foo_id');

ok($pe5->isa('change', 'web'), '$pe5 is a change');
$test_count++;

is($pe5->element, 'foo_id', 'change element is correct');
$test_count++;

$json = $pe5->serialize();
$deserialized = Kynetx::Events::Primitives->unserialize($json);
is_deeply($deserialized,$pe5,'$pe5 serialized and back');
$test_count++;


my $pe6 = Kynetx::Events::Primitives->new();
$pe6->submit('foo_id');

ok($pe6->isa('submit', 'web'), '$pe6 is a submit');
$test_count++;

is($pe6->element, 'foo_id', 'submit element is correct');
$test_count++;

$json = $pe6->serialize();
$deserialized = Kynetx::Events::Primitives->unserialize($json);
is_deeply($deserialized,$pe6,'$pe6 serialized and back');
$test_count++;


done_testing($test_count);


1;


