#!/usr/bin/perl -w 

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
use APR::URI;
use APR::Pool ();

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Referers qw/:all/;
use Kynetx::JavaScript qw/:all/;
my $preds = Kynetx::Predicates::Referers::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => 7 + int(@pnames);


my $BYU_req_info;
$BYU_req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$BYU_req_info->{'pool'} = APR::Pool->new;

my $no_referer_req_info;
$no_referer_req_info->{'pool'} = APR::Pool->new;

my %rule_env = ();


# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


ok(exists $preds->{'search_engine_referer'}, 
   "Is search_engine_referer predicate available?");
ok(exists $preds->{'remote_referer'}, 
   "Is remote_referer predicate available?");
ok(exists $preds->{'local_referer'}, 
   "Is local_referer predicate available?");

my $args;

# a small piece of the abstract syntax tree...
my $cond = {'args' => [
            {
              'str' => 'www.byu.edu'
            }
          ]
};

$args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});


ok(&{$preds->{'referer_domain'}}($BYU_req_info,\%rule_env,$args),
   "Referer domain");

$cond->{'args'}->[0]->{'str'} = 'www.windley.com';
$args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

ok( ! (&{$preds->{'referer_domain'}}($BYU_req_info,\%rule_env,$args)),
    "Referer domain wrong");

ok(&{$preds->{'remote_referer'}}($BYU_req_info),
   "Referer is set");

ok(&{$preds->{'local_referer'}}($no_referer_req_info),
   "Referer is not set");


1;


