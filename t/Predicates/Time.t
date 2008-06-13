
#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 20;
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

my $NYU_req_info;
$NYU_req_info->{'ip'} = '128.122.108.71'; # New York (NYU)

my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my %rule_env = ();

my $preds = Kynetx::Predicates::Time::get_predicates();
ok(exists $preds->{'daytime'}, "Is daytime predicate available?");
ok(exists $preds->{'nighttime'}, "Is nighttime predicate available?");
ok(exists $preds->{'morning'}, "Is morning predicate available?");
ok(exists $preds->{'timezone'}, "Is timezone predicate available?");


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


# not using this

my @jsargs = (
            {
              'num' => '1'
            },
            {
              'num' => '1'
            },
            {
              'num' => '1'
            },
            {
              'num' => '1'
            },
            {
              'num' => '1'
            },
            {
              'num' => '1'
            },
            {
              'num' => '1'
            }
    );


@datearg = Kynetx::JavaScript::gen_js_rands(\@jsargs);


1;


