#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use DateTime;
use Geo::IP;

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Rules qw/:all/;
use Kynetx::Util qw/:all/;

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


my (@test_cases, $krl_src, $krl,$result);

sub add_testcase {
    my($str, $expected, $req_info, $diag) = @_;
    my $val = Kynetx::Parser::parse_rule($str);
 
    chomp $str;
    diag("$str = ", Dumper($val)) if $diag;


    push(@test_cases, {'expr' => $val,
		       'val' => $expected,
		       'req_info' => $req_info,
		       'session' => $session,
		       'src' =>  $str,
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
var pt = \$('product_name').innerHTML;
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


#$krl = Kynetx::Parser::parse_rule($krl_src);
#diag(Dumper($krl));


plan tests => 5 + (@test_cases * 1);



# now test each test case twice
foreach my $case (@test_cases) {
    #diag(Dumper($case->{'expr'}));
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
	"Evaling predicate " . $case->{'src'});
    
}

is($session->{'archive_pages_now'}, undef, "Archive pages now reset");
is($session->{'archive_pages_now2'}, undef, "Archive pages now2 reset");
is($session->{'archive_pages_old'}, 4, "Archive pages old iterated");

#
# Repository tests
#

# this ought to be read from the httpd-perl.conf file
my $svn_conn = "http://krl.kobj.net/rules/client/|cs|fizzbazz";

# this test relies on a ruleset being available for site 10.
SKIP: {

    # this number must reflect the number of test in this SKIP block
    my $how_many = 1;

    my $site = 10; # the test site.  

    my ($ctx, $svn_url, $rules) ;
    eval {

	$rules = Kynetx::Rules::get_rules_from_repository($site, $svn_conn);
	
    };
    skip "Can't get SVN connection on $svn_conn", $how_many if $@;

    ok(exists $rules->{$site});

}


# This test relies on rulesets test0 and test 1 being identical.
# To test json and krl idempotence and that get_rules_from_repository
# returns .krl or .json as needed, test0 should be .krl and test1
# .json
SKIP: {

    # this number must reflect the number of test in this SKIP block
    my $how_many = 1;


    my ($rules0, $rules1);

    my $site = 'test0'; # the test site.  
    eval {

	$rules0 = Kynetx::Rules::get_rules_from_repository($site, $svn_conn);

	
    };
    skip "Can't get rules from $svn_conn for $site", $how_many if $@;

    $site = 'test1'; # the test site.  
    eval {

	$rules1 = Kynetx::Rules::get_rules_from_repository($site, $svn_conn);
	
    };
    skip "Can't get rules from $svn_conn for $site", $how_many if $@;

    is_deeply($rules0, $rules1);

}

diag("Safe to ignore warnings about unintialized values & unrecognized escapes");


1;


