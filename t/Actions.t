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
#plan tests => 24;
use Test::LongString;
use JSON::XS;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use APR::URI;
use APR::Pool ();
use LWP::Simple;
use Cache::Memcached;
use Apache::Session::Memcached;
use DateTime;

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::JavaScript qw/:all/;
use Kynetx::JavaScript::AST qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Json qw/:all/;

use Kynetx::FakeReq qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env({'foo' => 56});


my $session = Kynetx::Test::gen_session($r, $rid);

my $rel_url = "/kynetx/newsletter_invite.inc";
my $non_matching_url = "http://frag.kobj.net/widgets/weather.pl?zip=84042";
my $first_arg = "kobj_test"; 
my $second_arg = "This is a string";
my $given_args;


my($action,$args,$krl_src, $krl, $name, $url, $config, @test_cases);


sub add_testcase {
    my($str, $expected, $req_info, $url_changed, $desc, $diag) = @_;
    my $krl = Kynetx::Parser::parse_action($krl_src);
 
    chomp $str;
    diag("$str = ", Dumper($krl)) if $diag;

    push(@test_cases, {'expr' => $krl,
		       'expected' => $expected,
		       'name' => $krl->{actions}->[0]->{action}->{name} || 'no_name',
		       'args' => $krl->{actions}->[0]->{action}->{args},
		       'url' => $krl->{actions}->[0]->{action}->{args}->[1]->{val},
		       'changed' => ($url_changed eq 'changed'),
		       'req_info' => $req_info,
		       'src' =>  $str,
		       'desc' => $desc,
		       'diag' => $diag
	 }
	 );
}


$krl_src = <<_KRL_;
replace("kob_test", "http://frag.kobj.net/widgets/weather.pl?zip=84042");
_KRL_
add_testcase($krl_src,
	     'replace_html',
	     $my_req_info,
	     'changed',
	     'replace with non matching URL'
	     );


$krl_src = <<_KRL_;
replace("kob_test", "/kynetx/newsletter_invite.inc");
_KRL_
add_testcase($krl_src,
	     'replace_url',
	     $my_req_info,
	     'not_changed',
	     'replace with relative URL',
	     );


$krl_src = <<_KRL_;
replace_html("kobj_test", "This is a string");
_KRL_
add_testcase($krl_src,
	     'replace_html',
	     $my_req_info,
	     'not_changed',
	     'replace_html with text',
	     );


$krl_src = <<_KRL_;
float("kob_test", "http://frag.kobj.net/widgets/weather.pl?zip=84042");
_KRL_
add_testcase($krl_src,
	     'float_html',
	     $my_req_info,
	     'changed',
	     'float with non matching URL',
	     0
	     );

$krl_src = <<_KRL_;
float("kob_test", "/kynetx/newsletter_invite.inc");
_KRL_
add_testcase($krl_src,
	     'float_url',
	     $my_req_info,
	     'not_changed',
	     'float with relative URL',
	     );

$krl_src = <<_KRL_;
float_html("kobj_test", "This is a string");
_KRL_
add_testcase($krl_src,
	     'float_html',
	     $my_req_info,
	     'not_changed',
	     'float_html with text',
	     );


$krl_src = <<_KRL_;
alert("kobj_test", "foo");
_KRL_
add_testcase($krl_src,
	     'alert',
	     $my_req_info,
	     'not_changed',
	     'alert with text',
	     );


$krl_src = <<_KRL_;
popup("kobj_test", "foo");
_KRL_
add_testcase($krl_src,
	     'popup',
	     $my_req_info,
	     'not_changed',
	     'pop with text',
	     );


$krl_src = <<_KRL_;
redirect("http://www.google.com", "foo");
_KRL_
add_testcase($krl_src,
	     'redirect',
	     $my_req_info,
	     'not_changed',
	     'redirect',
	     );




#$krl = Kynetx::Parser::parse_action($krl_src);
#diag(Dumper($krl));


