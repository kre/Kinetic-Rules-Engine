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
use Test::LongString;

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
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($WARN);
#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;

# # configure KNS
# Kynetx::Configure::configure();

# Kynetx::Memcached->init();

# my $r = new Kynetx::FakeReq();


my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);


my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();


my $session = Kynetx::Test::gen_session($r, $rid);


# my $rid = 'cs_test';
# my $rule_name = 'foo';

# my $rule_env = empty_rule_env();

# $rule_env = extend_rule_env(
#     ['city','tc','temp','booltrue','boolfalse','a','b'],
#     ['Blackfoot','15',20,'true','false','10','11'],
#     $rule_env);

# #diag Dumper($rule_env);

# my $scope_hash = flatten_env($rule_env);
# #diag Dumper($scope_hash);
# my $rule_env_js = Kynetx::Actions::emit_var_decl($scope_hash);
# #diag $rule_env_js;

# # dummy up some counter data in the session

# my $session = process_session($r);

# session_store($rid, $session, 'archive_pages_old', 3);
# my $three_days_ago = DateTime->now->add( days => -3 );
# session_touch($rid, $session, 'archive_pages_old', $three_days_ago);

# session_store($rid, $session, 'archive_pages_now', 2);
# session_store($rid, $session, 'archive_pages_now2', 3);

# session_push($rid, $session, 'my_trail', "http://www.windley.com/foo.html");
# session_push($rid, $session, 'my_trail', "http://www.kynetx.com/foo.html");

# session_clear($rid, $session, 'my_flag');

my $krl_src;
my $js;
my $test_count;


my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)
$Amazon_req_info->{'rid'} = $rid;
$Amazon_req_info->{'txn_id'} = 'txn_id';
$Amazon_req_info->{'caller'} = 'http://www.google.com/search';

my (@test_cases, $json, $krl,$result);

sub add_testcase {
    my($str, $expected, $req_info, $diag) = @_;

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
		       'req_info' => $req_info,
		       'session' => $session,
		       'src' =>  $str,
		       'type' => $type,
		       'diag' => $diag
	 }
	 );
}


sub add_json_testcase {
    my($str, $expected, $req_info, $diag) = @_;
    my $val = Kynetx::Json::jsonToAst($str);
 
    chomp $str;
    diag("$str = ", Dumper($val)) if $diag;


    push(@test_cases, {'expr' => $val,
		       'val' => $expected,
		       'req_info' => $req_info,
		       'session' => $session,
		       'src' =>  $str,
		       'type' => 'rule',
	 }
	);
}


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

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_1',rid:'cs_test'},'testing'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
var c = 'Seattle';
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_2',rid:'cs_test'},('testing' + c)));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
rule test_3 is active {
  select using "/archives/" setting ()
  pre { 
      c = location:city();
  }
  if urban() then
    alert("testing " + c);
}
_KRL_

