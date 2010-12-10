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


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Keys qw/:all/;
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

my $test_count = 0;

my ($js, $krl, $ast, $value);

$krl = <<"_KRL_";
ruleset foo {
  meta {
    name "Ruleset for Orphans"
    description <<
Ruleset for testing something or other.
>>

    key googleanalytics "kfjsklfjslkfjslkfs"
    key twitter {
      "consumer_key": 583758935739,
      "consumer_secret" : "3HNb7NfksjflskIm2BuxKPSg6JYvMtLahvkMt6Std5SO0"
    }
  }
}
_KRL_

$ast = Kynetx::Parser::parse_ruleset($krl);

($js, $rule_env) = Kynetx::Keys::process_keys($my_req_info,
					      $rule_env, 
					      $ast);

#diag Dumper $rule_env;


$value = Kynetx::Keys::get_key($my_req_info,
			       $rule_env, 
			       'twitter');

is_deeply($value, 
	  {'consumer_secret' => '3HNb7NfksjflskIm2BuxKPSg6JYvMtLahvkMt6Std5SO0',
	   'consumer_key' => '583758935739'
	  },
	  "Get the twitter key");
$test_count++;


done_testing($test_count);



1;


