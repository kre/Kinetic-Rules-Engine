#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;

use Apache2::Const;
use Apache2::Request;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Events qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;

use Kynetx::Json qw/:all/;

use Kynetx::Parser;
use Kynetx::Rules;

use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;

my ($krl,$ast,$sm, $ev, $initial, $n1);

## test compile_event_expr

$my_req_info->{'domain'} = 'web';
$my_req_info->{'eventtype'} = 'pageview';

$krl = <<_KRL_;
rule foo is active {
  select when pageview "/archives/(\\d\\d\\d\\d)" setting(year)
  noop();
}
_KRL_

$my_req_info->{'caller'} = "http://www.windley.com/archives/2006/09/test.html";
$ev = mk_event($my_req_info);

$ast = Kynetx::Parser::parse_rule($krl);
$sm = compile_event_expr($ast->{'pagetype'}->{'event_expr'});

$initial = $sm->get_initial();
$n1 = $sm->next_state($initial, $ev);
ok($sm->is_final($n1), "ev leads to final state");
$test_count++;

#diag Dumper Kynetx::Rules::optimize_rule($ast);

#diag Dumper astToJson($ast);

#diag Kynetx::Events::process_event($r, 'web', 'pageview', ['cs_test_1']);

done_testing($test_count);

1;


