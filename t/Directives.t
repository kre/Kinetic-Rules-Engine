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
use Kynetx::Response qw/:all/;
use Kynetx::Directives qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Persistence::Ruleset qw/:all/;


use Kynetx::FakeReq qw/:all/;

#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);
$my_req_info->{'directives'} = [];

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;

my $dd = Kynetx::Response->create_directive_doc();


send_directive($my_req_info, 
	       $dd,
	       "emit_js", 
	       {'js' => 'var domain = $K(obj).data("domain");'});

is($dd->directives()->[0]->type(), "emit_js");
$test_count++;


is_deeply($dd->directives()->[0]->options(), 
	  {'js' => 'var domain = $K(obj).data("domain");'}
  );
$test_count++;


emit_js($my_req_info, 
	$dd,
	'var domain = $K(obj).data("domain");');


is_deeply($dd->directives()->[0]->options()->{'js'}, 
	  $dd->directives()->[1]->options()->{'js'}, 
	 );
$test_count++;

my $vars = {'a' => 5, 'b' => ['a', 'foo']};

send_data($my_req_info,
	  $dd,
	  $vars
	 );


is_deeply($dd->directives()->[2]->options(), 
	  $vars
	 );
$test_count++;

#diag (Dumper to_directive($my_req_info->{'directives'}->[2], $my_req_info->{'eid'}));

is_deeply(to_directive($dd->directives()->[2], $my_req_info->{'eid'}),
	  {'options' => {'a' => 5,
			 'b' => [
				 'a',
				 'foo'
				]
			},
	   'name' => 'data',
	   'meta' => {'eid' => '0123456789abcdef'},
	  });
$test_count++;

done_testing($test_count);



1;


