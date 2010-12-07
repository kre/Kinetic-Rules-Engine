#!/usr/bin/perl -w

use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;
use Test::Deep;

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
use Kynetx::Configure;
use Kynetx::Memcached;
use Kynetx::MongoDB;
use Kynetx::Persistence qw(
    get_persistent_var
    save_persistent_var
    contains_persistent_element
    add_persistent_element
    delete_persistent_var
);

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();


Kynetx::Configure::configure();

$logger->debug("Initializing memcached");
Kynetx::Memcached->init();

# Basic MongoDB commands
$logger->debug("Initializing mongoDB");
Kynetx::MongoDB::init();

my $kobj_root = Kynetx::Configure::get_config('KOBJ_ROOT');
$logger->debug("KOBJ root: $kobj_root");

my $test_count = 0;

my $r = Kynetx::Test::configure();

# foreach my $k (sort @{Kynetx::Configure::config_keys()}) {
#   diag "$k => ", Kynetx::Configure::get_config($k);
# }

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

#Kynetx::Test::gen_app_session($r, $my_req_info);


my($krl_src, $result, $js);

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

my $domain = "ent";

$krl_src = <<_KRL_;
fired {
  clear ent:archive_pages_now;
} else {
  ent:archive_pages_now += 2 from 1;
}
_KRL_


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'archive_pages_now'),
   4,
   "incrementing archive pages"
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'archive_pages_now'),
   undef,
   "incrementing archive pages"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'archive_pages_now'),
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

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'my_flag'),
   "setting my_flag"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! get_persistent_var($domain,$rid, $session, 'my_flag'),
   "clearing my_flag"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'my_flag'),
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
is(contains_persistent_element($domain,$rid, $session, 'my_trail',"testing"),
   3,
   'testing added'
  );
$test_count++;

is(contains_persistent_element($domain,$rid, $session, 'my_trail',"windley"),
   0,
   'windley pushed down'
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(contains_persistent_element($domain,$rid, $session, 'my_trail',"windley"),
   0,
   'testing forgotten'
  );
$test_count++;



diag "New SET syntax!";
#Log::Log4perl->easy_init($DEBUG);

#my $val_to_store = rand(100);
my $val_to_store = "test99.1";

$krl_src = <<_KRL_;
fired {
  clear ent:kvstore
} else {
  set ent:kvstore "$val_to_store"
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'kvstore'),
   "setting kvstore to ($val_to_store)"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! get_persistent_var($domain,$rid, $session, 'kvstore'),
   "clearing kvstore"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'kvstore'),$val_to_store,
   "Getting kvstore value $val_to_store"
  );
$test_count++;


# Integer
$val_to_store = 23;

$krl_src = <<_KRL_;
fired {
  clear ent:kvstore
} else {
  set ent:kvstore $val_to_store
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'kvstore'),
   "setting kvstore to ($val_to_store)"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! get_persistent_var($domain,$rid, $session, 'kvstore'),
   "clearing kvstore"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'kvstore'),$val_to_store,
   "Getting kvstore value $val_to_store"
  );
$test_count++;


# hash
$val_to_store = '{"foo" : "zipp"}';

$krl_src = <<_KRL_;
fired {
  clear ent:kvstore
} else {
  set ent:kvstore $val_to_store
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'kvstore'),
   "setting kvstore to ($val_to_store)"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! get_persistent_var($domain,$rid, $session, 'kvstore'),
   "clearing kvstore"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
cmp_deeply(get_persistent_var($domain,$rid, $session, 'kvstore'),{"foo" => "zipp"},
   "Getting kvstore value $val_to_store"
  );
$test_count++;

# array
$val_to_store = '["Stinky","Stunky",1]';

$krl_src = <<_KRL_;
fired {
  clear ent:kvstore
} else {
  set ent:kvstore $val_to_store
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'kvstore'),
   "setting kvstore to ($val_to_store)"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! get_persistent_var($domain,$rid, $session, 'kvstore'),
   "clearing kvstore"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
cmp_deeply(get_persistent_var($domain,$rid, $session, 'kvstore'),["Stinky","Stunky",1],
   "Getting kvstore value $val_to_store"
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! get_persistent_var($domain,$rid, $session, 'kvstore'),
   "clearing kvstore"
  );
$test_count++;

$krl_src = <<_KRL_;
fired {
  clear ent:my_flag;
  clear ent:archive_pages_now2;
  clear ent:archive_pages_now;
  clear ent:my_count;
  clear ent:my_trail;
  clear ent:archive_pages_old;
}
_KRL_


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! get_persistent_var($domain,$rid, $session, 'my_flag'),
   "clearing my_flag"
  );
$test_count++;



# Application Variables
diag "Application Variables";
$domain = "app";

save_persistent_var($domain,$rid,$session,'archive_pages_now',1);

$krl_src = <<_KRL_;
fired {
  clear app:archive_pages_now;
} else {
  app:archive_pages_now += 2 from 1;
}
_KRL_


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'archive_pages_now'),
   3,
   "incrementing archive pages"
  );
$test_count++;

is(get_persistent_var("ent",$rid, $session, 'archive_pages_now'),
   undef,
   "Check in the entity space (not found)"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'archive_pages_now'),
   undef,
   "incrementing archive pages"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'archive_pages_now'),
   1,
   "incrementing archive pages"
  );
$test_count++;


$krl_src = <<_KRL_;
fired {
  clear app:my_flag
} else {
  set app:my_flag
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'my_flag'),
   "setting my_flag"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(get_persistent_var($domain,$rid, $session, 'my_flag'),
   undef,
   "clearing my_flag"
  );
$test_count++;


run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
ok(get_persistent_var($domain,$rid, $session, 'my_flag'),
   "setting my_flag"
  );
$test_count++;

# seed the trail with an element
add_persistent_element($domain,$rid,$session,'my_trail',"windley");

$krl_src = <<_KRL_;
fired {
  forget "testing" in app:my_trail
} else {
  mark app:my_trail with "testing!"
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(contains_persistent_element($domain,$rid, $session, 'my_trail',"testing"),
   1,
   'testing added'
  );
$test_count++;

is(contains_persistent_element($domain,$rid, $session, 'my_trail',"windley"),
   0,
   'windley pushed down'
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(contains_persistent_element($domain,$rid, $session, 'my_trail',"windley"),
   0,
   'testing forgotten'
  );
$test_count++;

# Clean up testing data
delete_persistent_var($domain,$rid,$session,'my_trail');
delete_persistent_var($domain,$rid,$session,'my_flag');
delete_persistent_var($domain,$rid,$session,'archive_pages_now');

done_testing($test_count);



1;


