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

use Test::More;
use Test::LongString;
use Test::Deep;

use APR::URI;
use APR::Pool ();
use Cache::Memcached;


use JSON::XS;

use Kynetx::Test qw/:all/;
use Kynetx::Operators qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Memcached;
use Kynetx::Postlude qw/:all/;
use Kynetx::Persistence qw/:all/;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);



# configure KNS
Kynetx::Configure::configure();



my $test_count = 0;


my ($description,$key,$temp);

my $mod_rid = 'a144x172.prod';
my @default_rules = ['cs_test','10','a144x171.dev',$mod_rid];
my $test_env = Kynetx::Test::enchilada('ridlist','ridlist_rule',\@default_rules);
$logger->debug("Dump: ",sub {Dumper($test_env)});

subtest 'Environment created' => sub {Kynetx::Test::validate_env($test_env)};
$test_count++;

######################### Test Environment definitions
my $req_info = $test_env->{'req_info'};
my $sky_info = $test_env->{'sky_request_info'};
my $rule_env = $test_env->{'root_env'};
my $session  = $test_env->{'session'};
my $rulename = $test_env->{'rulename'};

my $anon_ken = $test_env->{'anonymous_user'};

my $user_ken = $test_env->{'user_ken'};
my $user_eci = $test_env->{'user_eci'};
my $user_username = $test_env->{'username'};
my $user_password = $test_env->{'password'};

my $t_rid = $test_env->{'rid'};
my $t_eid = $test_env->{'eid'};

############################
# Entity var searching
Log::Log4perl->easy_init($DEBUG);

$logger->debug("Foo!");

$description = "Optimized query";
my $map = Kynetx::Test::twitter_query_map($req_info,$rule_env,$session,$rid);

#$logger->debug("Twitter query: ", sub {Dumper($map)});

my $ekey = "searchkey";
my $result = save_persistent_var("ent",$t_rid,$session,$ekey,$map);
my $map_check = get_persistent_var("ent",$t_rid,$session,$ekey);

cmp_deeply([keys %{$map}],bag(keys %{$map_check}),$description);
$test_count++;



my $op_expr =q/ent:searchkey.query([],{
  'requires' :  '$and', 
  'conditions'   : [
    {
      'search_key' : ['retweeted_status', 'favorite_count'],
      'operator' : '$gt',
      'value' : 5
    },
    {
      'search_key' : ['retweeted_status', 'favorite_count'],
      'operator' : '$lt',
      'value' : 200
    }
  ]})/;
  
$result = test_operator($op_expr,undef,1);
foreach my $key (@{$result}) {
  $logger->debug("Key: ", sub {Dumper($key)});
  my $value = get_persistent_hash_var("ent",$t_rid,$session,$ekey,$key);
  $logger->debug("Val: ", sub {Dumper($value)});
  
}
  

my $op_expr =q/ent:searchkey.query([],{
  'requires' :  '$or', 
  'conditions'   : [
    {
      'search_key' : ['retweeted_status', 'favorite_count'],
      'operator' : '$gt',
      'value' : 5
    },
    {
      'search_key' : ['retweeted_status', 'favorite_count'],
      'operator' : '$lt',
      'value' : 200
    },
    {
      'search_key' : ['retweeted_status','retweet_count'],
      'operator' : '$gt',
      'value' : 4000
    }
  ]})/;

test_operator($op_expr,undef,1);





Log::Log4perl->easy_init($INFO);


######################### Clean up
Kynetx::Test::flush_test_user($user_ken,$user_username);

my $anon_uname = "_" . $anon_ken;
Kynetx::Test::flush_test_user($anon_ken,$anon_uname);

sub test_operator {
    my ($e, $x, $d) = @_;

    my ($v, $r);

    diag "Expr: ", Dumper($e) if $d;

    $v = Kynetx::Parser::parse_expr($e);
    diag "Parsed expr: ", Dumper($v) if $d;

    $r = eval_expr($v, $rule_env, $rulename,$req_info,$session);
    diag "Expect: ", Dumper($x) if $d;
    diag "Result: ", Dumper($r) if $d;
    my $result = cmp_deeply($r, $x, "Trying $e");


    #die unless ($result);
    return $r;
}


done_testing($test_count);
1;
