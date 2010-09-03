#!/usr/bin/perl -w

#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
#
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
#
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
#
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
#
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
#
use lib qw(/web/lib/perl);
use strict;


use Test::More;
use Test::Deep;
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);


use Kynetx::Test qw/:all/;
use Kynetx::JParser qw/:all/;
use Kynetx::Parser qw(:all);
use Kynetx::Configure;
use Kynetx::Json qw(:all);

Kynetx::Configure::configure();
my $logger = get_logger();

# grab the test data file names
my @krl_files = @ARGV ? @ARGV : <data/*.krl>;

# all the files in the rules repository
#my @krl_files = @ARGV ? @ARGV : </web/work/krl.kobj.net/rules/client/*.krl>;

# testing some...
# my @krl_files = <new/ineq[0-0].krl>;
#my @krl_files = <new/*.krl>;

plan tests => $#krl_files+1;

#Kynetx::JParser::env();

my $p = << "_KRL_";
pre {
  a = 10;
  b = 11;
  c = [4,5,6];
  i = [7,3,5,2,1,6];
  d = [];
  e = "this";
  f = [7,4,3,5,2,1,6];
  g = 5;
  h = [1,2,1,3,4,3,5,4,6,5];
  foo = "I like cheese";
  my_str = "This is a string";
  split_str = "A;B;C";
  my_url = "http://www.amazon.com/gp/products/123456789/";
  in_str = <<
  th[colspan="2"]
>>;
  my_jstr = <<
    {"www.barnesandnoble.com":[{"link":"http://aaa.com/barnesandnoble","text":"AAA members save money!","type":"AAA"}]}
>>;
  bad_jstr = <<
    "www.barnesandnoble.com":[{"link":"http://aaa.com/barnesandnoble","text":"AAA members save money!","type":"AAA"}]}
>>;
  a_s = ['apple','pear','orange','tomato'];
  b_s = ['string bean','corn','carrot','tomato','spinach'];
  c_s = ['wheat','barley','corn','rice'];
  d_s = ['','pear','corn'];
  e_s = '';
  f_s = ['corn','tomato'];
  g_s = ['corn','tomato','tomato','tomato','sprouts','lettuce','sprouts'];
  html_arr = [q_html,r_html];
  meta_str = <<td[style="background: #ddf;"]>>;
  mail_str = <<
  Dear Scott,

  We have placed your MRI images in your Personal Data Store. Based on the
  results we recommend that you select an orthopedic surgeon and set an
  appointment for a consultation. Please call our office with any questions.
  Next steps:
      * Select an orthopedic surgeon
      * Set an appointment for a consultation



  Best Regards,

  The office of Dr. William Chan

  >>;
  mail2_str = << Dear Scott,\r\n\r\nWe have placed your MRI images in your Personal Data Store. Based on the \r\nresults we recommend that you select an orthopedic surgeon and set an \r\nappointment for a consultation. Please call our office with any questions.\r\n\r\nNext steps:\r\n\r\n    * Select an orthopedic surgeon\r\n    * Set an appointment for a consultation\r\n\r\n\r\nBest Regards,\r\n\r\nThe office of Dr. William Chan\r\n>>;
  a_h = { "colors of the wind" : "many","pi as array" : [3,1,4,1,5,6,9]};
  b_h = {"mKey" : "mValue"};
  c_h = [{"hKey" : "hValue"}];
  d_h = [{"hKey" : "hValue"},{"mKey" : "mValue"}];
  e_h = [{"hKey" : "hValue"},{"mKey" : "mValue"},"Thing"];
  f_h = {"hKey" : {"innerKey" : "innerVal"}};
  g_h = {"hKey" : {"innerKey" : "REPLACED"}};
  i_h = {"hKey" : {"innerKey" : "innerVal"},"mKey" : "mValue"};
}

_KRL_

my $rs =<<END;
ruleset 10 {
    rule test0 is active {
        select using "/test/"
        replace("test","test");
    }
}
END

my $rs1 = <<END;
ruleset 10 {
    rule test0 is active {
        select using "/test/(.*)/" setting(name)
        pre {
            tc = weather:tomorrow_cond_code();
        city = geoip:city();
    }
        if (time:nighttime() && location:outside_state("UT"))
        then
    alert("hello");

    }
}
END

my $meta = <<END;
    meta {
      name "Ruleset for Orphans"
      description <<
Ruleset for testing something or other.
>>

      use module a61x59
      use module a61x60

    }

END

my $jparser = new Kynetx::JParser::Ahandle();
my $ptree = $jparser->doer($meta);
my $ast = Kynetx::Json::jsonToAst_w($ptree);
my $o_ast = Kynetx::Parser::parse_ruleset($meta);
cmp_deeply($o_ast,$ast,"Compare rules");
$logger->debug("Perl AST: ", sub {Dumper($ast)});
$logger->debug("Old AST: ", sub {Dumper($o_ast)});
ok(1);

1;


