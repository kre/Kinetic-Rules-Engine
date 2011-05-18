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
use Kynetx::Errors qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Scheduler qw/:all/;
use Kynetx::Postlude;


use Kynetx::FakeReq qw/:all/;


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

my $logger = get_logger();

my $rl;

#----------- start over -------------------
$my_req_info->{'schedule'} = Kynetx::Scheduler->new();

Kynetx::Errors::raise_error($my_req_info, 'warn',
			    "[keys] invalid operator argument",
			    {'rule_name' => $rule_name,
			     'genus' => 'flipper',
			     'species' => 'type mismatch'
			    }
			   );

$rl = []; 
while (my $task = $my_req_info->{'schedule'}->next()) {
#	$logger->debug("Task: ",sub {Dumper($task)});
	push(@{ $rl }, $task->{'rule'}->{'name'});	
}


is_deeply($rl, ['test_error_1'], "select one error rule");
$test_count++;


#----------- start over -------------------
$my_req_info->{'schedule'} = Kynetx::Scheduler->new();

Kynetx::Errors::raise_error($my_req_info, 'warn',
			    "[keys] invalid operator argument",
			    {'rule_name' => $rule_name,
			     'genus' => 'operator',
			     'species' => 'type mismatch'
			    }
			   );

$rl = []; 
while (my $task = $my_req_info->{'schedule'}->next()) {
#	$logger->debug("Task: ",sub {Dumper($task)});
	push(@{ $rl }, $task->{'rule'}->{'name'});	
}

#diag Dumper $rl;

is_deeply($rl, ['test_error_1','test_error_2'], "select two error rules");
$test_count++;



done_testing($test_count);



1;


