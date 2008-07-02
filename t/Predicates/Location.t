#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Location qw/:all/;

my $preds = Kynetx::Predicates::Location::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => 6 + int(@pnames);


my $NYU_req_info;
$NYU_req_info->{'ip'} = '128.122.108.71'; # New York (NYU)

my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)

my $BYU_req_info;
$BYU_req_info->{'ip'} = '128.187.16.242'; # Utah (BYU)

my %rule_env = ();

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}

my @args;

@args = ('Provo');
ok(&{$preds->{'city'}}($BYU_req_info, \%rule_env, \@args),
   "Is BYU in Provo?");

@args = (get_geoip($BYU_req_info,'city'));
ok(&{$preds->{'city'}}($BYU_req_info, \%rule_env, \@args),
   "Is the city we return the one in the predicate");

@args = (get_geoip($BYU_req_info,'state'));
ok(&{$preds->{'state'}}($BYU_req_info, \%rule_env, \@args),
   "Is the state we return the one in the predicate");

@args = (get_geoip($BYU_req_info,'region'));
ok(&{$preds->{'state'}}($BYU_req_info, \%rule_env, \@args),
   "Is the state we return the one in the predicate");

@args = (get_geoip($BYU_req_info,'city'));
ok(! &{$preds->{'outside_city'}}($BYU_req_info, \%rule_env, \@args),
   "city return and outside_city");

@args = (get_geoip($BYU_req_info,'state'));
ok(! &{$preds->{'outside_state'}}($BYU_req_info, \%rule_env, \@args),
   "state return and outside_state");



1;


