#!/usr/bin/perl -w 

#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
# 
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
# 
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
# 
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
# 
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
# 
use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString max => 100;
use Test::Deep;
use Data::Dumper;
use LWP::UserAgent;
use LWP::Simple;
use JSON::XS;
use Apache::Session::Memcached;

use APR::URI;
use Cache::Memcached;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);
#Log::Log4perl->easy_init($TRACE);
my $logger = get_logger();

use Kynetx::Test qw/:all/;
use Kynetx::Datasets qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Configure;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Rules qw/:all/;

Kynetx::Configure::configure();

my $req_info;
$req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$req_info->{'rid'} = 'cs_test';
$req_info->{'pool'} = APR::Pool->new;
$req_info->{'caller'} = 'http://www.baconsalt.com';
$req_info->{'txn_id'} = 'xml_tn_id';


my %rule_env = ();
my ($krl_src, $krl);


my(@cache_for_test_cases, @datasets_testcases, $result,@dataset_examples,@ruleset_testcases);

# full datasets
sub add_cache_for_testcase {
    my($str, $expected, $desc, $diag) = @_;
    my $krl = Kynetx::Parser::parse_global_decls($str);
 
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

sub add_dataset_example_testcase {
    my($str, $expected, $desc, $diag) = @_;
 
    chomp $str;
    diag("$str = ", Dumper($krl)) if $diag;

    push(@dataset_examples, 
     {'expr' => $str, 
      'expected' => $expected,
      'desc' => $desc,
      'debug' => $diag,
     }
    );
}

sub add_ruleset_testcase {
    my($str, $expected, $desc, $diag) = @_;
 
    chomp $str;
    diag("$str = ", Dumper($str)) if $diag;

    push(@ruleset_testcases, 
     {'expr' => $str, 
      'expected' => $expected,
      'desc' => $desc,
      'debug' => $diag,
     }
    );
}

my $url_re = re('http:\/\/');
my $str_re = re('\w+');
my $atom_string_re = re('(xmlns:google).+(xmlns:twitter=("http://api.twitter.com/"))');

my $atom_element = {
    '$t' => $str_re,
};

my $atom_l = {
    '@href' => $url_re,
    '@rel'  => $str_re,
    '@type' => $str_re,
};

my $atom_c = {
    'link' => array_each($atom_l),
    'content' => ignore(),
    'author'  => ignore(),
    'twitter$geo' => ignore(),
    'twitter$lang' => ignore(),
    'published' => ignore(),  
    'id' => $atom_element,  
    'title' => $atom_element,  
    'updated' => $atom_element,
    'twitter$source' => ignore(),       
};

my $atom_t = {
    'link' => array_each($atom_l),
    'entry' => array_each($atom_c),
    '@xml:lang' => ignore(),
    'id' => ignore(),
    'openSearch$itemsPerPage' => $atom_element,
    'title' => $atom_element,
    'twitter$warning' => ignore(),
    'updated' => ignore,       
};


my $atom_f = {
  'feed' => $atom_t, 
  '@encoding' => ignore(),
  '@version'  => ignore(),
};


#
# generate test cases for cache_dataset_for()
#
$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml";
}
_KRL_
add_cache_for_testcase($krl_src, 600, "cache_dataset_for non-cachable");


$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable;
}
_KRL_
add_cache_for_testcase($krl_src, 24*60*60, "cache_dataset_for default cachable");


$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 5 seconds;
}
_KRL_
add_cache_for_testcase($krl_src, 5, "cache_dataset_for 5 seconds");


$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 15 seconds;
}
_KRL_
add_cache_for_testcase($krl_src, 15, "cache_dataset_for 15 seconds");


$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 5 minutes;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60, "cache_dataset_for 5 minutes");


$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 5 hours;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60, "cache_dataset_for 5 hours");


$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 5 days;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24, "cache_dataset_for 5 days");


$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 5 weeks;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24*7, "cache_dataset_for 5 weeks");

$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 5 months;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24*30, "cache_dataset_for 5 months");

$krl_src = <<_KRL_;
global {
  dataset aaa:XML <- "books.xml" cachable for 5 years;
}
_KRL_
add_cache_for_testcase($krl_src, 5*60*60*24*365, "cache_dataset_for 5 years");

#
########    DATASET Tests from the documentation
# aaa.json
    $krl_src = <<_KRL_;
