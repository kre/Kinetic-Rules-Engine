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

use Kynetx::Test;
use Kynetx::Datasets;
use Kynetx::JavaScript;
use Kynetx::Parser;
use Kynetx::Configure;
use Kynetx::FakeReq;
use Kynetx::Environments;
use Kynetx::Rules;
use Kynetx::Predicates::OData;
use Kynetx::Session;

Kynetx::Configure::configure();

my $rid = 'ODataTests';
my $results;
my $tcount=0;

my $r = Kynetx::Test::configure();
my $session = Kynetx::Test::gen_session($r, $rid);
my $req_info = Kynetx::Test::gen_req_info();
my $rule_env = Kynetx::Test::gen_rule_env();

my $preds = Kynetx::Predicates::OData::get_predicates();
my @pnames = keys(%{$preds});
my $args;
my $expected;
my $got;
my $test_name;

sub test_odata {
    my ($pred,$req_info,$rule_env,$args) = @_;
    $tcount++;
    return &{$preds->{$pred}}($req_info, $rule_env,$args);    
};




$args = ['http://services.odata.org/OData/OData.svc'];
$results = test_odata('entity_sets',$req_info,$rule_env,$args);
cmp_deeply($results,bag('Products','Categories','Suppliers'),"Entity set from odata.org");







$args = ['http://odata.netflix.com/Catalog/'];
$results = test_odata('entity_sets',$req_info,$rule_env,$args);
cmp_deeply($results,superbagof('TitleAudioFormats',
  'TitleAwards',
  'Titles',
  'TitleScreenFormats',
  'Genres',
  'Languages',
  'People'),"Entity set from Netflix.com");








$test_name = "OData metadata";
$args = ['http://services.odata.org/OData/OData.svc'];
$results = test_odata('metadata',$req_info,$rule_env,$args);
$got = $results->{'edmx$Edmx'}->{'edmx$DataServices'}->{'Schema'}->{'@Namespace'};
$expected = 'ODataDemo';
cmp_deeply($got,$expected,$test_name);








# tests Service Operation (odata functions) with all supported
# operations and extra cruft to verify that we handle it correctly
$test_name = "OData Service Operation (odata functions)";
$args = ['http://services.odata.org/OData/OData.svc','GetProductsByRating',
    {'rating'=>4,
        'zip' => 'poo',
        '$format'=>'atom',
        '$expand'=>'Supplier',
        '$inlinecount'=>'allpages',
        '$top'=>1}];
$results = test_odata('service_operation',$req_info,$rule_env,$args);
$got = $results;
$expected = re(qr/http:..services.odata.org.OData.OData.svc.GetProductsByRating/);
cmp_deeply($got,$expected,$test_name);








$test_name = "OData Product Search";
$args = ['http://services.odata.org/OData/OData.svc','Products'];
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results->{'d'}->[0]->{'__metadata'}->{'type'};
$expected = 'ODataDemo.Product';
cmp_deeply($got,$expected,$test_name);






$test_name = "OData Product Count";
$args = ['http://services.odata.org/OData/OData.svc',['Products','$count']];
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results;
$expected = re(qr/\d+/);
cmp_deeply($got,$expected,$test_name);







$test_name = "OData Product Array arg";
$args = ['http://services.odata.org/OData/OData.svc',['Products']];
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results->{'d'}->[0]->{'__metadata'}->{'type'};
$expected = 'ODataDemo.Product';
cmp_deeply($got,$expected,$test_name);






$test_name = "OData single product";
$args = ['http://services.odata.org/OData/OData.svc',{'Products'=>2}];
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results->{'d'}->{'Name'};
$expected = 'Vint soda';
cmp_deeply($got,$expected,$test_name);








$test_name = "OData Product to supplier links";
$args = ['http://services.odata.org/OData/OData.svc',[{'Products'=>2},'$links','Supplier']];
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results;
$expected = {'d' => {'uri' => ignore()}};
cmp_deeply($got,$expected,$test_name);





