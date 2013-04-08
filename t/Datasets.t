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

use Test::More;
use Test::LongString;
use Test::Deep;
use Data::Dumper;
use LWP::UserAgent;
use LWP::Simple;
use JSON::XS;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
#Log::Log4perl->easy_init($WARN);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

my $logger = get_logger();

use Kynetx::Test qw/:all/;
use Kynetx::Datasets qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Configure;
use Kynetx::Rids qw/:all/;

Kynetx::Configure::configure();

my $req_info;
$req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$req_info->{'rid'} = mk_rid_info($req_info,'cs_test');
$req_info->{'pool'} = APR::Pool->new;


my %rule_env = ();
my ($krl_src, $krl);


my(@cache_for_test_cases, @datasets_testcases, $result);

# full datasets
sub add_cache_for_testcase {
    my($str, $expected, $desc, $diag) = @_;
    my $krl = Kynetx::Parser::parse_global_decls($krl_src);

    chomp $str;
    diag("$str = ", Dumper($krl)) if $diag;

    push(@cache_for_test_cases,
	 {'expr' => $krl->[0], # just the first one
	  'expected' => $expected,
	  'src' =>  $str,
	  'desc' => $desc
	 }
	);
}


#
# generate test cases for cache_dataset_for()
#
$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json";
}
_KRL_
add_cache_for_testcase($krl_src, 600, "cache_dataset_for non-cachable");


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable;
}
_KRL_
add_cache_for_testcase($krl_src, 24*60*60, "cache_dataset_for default cachable");


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 5 seconds;
}
_KRL_
add_cache_for_testcase($krl_src, 5, "cache_dataset_for 5 seconds");


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 15 seconds;
}
_KRL_
add_cache_for_testcase($krl_src, 15, "cache_dataset_for 15 seconds");


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 5 minutes;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60, "cache_dataset_for 5 minutes");


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 5 hours;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60, "cache_dataset_for 5 hours");


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 5 days;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24, "cache_dataset_for 5 days");


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 5 weeks;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24*7, "cache_dataset_for 5 weeks");

$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 5 months;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24*30, "cache_dataset_for 5 months");

$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json" cachable for 5 years;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24*365, "cache_dataset_for 5 years");


plan tests => 14 + int(@cache_for_test_cases);

foreach my $case (@cache_for_test_cases) {
    is(cache_dataset_for($case->{'expr'}),
       $case->{'expected'},
       $case->{'desc'});
}


$krl_src = <<_KRL_;
global {
  dataset aaa <- "aaa.json";
}
_KRL_
$krl = Kynetx::Parser::parse_global_decls($krl_src);
#diag Dumper($krl);

is_string_nows(get_dataset($krl->[0],$req_info),get_local_file("aaa.json"),"Local file");

$krl_src = <<_KRL_;
global {
   dataset fizz_data <- "http://frag.kobj.net/clients/cs_test/aaa.json";
   dataset fozz_data <- "http://frag.kobj.net/clients/cs_test/aaa.json" cachable;
}
_KRL_
$krl = Kynetx::Parser::parse_global_decls($krl_src);
#diag Dumper($krl);

ok(!global_dataset($krl->[0]),"not global");
ok(global_dataset($krl->[1]),"global");



my ($rule_env, $args);
SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "http://cs.kobj.net/blue/event/web/pageview/a144x165";

#    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", 2 if (! $response->is_success);

    $krl_src = <<_KRL_;
global {
   dataset fizz_data <- "http://cs.kobj.net/blue/event/web/pageview/a144x165";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);
#    diag Dumper($krl);

    is_string_nows(get_dataset($krl->[0],$req_info),get_local_file("aaa.json"),"URL file");

    $rule_env = {};

    my($this_js, $val, $var) = mk_dataset_js($krl->[0], $req_info, $rule_env);
    my $expected = "KOBJ['data']['fizz_data']  = " . get_local_file("aaa.json") . ";";
    is_string_nows($this_js,
		   "KOBJ['data']['fizz_data']  = " . get_local_file("aaa.json") . ";",
		   "is the JS alight?");


    $krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);


    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = ["?q=windley"];

