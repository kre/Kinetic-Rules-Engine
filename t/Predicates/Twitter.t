#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

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
use Kynetx::Predicates::Twitter qw/:all/;
use Kynetx::JavaScript qw(mk_js_str gen_js_var);
use Kynetx::Rules qw(:all);

use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $preds = Kynetx::Predicates::Twitter::get_predicates();
my @pnames = keys (%{ $preds } );

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

# these are KRE generic consumer tokens
$my_req_info->{$rid.':key:twitter'} = 
  {'consumer_secret' => '3HNb7NhKuqRIm2BuxKPSg6JYvMtLahvkMt6Std5SO0',
   'consumer_key' => 'jPlIPAk1gbigEtonC2yNA'
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
isnt(Kynetx::Predicates::Twitter::authorized($my_req_info, $rule_env, $session, $rule_name, ''.''), 
     "random calls aren't authorized");
$test_count++;

contains_string(Kynetx::Predicates::Twitter::authorize($my_req_info, $rule_env, $session, {},{}), "http://twitter.com/oauth/authorize?oauth_token", "authorize gets a URL");
$test_count++;

#2009/12/31 14:25:59 DEBUG Twitter.pm a16x42 [global] Exchanged request tokens for access tokens. access_token => 100844323-hNmGVEQlEblWGkof2gLFi3d97sQtc4LkoVAID0s1 & secret => quUCMtOgcKAm2iaDXAuTGwo4XiJ8AP93HllPaMOGk & user_id = 100844323 & screen_name = kynetx_test

# these are authorized against KRE OAuth on Twitter by kynetx_test
my $user_id = "100844323";
my $screen_name = "kynetx_test";
my $access_token = "100844323-XqQfRm33tQqp54mmhKCfNF9VIOaxVISrIYTOTXOy";
my $access_token_secret = "QdGk4MGc2RiNuD5MHjL5GVk9m1h3SsooGeMWfUQb7f0";

session_store($rid, $session, 'twitter:access_tokens', {
       access_token        => $access_token,
       access_token_secret => $access_token_secret,
       user_id => $user_id,
       screen_name => $screen_name
    });

my $rate_limit_status = eval_twitter($my_req_info,
				 $rule_env,
				 $session,
				 'foo',
				 'rate_limit_status',
				 []
				);

diag "Rate limit status: $rate_limit_status->{'remaining_hits'} of $rate_limit_status->{'hourly_limit'} ";

like($rate_limit_status->{'reset_time_in_seconds'}, qr/^\d+$/, "reset_time is a number");
$test_count++;

like($rate_limit_status->{'remaining_hits'}, qr/^\d+$/, "remaining_hits is a number");
$test_count++;


my $calculated_user_id = eval_twitter($my_req_info,
				      $rule_env,
				      $session,
				      'foo',
				      'user_id',
				      []
				     );

is($calculated_user_id, $user_id, "what goes around comes around");
$test_count++;



my $friends_timeline = eval_twitter($my_req_info,
				    $rule_env,
				    $session,
				    'foo',
				    'friends_timeline',
				    [{'count' => 10}]
				   );
#$logger->debug("Friends timeline: ", $friends_timeline);


is(int @{ $friends_timeline }, 10, "Getting back 10 returns");
$test_count++;

like($friends_timeline->[0]->{'user'}->{'friends_count'}, qr/\d+/, "Friend count is a number");
$test_count++;

my $user_timeline = eval_twitter($my_req_info,
				    $rule_env,
				    $session,
				    'foo',
				    'user_timeline',
				    [{'count' => 1}]
				   );
#$logger->debug("Friends timeline: ", $friends_timeline);


is(int @{ $user_timeline }, 1, "Getting back 1 returns");
$test_count++;

like($user_timeline->[0]->{'user'}->{'friends_count'}, qr/\d+/, "Friend count is a number");
$test_count++;


my $home_timeline = eval_twitter($my_req_info,
				 $rule_env,
				 $session,
				 'foo',
				 'home_timeline',
				 [{'count' => 12}]
				);

is(int @{ $home_timeline }, 12, "Getting back some home timeline returns");
$test_count++;


my $public_timeline = eval_twitter($my_req_info,
				 $rule_env,
				 $session,
				 'foo',
				 'public_timeline',
				 []
				);

is(int @{ $public_timeline }, 20, "Getting back some public timeline returns");
$test_count++;


my $mentions = eval_twitter($my_req_info,
				 $rule_env,
				 $session,
				 'foo',
				 'mentions',
				 [{'count' => 1}]
				);

is(int @{ $mentions }, 1, "Getting most recent mention");
$test_count++;


# clear out now for rerunning
session_delete($rid, $session, 'twitter:access_tokens');

done_testing($test_count + int(@pnames));


1;