my(@action_test_cases, $result);

# full actions
sub add_action_testcase {
    my($str, $expected, $req_info, $desc, $diag) = @_;
    my $krl = Kynetx::Parser::parse_action($krl_src);
 
    chomp $str;
    diag("$str = ", Dumper($krl)) if $diag;

    push(@action_test_cases, 
	 {'expr' => $krl->{'actions'}->[0], # just the first one
	  'expected' => $expected,
	  'req_info' => $req_info,
	  'src' =>  $str,
	  'desc' => $desc,
	  'name' => 'dummy_name',
	  'diag' => $diag
	 }
	);
}




$krl_src = <<_KRL_;
replace_html("kobj_test", "Hello World!");
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
]);

$result = <<_JS_;
(function(uniq, cb, config, sel, text) {
 var div = \$K('<div>');
 \$K(div).attr('class', 'kobj_'+uniq).css({display: 'none'}).html(text);
 \$K(sel).replaceWith(div);
 \$K(div).slideDown('slow');
 cb();
}
('%uniq%',callbacks23,$config,'kobj_test','Hello World!'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic replace_html action'
    );



$krl_src = <<_KRL_;
replace_html("kobj_test", "Hello World!")
 with foo = 5
_KRL_


$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
   {"foo" => 5},
]);


$result = <<_JS_;
(function(uniq, cb, config, sel, text) {
 var div = \$K('<div>');
 \$K(div).attr('class', 'kobj_'+uniq).css({display: 'none'}).html(text);
 \$K(sel).replaceWith(div);
 \$K(div).slideDown('slow');
 cb();
}
('%uniq%',callbacks23,$config,'kobj_test','Hello World!'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic replace_html action with one modifier'
    );



$krl_src = <<_KRL_;
replace_html("kobj_test", "Hello World!")
 with foo = 2+3
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
   {"foo" => {type => 'JS',
              val => '(2+3)'}
    }
  ]);


$result = <<_JS_;
(function(uniq, cb, config, sel, text) {
 var div = \$K('<div>');
 \$K(div).attr('class', 'kobj_'+uniq).css({display: 'none'}).html(text);
 \$K(sel).replaceWith(div);
 \$K(div).slideDown('slow');
 cb();
}
('%uniq%',callbacks23,$config,'kobj_test','Hello World!'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic replace_html action with one modifier (and addition)'
    );


##
## float and mod
##

$krl_src = <<_KRL_;
float_html("absolute", "top:50px", "right:50px", "Hello World!")
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
  ]);


$result = <<_JS_;
(function(uniq, cb, config, pos, top, side, text) {
     var d = KOBJ.buildDiv(uniq, pos, top, side,config);
     \$K(d).html(text);
     \$K('body').append(d);
     cb();
 }
 ('%uniq%',callbacks23,$config,'absolute','top:50px','right:50px','Hello World!'));
 \$K('#kobj_%uniq%').fadeIn();
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic float_html action with no modifier',
    0
    );


$krl_src = <<_KRL_;
float_html("absolute", "top:50px", "right:50px", "Hello World!")
 with effect = "slide"
_KRL_


$config = mk_config_string(
 [
  {"rule_name" => 'dummy_name'},
  {"rid" => 'cs_test'},
  {"txn_id" => '1234'},
  {"effect" => "slide"},
 ]);


$result = <<_JS_;
(function(uniq, cb, config, pos, top, side, text) {
     var d = KOBJ.buildDiv(uniq, pos, top, side,config);
     \$K(d).html(text);
     \$K('body').append(d);
     cb();
 }
 ('%uniq%',callbacks23,$config,'absolute','top:50px','right:50px','Hello World!'));
 \$K('#kobj_%uniq%').slideDown();
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic float_html action with one modifier (slide)',
    0
    );


