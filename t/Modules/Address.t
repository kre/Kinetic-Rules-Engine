#!/usr/bin/perl -w

use lib qw(/web/lib/perl);
use strict;
use warnings;

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
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Modules::Address qw/:all/;
use Kynetx::Modules qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;



use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $preds = Kynetx::Modules::Address::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;


# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
    $test_count++;
}

my $source = 'address';
my ($result,$args);

my $str = <<_EOF_;
900 METRO CENTER BLVD
M3-5D
FOSTER CITY, CA 94404-2172
_EOF_

$result = Kynetx::Modules::eval_module($my_req_info,
				       $rule_env,
				       $session,
				       $rule_name,
				       $source,
				       'all',
				       [$str]
				      );

my $exp = {
  'number' => '900',
  'street' => 'METRO CENTER BLVD
M3-5D',
  'state' => 'CA',
  'zip' => '94404',
  'city' => 'FOSTER CITY',
  'suffix' => undef,
  'type' => 'Blvd',
  'prefix' => undef
};
is_deeply($result,
   $exp,
   'address:all()');
$test_count++;

$result = Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       'state',
                       [$str]
                      );

$exp = 'CA';
is($result,
   $exp,
   'address:state()');
$test_count++;

$result = Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       'suffix',
                       [$str]
                      );

$exp = '';
is($result,
   $exp,
   'Undefined value');
$test_count++;
done_testing($test_count);



1;


