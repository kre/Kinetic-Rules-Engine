package t::ExprTests;
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
use strict;
#use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
get_expr_testcases
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Terse = 1;


use Kynetx::Parser qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Configure;



my (@expr_testcases, $str, $val, $krl, $js);

sub get_expr_testcases {
  my ($rule_env) = @_;

    sub add_expr_testcase {
      my($krl,$type,$js,$expected,$diag) = @_;

      push(@expr_testcases, {'krl' => $krl,
			     'type' => $type,
			     'expected_js' => $js,
			     'expected_val' => $expected,
			     'diag' => $diag,
			    });
    }

    my $krl_src;

    $krl_src = <<_KRL_;
"absolute"
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'absolute'",
    mk_expr_node('str', 'absolute'),
    0);

    $krl_src = <<_KRL_;
"1234567890"
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'1234567890'",
    mk_expr_node('str', '1234567890'),
    0);

$krl_src = <<_KRL_;
city
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    'city',
    mk_expr_node('str', 'Blackfoot')
    );

$krl_src = <<_KRL_;
true
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    'true',
    mk_expr_node('bool', 'true')
    );

$krl_src = <<_KRL_;
false
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    'false',
    mk_expr_node('bool', 'false')
    );

$krl_src = <<_KRL_;
1022
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    1022,
    mk_expr_node('num', 1022)
    );


$krl_src = <<_KRL_;
5 + 6
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '(5 + 6)',
    mk_expr_node('num', 11),
    0);

$krl_src = <<_KRL_;
6 - 5
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '(6 - 5)',
    mk_expr_node('num', 1));

$krl_src = <<_KRL_;
5 * 7
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '(5 * 7)',
    mk_expr_node('num', 35),
    0);

$krl_src = <<_KRL_;
25 / 5
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '(25 / 5)',
    mk_expr_node('num', 5));

$krl_src = <<_KRL_;
 -5
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '-5',
    mk_expr_node('num', -5),
    0);

$krl_src = <<_KRL_;
"foo" + "bar"
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "('foo' + 'bar')",
    mk_expr_node('str', 'foobar'),
    0);


$krl_src = <<_KRL_;
"/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "('/cgi-bin/weather.cgi?city=' + (city + ('&tc=' + tc)))",
    mk_expr_node('str', '/cgi-bin/weather.cgi?city=Blackfoot&tc=15'),
    0);

$krl_src = <<_KRL_;
"/cgi-bin/weather.cgi?city=" + city + "&tc=" + tc + "foo=" + city + "fizz=" + tc
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "('/cgi-bin/weather.cgi?city=' + (city + ('&tc=' + (tc + ('foo=' + (city + ('fizz=' + tc)))))))",
    mk_expr_node('str', '/cgi-bin/weather.cgi?city=Blackfoot&tc=15foo=Blackfootfizz=15'),
    0);




$krl_src = <<_KRL_;
5 + temp
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "(5 + temp)",
    mk_expr_node('num', 25),
    0);

$krl_src = <<_KRL_;
(5 + 6) * 3
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "((5 + 6) * 3)",
    mk_expr_node('num', 33),
    0);

$krl_src = <<_KRL_;
5 + 6 * 3
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "(5 + (6 * 3))",
    mk_expr_node('num', 23),
    0);


#
# conditional expressions
#
$krl_src = <<_KRL_;
(true) => 5 | 6
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "true ? 5 : 6",
    mk_expr_node('num', 5),
    0);


$krl_src = <<_KRL_;
(5 > 6) => 5 | 6
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "(5 > 6) ? 5 : 6",
    mk_expr_node('num', 6),
    0);


$krl_src = <<_KRL_;
(5 > 6 || 4 > 3) => 5 | 6
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "((5 > 6) || (4 > 3)) ? 5 : 6",
    mk_expr_node('num', 5),
    0);



$krl_src = <<_KRL_;
[5, 6, 7]
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "[5, 6, 7]",
     mk_expr_node('array', [mk_expr_node('num', 5),
 			    mk_expr_node('num', 6),
 			    mk_expr_node('num', 7)]),
    0);

$krl_src = <<_KRL_;
[5, 6, temp]
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "[5, 6, temp]",
     mk_expr_node('array', [mk_expr_node('num', 5),
 			    mk_expr_node('num', 6),
 			    mk_expr_node('num', 20)]),
    0);

$krl_src = <<_KRL_;
[false, true, true, booltrue]
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "[false, true, true, booltrue]",
     mk_expr_node('array', [mk_expr_node('bool', 'false'),
 			    mk_expr_node('bool', 'true'),
  			    mk_expr_node('bool', 'true'),
 			    mk_expr_node('bool', 'true')]),
    0);

$krl_src = <<_KRL_;
[boolfalse, booltrue]
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "[boolfalse, booltrue]",
     mk_expr_node('array', [mk_expr_node('bool', 'false'),
 			    mk_expr_node('bool', 'true')]),
    0);