$test_name = "OData Product->Supplier->Address->City";
$args = ['http://services.odata.org/OData/OData.svc',[{'Products'=>2},'Supplier','Address','City']];
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results;
$expected = {'d' => {'City' => ignore()}};
cmp_deeply($got,$expected,$test_name);




$test_name = "OData Product->Supplier->Address->City text value";
$args = ['http://services.odata.org/OData/OData.svc',[{'Products'=>2},'Supplier','Address','City','$value']];
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results;
$expected = re(qr/^\w+$/);
cmp_deeply($got,$expected,$test_name);




$args = ['http://services.odata.org/OData/OData.svc',[{'Categories'=>1},'Products']];
$test_name = "OData Products in Category 1";
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results;
$expected = superhashof({'d'=>array_each(ignore())});
cmp_deeply($got,$expected,$test_name);




$args = ['http://services.odata.org/OData/OData.svc',[{'Categories'=>1},{'Products'=>1}]];
$test_name = "OData Product 1 in Category 1";
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results->{'d'}->{'Name'};
$expected = 'Milk';
cmp_deeply($got,$expected,$test_name);




$args = ['http://services.odata.org/OData/OData.svc',[{'Categories'=>1},{'Products'=>1},'Name']];
$test_name = "OData Product 1 in Category 1";
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results->{'d'}->{'Name'};
$expected = 'Milk';
cmp_deeply($got,$expected,$test_name);



$args = ['http://services.odata.org/OData/OData.svc','Products',{'$expand' => 'Supplier'}];
$test_name = "OData Product with full supplier information";
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results->{'d'}->[0]->{'Supplier'}->{'Name'};
$expected = re(qr/.+/);
cmp_deeply($got,$expected,$test_name);






$args = ['http://services.odata.org/OData/OData.svc','Products',{'$expand' => 'Supplier',
    '$filter' => 'Price gt 100'
}];
$test_name = "OData Product with full supplier information and filter";
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results->{'d'}->[0]->{'Supplier'}->{'Name'};
$expected = re(qr/.+/);
cmp_deeply($got,$expected,$test_name);





$args = ['http://services.odata.org/OData/OData.svc','Products',{'$expand' => 'Supplier',
    '$top' => 2,
}];
$test_name = "OData Product with full supplier information, Top 2";
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results;
$expected = superhashof({'d'=>[ignore(),ignore()]});
cmp_deeply($got,$expected,$test_name);





$args = ['http://odata.netflix.com/Catalog/','Titles',{'$filter' => 
    'Type eq \'Movie\' and Instant/Available eq true and (Rating eq \'G\' or Rating eq \'PG-13\' or Rating eq \'PG\')',
    '$top' => 2,
    '$orderby' => 'AverageRating desc',
    '$select' => ['Name','Synopsis','AverageRating'],
       
}];
$test_name = "Netflix instant movies with filter, Top 2";
$results = test_odata('get',$req_info,$rule_env,$args);
$got = $results;
$expected = superhashof({'d'=>array_each(superhashof({'Synopsis'=>ignore(),
    'Name'=>ignore(),
    'AverageRating'=>ignore()}))});
cmp_deeply($got,$expected,$test_name);


my $app_name = "amz_test";
my $app_author = "Mark Horstmeier";
my $url = "http://services.odata.org/OData/OData.svc";

my $krl_expr=<<_KRL_;
pre {
    data =  odata:get(\"$url\","Products"); 
}
_KRL_

my $result = Kynetx::Parser::parse_pre($krl_expr);
my ($js,$re)=Kynetx::Expressions::eval_prelude($req_info,$rule_env,'test0',$session,$result);
cmp_deeply($js,re($url.'/Products'),"Odata pre eval test");
$logger->debug("rule env",sub {Dumper($js)});

plan tests => $tcount + 1;

1;


