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
use charnames ':full';

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
use Kynetx::Modules::Random qw/:all/;
use Kynetx::Modules;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;



use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();

my $preds = Kynetx::Modules::Random::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;
my ($source,$result,$args,$function,$description);


# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
    $test_count++;
}




$description = "Random word from dictionary";
$source = 'random';
$function = 'word';
$args = [];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$logger->debug("Random word: $result");
cmp_deeply($result,re(qr/\w+/),$description);
$test_count++;

$description = "Random quote";
$source = 'random';
$function = 'quote';
$args = [];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$logger->debug("Random quote: ", sub {Dumper($result)});
cmp_deeply($result->{'json_class'},"Fortune",$description);
$test_count++;

$description = "Random math quote";
$source = 'random';
$function = 'fortune';
$args = [{"source" => "math"}];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$logger->debug("Random quote: ", sub {Dumper($result)});
cmp_deeply($result->{'source'},"math",$description);
$test_count++;

$description = "Random powerfuff quote";
$source = 'random';
$function = 'fortune';
$args = [{"source" => "powerpuff",
		"min_lines" => 2
}];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$logger->debug("Random quote: ", sub {Dumper($result)});
cmp_deeply($result->{'source'},"powerpuff",$description);
$test_count++;

$description = "Random Photo";
$source = 'random';
$function = 'photo';
$args = [];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$logger->debug("Random photo: ", sub {Dumper($result)});
cmp_deeply($result->{'media$content'}->[0]->{'url'},re(qr/https?:\/\/\w+/),$description);
$test_count++;

$description = "UUID string";
$source = 'random';
$function = 'uuid';
$args = [];
my $regexp = '\w{8}-\w{4}-\w{4}-\w{4}-\w{12}';

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$logger->debug("UUID string: ", sub {Dumper($result)});
cmp_deeply($result,re($regexp),$description);
$test_count++;


done_testing($test_count);



1;