# $krl_src = <<_KRL_;
# page:id("foo")
# _KRL_
# add_expr_testcase(
#     $krl_src,
#     'expr',
#     '$K(\'foo\').html()',
#     mk_expr_node('JS', '$K(\'foo\').html()'),
#     0);


# $krl_src = <<_KRL_;
# page:id(city + "_ID")
# _KRL_
# add_expr_testcase(
#     $krl_src,
#     'expr',
#     '$K((city + \'_ID\')).html()',
#     mk_expr_node('JS', '$K(\'Blackfoot_ID\').html()'),
#     0);


$krl_src = <<_KRL_;
page:var("foo");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('num', 5),
    0);



$krl_src = <<_KRL_;
page:var("fo" + "o");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('num', 5),
    0);


# not in allowed (until we reinstate security patch, this will return Foo
$krl_src = <<_KRL_;
page:env("foozle");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
    mk_expr_node('str','Foo'),
    0);

$krl_src = <<_KRL_;
page:env("ip");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('str', '72.21.203.1'),
    0);

$krl_src = <<_KRL_;
page:url("protocol");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('str', 'http'),
    0);


$krl_src = <<_KRL_;
page:url("hostname");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
    mk_expr_node('str', 'www.windley.com'),
    0);


$krl_src = <<_KRL_;
page:url("domain");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('str', 'windley.com'),
    0);


$krl_src = <<_KRL_;
page:url("tld");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('str', 'com'),
    0);


$krl_src = <<_KRL_;
page:url("port");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('num', 80),
    0);

$krl_src = <<_KRL_;
page:url("path");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('str', '/archives/2008/07'),
    0);


$krl_src = <<_KRL_;
page:url("query");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
    mk_expr_node('str', 'q=foo'),
    0);


$krl_src = <<_KRL_;
page:param("datasets");
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
     mk_expr_node('str', "aaa,aaawa,ebates"),
    0);



$krl_src = <<_KRL_;
{"fizz": 3,
 "flip": 3 + 5,
 "flop": city + ", ID"}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "{'fizz' : 3, 'flip' : (3 + 5), 'flop' : (city + ', ID')}",
     mk_expr_node('hash',
		  {"fizz" => mk_expr_node('num',3),
		   "flip" => mk_expr_node('num',8),
		   "flop" => mk_expr_node('str',"Blackfoot, ID")}),
    0);


$krl_src = <<_KRL_;
{city: 3,
 4+5: 3 + 5,
 "#{city}_is" +"_cool": city + ", ID"}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "{city : 3, (4+5) : (3 + 5), (''+city+'_is'+ '_cool') : (city + ', ID')}",
     mk_expr_node('hash',
		  {"Blackfoot" => mk_expr_node('num',3),
		   9 => mk_expr_node('num',8),
		   "Blackfoot_is_cool" => mk_expr_node('str',"Blackfoot, ID")}),
    0);


#---------------------------------------------------------------------------------
# inequalities
#---------------------------------------------------------------------------------

$krl_src = <<_KRL_;
3 <= 5
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(3 <= 5)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
5 <= 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(5 <= 3)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
5 <= 5
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(5 <= 5)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
6 >= 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(6 >= 4)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
4 >= 6
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(4 >= 6)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
6 >= 6
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(6 >= 6)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
6 + 5 >= 4 + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((6 + 5) >= (4 + 3))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
6 + 5 <= 4 + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((6 + 5) <= (4 + 3))",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
3 < 5
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(3 < 5)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
5 < 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(5 < 3)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
5 < 5
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(5 < 5)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
6 > 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(6 > 4)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
6 < 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(6 < 4)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
6 > 6
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(6 > 6)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
6 + 5 > 4 + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((6 + 5) > (4 + 3))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
6 + 5 < 4 + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((6 + 5) < (4 + 3))",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
5 == 5
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(5 == 5)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
6 != 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(6 != 4)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
5 != 5
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(5 != 5)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
6 == 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(6 == 4)",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
5 == 5
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(5 == 5)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
6 + 3 != 4 * 44 + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((6 + 3) != ((4 * 44) + 3))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
4 * 5 == 5 * 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((4 * 5) == (5 * 4))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
3* (4 + 5) == 3 * 5 + 3 * 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((3* (4 + 5)) == ((3 * 5) + (3 * 4)))",
		  mk_expr_node('bool', 'true'),
		  0
    );





$krl_src = <<_KRL_;
3 <= temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(3 <= temp)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp <= 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp <= 3)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
temp <= temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp <= temp)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp >= 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp >= 4)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
4 >= temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(4 >= temp)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
temp >= temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp >= temp)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp + 5 >= temp + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((temp + 5) >= (temp + 3))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp + 5 <= temp + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((temp + 5) <= (temp + 3))",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
3 < temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(3 < temp)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp < 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp < 3)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
temp < temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp < temp)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
temp > 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp > 4)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp < 4
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  "(temp < 4)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
temp > temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp > temp)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
temp + 5 > temp + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((temp + 5) > (temp + 3))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp + 5 < temp + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((temp + 5) < (temp + 3))",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
temp == temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp == temp)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp != 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp != 4)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp != temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp != temp)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
temp == 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp == 4)",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
temp == temp
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(temp == temp)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
temp + 3 != temp * 44 + 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((temp + 3) != ((temp * 44) + 3))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
4 * temp == temp * 4
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((4 * temp) == (temp * 4))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
3* (4 + temp) == 3 * temp + 3 * 4
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  "((3* (4 + temp)) == ((3 * temp) + (3 * 4)))",
		  mk_expr_node('bool', 'true'),
		  0
    );