$krl_src = <<_KRL_;
float_html("absolute", "top:50px", "right:50px", "Hello World!")
 with effect = "slide" and 
      delay = 5
_KRL_


$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
   {"effect" => "slide"},
   {"delay" => 5},
 ]);


$result = <<_JS_;
setTimeout(function() {
(function(uniq, cb, config, pos, top, side, text) {
     var d = KOBJ.buildDiv(uniq, pos, top, side,config);
     \$K(d).html(text);
     \$K('body').append(d);
     cb();
 }
 ('%uniq%',callbacks23,$config,'absolute','top:50px','right:50px','Hello World!'));
 \$K('#kobj_%uniq%').slideDown();
;KOBJ.logger('timer_expired','1234','none','','success','dummy_name','cs_test');},(5*1000));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic float_html action with two modifier (slide & delay)',
    0
    );


$krl_src = <<_KRL_;
float_html("absolute", "top:50px", "right:50px", "Hello World!")
 with effect = "blind"
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
   {"effect" => 'blind'},
 ]);


$result = <<_JS_;
(function(uniq, cb, config, pos, top, side, text) {
     var d = KOBJ.buildDiv(uniq, pos, top, side,config);
     \$K(d).html(text);
     \$K('body').append(d);
     cb();
 }
 ('%uniq%',callbacks23,$config,'absolute','top:50px','right:50px','Hello World!'));
 \$K('#kobj_%uniq%').slideDown();
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic float_html action with one modifier (blind)',
    0
    );


$krl_src = <<_KRL_;
float_html("absolute", "top:50px", "right:50px", "Hello World!")
 with draggable = true
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
   {"draggable" => {'type' => 'JS',
                     'val' => 'true'}},
  ]);

$result = <<_JS_;
(function(uniq, cb, config, pos, top, side, text) {
     var d = KOBJ.buildDiv(uniq, pos, top, side,config);
     \$K(d).html(text);
     \$K('body').append(d);
     cb();
 }
 ('%uniq%',callbacks23,$config,'absolute','top:50px','right:50px','Hello World!'));
 \$K('#kobj_%uniq%').fadeIn();
 \$K('#kobj_%uniq%').draggable();
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic float_html action with one modifier (draggable)',
    0
    );

$krl_src = <<_KRL_;
float_html("absolute", "top:50px", "right:50px", "Hello World!")
 with draggable = true
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},  
   {"txn_id" => '1234'},
   {"draggable" => {'type' => 'JS',
                     'val' => 'true'}},
  ]);

$result = <<_JS_;
(function(uniq, cb, config, pos, top, side, text) {
     var d = KOBJ.buildDiv(uniq, pos, top, side,config);
     \$K(d).html(text);
     \$K('body').append(d);
     cb();
 }
 ('%uniq%',callbacks23,$config,'absolute','top:50px','right:50px','Hello World!'));
 \$K('#kobj_%uniq%').fadeIn();
 \$K('#kobj_%uniq%').draggable();
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic float_html action with one modifier (draggable)',
    0
    );


##
## popup
##

$krl_src = <<_KRL_;
popup("top:50px", "right:50px", "Hello World!", "50px", "100px", "http:")
 with effect="onpageexit"
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
   {"effect" => "onpageexit"},
  ]);


$result = <<_JS_;
function leave_kobj_%uniq% () {
(function(uniq, cb, config, top, left, width, height, url) {      
     var id_str = 'kobj_'+uniq;
     var options = 'toolbar=no,menubar=no,resizable=yes,scrollbars=yes,alwaysRaised=yes,status=no' +
                  'left=' + left + ', ' +
                  'top=' + top + ', ' +
                  'width=' + width + ', ' +
                  'height=' + height;
     open(url,id_str,options);
     cb();
 }
 ('%uniq%',callbacks23,$config,'top:50px','right:50px','Hello World!','50px','100px','http:'));
};
document.body.setAttribute('onUnload', 'leave_kobj_%uniq%()');
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'popup action with one modifier (onpageexit)',
    0
    );



