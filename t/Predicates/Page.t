#!/usr/bin/perl -w

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;
use Cache::Memcached;
use Apache::Session::Memcached;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Page qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $preds = Kynetx::Predicates::Page::get_predicates();
my @pnames = keys (%{ $preds } );


my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args



my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();


my $session = Kynetx::Test::gen_session($r, $rid);
my $session_id = Kynetx::Session::session_id($session);
my $options = {'g_id' => $session_id};
my $my_req_info = Kynetx::Test::gen_req_info($rid,$options);


my %rule_env = ();



# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


##
## page:url
##

is(get_pageinfo($my_req_info, 'url', ['hostname']),
   'www.windley.com',
   'page:url hostname');

is(get_pageinfo($my_req_info, 'url', ['domain']),
   'windley.com',
   'page:url domain');


is(get_pageinfo($my_req_info, 'url', ['tld']),
   'com',
   'page:url tld');

is(get_pageinfo($my_req_info, 'url', ['protocol']),
   'http',
   'page:url protocol');

is(get_pageinfo($my_req_info, 'url', ['query']),
   undef,
   'page:url query');

is(get_pageinfo($my_req_info, 'url', ['path']),
   "/",
   'page:url path');

is(get_pageinfo($my_req_info, 'url', ['port']),
   80,
   'page:url path');

# new domain
#diag "testing with two element hostname";
$my_req_info->{'caller_url'} = undef; # reset
$my_req_info->{'caller'} = 'http://windley.com';
is(get_pageinfo($my_req_info, 'url', ['hostname']),
   'windley.com',
   'page:url windley.com hostname');

is(get_pageinfo($my_req_info, 'url', ['domain']),
   'windley.com',
   'page:url windley.com domain');


is(get_pageinfo($my_req_info, 'url', ['tld']),
   'com',
   'page:url windley.com tld');

is(get_pageinfo($my_req_info, 'url', ['protocol']),
   'http',
   'page:url windley.com protocol');

is(get_pageinfo($my_req_info, 'url', ['query']),
   undef,
   'page:url windley.com query');

is(get_pageinfo($my_req_info, 'url', ['path']),
   undef,
   'page:url windley.com path');

is(get_pageinfo($my_req_info, 'url', ['port']),
   80,
   'page:url windley.com path');


# new domain with path and query
#diag "testing with path and query";
$my_req_info->{'caller_url'} = undef; #reset
$my_req_info->{'caller'} = 'http://www.windley.com/foo?x=y&foog=goog';
is(get_pageinfo($my_req_info, 'url', ['hostname']),
   'www.windley.com',
   'page:url path & query hostname');

is(get_pageinfo($my_req_info, 'url', ['domain']),
   'windley.com',
   'page:url path & query domain');


is(get_pageinfo($my_req_info, 'url', ['tld']),
   'com',
   'page:url path & query tld');

is(get_pageinfo($my_req_info, 'url', ['protocol']),
   'http',
   'page:url path & query protocol');

is(get_pageinfo($my_req_info, 'url', ['query']),
   'x=y&foog=goog',
   'page:url path & query query');

is(get_pageinfo($my_req_info, 'url', ['path']),
   '/foo',
   'page:url path & query path');

is(get_pageinfo($my_req_info, 'url', ['port']),
   80,
   'page:url path & query path');


my $params = {
   'msg' => 'Hello World!',
   'caller' => 'http://www.windley.com/foo?x=y&foog=goog'
 };


is_deeply(get_pageinfo($my_req_info, 'params', []), $params, "Params gives all");

is(get_pageinfo($my_req_info, 'env', ['g_id']),
   $session_id,
   'event:env("g_id")');

done_testing(23 + int(@pnames));


1;


