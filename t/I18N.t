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
use utf8;

use Test::More;
use Test::LongString;
use Test::Deep;
use Test::WWW::Mechanize;

use Data::Dumper;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::Util;
use Kynetx::Datasets qw/:all/;
use Kynetx::FakeReq qw/:all/;
use Kynetx::Actions qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);
my $logger = get_logger();

my $test_num = 0;
my $utf8_ruleset = "data/utf8.krl";
my ($fl,$krl_text) = getkrl($utf8_ruleset);
my $hash;
my $v;

$logger->debug("Sample Ruleset: $fl");
my $uHan = "隻氣墊船裝滿晒鱔";
my $oHan = Kynetx::Util::str_out($uHan);

my $req_info;
$req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$req_info->{'rid'} = 'cs_test';
$req_info->{'pool'} = APR::Pool->new;


# Parser rulesets

my $result = Kynetx::Parser::utf8_parse_ruleset($krl_text);
ok(! defined ($result->{'error'}), "UTF8 Ruleset passes parser");
$test_num++;

my $globals = $result->{'global'};
foreach my $den (@$globals) {
	if ($den->{'type'} eq 'expr') {		
		if ($den->{'rhs'}->{'type'} eq 'str') {
			my $key = $den->{'lhs'};
			my $value = $den->{'rhs'}->{'val'};
			$hash->{$key} = $value;
		}
	}	
}

cmp_deeply($hash->{'hang'}, $uHan,"String is UTF8 encoded");
$test_num++;

my $utf8_file = "http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt";

# DATASET UTF8

my $krl_src = <<_KRL_;
global {
	dataset utf8_data:HTML <- "$utf8_file" cachable for 1 second;
}
_KRL_

my $krl = Kynetx::Parser::parse_global_decls($krl_src);
my $source = get_dataset($krl->[0],$req_info);
#my $utf8_str = Kynetx::Util::str_in('ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ ᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ');
my $utf8_str = 'ᚻᛖ ᚳᚹᚫᚦ ᚦᚫᛏ ᚻᛖ ᛒᚢᛞᛖ ᚩᚾ ᚦᚫᛗ ᛚᚪᚾᛞᛖ ᚾᚩᚱᚦᚹᛖᚪᚱᛞᚢᛗ ᚹᛁᚦ ᚦᚪ ᚹᛖᛥᚫ';
my $e_utf8 = Kynetx::Util::str_in($utf8_str);
$logger->trace($source);    
contains_string($source,$utf8_str,"UTF-8 datasets");
$test_num++;

#
# HTTP Get
#
my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

$req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

#  As an action

$krl_src = <<_KRL_;
http:get("$utf8_file") setting(i18n);	  
_KRL_

$krl = Kynetx::Parser::parse_action($krl_src)->{'actions'}->[0]; # just the first one
#diag Dumper $krl;


my $js = Kynetx::Actions::build_one_action(
	    $krl,
	    $req_info, 
	    $rule_env,
	    $session,
	    'callback23',
	    'dummy_name');
	   
$result = Kynetx::Environments::lookup_rule_env('i18n',$rule_env);
my $content = $result->{'content'};

contains_string($content,$utf8_str,"http:get action preserves UTF-8");
$test_num++;

# http:get statement
$krl_src = <<_KRL_;
r = http:get("$utf8_file");
_KRL_

$krl = Kynetx::Parser::parse_decl($krl_src);

($v,$result) = Kynetx::Expressions::eval_decl(
    $req_info,
    $rule_env,
    $rule_name,
    $session,
    $krl
    );

contains_string($result->{'content'},$utf8_str,"http:get statement preserves UTF-8");
$test_num++;


# Evented
my $platform = '127.0.0.1';
$platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
$platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');


my $dn = "http://$platform/blue/event";
my $mech = Test::WWW::Mechanize->new();

my $event_url = $dn . '/web/submit/a144x124?User+text=my+text&HEX+NCR='. $uHan .'&element=%23UTF8Form&kvars=%7B%7D&a144x124:kynetx_app_version=dev';
my $like = "/$uHan/";
$result = $mech->get($event_url);
$mech->content_like($like);

$logger->trace(sub{Dumper($mech->content())});
$test_num++;

done_testing($test_num);
1;