$krl_src = <<_KRL_;
popup("top:50px", "right:50px", "Hello World!", "50px", "100px", "http:")
_KRL_

$config = mk_config_string(
   [
    {"rule_name" => 'dummy_name'},
    {"rid" => 'cs_test'},
    {"txn_id" => '1234'},
   ]);


$result = <<_JS_;
(function(uniq, cb, config, top, left, width, height, url) {      
     var id_str = 'kobj_'+uniq;
     var options = 'toolbar=no,menubar=no,resizable=yes,scrollbars=yes,alwaysRaised=yes,status=no' +
                  'left=' + left + ', ' +
                  'top=' + top + ', ' +
                  'width=' + width + ', ' +
                  'height=' + height;
     open(url,id_str,options);
     cb();
 }
 ('%uniq%',callbacks23,$config,'top:50px','right:50px','Hello World!','50px','100px','http:'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'popup action with no modifier',
    0
    );



##
## replace_img_src
##

$krl_src = <<_KRL_;
replace_image_src("kobj_test", "/images/foo.png");
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test' },
   {"txn_id" => '1234'},
  ]);


$result = <<_JS_;
(function(uniq, cb, config, id, new_url) {
    \$K(id).attr('src',new_url);
    cb();
}
('%uniq%',callbacks23, $config, 'kobj_test','/images/foo.png'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'replace_image_src'
    );


$krl_src = <<_KRL_;
noop();
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
  ]);

$result = <<_JS_;
(function(uniq, cb, config) {
    cb();
}
('%uniq%',callbacks23,$config));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'noop',
    0
    );


$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
   {"delay" => 5},
  ]);

$krl_src = <<_KRL_;
noop() with delay = 5;
_KRL_

$result = <<_JS_;
setTimeout(function(){
(function(uniq, cb, config) {
    cb();
}

('%uniq%',callbacks23,$config));
;KOBJ.logger('timer_expired','1234','none','','success','dummy_name','cs_test');},(5*1000));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'noop_with_delay',
    0
    );

$config = mk_config_string(
   [
    {"rule_name" => 'dummy_name'},
    {"rid" => 'cs_test'},
    {"txn_id" => '1234'},
    {"tabLocation" => "left"},
    {"pathToTabImage" => "http://wpaoli.building58.com/wp-content/uploads/2009/09/contact_tab.gif"},
    {"name" => "JAM_test2"},
    {"message" => "How do you do?"},
 ]);

$krl_src = <<_KRL_;
sidetab() with tabLocation = "left" and
    pathToTabImage = "http://wpaoli.building58.com/wp-content/uploads/2009/09/contact_tab.gif" and
    name = "JAM_test2" and 
    message = "How do you do?"
_KRL_

$result = <<_JS_;
(function(uniq, cb, config) {
     KOBJ.tabManager.addNew(config);
     cb();
 }
 ('%uniq%',callbacks23, $config
 ));

_JS_

add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'sidetab test',
    0
    );

$krl_src = <<_KRL_;
annotate_search_results(foo);
_KRL_

$config = mk_config_string(
  [
   {"rule_name" => 'dummy_name'},
   {"rid" => 'cs_test'},
   {"txn_id" => '1234'},
  ]
);


$result = <<_JS_;
(function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_search_results(annotate_fn, config, cb);
}
('%uniq%',callbacks23,$config,foo));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'annotate_search_results'
    );


$krl_src = <<_KRL_;
annotate_search_results();
_KRL_

$config = mk_config_string(
   [
    {"rule_name" => 'dummy_name'},
    {"rid" => 'cs_test'},
    {"txn_id" => '1234'},
  ]);


$result = <<_JS_;
(function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_search_results(annotate_fn, config, cb);
}
('%uniq%',callbacks23,$config));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'annotate_search_results'
    );

