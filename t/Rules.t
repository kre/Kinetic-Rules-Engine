#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use DateTime;
use Geo::IP;
use Cache::Memcached;
use LWP::Simple;
use LWP::UserAgent;
use JSON::XS;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Rules qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Memcached qw/:all/;


use Kynetx::FakeReq qw/:all/;

use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($WARN);
#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;



my $r = new Kynetx::FakeReq();


my $rule_name = 'foo';

my $rule_env = {$rule_name . ':city' => 'Blackfoot',
		$rule_name . ':tc' => '15',
		$rule_name . ':temp' => 20,
		$rule_name . ':booltrue' => 'true',
		$rule_name . ':boolfalse' => 'false',
               };


# dummy up some counter data in the session
my $session = {'archive_pages_old' => 3,
	       'archive_pages_now' => 3,
	       'archive_pages_now2' => 3};

my $now = DateTime->now;

my $three_days_ago = DateTime->now->add( days => -3 );


$session->{mk_created_session_name('archive_pages_now')} = $now->epoch;
$session->{mk_created_session_name('archive_pages_now2')} = $now->epoch;
$session->{mk_created_session_name('archive_pages_old')} = $three_days_ago->epoch;



my $Amazon_req_info;
$Amazon_req_info->{'ip'} = '72.21.203.1'; # Seattle (Amazon)
$Amazon_req_info->{'rid'} = 'cs_test';

my (@test_cases, $json, $krl_src, $krl,$result);

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



    chomp $str;
    diag("$str = ", Dumper($pt)) if $diag;
    

    push(@test_cases, {'expr' => $pt,
		       'val' => $expected,
		       'req_info' => $req_info,
		       'session' => $session,
		       'src' =>  $str,
		       'type' => $type,
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
  pre {  }
  alert("testing");
}
_KRL_

$result = <<_JS_;
function callBacks%uniq% () {};
(function(uniq, cb, msg) {alert(msg)}
('%uniq%',callBacks%uniq%,'testing'));
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
var c = 'Seattle';
function callBacks%uniq% () {};
(function(uniq, cb, msg) {alert(msg)}
('%uniq%',callBacks%uniq%,('testing' + c)));
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
var c = 'Seattle';
function callBacks%uniq% () {};
(function(uniq, cb, msg) {alert(msg)}
('%uniq%',callBacks%uniq%,('testing' + c)));
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
var c = 'Seattle';
function callBacks%uniq% () {};
(function(uniq, cb, msg) {alert(msg)}
('%uniq%',callBacks%uniq%,('testing' + c)));
_JS_

add_testcase(
    $krl_src,
    $result,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
rule test_5 is active {
  select using "/archives/" setting ()

    pre {
      c = counter.archive_pages_now;
    }

    if counter.archive_pages_now > 2 then 
      alert("test");

    fired {
      clear counter.archive_pages_now; 
    } else {
      counter.archive_pages_now += 1 from 1;  
    }
  }
_KRL_

$result = <<_JS_;
var c = 3;
function callBacks%uniq% () {};
(function(uniq, cb, msg) {alert(msg)}
('%uniq%',callBacks%uniq%,'test'));
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
      c = counter.archive_pages_now2;
    }

    if counter.archive_pages_now2 > 2 within 2 days then 
      alert("test");

    fired {
      clear counter.archive_pages_now2; 
    } else {
      counter.archive_pages_now2 += 1 from 1;  
    }
  }
_KRL_

$result = <<_JS_;
var c = 3;
function callBacks%uniq% () {};
(function(uniq, cb, msg) {alert(msg)}
('%uniq%',callBacks%uniq%,'test'));
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
      c = counter.archive_pages_old;
    }

    if counter.archive_pages_old > 2 within 2 days then 
      alert("test");

    fired {
      clear counter.archive_pages_old; 
    } else {
      counter.archive_pages_old += 1 from 1;  
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
function callBacks%uniq% () {
  KOBJ.obs('id','','rssfeed','success','test_8');
  KOBJ.obs('class','','newsletter','success','test_8');
  KOBJ.obs('id','','close_rss','failure','test_8');
};
(function(uniq, cb, msg) {alert(msg)}
 ('%uniq%',callBacks%uniq%,'test'));
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
var pt = K\$('product_name').innerHTML;
var html = '<p>This is the product title: '+pt+'</p>';
function callBacks%uniq% () {
};
(function(uniq, cb, msg) {alert(msg)}
 ('%uniq%',callBacks%uniq%,html));
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
pagename.replace(/-/, ' ');
function callBacks%uniq% () {
};
(function(uniq, cb, msg) {alert(msg)}
 ('%uniq%',callBacks%uniq%,pagename));
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
pagename.replace(/-/, ' ');
function callBacks%uniq% () {
};
(function(uniq, cb, msg) {alert(msg)}
 ('%uniq%',callBacks%uniq%,pagename));
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
var welcome = 'Don\\'t be false please! Be true!';
function callBacks%uniq% () {
};
(function(uniq, cb, msg) {alert(msg)}
 ('%uniq%',callBacks%uniq%,welcome));
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
function callBacks%uniq% () {
};
(function(uniq, cb, msg) {alert(msg)}
 ('%uniq%',callBacks%uniq%,'Hello Tim'));
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
function callBacks%uniq% () {
};
(function(){}());
callBacks%uniq%();
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
{"blocktype":"every","actions":[{"action":{"name":"alert","args":[{"val":"Hello Tim","type":"str"}],"modifiers":[]},"label":""}],"name":"april2008","pagetype":{"vars":["month"],"pattern":"http:\/\/www.utahjudo.com\\\/2008\\\/(.*?)"},"state":"active"}
_KRL_

$result = <<_JS_;
function callBacks%uniq% () {
};
(function(uniq, cb, msg) {alert(msg)}
 ('%uniq%',callBacks%uniq%,'Hello Tim'));
_JS_

add_json_testcase(
    $json,
    $result,
    $Amazon_req_info
    );


#
# global decls
#

$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_0 <- "aaa.json";
    }
}
_KRL_