$result = <<_JS_;
(function(){
var c = 'Seattle';
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_3',rid:'cs_test'},('testing' + c)));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
rule test_4 is active {
  select using "/archives/" setting ()
  pre { 
      c = location:city();
  }
  if urban() && location:city() eq "Seattle" then
    alert("testing " + c);
}
_KRL_

$result = <<_JS_;
(function(){
var c = 'Seattle';
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_4',rid:'cs_test'},('testing' + c)));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_flag_1',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
var c = 3;
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_5a',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
var c = 3;
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_6',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_trail_1',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_trail_2',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_trail_4',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_trail_5',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
function callBacks () {};
(function(uniq, cb, config, msg) {alert(msg);cb();}
('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_trail_7',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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

$result = <<_JS_;
(function(){
function callBacks () {
  KOBJ.obs('click', 'id','txn_id','rssfeed','success','test_8', 'cs_test');
  KOBJ.obs('click', 'class','txn_id','newsletter','success','test_8', 'cs_test');
  KOBJ.obs('click', 'id','txn_id','close_rss','failure','test_8', 'cs_test');
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_8',rid:'cs_test'},'test'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
rule test_page_id is active {
   select using "/identity-policy/" setting ()
   
   pre {
       pt = page:id("product_name");
       
       html = <<
<p>This is the product title: #{pt}</p>
       >>;

   }

   alert(html);

}
_KRL_

$result = <<_JS_;
(function(){
var pt = K\$('product_name').innerHTML;
var html = '<p>This is the product title: '+pt+'</p>';
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'test_page_id',rid:'cs_test'},html));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
    rule emit_test_0 is active {
        select using "/test/(.*).html" setting(pagename)
        pre {

	}     

        emit <<
pagename.replace(/-/, ' ');
>>
        alert(pagename);
    }
_KRL_

$result = <<_JS_;
(function(){
pagename.replace(/-/, ' ');
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'emit_test_0',rid:'cs_test'},pagename));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
    rule emit_test_1 is active {
        select using "/test/(.*).html" setting(pagename)
        pre {

	}     

        emit "pagename.replace(/-/, ' ');"

        alert(pagename);
    }
_KRL_

$result = <<_JS_;
(function(){
pagename.replace(/-/, ' ');
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'emit_test_1',rid:'cs_test'},pagename));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


# tests booleans inference.  When false and true appear in string, it 
# should still be string.
$krl_src = <<_KRL_;
rule extended_quote_test is active {
   select using "/identity-policy/" setting ()
   
   pre {
     welcome = <<
Don't be false please!  Be true!
     >>; 
   }
   alert(welcome);
}
_KRL_

$result = <<_JS_;
(function(){
var welcome = 'Don\\'t be false please! Be true!';
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'extended_quote_test',rid:'cs_test'},welcome));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
rule april2008 is active {
  select using "http://www.utahjudo.com\/2008\/(.*?)" setting (month)
  pre {
  }
  alert("Hello Tim");
}
_KRL_

$result = <<_JS_;
(function(){
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'april2008',rid:'cs_test'},'Hello Tim'));
}());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
    $Amazon_req_info
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
    ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_0',rid: 'cs_test'},x));
   }());
 (function(){
   var x = 2;
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
     cb();
    }
    ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_0',rid: 'cs_test'},x));
   }());
 (function(){
   var x = 4;
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
      cb();
    }
    ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_0',rid: 'cs_test'},x));
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
    ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_01',rid: 'cs_test'},x));
   }());
 (function(){
   var x = 'b';
   function callBacks () {
   };
   (function(uniq, cb, config, msg) {
      alert(msg);
     cb();
    }
    ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_01',rid: 'cs_test'},x));
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
    ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_1',rid: 'cs_test'},(x+(y+z))));
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
    ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_1',rid: 'cs_test'},(x+(y+z))));
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
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
      ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_2',rid: 'cs_test'},(x+(y+z))));
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
      ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_2',rid: 'cs_test'},(x+(y+z))));
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
      ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_2',rid: 'cs_test'},(x+(y+z))));
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
      ('%uniq%',callBacks,{txn_id: 'txn_id',rule_name: 'foreach_2',rid: 'cs_test'},(x+(y+z))));
     }());
   }());
 }());
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );






##
## JSON test cases
##
$json = <<_KRL_;
{"blocktype":"every","actions":[{"action":{"name":"alert","args":[{"val":"Hello Tim","type":"str"}],"modifiers":[]},"label":""}],"name":"april2008","pagetype":{"vars":["month"],"pattern":"http:\/\/www.utahjudo.com\\\/2008\\\/(.*?)","foreach":[]},"state":"active"}
_KRL_

$result = <<_JS_;
(function(){
function callBacks () {
};
(function(uniq, cb, config, msg) {alert(msg);cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'april2008',rid:'cs_test'},'Hello Tim'));
}());
_JS_

add_json_testcase(
    $json,
    $result,
    $Amazon_req_info
    );


#
# global decls, no datasource
#

$krl_src = <<_KRL_;
ruleset global_expr_0 {
    global {
	x = 3;
    }
}
_KRL_

my $global_expr_0 = <<_JS_;
(function(){
var x = 3;
}());
_JS_

add_testcase(
    $krl_src,
    $global_expr_0,
    $Amazon_req_info
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

my $global_expr_1 = <<_JS_;
(function(){
var x = 3;
(function(){
var y = 6;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'t0',rid:'cs_test'}));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $global_expr_1,
    $Amazon_req_info
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

$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'t0',rid:'cs_test'}));
}());
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'t1',rid:'cs_test'}));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $Amazon_req_info
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

$js = <<_JS_;
(function(){
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'t0',rid:'cs_test'}));
}());
}());
_JS_

add_testcase(
    $krl_src,
    $js,
    $Amazon_req_info
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

$js = <<_JS_;
(function(){
(function(){
var x = 3;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'t8',rid:'cs_test'}));
}());
(function(){
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'t9',rid:'cs_test'}));
}());
}());
_JS_


