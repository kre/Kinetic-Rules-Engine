#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 2;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Markets qw/:all/;


use LWP::Simple;
use XML::XPath;
use DateTime;


use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Weather qw/:all/;

my $NYU_req_info;
$NYU_req_info->{'ip'} = '128.122.108.71'; # New York (NYU)

my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my %rule_env = ();


my $preds = Kynetx::Predicates::Markets::get_predicates();

my @args = (0);
ok(&{$preds->{'djia_up_more_than'}}($BYU_req_info, \%rule_env, \@args) ? 
   (! &{$preds->{'djia_down_more_than'}}($BYU_req_info, \%rule_env, \@args)) :  
   1,
   "If the market's up, it's not down!");

ok(&{$preds->{'djia_down_more_than'}}($BYU_req_info, \%rule_env, \@args) ? 
   (! &{$preds->{'djia_up_more_than'}}($BYU_req_info, \%rule_env, \@args)) :  
   1,
   "If the market's down, it's not up!");


1;