$krl_src = <<_KRL_;
"foo" eq "foo"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "('foo' == 'foo')",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
"foo" eq "bar"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "('foo' == 'bar')",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
"foo" neq "foo"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "('foo' != 'foo')",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
"foo" neq "bar"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "('foo' !=
 'bar')",
		  mk_expr_node('bool', 'true'),
		  0
    );


$krl_src = <<_KRL_;
city eq "Blackfoot"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(city == 'Blackfoot')",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
"foo" eq city
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "('foo' == city)",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
"Blackfoot" neq city
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "('Blackfoot' != city)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
city neq "bar"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(city != 'bar')",
		  mk_expr_node('bool', 'true'),
		  0
    );




$krl_src = <<_KRL_;
"foobar" like "foo.*"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'foobar'.match(/foo.*/)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
"foobar" like re/foo.*/
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'foobar'.match(/foo.*/)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
"bar" like ".*bar"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'bar'.match(/.*bar/)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
"bar" like re/.*bar/
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'bar'.match(/.*bar/)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
"foobar" like "^bar"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'foobar'.match(/^bar/)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
"bar" like "foo.*"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'bar'.match(/foo.*/)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
"bar" like "foo.*"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'bar'.match(/foo.*/)",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
"Bar" like "bar"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'Bar'.match(/bar/)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
"Bar" like re/bar/
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'Bar'.match(/bar/)",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
"Bar" like re/bar/i
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "'Bar'.match(/bar/i)",
		  mk_expr_node('bool', 'true'),
		  0
    );


#
# comparison
# 

$krl_src = <<_KRL_;
6 <=> 7
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  "(6 < 7 ? -1 : (6 > 7 ? 1 : 0))",
		  mk_expr_node('num',    -1),
		  0
    );

$krl_src = <<_KRL_;
temp <=> temp
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  "(temp<temp?-1:(temp>temp?1:0))",
		  mk_expr_node('num', 0),
		  0
    );


$krl_src = <<_KRL_;
7 <=> 6
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  "(7 < 6 ? -1 : (7 > 6 ? 1 : 0))",
		  mk_expr_node('num', 1),
		  0
    );

$krl_src = <<_KRL_;
string1 cmp string2
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  "(string1 < string2 ? -1 : (string1 > string2 ? 1 : 0))",
		  mk_expr_node('num',    -1),
		  0
    );

$krl_src = <<_KRL_;
string1 cmp string1
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  "(string1<string1?-1:(string1>string1?1:0))",
		  mk_expr_node('num', 0),
		  0
    );


$krl_src = <<_KRL_;
string2 cmp string1
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  "(string2 < string1 ? -1 : (string2 > string1 ? 1 : 0))",
		  mk_expr_node('num', 1),
		  0
    );


#
# Membership
#

$krl_src = <<_KRL_;
[5,6,7] >< 6
_KRL_
add_expr_testcase($krl_src,
		  'expr',
		  "(\$KOBJ.inArray(6,[5,6,7])!=-1)",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
[5,6,7] >< 3
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(\$KOBJ.inArray(3,[5,6,7])!=-1)",
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
store.pick("\$..price") >< 8.95
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );


$krl_src = <<_KRL_;
myHash >< "a"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((myHash instanceof Array) ? (\$KOBJ.inArray('a',myHash) != -1)  : (function(){var tmp = myHash;return (typeof(tmp.a) !== 'undefined')}()))",
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
myHash >< "fizzle"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "((myHash instanceof Array) ? (\$KOBJ.inArray('fizzle',myHash) != -1)  : (function(){var tmp = myHash;return (typeof(tmp.fizzle) !== 'undefined')}()))",
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
{"a": 1, "b" : 2} >< "a"
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  "(({'a' : 1, 'b' : 2} instanceof Array) ? (\$KOBJ.inArray('a',{'a' : 1, 'b' : 2}) != -1)  : (function(){var tmp = {'a' : 1, 'b' : 2};return (typeof(tmp.a) !== 'undefined')}()))
",
		  mk_expr_node('bool', 'true'),
		  0
    );


#
# Booleans
#

$krl_src = <<_KRL_;
true == true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  '(true == true)',
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
true == false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  '(true == false)',
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
true != true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  '(true != true)',
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
true != false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  '(true != false)',
		  mk_expr_node('bool', 'true'),
		  0
    );


