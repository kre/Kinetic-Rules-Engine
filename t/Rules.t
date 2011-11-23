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

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use Geo::IP;
use Cache::Memcached;
use LWP::Simple;
use LWP::UserAgent;
use JSON::XS;
use APR::Pool ();

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Rules qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Modules qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Persistence qw/:all/;
use Kynetx::Response qw/:all/;
use Kynetx::Rids qw/:all/;


use Kynetx::FakeReq;

use Log::Log4perl::Level;
#use Log::Log4perl::Appender::FileLogger;
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($WARN);
#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $r = Kynetx::Test::configure();

# configure logging for production, development, etc.
#config_logging($r);
#Kynetx::Util::turn_off_logging();


my $rid = 'cs_test';

# test choose_action and args



my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();


my $my_req_info = Kynetx::Test::gen_req_info($rid);

#diag Dumper $rule_env;

my $session = Kynetx::Test::gen_session($r, $rid);


my $krl_src;
my $js;
my $test_count;
my $config;
my $config2;

#diag "_____________________________START TEST____________________________";
sub local_gen_req_info {
  my($rid) = @_;

  return Kynetx::Test::gen_req_info($rid,
				    {'ip' =>  '72.21.203.1',
				     'txn_id' => 'txn_id',
				     'caller' => 'http://www.google.com/search',
				    });
}

my $dummy_final_req_info = undef;
my $final_req_info = {};


#diag Dumper gen_req_info();

# $Amazon_req_info->{'ip'} = '72.21.203.1'w; # Seattle (Amazon)
# $Amazon_req_info->{'rid'} = $rid;
# $Amazon_req_info->{'txn_id'} = 'txn_id';
# $Amazon_req_info->{'caller'} = 'http://www.google.com/search';

my (@test_cases, $json, $krl,$result);

sub add_testcase {
    my($str, $expected, $final_req_info, $diag) = @_;

#     if ($diag) {
#       Kynetx::Util::turn_on_logging();
#     } else {
#       Kynetx::Util::turn_off_logging();
#     }

    my $pt;
    my $type = '';
    if($str =~ m#^ruleset#) {
	$pt = Kynetx::Parser::parse_ruleset($str);
	$type = 'ruleset';
     } else {
	$pt = Kynetx::Parser::parse_rule($str);
	$type = 'rule';
     }
    if ($pt->{'error'}) {
      diag $str;
      diag $pt->{'error'};
    }



    chomp $str;
    diag("$str = ", Dumper($pt)) if $diag;


    push(@test_cases, {'expr' => $pt,
		       'val' => $expected,
		       'session' => $session,
		       'src' =>  $str,
		       'type' => $type,
		       'final_req_info' => $final_req_info,
		       'diag' => $diag
	 }
	 );
}


sub add_json_testcase {
    my($str, $expected, $final_req_info, $diag) = @_;
    my $val = Kynetx::Json::jsonToAst($str);

    chomp $str;
    diag("$str = ", Dumper($val)) if $diag;


    push(@test_cases, {'expr' => $val,
		       'val' => $expected,
		       'session' => $session,
		       'src' =>  $str,
		       'final_req_info' => $final_req_info,
		       'type' => 'rule',
	 }
	);
}

#goto ENDY;
#
# note if the rules don't have unique names, you can get rule environment cross
# contamination
#

