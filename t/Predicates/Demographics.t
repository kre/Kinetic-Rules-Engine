#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 8;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
#Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Demographics qw/:all/;

my %rule_env = ();


my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

# Note: BYU zip not defined in demographics DB
my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my $amazon_median_income = get_demographics($Amazon_req_info, 'median_income');
# my $byu_median_income = get_demographics($BYU_req_info, 'median_income');

my $preds = Kynetx::Predicates::Demographics::get_predicates();

ok(defined($amazon_median_income), "Median income not undef");

my @args = (10000);
ok(&{$preds->{'median_income_above'}}
       ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income greater than 10000");


ok(! &{$preds->{'median_income_below'}}
       ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income greater than 10000");

@args = (20000);
ok(! &{$preds->{'median_income_above'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income not greater than 20000");

ok(&{$preds->{'median_income_below'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income not greater than 20000");


@args = (10000,20000);
ok(&{$preds->{'median_income_between'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon median income between 10000 and 20000");


ok(&{$preds->{'urban'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon is urban");

ok(! &{$preds->{'rural'}}
        ($Amazon_req_info, \%rule_env, \@args), 
   "Amazon is not rural");



1;