$krl_src = <<_KRL_;
true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  'true',
		  mk_expr_node('bool','true'),
		  0
    );

$krl_src = <<_KRL_;
false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
		  'false',
		  mk_expr_node('bool','false'),
		  0
    );

$krl_src = <<_KRL_;
true && true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(true && true)',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
true && false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(true && false)',
		  mk_expr_node('bool',    'false'),
		  0
    );

$krl_src = <<_KRL_;
false && true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(false && true)',
		  mk_expr_node('bool',    'false'),
		  0
    );


$krl_src = <<_KRL_;
false && false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(false && false)',
		  mk_expr_node('bool',    'false'),
		  0
    );


$krl_src = <<_KRL_;
true || true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(true||true)',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
true || false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(true||false)',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
false || true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(false||true)',
		  mk_expr_node('bool',    'true'),
		  0
    );


$krl_src = <<_KRL_;
false || false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(false||false)',
		  mk_expr_node('bool',    'false'),
		  0
    );



$krl_src = <<_KRL_;
string1 || string2
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(string1||string2)',
		  mk_expr_node('str',    'aab'),
		  0
    );

$krl_src = <<_KRL_;
false || string2
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(false||string2)',
		  mk_expr_node('str',    'abb'),
		  0
    );

$krl_src = <<_KRL_;
true || string2
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(true||string2)',
		  mk_expr_node('bool',    'true'),
		  0
    );



$krl_src = <<_KRL_;
not true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
        '!true',
		  mk_expr_node('bool',    'false'),
		  0
    );

$krl_src = <<_KRL_;
not false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
        '!false',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
not true || not true
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(!true||!true)',
		  mk_expr_node('bool',    'false'),
		  0
    );

$krl_src = <<_KRL_;
not true || not false
_KRL_
add_expr_testcase(
    $krl_src,
'expr',
    '(!true||!false)',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
not false || not true
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  '(!false||!true)',
		  mk_expr_node('bool',    'true'),
		  0
    );


$krl_src = <<_KRL_;
not false || not false
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  '(!false||!false)',
		  mk_expr_node('bool',    'true'),
		  0
    );


##
## arrays
##

$krl_src = <<_KRL_;
c[0]
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  'c[0]',
		  mk_expr_node('num',    5),
		  0
    );


$krl_src = <<_KRL_;
c[1]
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  'c[1]',
		  mk_expr_node('num',    6),
		  0
    );


$krl_src = <<_KRL_;
c[2]
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  'c[2]',
		  mk_expr_node('num',    4),
		  0
    );




##
## entity vars
##
$krl_src = <<_KRL_;
ent:my_count < 3
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );


$krl_src = <<_KRL_;
ent:my_count == 3
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'false'),
		  0
    );



$krl_src = <<_KRL_;
ent:my_count > 1
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );

sleep(2);

$krl_src = <<_KRL_;
ent:my_count > 1 within 40 seconds
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );


$krl_src = <<_KRL_;
ent:my_count > 1 within 1 seconds
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
seen "windley.com" in ent:my_trail
_KRL_

add_expr_testcase($krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
seen "google.com" in ent:my_trail
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
seen "kynetx.com/foo.html" after "windley.com/foo.html" in ent:my_trail
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
seen "kynetx.com/foo.html" before "windley.com/foo.html" in ent:my_trail
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'false'),
		  0
    );

$krl_src = <<_KRL_;
seen "kynetx.+foo.html" after "windley.+foo.html" in ent:my_trail
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
seen "kynetx.com.foo.html" before "windley.com.foo.html" in ent:my_trail
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
seen "windley.com" in ent:my_trail within 1 minutes
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );


$krl_src = <<_KRL_;
seen "windley.com" in ent:my_trail within 1 second
_KRL_

add_expr_testcase(
    $krl_src,
'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
ent:my_flag
_KRL_

add_expr_testcase(
		  $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('num', 1),
		  0
    );


#---------------------------------------------------------------------------------
# Null Tests
#---------------------------------------------------------------------------------

$krl_src = <<_KRL_;
	null
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'null',
	mk_expr_node("null","__undef__"),
	0
);

$krl_src = <<_KRL_;
	1 + null
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("null","__undef__"),
	0
);

$krl_src = <<_KRL_;
	"foost" + null
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("null","__undef__"),
	0
);


$krl_src = <<_KRL_;
	(cabletron).isnull()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("bool","true"),
	0
);

$krl_src = <<_KRL_;
	("thing").isnull()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("bool","false"),
	0
);

#---------------------------------------------------------------------------------
# typeof tests
#---------------------------------------------------------------------------------

#primitives
$krl_src = <<_KRL_;
	(1).typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","num"),
	0
);

$krl_src = <<_KRL_;
	("1").typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","str"),
	0
);

$krl_src = <<_KRL_;
	(["1"]).typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","array"),
	0
);


$krl_src = <<_KRL_;
	({}).typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","hash"),
	0
);

$krl_src = <<_KRL_;
	(null).typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","null"),
	0
);


