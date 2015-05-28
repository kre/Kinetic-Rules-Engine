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

Kynetx::Errors::raise_error($my_req_info, 
			    'warn',
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

Kynetx::Errors::raise_error($my_req_info, 
			    'warn',
			    "[keys] invalid operator argument",
			    {'rule_name' => $rule_name,
			     'genus' => 'flopper',
			     'species' => 'type mismatch'
			    }
			   );


#diag Dumper $my_req_info->{'schedule'};

$rl = []; 
while (my $task = $my_req_info->{'schedule'}->next()) {
#	$logger->debug("Task: ",sub {Dumper($task)});
	push(@{ $rl }, $task->{'req_info'}->{"event_attrs"}->{'error_rid'});	
}


is_deeply($rl, ['cs_test.prod'], "see the RID the error is from");
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