my $global_decl_0 = <<_JS_;
var global_decl_0 = {"www.barnesandnoble.com":[
	       {"link":"http://aaa.com/barnesandnoble",
		"text":"AAA members sav emoney!",
		"type":"AAA"}]
          };
_JS_


add_testcase(
    $krl_src,
    $global_decl_0,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_1 <- "test_data";
    }
}
_KRL_

my $global_decl_1 = <<_JS_;
var global_decl_1 = "here is some test data!";
_JS_

add_testcase(
    $krl_src,
    $global_decl_1,
    $Amazon_req_info
    );


$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_2 <- "http://frag.kobj.net/clients/cs_test/aaa.json";
    }
}
_KRL_

my $global_decl_2 = <<_JS_;
var global_decl_2 = {"www.barnesandnoble.com":[
	       {"link":"http://aaa.com/barnesandnoble",
		"text":"AAA members sav emoney!",
		"type":"AAA"}]
          };
_JS_

add_testcase(
    $krl_src,
    $global_decl_2,
    $Amazon_req_info
    );



$krl_src = <<_KRL_;
ruleset dataset0 {
    global {
	dataset global_decl_3 <- "http://frag.kobj.net/clients/cs_test/some_data.txt";
    }
}
_KRL_

my $global_decl_3 = <<_JS_;
var global_decl_3 = "Here is some test data!";
_JS_

add_testcase(
    $krl_src,
    $global_decl_3,
    $Amazon_req_info
    );





#diag(Dumper($test_cases[-1]->{'expr'}));


plan tests => 7 + (@test_cases * 1);



# now test each test case twice
foreach my $case (@test_cases) {
    if($case->{'type'} eq 'rule') {
#	diag(Dumper($case->{'expr'}));
	my $js = eval_rule($r,
			   $case->{'req_info'}, 
			   $rule_env, 
			   $case->{'session'}, 
			   $case->{'expr'},
	   );

	my $uniq = $rule_env->{'uniq_id'};
	$uniq =~ s/^kobj_(.*)/$1/;
	$case->{'val'} =~ s/%uniq%/$uniq/g;
	is_string_nows(
	    $js,
	    $case->{'val'},
	    "Evaling rule " . $case->{'src'});
    }
}

my $ua = LWP::UserAgent->new;
my $check_url = "http://frag.kobj.net/clients/cs_test/some_data.txt";
my $response = $ua->get($check_url);
my $no_server_available = (! $response->is_success);

# now test each test case twice
foreach my $case (@test_cases) {

    if($case->{'type'} eq 'ruleset') {
    
	my $js = "";
	if( $case->{'expr'}->{'global'} && @{ $case->{'expr'}->{'global'} })  {
	    $js = eval_globals($case->{'req_info'}, 
			       $case->{'expr'},
			       $rule_env, 
		);

	}    

      SKIP: {

	  skip "No server available", 1 if ($no_server_available);
	
	  is_string_nows(
	      $js,
	      $case->{'val'},
	      "Evaling ruleset: " . $case->{'src'});
	}

    }
}

#
# rule_env_tests
#


contains_string(nows($global_decl_0),
		nows(encode_json($rule_env->{'global_decl_0'})), 
		 "Global decl data set effects env");
contains_string(nows($global_decl_1), 
		nows($rule_env->{'global_decl_1'}),
		"Global decl data set effects env");
contains_string(nows($global_decl_2), 
		nows(encode_json($rule_env->{'global_decl_2'})),
		"Global decl data set effects env");
contains_string(nows($global_decl_3), 
		nows($rule_env->{'global_decl_3'}),
		"Global decl data set effects env");



#
# session tests
#
is($session->{'archive_pages_now'}, undef, "Archive pages now reset");
is($session->{'archive_pages_now2'}, undef, "Archive pages now2 reset");
is($session->{'archive_pages_old'}, 4, "Archive pages old iterated");



#diag Dumper($rule_env);




diag("Safe to ignore warnings about unintialized values & unrecognized escapes");


sub nows {
    my $str = shift;
    $str =~ y/\n\t\r //d;
    return $str;
}

1;


