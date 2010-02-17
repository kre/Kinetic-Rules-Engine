#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;
use Test::Deep;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels :easy);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($TRACE);
#Log::Log4perl->easy_init($DEBUG);

use Apache2::Const;
use APR::URI;
use APR::Pool;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;

use Kynetx::Test;
use Kynetx::Environments;
use Kynetx::Session qw/:all/;
use Kynetx::Configure;
use Kynetx::Predicates::Twitter;
use Kynetx::JavaScript;
use Kynetx::Rules;
use Kynetx::Modules;

use Kynetx::FakeReq;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $preds = {}; #Kynetx::Predicates::Twitter::get_predicates();
my @pnames = keys (%{ $preds } );

my $r = Kynetx::Test::configure();

my $rid = 'amz_test';
my $dev_secret = 'eumHLj+6s3supYM2yM1Vhuv5sovBRnD5PLqx+G8N';
my $dev_token = 'AKIAI3YUSFFKFNND6TRQ';
my $app_name = "amz_test";
my $app_author = "Mark Horstmeier";
my $meta_defs = <<_META_;
        name "$app_name"
        author "$app_author"
        description <<
Tutorial for Amazon Module             >>
        logging on        
_META_
# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

# these are KRE generic consumer tokens
$my_req_info->{$rid.':key:amazon'} = 
  {secret_key => $dev_secret,
   token => $dev_token
  };

$my_req_info->{"$rid:ruleset_name"} = $app_name;
$my_req_info->{"$rid:name"} = $app_name;
$my_req_info->{"$rid:author"} = $app_author;
$my_req_info->{"$rid:description"} = "This is a test rule";



my $rule_name = 'foo';
my $args;

my $rule_env = Kynetx::Test::gen_rule_env();
my $new_rule_env;

my $session = Kynetx::Test::gen_session($r, $rid);

my $logger = get_logger();

my $test_count = 0;
my ($got,$expected,$description);
my @test_args=();
my @fail_args=();
my $canned_list;

# 
# Parser validations
#
my $krl_amazon =<<_KRL_;
key amazon {
    token : "$dev_token",
    secret_key : "$dev_secret"
}
_KRL_

my $krl_ruleset=<<_KRL_;
ruleset amz_10 {
    meta {
        name "$app_name"
        author "$app_author"
        description <<
Tutorial for Amazon Module             >>
        logging on        
      $krl_amazon

    }
    rule test0 is active {
        select using "/test/" setting()


        pre {
    }     

        float("absolute", "top: 10px", "right: 10px",
              "/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc);

    }
}
_KRL_

# item search
$args = [{
    'locale' => 'us',
    'index' => 'all',
    'Keywords'=>"radio flyer",
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'apparel',
    'brand' => 'lucky',
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'automotive',
    'condition' => 'Used',
    'brand' => 'kia',
    'state' => 'ut',
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'electronics',
    'manufacturer' => 'sony',
    'keywords' => '1080p',
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'electronics',
    'manufacturer' => 'sony',
    'keywords' => '1080p',
    'response_group' => ['Offers','Subjects'],
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'electronics',
    'manufacturer' => 'sony',
    'keywords' => '1080p',
    'response_group' => ['ItemIds'],
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'electronics',
    'manufacturer' => 'sony',
    'keywords' => '1080p',
    'response_group' => ['ItemIds'],
    'itempage' => 4,
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'electronics',
    'manufacturer' => 'sony',
    'keywords' => '1080p',
    'response_group' => ['ItemIds','BrowseNodes','BrowseNodeInfo'],
    'itempage' => 4,
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'electronics',
    'textstream' => 'where can I find bluetooth headphones in provo',
}];

push(@test_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'electronics',
    'manufacturer' => 'sony',
    'keywords' => '1080p',
    'response_group' => ['ItemIds','OfferSummary'],
   'itempage' => 1,
}];

push(@test_args,$args);

$args = [{
    'locale' => 'ca',
    'index' => 'Kitchen',
    'keywords' => 'davenport ketchup chips',
}];

push(@test_args,$args);

# catch invalid requests
$args = [{
    'locale' => 'ca',
    'index' => 'apparel',
    'brand' => 'lucky',
}];

push(@fail_args,$args);

$args = [{
    'locale' => 'us',
    'index' => 'automotive',
    'condition' => 'Used',
    'state' => 'ut',
}];

push(@fail_args,$args);



# item searches
foreach my $case (@test_args) {
    $logger->trace("Item search args ",sub {Dumper($case)});
    my $ds = Kynetx::Modules::eval_module($my_req_info,$new_rule_env,$session,
        'amz_test','amazon','item_search',$case);
    my $good = Kynetx::Predicates::Amazon::good_response($ds);
    is ($good,1);
    if (! $good) {
        #$logger->debug("Bad result: ", sub {Dumper($ds)});
        my $error = Kynetx::Predicates::Amazon::get_error_msg($ds); 
        $logger->debug("Error: ", sub {Dumper($error)});
        $logger->debug("Args: ",sub {Dumper(Kynetx::Predicates::Amazon::get_request_args($ds))});
        
    }else {
        $logger->debug("Good result: ", sub {Dumper($ds)});
        my $titems = Kynetx::Predicates::Amazon::total_items($ds);
        my $tpages = Kynetx::Predicates::Amazon::total_pages($ds);
        my $asin = Kynetx::Predicates::Amazon::get_ASIN($ds);
        $logger->debug("Results: ",$titems," Pages: ",$tpages);
        $logger->debug("ASIN: ", sub {Dumper($asin)});
        
    };
      
}

$logger->info("Checking poorly formed requests, okay to ignore warnings");

foreach my $case (@fail_args) {
    $logger->trace("Item search args ",sub {Dumper($case)});
    my $ds = Kynetx::Modules::eval_module($my_req_info,$new_rule_env,$session,
        'amz_test','amazon','item_search',$case);
    my $good = Kynetx::Predicates::Amazon::good_response($ds);
    isnt ($good,1);
    if (! Kynetx::Predicates::Amazon::good_response($ds)) {
        my $error = Kynetx::Predicates::Amazon::get_error_msg($ds); 
        $logger->debug("Error: ", sub {Dumper($error)});
        $logger->debug("Args: ",sub {Dumper(Kynetx::Predicates::Amazon::get_request_args($ds))});        
    }else {
        $logger->debug("Good result: ", sub {Dumper($ds)});
        my $titems = Kynetx::Predicates::Amazon::total_items($ds);
        my $tpages = Kynetx::Predicates::Amazon::total_pages($ds);
        my $asin = Kynetx::Predicates::Amazon::get_ASIN($ds);
        $logger->debug("Results: ",$titems," Pages: ",$tpages);
        $logger->debug("ASIN: ", sub {Dumper($asin)});        
    };      
}

session_cleanup($session); 

done_testing($test_count + int(@test_args) + int(@fail_args));


1;