$krl_src = <<_KRL_;
annotate_local_search_results() with
  remote = "http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?";
_KRL_

$config = mk_config_string(
   [
    {"rule_name" => 'dummy_name'},
    {"rid" => 'cs_test'},
    {"txn_id" => '1234'},
    {"remote" => 'http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?'},
   ]);


$result = <<_JS_;
(function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_local_search_results(annotate_fn, config, cb);
}
('%uniq%',callbacks23,$config));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'annotate_search_local_results'
    );








$krl_src = <<_KRL_;
page_content("bob",{"google_footer":{"selector":"#fll","type":"text"},
      "search_links":{"selector":"#sbl","type":"text"}});
_KRL_


$config = mk_config_string(
 [
  {"rule_name" => 'dummy_name'},
  {"rid" => 'cs_test'},
  {"txn_id" => '1234'},
 ]);


$result = <<_JS_;
(   function(uniq, cb, config, label, selectors) {
        KOBJ.page_content_event(uniq, label, selectors ,config);
        cb();
    }
('%uniq%',callbacks23,$config ,'bob',{'google_footer' : {'selector' : '#fll', 'type' : 'text'}, 'search_links' : {'selector' : '#sbl', 'type' : 'text'}}));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Generate Page Data Action',
    0
    );



$krl_src = <<_KRL_;
page_collection_content("bob","#res","li.g",{"google_footer":{"selector":"#fll","type":"text"},
      "search_links":{"selector":"#sbl","type":"text"}}) with callback <|mycallback|>;
_KRL_


$config = mk_config_string(
 [
  {"rule_name" => 'dummy_name'},
  {"rid" => 'cs_test'},
  {"txn_id" => '1234'},
 ]);


$result = <<_JS_;
(   function(uniq, cb, config, label,top_selector,parent_selector,selectors) {
        KOBJ.page_collection_content_event(uniq, label,top_selector, parent_selector, selectors ,config);
        cb();
    }
('%uniq%',callbacks23,$config ,'bob','#res','li.g',{'google_footer' : {'selector' : '#fll', 'type' : 'text'}, 'search_links' : {'selector' : '#sbl', 'type' : 'text'}}));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Generate Page Collection Data Action',
    0
    );


# Test raise event

$krl_src = <<_KRL_;
raise_event("testevent") with app_id = "aaaa" and parameters = {"aaa":"bbb"};
_KRL_


$config = mk_config_string(
 [
  {"rule_name" => 'dummy_name'},
  {"rid" => 'cs_test'},
  {"txn_id" => '1234'},
  {"app_id" => 'aaaa'},
  {"parameters" => {"aaa" => "bbb" }}
 ]);