add_testcase(
    $krl_src,
    $js,
    $Amazon_req_info,
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

$js = <<_JS_;
(function(){
(function(){
var x = 3;
function callBacks () {
};
(function(uniq, cb, config) {cb();}
 ('%uniq%',callBacks,{txn_id:'txn_id',rule_name:'t10',rid:'cs_test'}));
}());
}());
_JS_


add_testcase(
    $krl_src,
    $js,
    $Amazon_req_info,
    0
    );


# now test each test case twice
foreach my $case (@test_cases) {

  if($case->{'type'} eq 'ruleset') {

    $js = Kynetx::Rules::eval_ruleset($r, 
				      $case->{'req_info'}, 
				      empty_rule_env(), 
				      $session, 
				      $case->{'expr'}, 
				      $case->{'expr'}->{'rules'});

  } elsif($case->{'type'} eq 'rule') {

    $js = Kynetx::Rules::eval_rule($r,
				   $case->{'req_info'}, 
				   $rule_env, 
				   $case->{'session'}, 
				   $case->{'expr'});

  } else {
    diag "WARNING: No test run! Case must be either rule or ruleset"
  }

  # reset the last flag for the next test
  $case->{'req_info'}->{$rid.':last'} = 0;

  # remove whitespace
  $js = nows($js);

  diag "Eval result: $js" if $case->{'diag'};

  $case->{'val'} = nows($case->{'val'});
	
  # quote special for RE
  $case->{'val'} =~ s/\\/\\\\/g;
  $case->{'val'} =~ s/\+/\\\+/g;
  $case->{'val'} =~ s/\(/\\\(/g;
  $case->{'val'} =~ s/\)/\\\)/g;
  $case->{'val'} =~ s/\[/\\\[/g;
  $case->{'val'} =~ s/\]/\\\]/g;
  $case->{'val'} =~ s/\{/\\\{/g;
  $case->{'val'} =~ s/\}/\\\}/g;
  $case->{'val'} =~ s/\^/\\\^/g;
  $case->{'val'} =~ s/\$/\\\$/g;
  $case->{'val'} =~ s/\|/\\\|/g;

  # now make RE substitutions
  $case->{'val'} =~ s/%uniq%/\\d+/g;

  $case->{'val'} = '^' . $case->{'val'} . '$';

  if ($case->{'val'} eq '') {
    is($js, $case->{'val'}, "Evaling rule " . $case->{'src'});
  } else {

    my $re = qr/$case->{'val'}/;

    like($js,
	 $re,
	 "Evaling rule " . $case->{'src'});
    
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
  my ($no_server_available, $src, $js, $req_info, $diag) = @_;
  $test_count++;
 SKIP: {

    skip "No server available", 1 if ($no_server_available);
    my $krl = Kynetx::Parser::parse_ruleset($src);
    my $val = Kynetx::Rules::eval_ruleset($r, 
				      $req_info, 
				      empty_rule_env(), 
				      $session, 
				      $krl, 
				      $krl->{'rules'});


    is_string_nows($val, $js, "Evaling ruleset: $src");
  }
}
$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_0 <- "aaa.json";
    }
}
_KRL_

$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_0'] = {"www.barnesandnoble.com":[
	       {"link":"http://aaa.com/barnesandnoble",
		"text":"AAA members sav emoney!",
		"type":"AAA"}]
          };
}());
_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $Amazon_req_info,
    0);


$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_1 <- "test_data";
    }
}
_KRL_

$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_1'] = 'here is some test data!';
}());
_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $Amazon_req_info,
    0
    );


$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_2 <- "http://frag.kobj.net/clients/cs_test/aaa.json";
    }
}
_KRL_

$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_2'] = {"www.barnesandnoble.com":[
	       {"link":"http://aaa.com/barnesandnoble",
		"text":"AAA members sav emoney!",
		"type":"AAA"}]
          };
}());
_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $Amazon_req_info,
    0
    );


$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_3 <- "http://frag.kobj.net/clients/cs_test/some_data.txt";
    }
}
_KRL_

$js = <<_JS_;
(function(){
KOBJ['data']['global_decl_3'] = 'Here is some test data!';
}());
_JS_

test_datafeeds(
    $no_server_available,
    $krl_src,
    $js,
    $Amazon_req_info,
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
    $Amazon_req_info,
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

is(session_get($rid,$session,'archive_pages_now'), undef, "Archive pages now reset");
is(session_get($rid,$session,'archive_pages_now2'), undef, "Archive pages now2 reset");
is(session_get($rid,$session,'archive_pages_old'), 4, "Archive pages old iterated");

session_delete($rid,$session,'archive_pages_old');
session_delete($rid,$session,'archive_pages_now');
session_delete($rid,$session,'archive_pages_now2');
session_delete($rid,$session,'my_flag');
session_delete($rid,$session,'my_trail');


#
# optimize tests
#

sub check_optimize {
  my($krl,$ip, $op, $desc) = @_;
  my $rst = Kynetx::Parser::parse_ruleset($krl);
#  diag "Unoptimized: ", Dumper($rst);
  my $ost = Kynetx::Rules::optimize_ruleset($rst);
#  my $ost = $rst;
#  diag "Optimized: ", Dumper($ost);

#  diag "Inner pre: ", Dumper $ost->{'rules'}->[0]->{'inner_pre'};
  $test_count++;

  is_deeply($ost->{'rules'}->[0]->{'inner_pre'} || [], 
	    $ip, 
	    $desc . "(inner)");


#  diag "Outer pre: ", Dumper $ost->{'rules'}->[0]->{'outer_pre'};
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



#diag "Test cases: " . int(@test_cases) . " and others: " . $test_count;

done_testing($test_count + (@test_cases * 1));

session_cleanup($session);

diag("Safe to ignore warnings about unintialized values & unrecognized escapes");



1;


