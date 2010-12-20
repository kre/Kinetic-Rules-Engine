#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Apache2::Const;
use APR::URI;
use APR::Pool;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;

use Kynetx::Test qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Predicates::KPDS qw/:all/;
use Kynetx::JavaScript qw(mk_js_str gen_js_var);
use Kynetx::Rules qw(:all);

use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;


my $preds = Kynetx::Predicates::KPDS::get_predicates();
my @pnames = keys (%{ $preds } );

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

# these are KRE generic consumer tokens
$my_req_info->{$rid.':key:kpds'} = 
  {'consumer_secret' => 'iS1jmmJ6WRudiA8denmt3b9mKsvz8EEcmt42yoSl',
   'consumer_key' => 'xVzxZSd7ArBV3at6YOnz'
  };

$my_req_info->{"$rid:ruleset_name"} = "cs_test";
$my_req_info->{"$rid:name"} = "cs_test";
$my_req_info->{"$rid:author"} = "Phil Windley";
$my_req_info->{"$rid:description"} = "This is a test rule";

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $logger = get_logger();

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}

my $test_count = 0;

# before we insert access tokens into session keys
isnt(Kynetx::Predicates::KPDS::authorized($my_req_info, $rule_env, $session, $rule_name,'',''), 
     "random calls aren't authorized");
$test_count++;

contains_string(Kynetx::Predicates::KPDS::authorize($my_req_info, $rule_env, $session, {},{}), "https://accounts.kynetx.com/oauth/authorize?oauth_token=", "authorize gets a URL");
$test_count++;


# clear out now for rerunning
session_delete($rid, $session, 'kpds:access_tokens');

done_testing($test_count + int(@pnames));

session_cleanup($session);

1;


