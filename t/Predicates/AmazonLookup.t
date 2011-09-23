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

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels  :easy);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);

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
use Kynetx::Session qw(session_cleanup);
use Kynetx::Configure;
use Kynetx::JavaScript;
use Kynetx::Rules;
use Kynetx::Json;
use Kynetx::PrettyPrinter;
use Kynetx::FakeReq;
use Kynetx::Modules;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $preds = {};
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

$my_req_info->{"$rid:ruleset_name"} = $app_name;
$my_req_info->{"$rid:name"} = $app_name;
$my_req_info->{"$rid:author"} = $app_author;
$my_req_info->{"$rid:description"} = "This is a test rule";



my $rule_name = 'foo';
my $args;

my $rule_env = Kynetx::Test::gen_rule_env();
my $new_rule_env;

my $js;
my $keys = 
  {secret_key => $dev_secret,
   token => $dev_token
  };
# these are KRE generic consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'amazon',
  $keys);




my $session = Kynetx::Test::gen_session($r, $rid);

my $logger = get_logger();

# check that predicates at least run without error
#my @dummy_arg = (0);
#foreach my $pn (@pnames) {
#    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
#}

my $test_count = 0;
my ($got,$expected,$description);
my @test_args=();
my @lookup_args=();
my @widget_args=();
my $canned_list;

#
# Parser validations
#
my $krl_amazon =<<_KRL_;
key amazon {
    token : "$dev_token",
    secret_key : "$dev_secret",
    associate_id : "latfordin-20"
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

# item lookup
$args = [{
    'item_id'=>["B000001JFR","B0001VSA32"]
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>["C2002-WK"],
    'idtype' =>'SKU',
    'merchantid' => 'All'
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>["C2002-WK"],
    'idtype' =>'SKU',
    'merchantid' => 'All',
    'condition' => 'Used'
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>["C2002-WK"],
    'idtype' =>'SKU',
    'merchantid' => 'All',
    'response_info' => ['Variations']
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>["C2002-WK"],
    'idtype' =>'SKU',
    'merchantid' => 'All',
    'response_group' => ['Variations'],
    'relationshiptype' => 'Track'
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => 'ItemIds',
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['OfferSummary','ItemIds'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['Accessories'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['BrowseNodes'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['EditorialReview'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['Images'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['ItemAttributes'],
}];
push(@lookup_args,$args);
$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['ItemIds'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['Large'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['ListmaniaLists'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['Medium'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['MerchantItemAttributes'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B001ET5U92',
    'response_group' => ['OfferFull'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B001ET5U92',
    'response_group' => ['Offers'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B000UYN9QS',
    'response_group' => ['OfferSummary'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B000V9CUP8',
    'relationshiptype' => 'Tracks',
    'response_group' => ['RelatedItems'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['Reviews'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['SalesRank'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['Similarities'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'0316769177',
    'response_group' => ['Subjects'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['Tags'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B00008OE6I',
    'response_group' => ['TagsSummary'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B0002PUHSI',
    'response_group' => ['Tracks'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B0009U7ROI',
    'response_group' => ['Variations'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B0009U7ROI',
    'response_group' => ['VariationImages'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B0009U7ROI',
    'response_group' => ['VariationMinimum'],
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'B0009U7ROI',
    'response_group' => ['VariationSummary'],
}];
push(@lookup_args,$args);


$args = [{
    'item_id'=>'B00247ASKY',
}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>["C2002-WK"],
    'idtype' =>'SKU',
    'merchantid' => 'All',
    'response_group' => ['EditorialReview','Tags'],
    'review_page' => 2,
    'tag_page' => 3,

}];
push(@lookup_args,$args);

$args = [{
    'item_id'=>'0312567073',
    'idtype' => 'ISBN',
    'condition' => 'All',
    'merchantid' => 'All',
    'response_group' => ['Offers'],
}];
push(@lookup_args,$args);


# item lookups
foreach my $case (@lookup_args) {
    $logger->trace("Item lookup args: ",sub {Dumper($case)});
    my $ds = Kynetx::Modules::eval_module($my_req_info,$rule_env,$session,
        'amz_test','amazon','item_lookup',$case);
    my $good = Kynetx::Predicates::Amazon::good_response($ds);
    if (! $good) {
        my $error = Kynetx::Predicates::Amazon::get_error_msg($ds);
        $logger->warn("Error: ", sub {Dumper($error)});
        $logger->warn("Args: ",sub {Dumper(Kynetx::Predicates::Amazon::get_request_args($ds))});
    }else {
        $logger->debug("Good result: ", sub {Dumper(Kynetx::Json::astToJson($ds))});
    }
    is ($good,1);
}





session_cleanup($session);

done_testing( int(@lookup_args));


1;