#    diag Dumper($rule_env);

#    diag Dumper($krl);

    contains_string(encode_json(get_datasource($rule_env,$args,"twitter_search")),
		    '{"since_id_str":"0","page":1,"query":"windley","completed_in":',
		    "JSON twitter search");



    $krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json" cachable for 30 minutes;
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);


    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = ["?q=kynetx"];

#    diag Dumper($rule_env);

#    diag Dumper($krl);

    contains_string(encode_json(get_datasource($rule_env,$args,"twitter_search")),
		    '{"since_id_str":"0","page":1,"query":"kynetx","completed_in":',
		    "JSON twitter search cachable");


    $krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json?callback=kntx";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);


    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = ["&q=iphone"];

#   diag Dumper($rule_env);

#    diag Dumper($krl);
	my $source = get_datasource($rule_env,$args,"twitter_search");
    cmp_deeply($source,
		    re('kntx\(\{.*"results":\[\{'),
		    "JSON twitter search with param in spec");


    $krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);


    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = ["?q=byu&callback=kntx"];

#    diag Dumper($rule_env);

#    diag Dumper($krl);

    cmp_deeply(get_datasource($rule_env,$args,"twitter_search"),
		    re('kntx\(\{.*"results":\[\{'),
		    "JSON twitter search with multiple params");





    $krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);


    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = [{'q' => 'byu',
	      'callback' => 'kntx'}];

#    diag Dumper($rule_env);

#    diag Dumper($krl);

# http://search.twitter.com/search.json?callback=kntx&q=byu


    cmp_deeply(get_datasource($rule_env,$args,"twitter_search"),
		    re('kntx\(\{.*"results":\[\{'),
		    "JSON twitter search with multiple params");



    $krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.json?callback=kntx";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);


    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = [{'q' => 'byu',
	      'a' => 'phil'}];

#    diag Dumper($rule_env);

#    diag Dumper($krl);

# http://search.twitter.com/search.json?callback=kntx&q=byu


    cmp_deeply(get_datasource($rule_env,$args,"twitter_search"),
		    re('kntx\(\{.*"results":\[\{'),
		    "JSON twitter search with multiple params");


    $krl_src = <<_KRL_;
global {
   dataset fizz_data:HTML <- "http://cs.kobj.net/blue/event/web/pageview/a144x165";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);
#    diag Dumper($krl);

    is_string_nows(get_dataset($krl->[0],$req_info),get_local_file("aaa.json"),"URL file as string");

    $rule_env = {};

    ($this_js, $val, $var) = mk_dataset_js($krl->[0], $req_info, $rule_env);
    $expected = "KOBJ['data']['fizz_data'] = '" . get_local_file("aaa.json") . "';";
    is_string_nows($this_js,
           $expected,
           "JS is correct");

    $krl_src = <<_KRL_;
global {
	// google dataset below is from a bug, but it is not going to always return UTF-8
    //dataset utf8_data:RSS <- "http://www.google.com/search?h1=en&oe=utf-8&q=kynetx&tbm=blg&output=rss&cb=664" cachable for 1 second;
	dataset utf8_data:HTML <- "http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt" cachable for 1 second;
}
_KRL_

    $krl = Kynetx::Parser::parse_global_decls($krl_src);
#    diag Dumper($krl);

    $source = get_dataset($krl->[0],$req_info);
    my $utf8_str = Kynetx::Util::str_in('ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ ᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ');
	#$logger->debug($source);    
    contains_string($source,$utf8_str,"UTF-8 datasets");


}



sub get_local_file {
    my($name) = @_;
    my $filename="/web/data/client/cs_test/" . $name;
    open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
    local $/ = undef;
    my $content = <KRL>;
    close KRL;
    return $content;
}


1;