# using vars from rule_env
$krl_src = <<_KRL_;
	city.typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","str"),
	0
);

$krl_src = <<_KRL_;
	temp.typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","num"),
	0
);

$krl_src = <<_KRL_;
	booltrue.typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","bool"),
	0
);

$krl_src = <<_KRL_;
	boolfalse.typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","bool"),
	0
);

$krl_src = <<_KRL_;
	c.typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","array"),
	0
);

$krl_src = <<_KRL_;
	foop.typeof()
_KRL_

add_expr_testcase(
	$krl_src,
	'expr',
	'_ignore_',
	mk_expr_node("str","null"),
	0
);

$krl_src = <<_KRL_;
c = null;
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = null;',
    '__undef__',
    0);


#---------------------------------------------------------------------------------
# functions and predicates
#---------------------------------------------------------------------------------


$krl_src = <<_KRL_;
demographics:urban()
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
demographics:rural()
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'false'),
		  0
    );

$krl_src = <<_KRL_;
demographics:median_income_above(5000)
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
demographics:median_income_below(50000)
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );


$krl_src = <<_KRL_;
demographics:urban() && demographics:median_income_below(50000)
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );


$krl_src = <<_KRL_;
demographics:urban() || demographics:median_income_below(50000)
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',   'true'),
		  0
    );

$krl_src = <<_KRL_;
demographics:rural() || demographics:median_income_below(50000)
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
demographics:urban() || demographics:median_income_below(1000)
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );


$krl_src = <<_KRL_;
not demographics:rural()
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
not demographics:urban() || not demographics:median_income_below(1000)
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
not (demographics:urban() && demographics:median_income_below(1000))
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );


$krl_src = <<_KRL_;
location:country_code() eq "US"
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
location:country_code() eq "GB"
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'false'),
		  0
    );

$krl_src = <<_KRL_;
location:country_code() eq "US" && demographics:urban()
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
page:var("foo") > 3
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
page:var("foo") >= 5
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
3 + page:var("foo") >= 5
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
page:var("foo") * 2 >= 5
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
3 < page:var("foo") * 2
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
page:var("bar") eq "fizz"
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );

$krl_src = <<_KRL_;
page:var("bar") + "er" eq "fizzer"
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool',    'true'),
		  0
    );




$krl_src = <<_KRL_;
demographics:urban() && "Seattle" eq location:city()
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
demographics:urban() && location:city() eq "Seattle"
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );


$krl_src = <<_KRL_;
demographics:urban() && city2 eq location:city()
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
demographics:urban() && location:city() eq city2
_KRL_
add_expr_testcase(
    $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );

$krl_src = <<_KRL_;
demographics:urban() && location:city() eq "Sea" + "ttle"
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );


#---------------------------------------------------------------------------------
# user-defined functions
#---------------------------------------------------------------------------------
$krl_src = <<_KRL_;
function(x,y) {
	b = x + y;
	b;
}
_KRL_
add_expr_testcase(
	$krl_src,
	'expr',
	'function(x,y) {var b = (x + y); return b}',
	mk_expr_node('closure',{'vars' => ['x','y'],
					'decls' => [ {
         'lhs' => 'b',
         'rhs' => {'args' => [
			      {
			       'val' => 'x',
			       'type' => 'var'
			      },
			      {
			       'val' => 'y',
			       'type' => 'var'
			      }
			     ],
		   'type' => 'prim',
		   'op' => '+'
		  },
         'type' => 'expr'
       }
					],
					'sig' => 'e3a67271dec96c050738f32b4017100b',
					'expr' => {'val' => 'b','type'=>'var'},
					'env' => $rule_env,
	}),
	0
);


$krl_src = <<_KRL_;
function(x) {
      x
    }
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    'function(x) {return x}',
    mk_expr_node('closure', {'vars' => ['x'],
			     'decls' => [],
			     'sig' => '440dcf65d6fa90d64db50f722121eecb',
			     'expr' => {'val' => 'x',
					'type' => 'var'
				       },
			     'env' => $rule_env
			    }
		 ),
    0);


$krl_src = <<_KRL_;
function(x) {
      y = x + 3;
      (y < 5)
    }
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    'function(x) {var y = (x + 3); return (y < 5)}',
    mk_expr_node('closure', {'vars' => ['x'],
			     'decls' => [{'rhs' => {
						    'args' => [
							       {
								'val' => 'x',
								'type' => 'var'
							       },
							       {
								'val' => 3,
								'type' => 'num'
							       }
							      ],
						    'type' => 'prim',
						    'op' => '+'
						   },
					  'lhs' => 'y',
					  'type' => 'expr'
					 }
					],
			     'sig' => '35bb6d4e09fcc3cf07d5fddeb606a676',
			     'expr' => {'args' => [
						   {
						    'val' => 'y',
						    'type' => 'var'
						   },
						   {
						    'val' => 5,
						    'type' => 'num'
						   }
						  ],
					'type' => 'ineq',
					'op' => '<'
				       },
			     'env' => $rule_env
			    }
		 ),
    0);


