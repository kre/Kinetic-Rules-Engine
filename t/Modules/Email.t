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
use Email::MIME;
use MIME::QuotedPrint::Perl;
use Encode;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Modules::Email qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Parser qw/:all/;


use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();

my $preds = Kynetx::Modules::Email::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;

my($config, $mods, $args, $krl, $krl_src, $js, $result, $v);
my $description;
my $expected;
my $function;
my $str_re = qr/.+/;

###### Load emails
my @email_files = @ARGV ? @ARGV : </web/lib/perl/t/data/emails/*.txt>;
my $email_list = {};
foreach my $f (@email_files) {
    #next unless ($f eq '/web/lib/perl/t/data/emails/email07.txt');
    my ($key,$text) = getkrl($f);
    chop($key);
    $email_list->{$key} = $text;
    #diag Dumper($email_list);
}

#Log::Log4perl->easy_init($DEBUG);
##

##
$function = 'body';
$description = "Get Body (multipart html)";
$expected = re($str_re);
$args = [$email_list->{'// multipart text/html'}];
test_email($function,$args,$expected,$description,0);

#goto ENDY;

$function = 'parts';
$description = "Get all text/plain PNP (parts)";
$expected = array_each({"text/plain"=> re($str_re)});
$args = [$email_list->{'// PNP'},"text/plain"];
test_email($function,$args,$expected,$description,0);

##
$function = 'body';
$description = "Check PNP email (body)";
$expected = re($str_re);
$args = [$email_list->{'// PNP'},"text/plain"];
test_email($function,$args,$expected,$description,0);

##
$function = 'parts';
$description = "Get all parts (simple)";
$expected = array_each({"text/plain"=> re($str_re)});
$args = [$email_list->{'// Base64'},"text/plain"];
test_email($function,$args,$expected,$description,0);


# check that predicates at least run without error
$logger->debug("Email labels: ", sub {Dumper(keys %$email_list)});
my @dummy_arg = ($email_list->{'// multipart text/html'});
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
    $test_count++;
}

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
]);



# set variable and raise event
my $etext = $email_list->{"// multipart text/html"};
$krl_src = <<_KRL_;
pre {
text = <<
  $etext
    >>;
myM = email:multipart(text);
}
_KRL_

$krl = Kynetx::Parser::parse_pre($krl_src);
cmp_deeply($krl,array_each({"rhs" => ignore(),"lhs" => ignore(),'type'=>ignore()}),"KRL -> AST");
$test_count++;

##
$function = 'header';
$description = "Get all headers v1";
$expected = array_each(re($str_re));
$args = [$email_list->{'//simple'}];
test_email($function,$args,$expected,$description,0);

##
$function = 'header';
$description = "Get an header";
$expected = re($str_re);
$args = [$email_list->{'//simple'},"To"];
test_email($function,$args,$expected,$description,0);

##
$function = 'header';
$description = "Get multiple headers";
$expected = {"To" => ignore(),"Subject" => ignore()};
$args = [$email_list->{'//simple'},["To","Subject"]];
test_email($function,$args,$expected,$description,0);

##
$function = 'header';
$description = "Request an invalid header";
$expected = undef;
$args = [$email_list->{'//simple'},"Content-Type"];
test_email($function,$args,$expected,$description,0);

##
$function = 'header';
$description = "Get multiple headers (one invalid)";
$expected = {"To" => ignore(),"Subject" => ignore(),"Foo"=> undef};
$args = [$email_list->{'//simple'},["To","Subject","Foo"]];
test_email($function,$args,$expected,$description,0);

##
$function = 'parts';
$description = "Get all parts (simple)";
$expected = array_each({"text/plain"=> re($str_re)});
$args = [$email_list->{'//simple'}];
test_email($function,$args,$expected,$description,0);

##
$function = 'parts';
$description = "Get all parts (multipart)";
$expected = array_each({"text/plain"=> re($str_re)});
$args = [$email_list->{'//multipart'}];
test_email($function,$args,$expected,$description,0);

##
$function = 'parts';
$description = "Get all parts (multipart html)";
$expected = array_each(ignore());
$args = [$email_list->{'// multipart text/html'}];
test_email($function,$args,$expected,$description,0);


##
$function = 'body';
$description = "Get Body";
$expected = re($str_re);
$args = [$email_list->{'//complex'}];
test_email($function,$args,$expected,$description,0);


##
$function = 'body';
$description = "Get Body (sample)";
$expected = re($str_re);
$args = [$email_list->{'//sam*ple'}];
test_email($function,$args,$expected,$description,0);


## check for quoted printable
$function = 'parts';
$description = "Get plaintext parts (quoted-printable)";
$expected = array_each({'text/plain'=>ignore()});
$args = [$email_list->{'// quoted-printable'},'text/plain'];
test_email($function,$args,$expected,$description,0);

ENDY:

done_testing($test_count);

sub test_email {
    my ($function,$args,$expected,$description,$debug) = @_;
    $test_count++;
    #diag Dumper($args);
    my $json = Kynetx::Modules::Email::run_function($my_req_info,$function,$args);
    if ($debug) {
        $logger->info($description);
        $logger->info("Returned from run_function: ", sub { Dumper($json)});
    }
    cmp_deeply($json,$expected,$description);
    return $json;
}



1;


