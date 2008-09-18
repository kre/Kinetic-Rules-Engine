#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);


use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Predicates::MediaMarkets qw/:all/;
use Kynetx::JavaScript qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $preds = Kynetx::Predicates::MediaMarkets::get_predicates();
my @pnames = keys (%{ $preds } );

plan tests => 2 + int(@pnames);


my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)


my $no_referer_req_info;
$no_referer_req_info->{'pool'} = APR::Pool->new;

my %rule_env = ();

# check that predicates at least run without error
my @dummy_arg = (200);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($Amazon_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


my($krl_src,$cond,$args);

$krl_src = <<_KRL_;
media_market_greater_than(500)
_KRL_

$cond = Kynetx::Parser::parse_predexpr($krl_src);

$args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

#diag(Dumper($args));


ok(&{$preds->{'media_market_rank_greater_than'}}($Amazon_req_info,\%rule_env,$args),
   "Media market rank predicate");

$krl_src = <<_KRL_;
dma_is(819)
_KRL_

$cond = Kynetx::Parser::parse_predexpr($krl_src);

$args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});



ok(&{$preds->{'dma_is'}}($Amazon_req_info,\%rule_env,$args),
   "Seattle's DMA is 819");


1;