$krl_src = <<_KRL_;
function() {
  d = << Count is #{ent:my_count} >>;
  "Count is #{ent:my_count}"
}
_KRL_
add_expr_testcase(
	$krl_src,
	'expr',
	"function() {var d = 'Count is 0'; return 'Count is ' + 'UNTRANSLATABLE KRL EXPRESSION'+''}",
	mk_expr_node('closure',{'vars' => [],
				'decls' => [ 
       {
         'lhs' => 'd',
         'rhs' => ' Count is #{ent:my_count} ',
         'type' => 'here_doc'
       }

					   ],
					'sig' => 'b762cedd25052718f90b2540841e859d',
					'expr' => {'val' => 'Count is #{ent:my_count}','type'=>'str'},
					'env' => $rule_env,
	}),
	0
);


# requires foo to be defined in env as function above
$krl_src = <<_KRL_;
foo(5)
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'false'),
		  0
    );


$krl_src = <<_KRL_;
foo(1)
_KRL_
add_expr_testcase(
		  $krl_src,
		  'expr',
		  '_ignore_',
		  mk_expr_node('bool', 'true'),
		  0
    );


#
#  Modulus Test Cases
#
$krl_src = <<_KRL_;
(23 % 5) + 1
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '((23 % 5) + 1)',
    mk_expr_node('num', 4),
    0);


$krl_src = <<_KRL_;
23 % 5 + 1
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '((23 % 5) + 1)',
    mk_expr_node('num', 4),
    0);

$krl_src = <<_KRL_;
21 % 7
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '(21 % 7)',
    mk_expr_node('num', 0),
    0);

$krl_src = <<_KRL_;
1 + 31 % 5
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '(1 + (31 % 5))',
    mk_expr_node('num', 2),
    0);

$krl_src = <<_KRL_;
6 * 31 % 5
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '(6 * (31 % 5))',
    mk_expr_node('num', 6),
    0);






#---------------------------------------------------------------------------------
# declarations
#---------------------------------------------------------------------------------

$krl_src = <<_KRL_;
c = 3;
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = 3;',
    '3',
    0);

$krl_src = <<_KRL_;
c=3;
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = 3;',
    '3',
    0);


$krl_src = <<_KRL_;
c = -5;
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = -5;',
    '-5',
    0);

$krl_src = <<_KRL_;
c = 3 + a;
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = 13;',
    '13',
    0);


$krl_src = <<_KRL_;
c = b * a;
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = 110;',
    '110',
    0);


$krl_src = <<_KRL_;
c = b + store.pick("\$..book[1].price");
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = 23.99;',
    '23.99',
    0);


$krl_src = <<_KRL_;
c = b + store.pick("\$..book[-1:].price");
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var c = 33.99;',
    '33.99',
    0);


$krl_src = <<_KRL_;
c = "I love " + store.pick("\$..book[0].author");
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    "var c = 'I love Nigel Rees';",
    'I love Nigel Rees',
    0);

$krl_src = <<_KRL_;
d = ent:my_count + 3
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    'var d = 5;',
    5,
    0);

$krl_src = <<_KRL_;
d = 2 * ent:my_count
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    "var d = 4;",
    4,
    0);

$krl_src = <<_KRL_;
d = current ent:my_trail
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    "var d = 'http://www.windley.com/bar.html';",
    'http://www.windley.com/bar.html',
    0);

$krl_src = <<_KRL_;
d = history 2 ent:my_trail
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    "var d = 'http://www.windley.com/foo.html';",
    'http://www.windley.com/foo.html',
    0);


$krl_src = <<_KRL_;
d = (history 2 ent:my_trail).replace(re/foo.html/,"hello.html") + ''
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    "var d = 'http://www.windley.com/hello.html';",
    'http://www.windley.com/hello.html',
    0);



$krl_src = <<_KRL_;
d = "#{ent:my_count}"
_KRL_
add_expr_testcase(
    $krl_src,
    'decl',
    "var d = '2';",
    2,
    0);


#--------------------------------------------------------------------------------
# prelude testing
#--------------------------------------------------------------------------------


my $re1 = extend_rule_env(['c'],
			  ['Hello'],
			  $rule_env);
$krl_src = <<_KRL_;
pre {
    c = "Hello";
}
_KRL_

$js = <<_JS_;
var c = 'Hello';
_JS_


add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);


$re1 = extend_rule_env(['c','d'],
		       ['Hello','Hello world!'],
		       $rule_env);
$krl_src = <<_KRL_;
pre {
    c = "Hello";
    d = c + " world!";
}
_KRL_

$js = <<_JS_;
var c = 'Hello';
var d = 'Hello world!';
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);


$re1 = extend_rule_env(['c','d'],
		       ['Hello',"\nHello world!"],
		       $rule_env);
$krl_src = <<_KRL_;
pre {
    c = "Hello";
    d = <<
#{c} world!>>;
}
_KRL_