global {
   dataset fizz_data:JSON <- "http://frag.kobj.net/clients/cs_test/aaa.json";
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("aaa.json"),"URL file: aaa.json",0);

# books.json
    $krl_src = <<_KRL_;
global {
   dataset fozz_data:JSON <- "http://frag.kobj.net/clients/cs_test/books.json";
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("books.json"),"URL file: books.json",0);

# ktut.json
    $krl_src = <<_KRL_;
global {
   dataset fazz_data:JSON <- "http://frag.kobj.net/clients/cs_test/ktut.json";
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("ktut.json"),"URL file: ktut.json",0);

# aaa.json
    $krl_src = <<_KRL_;
global {
   dataset fuzz_data <- "http://frag.kobj.net/clients/cs_test/aaa.json";
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("aaa.json"),"URL file: aaa.json",0);

# books.json
    $krl_src = <<_KRL_;
global {
   dataset fozz_data:JSON <- "http://frag.kobj.net/clients/cs_test/books.json" cachable;
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("books.json"),"URL file: books.json",0);

# ktut.json
    $krl_src = <<_KRL_;
global {
   dataset fazz_data:JSON <- "http://frag.kobj.net/clients/cs_test/ktut.json" cachable for 30 minutes;
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("ktut.json"),"URL file: ktut.json",0);

# books.xml
    $krl_src = <<_KRL_;
global {
   dataset fixx_data:XML <- "http://frag.kobj.net/clients/cs_test/books.xml";
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("books.xml"),"URL file: books.xml",0);

# books.xml
    $krl_src = <<_KRL_;
global {
   dataset fixx_data:XML <- "http://frag.kobj.net/clients/cs_test/books.xml" cachable for 5 weeks;
}
_KRL_
add_dataset_example_testcase($krl_src,get_local_file("books.xml"),"URL file: books.xml",0);




$krl_src = <<_KRL_;
global {
  dataset aaa <- "books.xml";
}
_KRL_
$krl = Kynetx::Parser::parse_global_decls($krl_src);
#diag Dumper($krl);

is_string_nows(get_dataset($krl->[0],$req_info),get_local_file("books.xml"),"Local file");

$krl_src = <<_KRL_;
global {
   dataset fizz_data:XML <- "http://frag.kobj.net/clients/cs_test/books.xml";
   dataset fozz_data:XML <- "http://frag.kobj.net/clients/cs_test/books.xml" cachable;
}
_KRL_
$krl = Kynetx::Parser::parse_global_decls($krl_src);
#diag Dumper($krl);

ok(!global_dataset($krl->[0]),"not global");
ok(global_dataset($krl->[1]),"global");



my ($rule_env, $args);
SKIP: {
    my $ua = LWP::UserAgent->new;

    my $check_url = "http://frag.kobj.net/clients/cs_test/books.xml";

#    diag "Checking $check_url";
    my $response = $ua->get($check_url);
    skip "No server available", 2 if (! $response->is_success);

    $krl_src = <<_KRL_;
global {
   dataset fizz_data:XML <- "http://frag.kobj.net/clients/cs_test/books.xml";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);
#    diag Dumper($krl);

    is_string_nows(get_dataset($krl->[0],$req_info),get_local_file("books.xml"),"URL file");

    $rule_env = {};

    my($this_js, $val, $var) = mk_dataset_js($krl->[0], $req_info, $rule_env);
    my $expected = "KOBJ['data']['fizz_data']  = " . get_local_file("books.json") . ";";
    #$logger->debug("Expected: ", $expected);
    #$logger->debug("Created: ", $this_js);

    is_string_nows($this_js, 
		   $expected, 
		   "is the JS Correct?");
    
    $krl_src = <<_KRL_;
global {
   datasource twitter_search:XML <- "http://search.twitter.com/search.atom";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);
    

    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = ["?q=windley"];

#    diag Dumper($rule_env);

#    diag Dumper($krl);

    my $ds = get_datasource($rule_env,$args,"twitter_search");

#    contains_string(encode_json($ds),
#		    '{"page":1,"query":"windley","completed_in":',
#		    "JSON twitter search");

    cmp_deeply($ds,$atom_f,"XML->JSON conversion");


    $krl_src = <<_KRL_;
global {
   datasource twitter_search :XML <- "http://search.twitter.com/search.atom" cachable for 30 minutes;
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);
    

    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];

    $args = ["?q=kynetx"];
    $ds = get_datasource($rule_env,$args,"twitter_search");
    cmp_deeply($ds,$atom_f,"XML->JSON conversion with CACHE tag");

    $krl_src = <<_KRL_;
