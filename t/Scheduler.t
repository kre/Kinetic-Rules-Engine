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

use Kynetx::Test qw/:all/;
use Kynetx::Scheduler qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $req_info_1 = Kynetx::Test::gen_req_info('1');
my $req_info_2 = Kynetx::Test::gen_req_info('2');
my $req_info_3 = Kynetx::Test::gen_req_info('3');

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;


my $schedule = Kynetx::Scheduler->new();

$schedule->add('1', 
	       {'name' => 'rule_1_1'}, 
	       {'rid' => '1'},
	      );

$schedule->add('1', 
	       {'name' => 'rule_1_2'}, 
	       {'rid' => '1'},
	      );

$schedule->add('2', 
	       {'name' => 'rule_2_1'}, 
	       {'rid' => '2'},
	      );

$schedule->add('3', 
	       {'name' => 'rule_3_1'}, 
	       {'rid' => '3'},
	      );

$schedule->add('3', 
	       {'name' => 'rule_3_2'}, 
	       {'rid' => '3'},
	      );

$schedule->add('3', 
	       {'name' => 'rule_3_3'}, 
	       {'rid' => '3'},
	      );

#diag Dumper $schedule;

my $rl = []; 
while (my $task = $schedule->next()) {
  if ($task->{'rule'}->{'name'} eq 'rule_2_1') {
    $schedule->add('2', 
		   {'name' => 'rule_2_2'}, 
		   {'rid' => '2'},
		   $req_info_2
		  );
  } elsif ($task->{'rule'}->{'name'} eq 'rule_3_1') {
    $schedule->add('1', 
		   {'name' => 'rule_1_3'}, 
		   {'rid' => '1'},
		   $req_info_1
		  );
  }
  push(@{ $rl }, $task->{'rule'}->{'name'});
}

is_deeply($rl, 
	  ['rule_1_1',
	   'rule_1_2',
	   'rule_2_1',
	   'rule_2_2',
	   'rule_3_1',
	   'rule_3_2',
	   'rule_3_3',
	   'rule_1_3',
	  ]
	 );
$test_count++;


done_testing($test_count);



1;