$result = <<_JS_;
(   function(uniq, cb, config, event_name) {
        KOBJ.raise_event_action(uniq, event_name,config);
        cb();
    }
('%uniq%',callbacks23,$config ,'testevent'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Generate Page Collection Data Action',
    0
    );



# Test content_changed

$krl_src = <<_KRL_;
content_changed("#rso") with parameters = {"aaa":"bbb"};
_KRL_


$config = mk_config_string(
 [
  {"rule_name" => 'dummy_name'},
  {"rid" => 'cs_test'},
  {"txn_id" => '1234'},
  {"parameters" => {"aaa" => "bbb" }}
 ]);


$result = <<_JS_;
(   function(uniq, cb, config, selector) {
    var app = KOBJ.get_application(config.rid);
          if(config.parameters)
            KOBJEventManager.register_interest("content_change",selector,app,{"param_data" : config.parameters });
          else
            KOBJEventManager.register_interest("content_change",selector,app);
        cb();
    }
('%uniq%',callbacks23,$config ,'#rso'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Generate Page Collection Data Action',
    0
    );



# now test choose_action
foreach my $case (@test_cases) {
    diag(Dumper($case->{'url'})) if $case->{'diag'};

    my $in_args = gen_js_rands( $case->{'args'} );
    diag("In ", Dumper($in_args)) if $case->{'diag'};

    ($action, $args) = 
	choose_action($case->{'req_info'}, 
		      $case->{'name'},
		      $case->{'args'},
                      {}, # empty rule env
                      'dummy_rule'
         );

    my $out_args = gen_js_rands( $case->{'args'} );
    diag("Out ", Dumper($out_args))  if $case->{'diag'};

    my $desc = $case->{'desc'};

    is($action, $case->{'expected'},"Action: $desc");
    is($out_args->[0], $in_args->[0], "First arg: $desc");
    if ($case->{'changed'}) {
	isnt($out_args->[1], "'".$case->{url}."'", "Last arg: $desc");
    } else {
	is($out_args->[1], "'".$case->{url}."'", "Last arg: $desc");
    }

}


# now test build_one_action
foreach my $case (@action_test_cases) {
    diag(Dumper($case))  if $case->{'diag'};

    my $js = 
	Kynetx::Actions::build_one_action(
	    $case->{'expr'},
	    $case->{'req_info'}, 
	    extend_rule_env(['uniq_id', 'uniq'], ['kobj_23','23'],	    
		extend_rule_env(['actions','labels','tags'],[[],[],[]],$rule_env)),
	    $session,
	    'callbacks23',
	    $case->{'name'});

    diag $js if $case->{'diag'};

    my $desc = $case->{'desc'};
    
    my $expected = $case->{'expected'};
    $expected =~ s/%uniq%/$case->{'req_info'}->{'uniq'}/g;

    is_string_nows(
	$js,
	$expected,
	"build_one_action: $desc");

}




#diag Dumper($session);

## resouce testing

my $fl_resources = Kynetx::Actions::FlippyLoo::get_resources();
Kynetx::JavaScript::AST::register_resources($my_req_info, $fl_resources);

is_deeply($my_req_info->{'resources'}, $fl_resources, "got right resources");

my $ast = Kynetx::JavaScript::AST->new(time);
$ast->add_resources($rid, $my_req_info->{'resources'});
my $resource_js = $ast->mk_registered_resource_js($rid);
like($resource_js, qr#KOBJ.registerExternalResources\('cs_test', \{"http://static.kobj.net/kjs-frameworks/flippy_loo/\d.\d/obFlippyloo.js":\{"type":"js"\}\}\);#, "got the right JS");

my $jqui_resources = Kynetx::Actions::JQueryUI::get_resources();
Kynetx::JavaScript::AST::register_resources($my_req_info, $jqui_resources);


my $merged_resource = {};

 while( my ($k, $v) = each %$fl_resources ) {
            $merged_resource->{$k} = $v;
        }

 while( my ($k, $v) = each %$jqui_resources ) {
            $merged_resource->{$k} = $v;
        }

is_deeply($my_req_info->{'resources'}, $merged_resource, "got right resources");

$ast->add_resources($rid, $my_req_info->{'resources'});
$resource_js = $ast->mk_registered_resource_js($rid);
#like($resource_js, qr#KOBJ.registerExternalResources\('cs_test', \{"http://static.kobj.net/kjs-frameworks/flippy_loo/\d.\d/obFlippyloo.js":\{"type":"js"\},"http://static.kobj.net/kjs-frameworks/jquery_ui/\d.\d/jquery-ui-\d.\d.custom.js":\{"type":"js"\},"http://static.kobj.net/kjs-frameworks/jquery_ui/\d.\d/css/ui-darkness/jquery-ui-\d.\d.custom.css":\{"selector":".ui-helper-hidden","type":"css"\}\}\);#, "got the right JS");
#diag($resource_js);

#diag Dumper $my_req_info;
#diag "Resource JS: ", $resource_js;

done_testing(3 + (@test_cases * 3) + (@action_test_cases * 1));

#diag("Safe to ignore warnings about unrecognized escapes");

session_cleanup($session);

1;


