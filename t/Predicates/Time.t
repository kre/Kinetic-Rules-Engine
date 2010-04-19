
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
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);


use LWP::Simple;
use XML::XPath;
use DateTime;

use Kynetx::Test qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Predicates::Time qw/:all/;

my $preds = Kynetx::Predicates::Time::get_predicates();
my @pnames = keys (%{ $preds } );
plan tests => 21 + int(@pnames);


my $NYU_req_info;
$NYU_req_info->{'ip'} = '128.122.108.71'; # New York (NYU)

my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my %rule_env = ();

# check that predicates at least run without error
my @dummy_arg = (0,0,0,0,0,0,0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


# ok($preds->{'timezone'}($BYU_req_info, {}, ["America/Denver"]), "Checking Mountain Time Zone"); 


is(get_local_time($NYU_req_info)->time_zone->name, 
   "America/New_York", 
   "Checking eastern time zone");

is(get_local_time($Amazon_req_info)->time_zone->name, 
   "America/Los_Angeles", 
   "Checking pacific time zone");

is(get_local_time($BYU_req_info)->time_zone->name, 
   "America/Denver", 
   "Checking mountain time zone");

ok(&{$preds->{'morning'}}($BYU_req_info) ? 
     &{$preds->{'daytime'}}($BYU_req_info) : 1,
   "Its daytime if it's morning");

ok(&{$preds->{'lunch_time'}}($BYU_req_info) ? 
     &{$preds->{'daytime'}}($BYU_req_info) : 1,
   "Its daytime if it's lunchtime");

ok(&{$preds->{'late_morning'}}($BYU_req_info) ? 
     &{$preds->{'daytime'}}($BYU_req_info) : 1,
   "Its daytime if it's late morning");

ok(&{$preds->{'early_afternoon'}}($BYU_req_info) ? 
     &{$preds->{'daytime'}}($BYU_req_info) : 1,
   "Its daytime if it's early afternoon");

ok(&{$preds->{'early_afternoon'}}($BYU_req_info) ? 
     &{$preds->{'daytime'}}($BYU_req_info) : 1,
   "Its daytime if it's early afternoon");


ok(&{$preds->{'weekday'}}($BYU_req_info) ? 
   (! &{$preds->{'weekend'}}($BYU_req_info)) :  
   &{$preds->{'weekend'}}($BYU_req_info),
   "If it's a weekday, it's not the weekend, otherwise it is");


my @dow = qw(
Sunday
Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
);


my $now = get_local_time($BYU_req_info);

is($dow[$now->day_of_week], local_day_of_week($BYU_req_info),
   "The day of the week is OK");

my @dow_args = ($dow[$now->day_of_week]);
ok(&{$preds->{'day_of_week'}}($BYU_req_info, \%rule_env, \@dow_args),
   "The day of the week is OK with predicate");

my @everyday = (1,1,1,1,1,1,1);
#my $logger = get_logger();
#$logger->debug(join(", ", @everyday) );


ok(&{$preds->{'today_is'}}($BYU_req_info, \%rule_env, \@everyday),
   "Everyday is a day of the week");


# date between
my $after = $now->clone->add(days => 1);
my $before = $now->clone->subtract(days => 1);


my @datearg = ($before->month,$before->day,$before->year,
               $after->month,$after->day,$after->year);
ok(&{$preds->{'date_between'}}($BYU_req_info, \%rule_env, \@datearg),
   "Today is between yeaterday and tomorrow");

@datearg = ($before->month,$before->day,$before->year);
ok(&{$preds->{'date_start'}}($BYU_req_info, \%rule_env, \@datearg),
   "Today after yesterday.");




ok(&{$preds->{'today_is'}}($BYU_req_info, \%rule_env, \@everyday),
   "Everyday is a day of the week");


my @no_day = (0,0,0,0,0,0,0);
$no_day[$now->day_of_week] = 1;


my $logger = get_logger();
$logger->debug(join(", ", @no_day), " ", $now->day_of_week );

ok(
    &{$preds->{'today_is'}}($BYU_req_info, \%rule_env, \@no_day),
   "Check today");

my $tz = 'America/Denver';;
my $base_time = DateTime->now('time_zone' => $tz);
my $rightnow = Kynetx::Predicates::Time::get_time($BYU_req_info,'now',[{'tz'=>$tz}]);
cmp_ok($base_time->truncate("to" => 'hour'),'eq',$rightnow->truncate('to'=>'hour'),"time:now()");

my $t = Kynetx::Predicates::Time::get_time($BYU_req_info,'new',["2010-08-08"]);
cmp_ok("$t",'eq','2010-08-08T00:00:00',"Create a new time string");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'add',["$t",{"hours"=>4}]);
cmp_ok("$t",'eq','2010-08-08T04:00:00',"Create a new time string");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'strftime',["$t","%F %T"]);
cmp_ok("$t",'eq','2010-08-08 04:00:00',"Create a new time string");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'atom',["2010-08-08",{'tz'=>'America/Denver'}]);
cmp_ok("$t",'eq','2010-08-08T06:00:00Z',"Create a new time string");
$logger->debug("t: ", $t);

1;


