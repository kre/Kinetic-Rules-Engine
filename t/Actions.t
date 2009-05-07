#!/usr/bin/perl -w 

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

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::JavaScript qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;


# test choose_action and args

my $my_req_info;
$my_req_info->{'caller'} = 'http://www.windley.com';
$my_req_info->{'pool'} = APR::Pool->new;
$my_req_info->{'txn_id'} = '1234';

my $rel_url = "/kynetx/newsletter_invite.inc";
my $non_matching_url = "http://frag.kobj.net/widgets/weather.pl?zip=84042";
my $first_arg = "kobj_test"; 
my $second_arg = "This is a string";
my $given_args;

my $rule_name = 'foo';

my $rule_env = {$rule_name . ':city' => 'Blackfoot',
		$rule_name . ':tc' => '15',
		$rule_name . ':temp' => 20,
		$rule_name . ':booltrue' => 'true',
		$rule_name . ':boolfalse' => 'false',
               };

my $session = {};




my($action,$args,$krl_src, $krl, $name, $url, @test_cases);


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
		       'desc' => $desc
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
	  'name' => 'dummy_name'
	 }
	);
}




$krl_src = <<_KRL_;
replace_html("kobj_test", "Hello World!");
_KRL_

$result = <<_JS_;
(function(uniq, cb, config, sel, text) {
 var div = \$K('<div>');
 \$K(div).attr('class', 'kobj_'+uniq).css({display: 'none'}).html(text);
 \$K(sel).replaceWith(div);
 \$K(div).slideDown('slow');
 cb();
}
('23',callbacks23,{txn_id:'1234',rule_name:'dummy_name'},'kobj_test','Hello World!'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'Basic replace_html action'
    );


$krl_src = <<_KRL_;
replace_html("kobj_test", "Hello World!")
with highlight = "yellow";
_KRL_

$result = <<_JS_;
(function(uniq, cb, config, sel, text) {
 var div = \$K('<div>');
 \$K(div).attr('class', 'kobj_'+uniq).css({display: 'none'}).html(text);
 \$K(sel).replaceWith(div);
 \$K(div).slideDown('slow');
 cb();
}
('23',callbacks23,{txn_id:'1234',rule_name:'dummy_name','highlight':'yellow'},'kobj_test','Hello World!'));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'replace_html with a single modifier'
    );



$krl_src = <<_KRL_;
replace_image_src("kobj_test", "/images/foo.png");
_KRL_

$result = <<_JS_;
(function(uniq, cb, config, id, new_url) {
    \$K(id).attr('src',new_url);
    cb();
}
('23',callbacks23, {txn_id:'1234',rule_name:'dummy_name'}, 'kobj_test','/images/foo.png'));
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

$result = <<_JS_;
(function(uniq, cb, config) {
    cb();
}
('23',callbacks23,{txn_id:'1234',rule_name:'dummy_name'}));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'noop'
    );


$krl_src = <<_KRL_;
noop() with delay = 5;
_KRL_

$result = <<_JS_;
setTimeout(function(){
(function(uniq, cb, config) {
    cb();
}

('23',callbacks23,{txn_id:'1234',rule_name:'dummy_name','delay':5}));
;KOBJ.logger('timer_expired','1234','none','','success','dummy_name');},(5*1000));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'noop_with_delay'
    );


$krl_src = <<_KRL_;
annotate_search_results(foo);
_KRL_

$result = <<_JS_;
(function(uniq, cb, config, annotate_fn) {
    KOBJ.annotate_search_results(annotate_fn, config, cb);
}
('23',callbacks23,{txn_id:'1234',rule_name:'dummy_name'},foo));
_JS_


add_action_testcase(
    $krl_src,
    $result,
    $my_req_info,
    'annotate_search_results'
    );



plan tests => 5 + (@test_cases * 3) + (@action_test_cases * 1);



# now test choose_action
foreach my $case (@test_cases) {
#    diag(Dumper($case->{'url'}));

    my $in_args = gen_js_rands( $case->{'args'} );
#    diag("In ", Dumper($in_args));

    ($action, $args) = 
	choose_action($case->{'req_info'}, 
		      $case->{'name'},
		      $case->{'args'},
                      {}, # empty rule env
                      'dummy_rule'
         );

    my $out_args = gen_js_rands( $case->{'args'} );
#    diag("Out ", Dumper($out_args));

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
    #diag(Dumper($case));


    my $js = 
	Kynetx::Actions::build_one_action(
	    $case->{'expr'},
	    $case->{'req_info'}, 
	    $rule_env,
	    $session,
	    '23',
	    'id_23',
	    'callbacks23',
	    $case->{'name'});

    my $desc = $case->{'desc'};

    is_string_nows(
	$js,
	$case->{'expected'},
	"build_one_action: $desc");

}

# emit js vars
is_string_nows(Kynetx::Actions::emit_var_decl("x", 5), 
    "var x = 5;", 
    "emit a number");
my $no_escape = "foo bar is a boo bar";
my $pls_escape = "foo bar isn't a boo bar";
my $escaped = "foo bar isn\\'t a boo bar";
is_string_nows(Kynetx::Actions::emit_var_decl("x", $no_escape), 
    "var x = '". $no_escape ."';", 
    "emit a string");
is_string_nows(Kynetx::Actions::emit_var_decl("x", $pls_escape), 
    "var x = '". $escaped . "';", 
    "emit a string");
my $a = [1,2,3];
is_string_nows(Kynetx::Actions::emit_var_decl("x", $a), 
    "var x = ". encode_json($a).";", 
    "emit an array");
my $h = {"a" =>1,
    "b" => 2,
    "c" => 3};
is_string_nows(Kynetx::Actions::emit_var_decl("x", $h), 
    "var x = ". encode_json($h).";", 
    "emit a hash");



diag("Safe to ignore warnings about unrecognized escapes");

1;