$js = <<_JS_;
var c = 'Hello';
var d = '\\nHello world!';
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);

$re1 = extend_rule_env(['a','b','multiline'],
            ['1','3','
1
3
'],
            $rule_env);
$krl_src = <<_KRL_;
pre {
    a = "1";
    b = "3";
    multiline = <<
#{a}
#{b}
>>;
}
_KRL_

$js = <<_JS_;
var a = '1';
var b = '3';
var multiline = '\\n1\\n3\\n';
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);



$re1 = extend_rule_env(['kx','ky'],
    ['windley.com','$..windley.com']
    ,$rule_env);

$krl_src = <<_KRL_;
pre {
    kx = page:url("domain");
    ky = "\$\.\.#{kx}";
}
_KRL_


$js = <<_JS_;
var kx = 'windley.com';
var ky = '\$\.\.windley.com';
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);

$re1 = extend_rule_env(['kx'],
	[['Nigel Rees','Herman Melville']],
	$rule_env);
$krl_src = <<_KRL_;
pre {
    kx = store.pick("\$..book[?(@.price < #{a})].author");
}
_KRL_

$js = <<_JS_;
var kx = ['Nigel Rees','Herman Melville'];
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);


$re1 = extend_rule_env(['fact','x'],
	[{'val' => {
		    'sig' => '435c8f0d1eae220769d7506ba326264f',
		    'expr' => {
			       'test' => {
					  'args' => [
						     {
						      'val' => 'n',
						      'type' => 'var'
						     },
						     {
						      'val' => 0,
						      'type' => 'num'
						     }
						    ],
					  'type' => 'ineq',
					  'op' => '<='
					 },
			       'then' => {
					  'val' => 1,
					  'type' => 'num'
					 },
			       'else' => {
					  'args' => [

						     {
						      'val' => 'n',
						      'type' => 'var'
						     },
						     {
						      'args' => [
								 {
								  'args' => [
									     {
									      'val' => 'n',
									      'type' => 'var'
									     },
									     {
									      'val' => 1,
									      'type' => 'num'
									     }
									    ],
								  'type' => 'prim',
								  'op' => '-'
								 }
								],
						      'function_expr' => {
									  'val' => 'fact',
									  'type' => 'var'
									 },
						      'type' => 'app'
						     }
						    ],
					  'type' => 'prim',
					  'op' => '*'
					 },
			       'type' => 'condexpr'
			      },
		    'env' => Test::Deep::ignore(),
		    'vars' => [
			       'n'
			      ],
		    'decls' => []
		   },
	  'type' => 'closure'
	 },
	 120],
		       $rule_env);

$krl_src = <<_KRL_;
pre {
   fact = function(n) {
             (n <= 0) => 1
                       | n * fact(n-1)
          };
   x = fact(5);
}
_KRL_

$js = <<_JS_;
var fact = function(n) {return (n <= 0) ? 1 : (n * fact((n - 1)))};
var x = 120;
_JS_

my $function_call_threshold = Kynetx::Configure::get_config("FUNCTION_CALL_THRESHOLD") || 100;
$function_call_threshold++;

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);



$re1 = extend_rule_env(['inc','x'],
        [{'val' => {
		    'sig' => '4af1415f30a34055937721753dc218fe',
		    'expr' => {
			       'test' => {
					  'args' => [
						     {
						      'val' => 'n',
						      'type' => 'var'
						     },
						     {
						      'val' => 0,
						      'type' => 'num'
						     }
						    ],
					  'type' => 'ineq',
					  'op' => '<='
					 },
			       'then' => {
					  'val' => 0,
					  'type' => 'num'
					 },
			       'else' => {
					  'args' => [
						     {
						      'val' => 1,
						      'type' => 'num'
						     },
						     {
						      'args' => [
								 {
								  'args' => [
									     {
									      'val' => 'n',
									      'type' => 'var'
									     },
									     {
									      'val' => 1,
									      'type' => 'num'
									     }
									    ],
								  'type' => 'prim',
								  'op' => '-'
								 }
								],
						      'function_expr' => {
									  'val' => 'inc',
									  'type' => 'var'
									 },
						      'type' => 'app'
						     }
						    ],
					  'type' => 'prim',
					  'op' => '+'
					 },
			       'type' => 'condexpr'
			      },
		    'env' => Test::Deep::ignore(),
		    'vars' => [
			       'n'
			      ],
		    'decls' => []
		   },
	  'type' => 'closure'
	 },
	 $function_call_threshold],
		       $rule_env);

$krl_src = <<_KRL_;
pre {
   inc = function(n) {
             (n <= 0) => 0
                       | 1 + inc(n-1)
          };
   x = inc(2010);
}
_KRL_

$js = <<_JS_;
var inc = function(n) {return (n <= 0) ? 0 : (1 + inc((n - 1)))};
var x = $function_call_threshold;
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);




#-------------------------------------------------------------------------------
# predicate guards
#-------------------------------------------------------------------------------



