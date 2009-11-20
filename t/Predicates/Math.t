#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Math qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;



plan tests => 15;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);


my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();


my $session = Kynetx::Test::gen_session($r, $rid);

#
# random
#
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');


like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');


like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');







1;


