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
use Kynetx::Postlude qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;


my $test_count = 0;

my $r = Kynetx::Test::configure();

foreach my $k (sort @{Kynetx::Configure::config_keys()}) {
  diag "$k => ", Kynetx::Configure::get_config($k);
}

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);




my($krl_src);


sub run_post_testcase {
    my($src, $req_info, $session, $rule_env, $fired, $diag) = @_;
    my $krl = Kynetx::Parser::parse_post($src);
 
    
    chomp $krl;

    # fix it up for what eval_post_expr expects
    $krl = {'post' => $krl};
    diag(Dumper($krl)) if $diag;

    return eval_post_expr($krl, 
			  $session, 
			  $req_info, 
			  $rule_env, 
			  $fired);

}

use constant FIRED => 1;
use constant NOTFIRED => 0;

$krl_src = <<_KRL_;
fired {
  clear ent:archive_pages_now; 
} else {
  ent:archive_pages_now += 2 from 1;  
}
_KRL_


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(session_get($rid, $session, 'archive_pages_now'),
   4,
   "incrementing archive pages"
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(session_get($rid, $session, 'archive_pages_now'),
   undef,
   "incrementing archive pages"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(session_get($rid, $session, 'archive_pages_now'),
   1,
   "incrementing archive pages"
  );
$test_count++;


$krl_src = <<_KRL_;
fired {
  clear ent:my_flag
} else {
  set ent:my_flag
}
_KRL_

#diag("my_flag: ", session_get($rid, $session, 'my_flag'));
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(session_true($rid, $session, 'my_flag'),
   "setting my_flag"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! session_true($rid, $session, 'my_flag'),
   "clearing my_flag"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(session_true($rid, $session, 'my_flag'),
   "setting my_flag"
  );
$test_count++;


$krl_src = <<_KRL_;
fired {
  forget "testing" in ent:my_trail
} else {
  mark ent:my_trail with "testing!" 
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(session_seen($rid, $session, 'my_trail',"testing"),
   0,
   'testing added'
  );
$test_count++;

is(session_seen($rid, $session, 'my_trail',"windley"),
   1,
   'windley pushed down'
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(session_seen($rid, $session, 'my_trail',"windley"),
   0,
   'testing forgotten'
  );
$test_count++;





done_testing($test_count);



1;