global {
   datasource twitter_search <- "http://search.twitter.com/search.atom";
}
_KRL_
    $krl = Kynetx::Parser::parse_global_decls($krl_src);
    

    $rule_env->{'datasource:'.$krl->[0]->{'name'}} = $krl->[0];
    $args = ["?q=iphone&rpp=2"];
    my $dsr = lookup_rule_env('datasource:twitter_search',$rule_env);
    $ds = Kynetx::Datasets->new($dsr);
    $ds->load($req_info,$args);
    $ds->unmarshal();
    
    
    cmp_deeply($ds->sourcedata,$atom_string_re,"XML->JSON mis-conversion");
}

my $krl_full = <<_KRL_;
ruleset txml {
    meta {
        name "xml test"
        description <<
Dataset manipulation             >>
        logging on    }
    global {
        dataset fazz_data:JSON <- "http://frag.kobj.net/clients/cs_test/ktut.json" cachable for 30 minutes;
        dataset fixx_data:XML <- "http://frag.kobj.net/clients/cs_test/books.xml";   
        dataset fexx_data:XML <- "http://frag.kobj.net/clients/cs_test/ktut.xml" cachable for 5 seconds;
        datasource clear:JSON <- "http://clearplay.com/filtercart.aspx?" cachable for 1 seconds;
     }
    rule txml_rule is active {
        select using ".*" setting ()

        pre {
            json_pick = fazz_data.pick("\$..tree[0].name");
            xml_pick = fixx_data.pick("\$..book[2].title.\$t");
            x2j_pick = fexx_data.pick("\$..tree[0].\@name");
            clearPlay = datasource:clear({"SearchValue" : "Sneakers"});
         }
        every {
            notify("Picked (ktut.xml): ", x2j_pick)
                with
                    sticky = true and
                    opacity = 1;            
            notify("Picked (ktut.json): ", json_pick)
                with
                    sticky = true and
                    opacity = 1;            
            notify("Picked (books.xml): ", xml_pick)
                with
                    sticky = true and
                    opacity = 1;            
        }
    }
}
_KRL_

add_ruleset_testcase($krl_full,re('json_pick =.+Lemon Tree.+'),"JSON Data pick",0);
add_ruleset_testcase($krl_full,re('xml_pick =.+Maeve Ascendant.+'),"XML Data pick",0);
add_ruleset_testcase($krl_full,re('x2j_pick =.+Lemon Tree.+'),"XML Data pick",0);

my $krl_clear = <<_KRL_;
    ruleset cp_test {
        meta {
            name "ClearPlay"
            author "test harness"
            logging on    }
        
        global {
            
        }
        rule cp_t is active {
            select using "www.netflix.com/" setting ()
            pre {
                title = "Sneakers";
                clearPlay = datasource:clear("SearchValue=Sneakers");
            }
              noop;
        }
    }
_KRL_

#add_ruleset_testcase($krl_clear,re('.+'),"clearplay",1);



foreach my $case (@cache_for_test_cases) {
    is(cache_dataset_for($case->{'expr'}), 
       $case->{'expected'},
       $case->{'desc'});
}

foreach my $case (@dataset_examples) {
    my $krl = Kynetx::Parser::parse_global_decls($case->{'expr'});    
    my $dsr = $krl->[0];
    my $ds = Kynetx::Datasets->new($dsr);
    $ds->load($req_info);
    $ds->unmarshal();
    $logger->debug("[examples] ", $ds->name);
    is_string_nows($ds->sourcedata,$case->{'expected'},$case->{'desc'});    
}

foreach my $case (@ruleset_testcases) {
    my $r = Kynetx::Test::configure();
    my $session = Kynetx::Test::gen_session($r,'cs_test');
    my $parsed = Kynetx::Parser::parse_ruleset($case->{'expr'});
    my $val = Kynetx::Rules::eval_ruleset($r,
        $req_info,
        empty_rule_env(),
        $session,
        $parsed,
        $parsed->{'rules'});
    $logger->debug(Dumper $val);
    cmp_deeply($val,$case->{'expected'},$case->{'desc'});
    
}


plan tests => 8 + int(@cache_for_test_cases) + int(@dataset_examples) + int(@ruleset_testcases);

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


