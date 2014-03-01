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
    contains_trail_element
    add_trail_element
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
#Log::Log4perl->easy_init($DEBUG);

# array
my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $big_val = [];
my $max = 1000000;
for (my $i = 0; $i < $max; $i++) {
	my $yav = $DICTIONARY[rand(@DICTIONARY)];
	chomp($yav);
	push(@$big_val,$yav);	
}

my $big_e = extend_rule_env({'foosh' => $big_val},$rule_env);

my $expr = {
  'domain' => 'ent',
  'test' => undef,
  'value' => {
    'type' => 'var',
    'val' => 'foosh'
  },
  'action' => 'set',
  'name' => 'kvstore',
  'type' => 'persistent'
};

$result = Kynetx::Postlude::eval_persistent_expr($expr,$session,$my_req_info,$big_e,"cs_test");
#$logger->debug("Result: ", sub {Dumper($result)});
cmp_deeply($result->{'_error_'},1,"set persistent variable which is too large");
$test_count++;
#goto ENDY;

my $description = "Insert a hash element (creating the hash)";
$krl_src = <<_KRL_;
fired {
  set ent:hTest{"a"} 1.2345
} 
_KRL_

my $expected = {
	'a' => 1.2345
};

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
$result = get_persistent_var($domain,$rid, $session, 'hTest');
$logger->debug("Result: ", sub {Dumper($result)});
cmp_deeply($result,
   $expected,
   $description
  );
$test_count++;

$description = "Insert a hash element (sub hash)";
$krl_src = <<_KRL_;
fired {
  set ent:hTest{"c"} {"b" : [1,2,3]}
} 
_KRL_

$expected = {
  'c' => {
    'b' => [
      1,
      2,
      3
    ]
  },
	'a' => 1.2345
};

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
$result = get_persistent_var($domain,$rid, $session, 'hTest');
$logger->debug("Result: ", sub {Dumper($result)});
cmp_deeply($result,
   $expected,
   $description
  );
$test_count++;




$description = "Insert a hash element (sub hash)";
$krl_src = <<_KRL_;
fired {
  clear ent:hTest{["a"]} 
} 
_KRL_

$expected = {
  'c' => {
    'b' => [
      1,
      2,
      3
    ]
  },
};

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
$result = get_persistent_var($domain,$rid, $session, 'hTest');
$logger->debug("Result: ", sub {Dumper($result)});
cmp_deeply($result,
   $expected,
   $description
  );
$test_count++;


$description = "Insert a hash element (empty hash)";
$krl_src = <<_KRL_;
fired {
  set ent:hTest{["c","b"]} []
} 
_KRL_

$expected = {
  'c' => {
    'b' => []
  },
};

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
$result = get_persistent_var($domain,$rid, $session, 'hTest');
$logger->debug("Result: ", sub {Dumper($result)});
cmp_deeply($result,
   $expected,
   $description
  );
$test_count++;

$description = "Insert a hash element (empty hash)";
$krl_src = <<_KRL_;
fired {
  set ent:hTest{["c","d"]} ["Vitamin water", "Hoo", "Hah"]
} 
_KRL_

$expected = {
  'c' => {
    'b' => [],
    'd' => ["Vitamin water", "Hoo", "Hah"]
  },
};

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
$result = get_persistent_var($domain,$rid, $session, 'hTest');
$logger->debug("Result: ", sub {Dumper($result)});
cmp_deeply($result,
   $expected,
   $description
  );
$test_count++;



delete_persistent_var($domain,$rid,$session,'hTest');



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
is(contains_trail_element($domain,$rid, $session, 'my_trail',"testing"),
   3,
   'testing added'
  );
$test_count++;