$krl_src = <<_KRL_;
pre {
  a3 = [4,5,6];
  b3 = a3.length() > 0 && a3[0];
}
_KRL_

$js = <<_JS_;
var a3 = [4,5,6];
var b3 = 4;
_JS_

$re1 = extend_rule_env(['a3','b3'],
		       [[4,5,6],4],
		       $rule_env);


add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);



$krl_src = <<_KRL_;
pre {
  a3 = [];
  b3 = a3.length() > 0 && a3[0];
}
_KRL_

$js = <<_JS_;
var a3 = [];
var b3 = false;
_JS_

$re1 = extend_rule_env(['a3','b3'],
		       [[],JSON::XS::false],
		       $rule_env);


add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);


$krl_src = <<_KRL_;
pre {
  a3 = [4,5,6];
  b3 = a3.length() > 0 || 6;
}
_KRL_

$js = <<_JS_;
var a3 = [4,5,6];
var b3 = true;
_JS_

$re1 = extend_rule_env(['a3','b3'],
		       [[4,5,6],JSON::XS::true],
		       $rule_env);


add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);



$krl_src = <<_KRL_;
pre {
  a3 = [];
  b3 = a3.length() > 0 || 6;
}
_KRL_

$js = <<_JS_;
var a3 = [];
var b3 = 6;
_JS_

$re1 = extend_rule_env(['a3','b3'],
		       [[],6],
		       $rule_env);


add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);



#-------------------------------------------------------------------------------
# hash/struct testing
#-------------------------------------------------------------------------------
$re1 = extend_rule_env(['a','b'],
		       [{'y'=> 5},[{'y' => 5}]],
		       $rule_env);


$krl_src = <<_KRL_;
pre {
  a = {"y": 5};
  b = [{"y": 5}];
}
_KRL_

$js = <<_JS_;
var a = {'y': 5};
var b = [{'y': 5}];
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0);



$krl_src = <<_KRL_;
pre {
  foo = function(x){x};
  w = foo({"x":5})
}
_KRL_

$re1 = extend_rule_env(['foo','w'],
		       [{'val' => {'sig' => '440dcf65d6fa90d64db50f722121eecb',
				   'expr' => {
					     'val' => 'x',
					     'type' => 'var'
					    },
				   'env' => Test::Deep::ignore(),
				   'vars' => [
					      'x'
					     ],
				   'decls' => []
				  },
			 'type' => 'closure'
			},
			{"x" => 5}
		       ],
		       $rule_env);

add_expr_testcase(
		  $krl_src,
		  'pre',
		  '_ignore_',
		  $re1,
		  0
    );


$re1 = extend_rule_env(['a','b','c'],
		       [[{"foo"=>"bar"},
			 {"bar"=>"baz"}],
                        [{"foo" => "bar"}, {"bar" => "baz"}],
                        [[], 'baz']],
		       $rule_env);


$krl_src = <<_KRL_;
pre {
  a = [{"foo": "bar"}, {"bar": "baz"}];
  b = a.map(function(x){ x });
  c = a.map(function(x){ x.pick("\$.bar") });
}
_KRL_

$js = <<_JS_;
var a = [{'foo': 'bar'}, {'bar': 'baz'}];
var b = [{'foo': 'bar'}, {'bar': 'baz'}];
var c = [[], 'baz'];
_JS_

add_expr_testcase(
    $krl_src,
    'pre',
    $js,
    $re1,
    0
   );

$krl_src = <<_KRL_;
myHash{["b", "f", "g",1]}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '{}',
    mk_expr_node('str', '3.b'),
    0);;


$krl_src = <<_KRL_;
c[1]
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    'c[1]',
    mk_expr_node('num', 6),
    0);;

$krl_src = <<_KRL_;
myHash{"d"}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '{}',
    mk_expr_node('num', '1.3'),
    0);
    
    
$krl_src = <<_KRL_;
myHash{"b"}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '{}',
    mk_expr_node('hash', {
    'e' => '2.2',
    'c' => '2.1',
    'f' => {
      'h' => 5,
      'g' => [
        '3.a',
        '3.b',
        '3.c',
        '3.d'
      ]
    }}),
    0);

$krl_src = <<_KRL_;
myHash{g}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    '{}',
    mk_expr_node('num',1.1),
    0);

$krl_src = <<_KRL_;
ent:tHash{g}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
    mk_expr_node('num',1.1),
    0);

$krl_src = <<_KRL_;
ent:tHash{"a"}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
    mk_expr_node('num',1.1),
    0);

$krl_src = <<_KRL_;
ent:tHash{["b","f","g"]}
_KRL_
add_expr_testcase(
    $krl_src,
    'expr',
    "'UNTRANSLATABLE KRL EXPRESSION'",
    mk_expr_node('array',['3.a','3.b','3.c','3.d']),
    0);



	 
#----------------------------------------------------------------------------
# we're done--send 'em back
#----------------------------------------------------------------------------
  return \@expr_testcases;
}


1;


