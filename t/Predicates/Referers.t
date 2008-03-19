#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 7;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);


use LWP::Simple;
use XML::XPath;
use DateTime;
use APR::URI;
use APR::Pool ();

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Referers qw/:all/;

my $BYU_req_info;
$BYU_req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$BYU_req_info->{'pool'} = APR::Pool->new;

my $no_referer_req_info;
$no_referer_req_info->{'pool'} = APR::Pool->new;

my %rule_env = ();

my $preds = Kynetx::Predicates::Referers::get_predicates();


ok(exists $preds->{'search_engine_referer'}, 
   "Is search_engine_referer predicate available?");
ok(exists $preds->{'remote_referer'}, 
   "Is remote_referer predicate available?");
ok(exists $preds->{'local_referer'}, 
   "Is local_referer predicate available?");


my @testargs = ("www.byu.edu");
ok(&{$preds->{'referer_domain'}}($BYU_req_info,\%rule_env,\@testargs),
   "Referer domain");

@testargs = ("www.windley.com");
ok( ! (&{$preds->{'referer_domain'}}($BYU_req_info,\%rule_env,\@testargs)),
    "Referer domain wrong");

ok(&{$preds->{'remote_referer'}}($BYU_req_info),
   "Referer is set");

ok(&{$preds->{'local_referer'}}($no_referer_req_info),
   "Referer is not set");


1;