$krl_src = <<_KRL_;
rule test_1 is active {
  select using "/archives/" setting ()
  alert("testing");
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_1'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'testing'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );

$krl_src = <<_KRL_;
rule test_2 is active {
  select using "/archives/" setting ()
  pre {
      c = location:city();
  }
  alert("testing " + c);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_2'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
var c = 'Seattle';
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'testing Seattle'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_3 is active {
  select using "/archives/" setting ()
  pre {
      c = location:city();
  }
  if demographics:urban() then
    alert("testing " + c);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_3'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$result = <<_JS_;
(function(){
var c = 'Seattle';
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'testing Seattle'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_4 is active {
  select using "/archives/" setting ()
  pre {
      c = location:city();
  }
  if demographics:urban() && location:city() eq "Seattle" then
    alert("testing " + c);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_4'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$result = <<_JS_;
(function(){
var c = 'Seattle';
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'testing Seattle'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );

#
# entity vars
#

$krl_src = <<_KRL_;
rule test_flag_1 is active {
  select using "/archives/" setting ()

    if ent:my_flag then
      alert("test");

    fired {
      clear ent:my_flag
    } else {
      set ent:my_flag
    }
  }
_KRL_

# empty because rule does fire.  It increments counter so next rule fires
$result = <<_JS_;
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


# should fire now!
$krl_src = <<_KRL_;
rule test_flag_1 is active {
  select using "/archives/" setting ()

    if ent:my_flag then
      alert("test");

    fired {
      clear ent:my_flag
    } else {
      set ent:my_flag
    }
  }
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_flag_1'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );



# this shouldn't fire first time
$krl_src = <<_KRL_;
rule test_5 is active {
  select using "/archives/" setting ()

    pre {
      c = ent:archive_pages_now;
    }

    if ent:archive_pages_now > 2 then
      alert("test");

    fired {
      clear ent:archive_pages_now;
    } else {
      ent:archive_pages_now += 1 from 1;
    }
  }
_KRL_


# empty because rule does fire.  It increments counter so next rule fires
$result = <<_JS_;
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );

# this should fire
$krl_src = <<_KRL_;
rule test_5a is active {
  select using "/archives/" setting ()

    pre {
      c = ent:archive_pages_now;
    }

    if ent:archive_pages_now > 2 then
      alert("test");

    fired {
      clear ent:archive_pages_now;
    } else {
      ent:archive_pages_now += 1 from 1;
    }
  }
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_5a'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
var c = 3;
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


# use different counter since previous test clears it!
$krl_src = <<_KRL_;
rule test_6 is active {
  select using "/archives/" setting ()

    pre {
      c = ent:archive_pages_now2;
    }

    if ent:archive_pages_now2 > 2 within 2 days then
      alert("test");

    fired {
      clear ent:archive_pages_now2;
    } else {
      ent:archive_pages_now2 += 1 from 1;
    }
  }
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_6'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$result = <<_JS_;
(function(){
var c = 3;
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_7 is active {
  select using "/archives/" setting ()

    pre {
      c = ent:archive_pages_old;
    }

    if ent:archive_pages_old > 2 within 2 days then
      alert("test");

    fired {
      clear ent:archive_pages_old;
    } else {
      ent:archive_pages_old += 1 from 1;
    }
  }
_KRL_

# result is empty (rule shouldn't fire)
$result = <<_JS_;
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );

$krl_src = <<_KRL_;
rule test_trail_1 is active {
  select using "/archives/" setting ()

    if seen "windley.com" in ent:my_trail then
      alert("test");

    fired {
      mark ent:my_trail
    }
  }
_KRL_

#my $r = Kynetx::Parser::parse_rule($krl_src);
#diag Dumper($r);

$config = mk_config_string(
  [
   {"rule_name" => 'test_trail_1'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_trail_2 is active {
  select using "/archives/" setting ()

    if seen "google.com" in ent:my_trail then
      alert("test");

    fired {
      forget "google.com" in ent:my_trail
    }
  }
_KRL_

#my $r = Kynetx::Parser::parse_rule($krl_src);
#diag Dumper($r);

$config = mk_config_string(
  [
   {"rule_name" => 'test_trail_2'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_trail_3 is active {
  select using "/archives/" setting ()

    if seen "google.com" in ent:my_trail then
      alert("test");

    notfired {
      mark ent:my_trail with "amazon.com"
    }
  }
_KRL_

##my $r = Kynetx::Parser::parse_rule($krl_src);
#diag Dumper($r);

$result = <<_JS_;
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_trail_4 is active {
  select using "/archives/" setting ()

    if seen "amazon.com" in ent:my_trail then
      alert("test");

  }
_KRL_

#my $r = Kynetx::Parser::parse_rule($krl_src);
#diag Dumper($r);

$config = mk_config_string(
  [
   {"rule_name" => 'test_trail_4'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_trail_5 is active {
  select using "/archives/" setting ()

    if seen "amazon.com" after "windley.com" in ent:my_trail then
      alert("test");

  }
_KRL_

#my $r = Kynetx::Parser::parse_rule($krl_src);
#diag Dumper($r);

$config = mk_config_string(
  [
   {"rule_name" => 'test_trail_5'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_trail_6 is active {
  select using "/archives/" setting ()

    if seen "amazon.com" before "windley.com" in ent:my_trail then
      alert("test");

  }
_KRL_

#my $r = Kynetx::Parser::parse_rule($krl_src);
#diag Dumper($r);

# shouldn't fire
$result = <<_JS_;
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule test_trail_7 is active {
  select using "/archives/" setting ()

    if seen "amazon.com" in ent:my_trail within 1 minute then
      alert("test");

  }
_KRL_

#my $r = Kynetx::Parser::parse_rule($krl_src);
#diag Dumper($r);

$config = mk_config_string(
  [
   {"rule_name" => 'test_trail_7'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


#
# callbacks
#

$krl_src = <<_KRL_;
rule test_8 is inactive {
   select using "/identity-policy/" setting ()

   pre { }

   alert("test");

   callbacks {
      success {
        click id="rssfeed";
        click class="newsletter"
   }

   failure {
      click id="close_rss"
   }
  }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'test_8'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$result = <<_JS_;
(function(){
function callBacks () {
  KOBJ.obs('click', 'id','txn_id','rssfeed','success','test_8', 'cs_test');
  KOBJ.obs('click', 'class','txn_id','newsletter','success','test_8', 'cs_test');
  KOBJ.obs('click', 'id','txn_id','close_rss','failure','test_8', 'cs_test');
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,$config,'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


# $krl_src = <<_KRL_;
# rule test_page_ida is active {
#    select using "/identity-policy/" setting ()

#    pre {
#        pt = page:id("product_name");

#        html = <<<p>This is the product title: #{pt}</p>       >>;

#    }

#    alert(html);

# }
# _KRL_


# $config = mk_config_string(
#   [
#    {"rule_name" => 'test_page_ida'},
#    {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
#    {"txn_id" => 'txn_id'},
#   ]
# );

# $result = <<_JS_;
# (function(){
# var pt = \$K('product_name').html();
# var html = '<p>This is the product title: '+pt+'</p>';
# function callBacks () {
# };
# (function(uniq, cb, config, msg) {alert(msg);cb();}
#  ('%uniq%',callBacks,$config,html));
# }());
# _JS_

# add_testcase(
#     $krl_src,
#     $result,
#     $dummy_final_req_info
#     );


$krl_src = <<_KRL_;
    rule emit_test_0 is active {
        select using "/test/(.*).html" 
        pre {
         pagename = "Hello";
	}

        emit <<
pagename.replace(/-/, ' ');
>>
        alert(pagename);
    }
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'emit_test_0'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
var pagename = 'Hello';
pagename.replace(/-/, ' ');
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,$config,pagename));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
    rule emit_test_1 is active {
        select using "/test/(.*).html" setting(pagename)
        pre {
         pagename = "Hello";
	}

        emit "pagename.replace(/-/, ' ');"

        alert(pagename);
    }
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'emit_test_1'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);



$result = <<_JS_;
(function(){
var pagename = 'Hello';
pagename.replace(/-/, ' ');
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,$config,pagename));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


# tests booleans inference.  When false and true appear in string, it
# should still be string.
$krl_src = <<_KRL_;
rule extended_quote_test is active {
   select using "/identity-policy/" setting ()

   pre {
     welcome = <<
Don't be false please!  Be true!>>;
   }
   alert(welcome);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'extended_quote_test'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);



$result = <<_JS_;
(function(){
var welcome = '\\nDon\\'t be false please! Be true!';
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,$config,welcome));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule april2008 is active {
  select using "http://www.utahjudo.com\/2008\/(.*?)" setting (month)
  pre {
  }
  alert("Hello Tim");
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'april2008'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,$config,'Hello Tim'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );



$krl_src = <<_KRL_;
rule emit_in_action is active {
  select using "http://www.utahjudo.com\/2008\/(.*?)" setting (month)
  pre {
  }
  if true then
     emit <<(function(){}())>>
}
_KRL_

$result = <<_JS_;
(function(){
function callBacks () {
};
(function(){}());
callBacks();
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


##
## foreach tests
##
$krl_src = <<_KRL_;
rule foreach_0 is active {
  select using "http://www.google.com" setting ()
   foreach [1,2,4] setting (x)
    pre {
    }
    alert(x);
}
_KRL_


$config = mk_config_string(
  [
   {"rule_name" => 'foreach_0'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$result = <<_JS_;
(function(){
 (function(){
   var x = 1;
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,x));
   }());
 (function(){
   var x = 2;
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
     cb();
    }
    ('%uniq%',callBacks,$config,x));
   }());
 (function(){
   var x = 4;
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,x));
  }());
 }());
_JS_

$krl_src = <<_KRL_;
rule foreach_01 is active {
  select using "http://www.google.com" setting ()
   foreach ["a","b"] setting (x)
    pre {
    }
    alert(x);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foreach_01'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$result = <<_JS_;
(function(){
 (function(){
   var x = 'a';
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,x));
   }());
 (function(){
   var x = 'b';
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
     cb();
    }
    ('%uniq%',callBacks,$config,x));
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );



$krl_src = <<_KRL_;
rule foreach_1 is active {
  select using "http://www.google.com" setting ()
   foreach [2,7] setting (x)
    pre {
      y = x + 1;
      z = 6
    }
    alert(x+y+z);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foreach_1'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);



$result = <<_JS_;
(function(){
 var z = 6;
 (function(){
   var x = 2;
   var y = 3;
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,11));
   }());
 (function(){
   var x = 7;
   var y = 8;
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
     cb();
    }
    ('%uniq%',callBacks,$config,21));
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );



$krl_src = <<_KRL_;
rule foreach_2 is active {
  select using "http://www.google.com" setting ()
   foreach [2,7] setting (x)
   foreach [x+1,x+3] setting (z)
    pre {
      y = x + 1;
    }
    alert(x+y+z);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foreach_2'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$final_req_info = {
 'results' => ['fired'],
 'names' => [$rid.':foreach_2'],
 'all_actions' => [['alert','alert','alert','alert']],
 };

$result = <<_JS_;
(function(){
 (function(){
   var x = 2;
   (function(){
     var z = 3;
     var y = 3;
     function callBacks () {
     };
     (function(uniq,cb,config,msg) {
        alert(msg);
        cb();
      }
      ('%uniq%',callBacks,$config,8));
    }());
   (function(){
     var z = 5;
     var y = 3;
     function callBacks () {
     };
     (function(uniq,cb,config,msg) {
        alert(msg);
        cb();
      }
      ('%uniq%',callBacks,$config,10));
    }());
  }());
 (function(){
   var x = 7;
   (function(){
     var z = 8;
     var y = 8;
     function callBacks () {
     };
     (function(uniq, cb, config, msg) {
        alert(msg);
       cb();
      }
      ('%uniq%',callBacks,$config,23));
     }());
   (function(){
     var z = 10;
     var y = 8;
     function callBacks () {
     };
     (function(uniq, cb, config, msg) {
        alert(msg);
        cb();
      }
      ('%uniq%',callBacks,$config,25));
     }());
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $final_req_info,
    0
    );



$krl_src = <<_KRL_;
rule foreach_here is active {
  select using "http://www.google.com" setting ()
   foreach [2,7] setting (x)
    pre {
      y = <<
This is the number #{x}>>;
      z = 6;
      w = <<
This is another number #{z}>>;
    }
    alert(x+y+z);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foreach_here'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);



$result = <<_JS_;
(function(){
 var z = 6;
 var w = '\\nThis is another number 6';
 (function(){
   var x = 2;
   var y = '\\nThis is the number 2';
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,'2\\nThisisthenumber26'));
   }());
 (function(){
   var x = 7;
   var y = '\\nThis is the number 7';
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
     cb();
    }
    ('%uniq%',callBacks,$config,'7\\nThisisthenumber76'));
   }());
 }());
_JS_


add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
rule foreach_here is active {
  select using "http://www.google.com" setting ()
   foreach [2,7] setting (x)
    pre {
      p = x.pick("\$..foo");
      y = <<
This is the number #{p}>>;
      z = 6;
      w = <<
This is another number #{z}>>;
    }
    alert(x+y+z);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foreach_here'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$final_req_info = {
 'results' => ['fired'],
 'names' => [$rid.':foreach_here'],
 'all_actions' => [['alert','alert']],
 };


$result = <<_JS_;
(function(){
 var z = 6;
 var w = '\\nThis is another number 6';
 (function(){
   var x = 2;
   var p = [];
   var y = '\\nThis is the number []';
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,'2\\nThisisthenumber\[\]6'));
   }());
 (function(){
   var x = 7;
   var p = [];
   var y = '\\nThis is the number []';
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
     cb();
    }
    ('%uniq%',callBacks,$config,'7\\nThisisthenumber\[\]6'));
   }());
 }());
_JS_


add_testcase(
    $krl_src,
    $result,
    $final_req_info, 0
    );


$krl_src = <<_KRL_;
rule foreach_hash_1 is active {
  select using "http://www.google.com" setting ()
   foreach {"a": 1, "b": 2, "c":3} setting (k,v)
    pre {
      x = "Key " + k;
      y = v + 1;
      z = 6
    }
    alert(v);
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foreach_hash_1'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);



$result = <<_JS_;
(function(){
 var z = 6;
 (function(){
   var k = 'c';
   var v = 3;
   var x = 'Key c';
   var y = 4;
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,v));
   }());
 (function(){
   var k = 'a';
   var v = 1;
   var x = 'Key a';
   var y = 2;
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,v));
   }());
 (function(){
   var k = 'b';
   var v = 2;
   var x = 'Key b';
   var y = 3;
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,v));
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info
    );


##
$krl_src = <<_KRL_;
ruleset foozle {
 global {
  coolness = {
		"Jam" : "Phil",
		"Alex" : "Horsty",
		"everyone" : "Steve"
	};
 }
 rule foreach_hash_2 is active {
  select using "http://www.google.com" setting ()
   foreach coolness setting (k,v)
   alert(v);
 }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foreach_hash_2'},
   {"rid" => {'rid' => 'foozle','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);



$result = <<_JS_;
(function(){
 (function(){
   var k = 'Alex';
   var v = 'Horsty';
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,v));
   }());
 (function(){
   var k = 'Jam';
   var v = 'Phil';
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,v));
   }());
 (function(){
   var k = 'everyone';
   var v = 'Steve';
   function callBacks () {
   };
   (function(uniq,cb,config,msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,$config,v));
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $dummy_final_req_info,
    0
    );




##
## JSON test cases
##
$json = <<_KRL_;
{"blocktype":"every","actions":[{"action":{"name":"alert","args":[{"val":"Hello Tim","type":"str"}],"modifiers":[]},"label":""}],"name":"april2008","pagetype":{"vars":["month"],"pattern":"http:\/\/www.utahjudo.com\\\/2008\\\/(.*?)","foreach":[]},"state":"active"}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'april2008'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);



$result = <<_JS_;
(function(){
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,$config,'Hello Tim'));
}());
_JS_

add_json_testcase(
    $json,
    $result,
    $dummy_final_req_info
    );


#
# global decls, no datasource
#

$krl_src = <<_KRL_;
ruleset global_expr_0 {
    global {
	x = 3;
    }
    rule foo is active {
     select using ".*"
     noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foo'},
   {"rid" => {'rid' => 'global_expr_0','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

my $global_expr_0 = <<_JS_;
(function(){
var x = 3;
(function(){
 function callBacks(){};
 (function(uniq,cb,config){cb();}
  ('%uniq%',callBacks,$config));
 }());
}());
_JS_

add_testcase(
    $krl_src,
    $global_expr_0,
    $dummy_final_req_info,
    0
    );


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    global {
	x = 3;
    }
    rule t0 is active {
      select using ".*" setting ()
      pre {
         y = 6;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't0'},
   {"rid" => {'rid' => 'global_expr_1','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$final_req_info = {
 'results' => ['fired'],
 'names' => ['global_expr_1:t0'],
 'all_actions' => [['noop']],
 };

my $global_expr_1 = <<_JS_;
(function(){
var x = 3;
(function(){
var y = 6;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $global_expr_1,
    $final_req_info, 0
    );



#
# meta blocks, use, etc.
#

$krl_src = <<_KRL_;
ruleset meta_0 {
    meta {
	use javascript resource "http://init-files.s3.amazonaws.com/kjs-frameworks/jquery_ui/1.8/jquery-ui-1.8.2.custom.js"
        use css resource "http://init-files.s3.amazonaws.com/kjs-frameworks/jquery_ui/1.8/css/kynetx_ui_darkness/jquery-ui-1.8.2.custom.css"
    }
    rule foo is active {
     select using ".*"
     noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foo'},
   {"rid" => {'rid' => 'meta_0','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

my $meta_0 = <<_JS_;
KOBJ.registerExternalResources('meta_0',{
 "http://init-files.s3.amazonaws.com/kjs-frameworks/jquery_ui/1.8/jquery-ui-1.8.2.custom.js":{"type":"javascript"},
 "http://init-files.s3.amazonaws.com/kjs-frameworks/jquery_ui/1.8/css/kynetx_ui_darkness/jquery-ui-1.8.2.custom.css":{"type":"css"}
 });
_JS_

add_testcase(
     $krl_src,
     $meta_0,
     $dummy_final_req_info,
     0
     );


#
# control statements in rulesets
#
$krl_src = <<_KRL_;
ruleset two_rules_both_fire {
    rule t0 is active {
      select using ".*" setting ()
      pre {
      }
      noop();
    }
    rule t1 is active {
      select using ".*" setting ()
      pre {
      }
      noop();
    }
}
_KRL_


$config = mk_config_string(
  [
   {"rule_name" => 't0'},
   {"rid" => {'rid' => 'two_rules_both_fire','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$config2 = mk_config_string(
  [
   {"rule_name" => 't1'},
   {"rid" => {'rid' => 'two_rules_both_fire','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );


$krl_src = <<_KRL_;
ruleset two_rules_first_fires {
    rule t0 is active {
      select using ".*" setting ()
      pre {
      }
      noop();
      fired {
        last;
      }
    }
    rule t1 is active {
      select using ".*" setting ()
      pre {
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't0'},
   {"rid" => {'rid' => 'two_rules_first_fires','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info
    );


$krl_src = <<_KRL_;
ruleset two_rules_both_fire {
    rule t8 is active {
      select using ".*" setting ()
      pre {
        x = 3
      }
      noop();
      fired {
        last if(x==4)
      }
    }
    rule t9 is active {
      select using ".*" setting ()
      pre {
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't8'},
   {"rid" => {'rid' => 'two_rules_both_fire','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$config2 = mk_config_string(
  [
   {"rule_name" => 't9'},
   {"rid" => {'rid' => 'two_rules_both_fire','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$js = <<_JS_;
(function(){
(function(){
var x = 3;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_


add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );

$krl_src = <<_KRL_;
ruleset two_rules_both_fire {
    rule t10 is active {
      select using ".*" setting ()
      pre {
        x = 3
      }
      noop();
      fired {
        last if(x==3)
      }
    }
    rule t11 is active {
      select using ".*" setting ()
      pre {
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_both_fire','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
var x = 3;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
}());
_JS_


add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );
    

# the following tests don't know about installed apps and this can't handle 
$my_req_info->{'api'} = 'blue';


$krl_src = <<_KRL_;
ruleset two_rules_first_raises_second {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event foo for two_rules_first_raises_second
      }
    }
    rule t12 is active {
      select when explicit foo
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_first_raises_second','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_first_raises_second','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
var x = 5;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    );

# multiple raises
$krl_src = <<_KRL_;
ruleset two_rules_first_raises_second_twice {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event foo for two_rules_first_raises_second_twice;
        raise explicit event foo for two_rules_first_raises_second_twice;
      }
    }
    rule t12 is active {
      select when explicit foo
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_twice','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_twice','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
var x = 5;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
(function(){
var x = 5;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    );



# now with expressions
$krl_src = <<_KRL_;
ruleset two_rules_first_raises_second_with_expr {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event "f"+"ood" for two_rules_first_raises_second_with_expr ;
      }
    }
    rule t12 is active {
      select when explicit food
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_expr','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_expr','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
var x = 5;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );

# now with explicit for
$krl_src = <<_KRL_;
ruleset two_rules_first_raises_second_with_for {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event "f"+"ood" for two_rules_first_raises_second_with_for;
      }
    }
    rule t12 is active {
      select when explicit food
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_for','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_for','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
var x = 5;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );


# now with explicit for and expr
$krl_src = <<_KRL_;
ruleset two_rules_first_raises_second_with_for_expr {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event "f"+"ood" for "two_rules_first_raises" + "_second_with_for_expr";
      }
    }
    rule t12 is active {
      select when explicit food
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_for_expr','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_for_expr','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
var x = 5;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );

# now with explicit for array
$krl_src = <<_KRL_;
ruleset two_rules_first_raises_second_with_for_array {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event "f"+"ood" for ["two_rules_first_raises" + "_second_with_for_array"];
      }
    }
    rule t12 is active {
      select when explicit food
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_for_array','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_first_raises_second_with_for_array','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
(function(){
var x = 5;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config2));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );


#not raised
$krl_src = <<_KRL_;
ruleset two_rules_second_not_raised {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event bar;
      }
    }
    rule t12 is active {
      select when explicit foo
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_second_not_raised','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_second_not_raised','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
}());
_JS_


add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );


# not with explicit for expr
$krl_src = <<_KRL_;
ruleset two_rules_second_not_raised_with_for_expr {
    rule t10 is active {
      select when pageview ".*"
      noop();
      fired {
        raise explicit event "dr"+"ool" for "two_rules" + "_second_not_raised_with_for_expr";
      }
    }
    rule t12 is active {
      select when explicit food
      pre {
        x = 5;
      }
      noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 't10'},
   {"rid" => {'rid' => 'two_rules_second_not_raised_with_for_expr','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$config2 = mk_config_string(
  [
   {"rule_name" => 't12'},
   {"rid" => {'rid' => 'two_rules_second_not_raised_with_for_expr','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
 );


$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,$config));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );



# now test each test case twice
foreach my $case (@test_cases) {

#   if ($case->{'diag'}) {
#     Kynetx::Util::turn_on_logging();
#   } else {
#     Kynetx::Util::turn_off_logging();
#   }

  my $ruleset_rid = $case->{'expr'}->{'ruleset_name'} || $rid;
#  diag "######################## Testing $ruleset_rid";
  # note that gen_req_info has been redefined
  my $req_info = local_gen_req_info($ruleset_rid);
  $req_info->{'eventtype'} = 'pageview';
  $req_info->{'domain'} = 'web';

  my $dd = Kynetx::Response->create_directive_doc($req_info->{'eid'});

  if($case->{'type'} eq 'ruleset') {

    Kynetx::Rules::stash_ruleset($req_info,
				 Kynetx::Rules::optimize_ruleset($case->{'expr'})
				);

    my $ev = Kynetx::Events::mk_event($req_info);

    #diag("Processing events for $req_info->{'rid'} with event ", sub {Dumper $ev});

    my $schedule = Kynetx::Scheduler->new();

    #diag("Processing events for $req_info->{'rid'} ($ruleset_rid)");

    my $rid_info = Kynetx::Rids::mk_rid_info($req_info, $ruleset_rid);

    Kynetx::Events::process_event_for_rid($ev,
					  $req_info,
					  $session,
					  $schedule,
					  $rid_info
					 );


    $js = Kynetx::Rules::process_schedule($r,
					  $schedule,
					  $session,
					  time,
					  $req_info,
					  $dd
					 );


  } elsif($case->{'type'} eq 'rule') {

    $js = Kynetx::Rules::eval_rule($r,
				   $req_info,
				   $rule_env,
				   $case->{'session'},
				   $case->{'expr'},
				   '',
				   $dd
				  );

  } else {
    diag "WARNING: No test run! Case must be either rule or ruleset"
  }

  # reset the last flag for the next test
#  $case->{'req_info'}->{$rid.':last'} = 0;

  # remove whitespace
  $js = nows($js);

  diag "Eval result: $js" if $case->{'diag'};


  $case->{'val'} = mk_reg_exp($case->{'val'});

  if ($case->{'val'} eq '') {
    is($js, $case->{'val'}, "Evaling rule " . $case->{'src'});
    $test_count++;
  } else {

    my $re = qr/$case->{'val'}/;

    my $result = cmp_deeply($js,
	 re($re),
	 "Evaling rule " . $case->{'src'});
    $test_count++;

    if (! $result){
        diag $js;
        die;
    };

  }

  # check the request env

  if (defined $case->{'final_req_info'}) {
    foreach my $k (keys %{ $case->{'final_req_info'}} ) {
      my $result = is_deeply($req_info->{$k}, $case->{'final_req_info'}->{$k}, "Checking $k");
      if (! $result) {
      	diag "Key: ",$k;
      	diag "Got: ", Dumper($req_info->{$k});
      	diag "Expected: ", Dumper($case->{'final_req_info'}->{$k});
      	die;
      }
      $test_count++;
    }
  }

}

#diag "Starting tests of global decls with data feeds";

#
# global decls with data sources
#

my $ua = LWP::UserAgent->new;
my $check_url = "http://frag.kobj.net/clients/cs_test/some_data.txt";
my $response = $ua->get($check_url);
my $no_server_available = (! $response->is_success);


sub test_datafeeds {
  my ($no_server_available, $src, $js, $log_results, $diag) = @_;

 SKIP: {

    skip "No server available", 1 if ($no_server_available);
    my $krl = Kynetx::Parser::parse_ruleset($src);

    my $req_info = local_gen_req_info($krl->{'ruleset_name'});

    Kynetx::Rules::stash_ruleset($req_info,
				 Kynetx::Rules::optimize_ruleset($krl)
				);


    my $schedule = Kynetx::Rules::mk_schedule($req_info,
					      $req_info->{'rid'},
					      $krl);

    my $val = Kynetx::Rules::process_schedule($r,
					      $schedule,
					      $session,
					      time
					     );

    diag $val if $diag;

    $val = nows($val);

    $js = mk_reg_exp($js);
    my $re = qr/$js/;

    like($val,
	 $re,
	 "Evaling ruleset " . $src);
    $test_count++;



  }
}

$krl_src = <<_KRL_;
ruleset cs_test {
    global {
	dataset global_decl_0 <- "aaa.json";
    }
    rule foo is active {
     select using ".*"
     noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foo'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_0'] = {"www.barnesandnoble.com":[
	       {"link":"http://aaa.com/barnesandnoble",
		"text":"AAA members sav emoney!",
		"type":"AAA"}]
          };
(function(){
 function callBacks(){};
 (function(uniq,cb,config){cb();}
  ('%uniq%',callBacks,$config));
 }());
}());
_JS_

test_datafeeds(
    0, # this test can run without a server
    $krl_src,
    $js,
    $dummy_final_req_info,
    0);


$krl_src = <<_KRL_;
ruleset cs_test {
    global {
	dataset global_decl_1 <- "test_data";
    }
    rule foo is active {
     select using ".*"
     noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foo'},
   {"rid" => {'rid' => 'cs_test','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_1'] = 'here is some test data!\\n';
(function(){
 function callBacks(){};
 (function(uniq,cb,config){cb();}
  ('%uniq%',callBacks,$config));
 }());
}());
_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );


$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_2 <- "http://frag.kobj.net/clients/cs_test/aaa.json";
    }
    rule foo is active {
     select using ".*"
     noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foo'},
   {"rid" => {'rid' => 'dataset0','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_2'] = {"www.barnesandnoble.com":[
	       {"link":"http://aaa.com/barnesandnoble",
		"text":"AAA members sav emoney!",
		"type":"AAA"}]
          };
(function(){
 function callBacks(){};
 (function(uniq,cb,config){cb();}
  ('%uniq%',callBacks,$config));
 }());
}());
_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );


$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_3 <- "http://frag.kobj.net/clients/cs_test/some_data.txt";
    }
    rule foo is active {
     select using ".*"
     noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foo'},
   {"rid" => {'rid' => 'dataset0','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);


$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_3'] = 'Here is some test data!\\n';
(function(){
 function callBacks(){};
 (function(uniq,cb,config){cb();}
  ('%uniq%',callBacks,$config));
 }());
}());
_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );

$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
       datasource twitter_search <- "http://search.twitter.com/search.json";
    }
}
_KRL_

$js = <<_JS_;
_JS_


test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );



$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
      dataset site_data <- "http://frag.kobj.net/clients/cs_test/aaa.json";
      type = site_data.pick("\$..type");
      css <<
.foo: 4
>>;
      x = type + " Rocks!";
      datasource sites <- "aaa.json";
    }
    rule foo is active {
     select using ".*"
     noop();
    }
}
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'foo'},
   {"rid" => {'rid' => 'dataset0','kinetic_app_version' => 'dev'}},
   {"txn_id" => 'txn_id'},
  ]
);

$js = <<_JS_;
(function(){KOBJ['data']['site_data'] = {"www.barnesandnoble.com":[{"link":"http://aaa.com/barnesandnoble","text":"AAA members save money!","type":"AAA"}]} ;
 var type = 'AAA';
 KOBJ.css('\\n.foo: 4\\n ');
 var x = 'AAA Rocks!';
(function(){
 function callBacks(){};
 (function(uniq,cb,config){cb();}
  ('%uniq%',callBacks,$config));
 }());
}());

_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $dummy_final_req_info,
    0
    );



#
# rule_env_tests
#
#diag "Stating rule environment tests";

# contains_string(nows($global_decl_0),
# 		nows(encode_json(lookup_rule_env('global_decl_0',$rule_env))),
# 		 "Global decl data set effects env");
# contains_string(nows($global_decl_1),
# 		nows(lookup_rule_env('global_decl_1',$rule_env)),
# 		"Global decl data set effects env");
# contains_string(nows($global_decl_2),
# 		nows(encode_json(lookup_rule_env('global_decl_2',$rule_env))),
# 		"Global decl data set effects env");
# contains_string(nows($global_decl_3),
# 		nows(lookup_rule_env('global_decl_3',$rule_env)),
# 		"Global decl data set effects env");



#
# session tests
#
$test_count += 3;
my $domain = "ent";
is(get_persistent_var($domain,$rid,$session,'archive_pages_now'), undef, "Archive pages now reset");
is(get_persistent_var($domain,$rid,$session,'archive_pages_now2'), undef, "Archive pages now2 reset");
is(get_persistent_var($domain,$rid,$session,'archive_pages_old'), 4, "Archive pages old iterated");

session_delete($rid,$session,'archive_pages_old');
session_delete($rid,$session,'archive_pages_now');
session_delete($rid,$session,'archive_pages_now2');
session_delete($rid,$session,'my_flag');
session_delete($rid,$session,'my_trail');


#
# optimize tests
#

sub check_optimize {
  my($krl,$ip, $op, $desc, $diag) = @_;
  diag "============================================================"  if $diag;
  my $rst = Kynetx::Parser::parse_ruleset($krl);
#  diag "Unoptimized: ", Dumper($rst) if $diag;
  my $ost = Kynetx::Rules::optimize_ruleset($rst);
#  diag "Optimized: ", Dumper($ost) if $diag;

  diag "Inner pre: ", Dumper $ost->{'rules'}->[0]->{'inner_pre'}  if $diag;
  $test_count++;

  is_deeply($ost->{'rules'}->[0]->{'inner_pre'} || [],
	    $ip,
	    $desc . "(inner)");


  diag "Outer pre: ", Dumper $ost->{'rules'}->[0]->{'outer_pre'}  if $diag;
  $test_count++;
  is_deeply($ost->{'rules'}->[0]->{'outer_pre'} || [],
	    $op,
	    $desc . "(outer)");
}


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
       pre {
          y = 6;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [],
	       [{
		 'rhs' => {
			   'val' => '6',
			   'type' => 'num'
			  },
		 'lhs' => 'y',
		 'type' => 'expr'
		}],
	       "No dependence");


$krl_src = <<_KRL_;
ruleset global_expr_1a {
    rule t0 is active {
      select using ".*" setting ()
       foreach {"a":1,"b":"Hello"} setting (k,v)
       pre {
          x = k;
          y = v;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [ {'rhs' => {
			    'val' => 'k',
			    'type' => 'var'
			   },
		  'lhs' => 'x',
		  'type' => 'expr'
		 },
		 {
		  'rhs' => {
			    'val' => 'v',
			    'type' => 'var'
			   },
		  'lhs' => 'y',
		  'type' => 'expr'
		 }
	       ],
	       [],
	       "Hash with dependence",
	       0
	       );


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
       pre {
          y = x + 6;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'x',
				       'type' => 'var'
				      },
				      {
				       'val' => '6',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'y',
		 'type' => 'expr'
		}],
	       [],
	       "One dependence");


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
       pre {
          z = 5;
          y = x + 6;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'x',
				       'type' => 'var'
				      },
				      {
				       'val' => '6',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'y',
		 'type' => 'expr'
		}],
	       [{
		 'rhs' => {
			   'val' => '5',
			   'type' => 'num'
			  },
		 'lhs' => 'z',
		 'type' => 'expr'
		}],
	       "One independent, one dependent");



$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
       pre {
          y = x + 6;
          z = 5;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'x',
				       'type' => 'var'
				      },
				      {
				       'val' => '6',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'y',
		 'type' => 'expr'
		}],
	       [{
		 'rhs' => {
			   'val' => '5',
			   'type' => 'num'
			  },
		 'lhs' => 'z',
		 'type' => 'expr'
		}],
	       "One independent, one dependent, order doesn't matter");


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
       pre {
          y = x + 6;
          z = 5;
          w = 4 + y;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'x',
				       'type' => 'var'
				      },
				      {
				       'val' => '6',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'y',
		 'type' => 'expr'
		},
		{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => '4',
				       'type' => 'num'
				      },
				      {
				       'val' => 'y',
				       'type' => 'var'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'w',
		 'type' => 'expr'
		},
	       ],
	       [{
		 'rhs' => {
			   'val' => '5',
			   'type' => 'num'
			  },
		 'lhs' => 'z',
		 'type' => 'expr'
		}],
	       "One independent, two dependent");


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
       pre {
          y = x + 6;
          z = 5;
          w = 4 + y;
          a = w;
          b = 7;
          c = a;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'x',
				       'type' => 'var'
				      },
				      {
				       'val' => '6',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'y',
		 'type' => 'expr'
		},
		{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => '4',
				       'type' => 'num'
				      },
				      {
				       'val' => 'y',
				       'type' => 'var'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'w',
		 'type' => 'expr'
		},
		{
		 'rhs' => {
			   'val' => 'w',
			   'type' => 'var'
			  },
		 'lhs' => 'a',
		 'type' => 'expr'
		},
		{
		 'rhs' => {
			   'val' => 'a',
			   'type' => 'var'
			  },
		 'lhs' => 'c',
		 'type' => 'expr'
		}
	       ],
	       [{
		 'rhs' => {
			   'val' => '5',
			   'type' => 'num'
			  },
		 'lhs' => 'z',
		 'type' => 'expr'
		},
		{
		 'rhs' => {
			   'val' => '7',
			   'type' => 'num'
			  },
		 'lhs' => 'b',
		 'type' => 'expr'
		}
	       ],
	       "Many dependent and independent mixed");


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
         foreach ['a','b','c'] setting (y)
       pre {
          z = 6;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [],
	       [{
		 'rhs' => {
			   'val' => '6',
			   'type' => 'num'
			  },
		 'lhs' => 'z',
		 'type' => 'expr'
		}],
	       "No dependence");


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
         foreach ['a','b','c'] setting (y)
       pre {
          z = y + 6;
       }
       noop();
    }
}
_KRL_

check_optimize($krl_src,
	       [{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'y',
				       'type' => 'var'
				      },
				      {
				       'val' => '6',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'z',
		 'type' => 'expr'
		}],
	       [],
	       "Two foreach, one dependence");


$krl_src = <<_KRL_;
ruleset global_expr_1 {
    rule t0 is active {
      select using ".*" setting ()
       foreach [1,2,3] setting (x)
         foreach ['a','b','c'] setting (y)
       pre {
          w = x + 6;
          v = y + 7;
          z = 5;
       }
       noop();
    }
}
_KRL_



check_optimize($krl_src,
	       [{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'x',
				       'type' => 'var'
				      },
				      {
				       'val' => '6',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'w',
		 'type' => 'expr'
		},
		{
		 'rhs' => {
			   'args' => [
				      {
				       'val' => 'y',
				       'type' => 'var'
				      },
				      {
				       'val' => '7',
				       'type' => 'num'
				      }
				     ],
			   'type' => 'prim',
			   'op' => '+'
			  },
		 'lhs' => 'v',
		 'type' => 'expr'
		}],
	       [{
		 'rhs' => {
			   'val' => '5',
			   'type' => 'num'
			  },
		 'lhs' => 'z',
		 'type' => 'expr'
		}],
	       "Two foreach; One independent, one dependent, order doesn't matter");


$krl_src = <<_KRL_;
ruleset global_expr_1 {
 rule foreach_here is active {
  select using "http://www.google.com" setting ()
   foreach [2,7] setting (x)
    pre {
      tweetUser = x.pick("\$..foo");
      y = <<
This is the number #{tweetUser} and #{x}   >>;
      z = 6;
      w = <<
This is another number #{z}  >>;
    }
    alert(x+y+z);
 }
}
_KRL_

check_optimize($krl_src,
[{
     'rhs' => {
       'obj' => {
         'val' => 'x',
         'type' => 'var'
       },
       'args' => [
         {
           'val' => '$..foo',
           'type' => 'str'
         }
       ],
       'name' => 'pick',
       'type' => 'operator'
     },
     'lhs' => 'tweetUser',
     'type' => 'expr'
   },
   {
     'rhs' => '
This is the number #{tweetUser} and #{x}   ',
     'lhs' => 'y',
     'type' => 'here_doc'
   }
],[{
     'rhs' => {
       'val' => 6,
       'type' => 'num'
     },
     'lhs' => 'z',
     'type' => 'expr'
   },
   {
     'rhs' => '
This is another number #{z}  ',
     'lhs' => 'w',
     'type' => 'here_doc'
   }
], "Extended quotes", 0);


# test eval_use
my $empty_rule_env = empty_rule_env();
my $mod_rule_env;

$krl =  << "_KRL_";
ruleset foobar {
  meta {
    use module a16x78 
  }
  global {
    x = a16x78:a + 4;
    y = a16x78:f(4);
    z = (a16x78:search_twitter("kynetx")).pick("\$..query");
  }
}
_KRL_

my $module_rs = Kynetx::Parser::parse_ruleset($krl);
#diag Dumper $module_rs;
($js, $mod_rule_env) = Kynetx::Rules::eval_use($my_req_info, $module_rs, $empty_rule_env);

# diag Dumper $mod_rule_env;

is(lookup_module_env("a16x78", "a", $mod_rule_env), 5, "a is 5" );
$test_count++;


($js, $mod_rule_env) = 
    eval_globals($my_req_info, $module_rs, $mod_rule_env, $session);

# diag Dumper $mod_rule_env;


is(lookup_rule_env("x", $mod_rule_env), 9, "get 9 back from adding 4 to a");
$test_count++;

is(lookup_rule_env("y", $mod_rule_env), 
   10,
   "get 10 back applying f to 4");
$test_count++;

is(lookup_rule_env("z", $mod_rule_env), 'kynetx', "get kynetx back as query");
$test_count++;


$krl =  << "_KRL_";
ruleset foobar {
  meta {
    use module a16x78 alias flipper
  }
  global {
    x = flipper:a + 4;
  }
}
_KRL_

$module_rs = Kynetx::Parser::parse_ruleset($krl);
#diag Dumper $module_rs;
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_use($my_req_info, $module_rs, $empty_rule_env);

is(lookup_module_env("flipper", "a", $mod_rule_env), 5, "a is 5" );
$test_count++;

is(lookup_module_env("flipper", "b", $mod_rule_env), undef, "b is undef" );
$test_count++;



$krl =  << "_KRL_";
ruleset foobar {
  meta {
    use module a16x78 alias flipper
  }
  global {
    x = flipper:b;
  }
}
_KRL_

$module_rs = Kynetx::Parser::parse_ruleset($krl);
#diag Dumper $module_rs;
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_use($my_req_info, $module_rs, $empty_rule_env);

#diag Dumper $mod_rule_env;

is(lookup_rule_env("x", $mod_rule_env), undef, "x is undef" );
$test_count++;

# use the same module twice 
$krl =  << "_KRL_";
ruleset foobar {
  meta {
    use module a16x78 alias flipper
    use module a16x78 alias flopper
  }
  global {
    x = flipper:a;
    y = flopper:a;
  }
}
_KRL_

$module_rs = Kynetx::Parser::parse_ruleset($krl);
#diag Dumper $module_rs;
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_use($my_req_info, $module_rs, $empty_rule_env);
($js, $mod_rule_env) = 
    eval_globals($my_req_info, $module_rs, $mod_rule_env, $session);


# diag Dumper $mod_rule_env;

is(lookup_rule_env("x", $mod_rule_env), 5, "x is 5 from flippy" );
$test_count++;

is(lookup_rule_env("y", $mod_rule_env), 5, "y is 5 from floppy" );
$test_count++;


$krl =  << "_KRL_";
ruleset foobar {
  meta {
    key floppy "world"
    use module a16x78
  }
  global {
    a = keys:floppy();
    b = a16x78:flippy;
  }
}
_KRL_



$module_rs = Kynetx::Parser::parse_ruleset($krl);

#diag Dumper $module_rs;
$my_req_info->{'rid'} = mk_rid_info($my_req_info,'foobar');
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_meta($my_req_info, $module_rs, $empty_rule_env, $session);

($js, $mod_rule_env) = 
    eval_globals($my_req_info, $module_rs, $mod_rule_env, $session);
#diag Dumper $mod_rule_env;


is(lookup_rule_env("a", $mod_rule_env), "world", "a is world" );
$test_count++;

is(lookup_rule_env("b", $mod_rule_env), "hello", "a is world" );
$test_count++;


is(lookup_module_env("a16x78", "a", $mod_rule_env), 5, "a is 5" );
$test_count++;

is(lookup_module_env("a16x78", "floppy", $mod_rule_env), "six", "got six" );
$test_count++;


$krl =  << "_KRL_";
ruleset foobar {
  meta {
    use module a16x78
  }
  global {
    a = a16x78:calling_rid;
    b = a16x78:calling_ver;
    c = a16x78:my_rid;
    d = a16x78:my_ver;
  }
}
_KRL_


$module_rs = Kynetx::Parser::parse_ruleset($krl);
# diag Dumper $module_rs;
$my_req_info->{'rid'} = mk_rid_info($my_req_info,'foobar');
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_meta($my_req_info, $module_rs, $empty_rule_env, $session);

($js, $mod_rule_env) = 
    eval_globals($my_req_info, $module_rs, $mod_rule_env, $session);
#diag Dumper $mod_rule_env;


is(lookup_rule_env("a", $mod_rule_env), "foobar", "a is foobar" );
$test_count++;

is(lookup_rule_env("b", $mod_rule_env), "prod", "b is prod" );
$test_count++;

is(lookup_rule_env("c", $mod_rule_env), "a16x78", "c is a16x78" );
$test_count++;

is(lookup_rule_env("d", $mod_rule_env), "prod", "d id prod" );
$test_count++;


is(lookup_module_env("a16x78", "a", $mod_rule_env), 5, "a is 5" );
$test_count++;

is(lookup_module_env("a16x78", "floppy", $mod_rule_env), "six", "got six" );
$test_count++;





# look up in module env even though the var isn't provided...
sub poke_mod_env {
  my($name, $key, $env) = @_;
  my $mod_env = Kynetx::Environments::lookup_rule_env($Kynetx::Modules::name_prefix . $name, $env);
    return Kynetx::Environments::lookup_rule_env($key, $mod_env);
}



# test module configuration
$krl =  << "_KRL_";
ruleset foobar {
  meta {
    key floppy "world"
    use module a16x78
          with c = keys:floppy() 
           and d = 234
  }
  global {
    a = a16x78:g();
  }
}
_KRL_


$module_rs = Kynetx::Parser::parse_ruleset($krl);
# diag Dumper $module_rs;
$my_req_info->{'rid'} = mk_rid_info($my_req_info,'foobar');
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_meta($my_req_info, $module_rs, $empty_rule_env, $session);

($js, $mod_rule_env) = 
    eval_globals($my_req_info, $module_rs, $mod_rule_env, $session);
#diag Dumper $mod_rule_env;


is(lookup_rule_env("a", $mod_rule_env), "world", "a is world" );
$test_count++;


is(poke_mod_env("a16x78", "c", $mod_rule_env), "world", "key gets passed to config" );
$test_count++;


is(poke_mod_env("a16x78", "d", $mod_rule_env), undef, "key gets passed to config" );
$test_count++;


# test module configuration
$krl =  << "_KRL_";
ruleset foobar {
  meta {
    key floppy "world"
    use module a16x78
  }
  global {
    a = a16x78:g();
  }
}
_KRL_


$module_rs = Kynetx::Parser::parse_ruleset($krl);
# diag Dumper $module_rs;
$my_req_info->{'rid'} = mk_rid_info($my_req_info,'foobar');
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_meta($my_req_info, $module_rs, $empty_rule_env, $session);

($js, $mod_rule_env) = 
    eval_globals($my_req_info, $module_rs, $mod_rule_env, $session);
#diag Dumper $mod_rule_env;


is(lookup_rule_env("a", $mod_rule_env), "Hello", "a is Hello" );
$test_count++;


is(poke_mod_env("a16x78", "c", $mod_rule_env), "Hello", "key gets passed to config" );
$test_count++;

ENDY:
# test module configuration
$krl =  << "_KRL_";
ruleset foobar {
  meta {
    key floppy "world"
    use module a16x78 alias foo with c = "FOO"
    use module a16x78 version "dev" alias bar with c = "BAR"
  }
  global {
    a = foo:g();
    b = bar:g();
  }
}
_KRL_


$module_rs = Kynetx::Parser::parse_ruleset($krl);
# diag Dumper $module_rs;
$my_req_info->{'rid'} = mk_rid_info($my_req_info,'foobar');
$mod_rule_env = empty_rule_env();
($js, $mod_rule_env) = Kynetx::Rules::eval_meta($my_req_info, $module_rs, $empty_rule_env, $session);

($js, $mod_rule_env) = 
    eval_globals($my_req_info, $module_rs, $mod_rule_env, $session);
#diag Dumper $mod_rule_env;


is(lookup_rule_env("a", $mod_rule_env), "FOO", "a is FOO" );
$test_count++;

is(lookup_rule_env("b", $mod_rule_env), "BAR", "b is BAR" );
$test_count++;






#diag "Test cases: " . int(@test_cases) . " and others: " . $test_count;


done_testing($test_count);

session_cleanup($session);

diag("Safe to ignore warnings about unintialized values & unrecognized escapes");

sub mk_reg_exp {
  my $val = shift;

  $val = nows($val);

  # quote special for RE
  $val =~ s/\\/\\\\/g;
  $val =~ s/\+/\\\+/g;
  $val =~ s/\(/\\\(/g;
  $val =~ s/\)/\\\)/g;
  $val =~ s/\[/\\\[/g;
  $val =~ s/\]/\\\]/g;
  $val =~ s/\{/\\\{/g;
  $val =~ s/\}/\\\}/g;
  $val =~ s/\^/\\\^/g;
  $val =~ s/\$/\\\$/g;
  $val =~ s/\|/\\\|/g;

  # now make RE substitutions
  $val =~ s/%uniq%/\\d+/g;

  $val =  $val ;

  return $val;
}

1;


