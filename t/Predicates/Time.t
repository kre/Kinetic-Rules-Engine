
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
use Data::Dumper;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);


use LWP::Simple;
use XML::XPath;
use DateTime;

use Kynetx::Test qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::Predicates::Time qw/:all/;

my $preds = Kynetx::Predicates::Time::get_predicates();
my @pnames = keys (%{ $preds } );
plan tests => 26 + int(@pnames);


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
my $pause = 1;
diag "Wait for $pause second(s)";
sleep($pause);
my $rightnow = Kynetx::Predicates::Time::get_time($BYU_req_info,'now',[{'tz'=>$tz}]);
my $rn_dt = Kynetx::Predicates::Time::ISO8601($rightnow);
my $diff = $rn_dt->subtract_datetime($base_time);
cmp_ok($diff->seconds,'>=',$pause,"time:now()");

my $t = Kynetx::Predicates::Time::get_time($BYU_req_info,'new',["2010-08-08"]);
cmp_ok("$t",'eq','2010-08-08T00:00:00+00:00',"Create a new time string");

my $t2 = Kynetx::Predicates::Time::get_time($BYU_req_info,'new',['2010-08-08T04:00:00+00:00']);
$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'add',["$t",{"hours"=>4}]);
cmp_ok("$t",'eq',$t2,"Add 4 hours");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'strftime',["$t","%F %T"]);
cmp_ok("$t",'eq','2010-08-08 04:00:00',"Format a datetime string");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'atom',["2010-08-08T12:00:00-06:00"]);
cmp_ok("$t",'eq','2010-08-08T18:00:00Z',"Create a RFC3339 time string");

#Log::Log4perl->easy_init($DEBUG);
$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'strftime',["$t","%F %T",{'tz'=>'America/New_York'}]);
cmp_ok("$t",'eq','2010-08-08 14:00:00',"Format a datetime string for Timezone America/New_York");

$t2 = Kynetx::Predicates::Time::get_time($BYU_req_info,'new',['08:00:00']);

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'compare',["$rightnow","$t2"]);
my $dt1 = DateTime::Format::ISO8601->parse_datetime($rightnow);
my $dt2 = DateTime::Format::ISO8601->parse_datetime($t2);
cmp_ok($t,'eq',DateTime->compare($dt1,$dt2),"Time only and compare");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'add',["$rightnow",{"hours"=>4}]);
$t2 = Kynetx::Predicates::Time::get_time($BYU_req_info,'add',["$rightnow",{"hours"=>-4}]);

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'compare',["$t","$rightnow"]);
cmp_ok($t,'eq',1,"compare +4hours");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'compare',["$t2","$rightnow"]);
cmp_ok($t,'eq',-1,"compare -4hours");

$t = Kynetx::Predicates::Time::get_time($BYU_req_info,'compare',["$rightnow","$rightnow"]);
cmp_ok($t,'eq',0,"compare same time");
1;


