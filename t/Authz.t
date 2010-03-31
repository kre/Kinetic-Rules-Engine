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
use Kynetx::Authz qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Rules qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::PersistentDataService qw/:all/;


use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $test_count = 0;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

$my_req_info->{"$rid:name"} = "Test App";
$my_req_info->{"$rid:author"} = "Phil Windley";
$my_req_info->{"$rid:description"} = "Just a test ma'am!";

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $krl = <<_KRL_;
ruleset $rid {
    meta {
    }
    rule $rule_name is active {
        select using "/test/" setting()
	alert("hello");
    }
}
_KRL_

my $pt = Kynetx::Parser::parse_ruleset($krl);

ok(is_authorized($rid,$pt,$session),"no authz request");
$test_count++;


$krl = <<_KRL_;
ruleset $rid {
    meta {
      authz require user
    }
    rule $rule_name is active {
        select using "/test/" setting()
	alert("hello");
    }
}
_KRL_

$pt = Kynetx::Parser::parse_ruleset($krl);

ok(!is_authorized($rid,$pt,$session),"authz request without settion fails");
$test_count++;


#$session->{'chico'}->{'authz_tokens'} = {$rid => {'type' => 'require',
#						  'level' => 'user'}};

Kynetx::PersistentDataService::store_values('chico', 
					    $session, 
					    'authz_tokens',
					    {$rid => {'type' => 'require',
						      'level' => 'user'}});


$krl = <<_KRL_;
ruleset $rid {
    meta {
      authz require user
    }
    rule $rule_name is active {
        select using "/test/" setting()
	alert("hello");
    }
}
_KRL_

$pt = Kynetx::Parser::parse_ruleset($krl);

ok(is_authorized($rid,$pt,$session),"authz request with settion works");
$test_count++;


$krl = <<_KRL_;
ruleset $rid {
    meta {
    }
    rule $rule_name is active {
        select using "/test/" setting()
	alert("hello");
    }
}
_KRL_

$pt = Kynetx::Parser::parse_ruleset($krl);
my $authorize_message = authorize_message($my_req_info, $session, $pt);
#diag $authorize_message;
like($authorize_message,
     qr/KOBJ_ruleset_activation/,
     'we get something back');
$test_count++;

my $rl = Kynetx::Rules::mk_rule_list($my_req_info, $rid);
my $js = Kynetx::Rules::process_ruleset($r, $rl, $rule_env, $session, $rid);
unlike($js,
     qr/KOBJ_ruleset_activation/,
     'plain ruleset does not ask for activation');
$test_count++;

$rl = Kynetx::Rules::mk_rule_list($my_req_info, 'cs_test_authz');
$js = Kynetx::Rules::process_ruleset($r, $rl, $rule_env, $session, 
				       'cs_test_authz');

#diag $js;
like($js,
     qr/KOBJ_ruleset_activation/,
     'authz ruleset does ask for activation');
$test_count++;


done_testing($test_count);

1;