is(contains_trail_element($domain,$rid, $session, 'my_trail',"windley"),
   0,
   'windley pushed down'
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(contains_trail_element($domain,$rid, $session, 'my_trail',"windley"),
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
add_trail_element($domain,$rid,$session,'my_trail',"windley");

$krl_src = <<_KRL_;
fired {
  forget "testing" in app:my_trail
} else {
  mark app:my_trail with "testing!"
}
_KRL_

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, NOTFIRED, 0);
is(contains_trail_element($domain,$rid, $session, 'my_trail',"testing"),
   1,
   'testing added'
  );
$test_count++;

is(contains_trail_element($domain,$rid, $session, 'my_trail',"windley"),
   0,
   'windley pushed down'
  );
$test_count++;

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
is(contains_trail_element($domain,$rid, $session, 'my_trail',"windley"),
   0,
   'testing forgotten'
  );
$test_count++;


# conditions

$krl_src = <<_KRL_;
fired {
  last
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok($my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info");
$test_count++;


$krl_src = <<_KRL_;
fired {
  last if true
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok($my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info when true");
$test_count++;

$krl_src = <<_KRL_;
fired {
  last if false
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! defined $my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last not modified req_info when false");
$test_count++;

$krl_src = <<_KRL_;
fired {
  last if (3 == 3)
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(defined $my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info when expr");
$test_count++;


$krl_src = <<_KRL_;
fired {
  last if 3 == 3 && 'b' neq 'c'
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(defined $my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info when expr");
$test_count++;

$krl_src = <<_KRL_;
fired {
  last if 3 == 3 && 'b' neq 'c' && 5 != 6
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(defined $my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info when expr");
$test_count++;

$krl_src = <<_KRL_;
fired {
  last if (3 == 3 && 'b' neq 'c' && 5 == 6) || 'a' eq 'a'
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(defined $my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info when expr");
$test_count++;


$krl_src = <<_KRL_;
fired {
  last if ((event:attr("namespace") eq "meta") && 
           (event:attr("keyvalue") eq "namespace") && 
           (event:attr("gtourInit").match(re/yes/gi))); 
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
Kynetx::Request::add_event_attr($my_req_info, 'namespace', 'meta');
Kynetx::Request::add_event_attr($my_req_info, 'keyvalue', 'namespace');
Kynetx::Request::add_event_attr($my_req_info, 'gtourInit', 'yes');

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(defined $my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info when expr");
$test_count++;


$krl_src = <<_KRL_;
fired {
  last if ((event:attr("namespace") eq "meta") && 
           (event:attr("keyvalue") eq "namespace") && 
           (event:attr("gtourInit").match(re/yes/gi))); 
}
_KRL_

$my_req_info = Kynetx::Test::gen_req_info($rid); # reset
Kynetx::Request::add_event_attr($my_req_info, 'namespace', 'meta');
Kynetx::Request::add_event_attr($my_req_info, 'keyvalue', 'namespace');
Kynetx::Request::add_event_attr($my_req_info, 'gtourInit', 'no');

run_post_testcase($krl_src, $my_req_info, $session, $rule_env, FIRED, 0);
ok(! defined $my_req_info->{'cs_test:__KOBJ_EXEC_LAST'}, "last modified req_info when expr");
$test_count++;





#
# raise functionality tested in Rules.t
# 

# testing attributes clause
$krl_src = <<_KRL_;
always {
  raise explicit event foo attributes {"b": 2, "c": 3};
} 
_KRL_

my ($krl, $res, $src);

$krl = Kynetx::Parser::parse_post($krl_src);

chomp $krl;

# fix it up for what eval_post_expr expects
$krl = {'post' => $krl};
#diag Dumper $krl;

$res = eval_post_expr($krl,
		      $session,
		      $my_req_info,
		      $rule_env,
		      1);

is(Kynetx::Request::get_attr($my_req_info,'b'), 2, "attributes correctly stored");
is(Kynetx::Request::get_attr($my_req_info,'c'), 3, "attributes correctly stored");
$test_count += 2;





# testing modifiers clause
$krl_src = <<_KRL_;
always {
  raise explicit event foo with 
   x = 5 and
   y = 6
} 
_KRL_

$krl = Kynetx::Parser::parse_post($krl_src);

chomp $krl;

# fix it up for what eval_post_expr expects
$krl = {'post' => $krl};
#diag Dumper $krl;

$res = eval_post_expr($krl,
		      $session,
		      $my_req_info,
		      $rule_env,
		      1);

is(Kynetx::Request::get_attr($my_req_info,'x'), 5, "attributes correctly stored (with)");
is(Kynetx::Request::get_attr($my_req_info,'y'), 6, "attributes correctly stored (with)");
is(Kynetx::Request::get_attr($my_req_info,'_generatedby'), 'cs_test.prod', '_generatedby attribute correct');
$test_count += 3;



# schedule repeat/at
my $alt_rid = "schedev_test";
my $sched_req_info = Kynetx::Test::gen_req_info($alt_rid);
my $ename = $DICTIONARY[rand(@DICTIONARY)];
my $sdomain = "notification";
chomp($ename);
my @now = localtime(time);
my $min = $now[1] + 1;

$description = "Add a repeating schedEv";
$krl_src = <<_KRL_;
always {
  schedule $sdomain event $ename repeat "$min * * * *"
   with 
     x = 5 and
     y = 6
} 
_KRL_

$krl = Kynetx::Parser::parse_post($krl_src);

chomp $krl;
$krl = {'post' => $krl};
$res = eval_post_expr($krl,
		      $session,
		      $sched_req_info,
		      $rule_env,
		      1);

my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
my $key = {
  'source' => $alt_rid
};
my @expected = [ignore(),"$sdomain/$ename","repeat",$alt_rid,ignore()]; 
$result = Kynetx::Persistence::SchedEv::schedev_query($ken,$key);
$logger->debug("SchedEv Query: ", sub { Dumper($result)});
cmp_deeply($result,superbagof(@expected),$description);
$test_count++;

#Log::Log4perl->easy_init($DEBUG);
$description = "Add a one time event";
$krl_src = <<_KRL_;
always {
  schedule $sdomain event $ename at time:add(time:now(),{"minutes" : 1})
   with 
     x = 5 and
     y = 6
} 
_KRL_
$krl = Kynetx::Parser::parse_post($krl_src);

chomp $krl;
$krl = {'post' => $krl};
$res = eval_post_expr($krl,
		      $session,
		      $sched_req_info,
		      $rule_env,
		      1);
@expected = [ignore(),"$sdomain/$ename","once",$alt_rid,ignore()]; 
$result = Kynetx::Persistence::SchedEv::schedev_query($ken,$key);
$logger->debug("SchedEv Query: ", sub { Dumper($result)});
cmp_deeply($result,superbagof(@expected),$description);
$test_count++;
#Log::Log4perl->easy_init($INFO);

# Clean up testing data
delete_persistent_var($domain,$rid,$session,'my_trail');
delete_persistent_var($domain,$rid,$session,'my_flag');
delete_persistent_var($domain,$rid,$session,'archive_pages_now');


my($rids, $ruleset, $rid_info_list);

$ruleset = undef;

$rids = Kynetx::Expressions::den_to_exp(
    	 Kynetx::Postlude::eval_expr_with_default(
			$ruleset,
 		        # default value is current ruleset
			Kynetx::Rids::get_rid($my_req_info->{'rid'}).".".Kynetx::Rids::get_version($my_req_info->{'rid'}),    
			$rule_env,
			$rule_name,
			$my_req_info,
			$session
		       )
		);

is($rids, 'cs_test.prod', "default works");
$test_count += 1;

     



ENDY:


done_testing($test_count);



1;


