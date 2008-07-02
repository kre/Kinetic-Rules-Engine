#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 24;
use Test::LongString;

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


# test choose_action

my $my_req_info;
$my_req_info->{'caller'} = 'http://www.windley.com';
$my_req_info->{'pool'} = APR::Pool->new;

my $rel_url = "/kynetx/newsletter_invite.inc";
my $non_matching_url = "http://127.0.0.1/kynetx/newsletter_invite.inc";
my $first_arg = "kobj_test"; 
my $second_arg = "This is a string";
my $given_args;

my($action,$args);

my $action_ast = {
    'args' => [
	{
	    'str' => $first_arg
	},
	{
	    'str' => $non_matching_url
	}
	]
};




# replace tests

my $in_args = gen_js_rands( $action_ast->{'args'} );

($action, $args) = 
    choose_action($my_req_info, 
		  "replace",
		  $action_ast->{'args'});

my $out_args = gen_js_rands( $args );


is($action, "replace_html","Replace with non-matching domain");
is($out_args->[0], $in_args->[0], "First arg unchanged");
isnt($out_args->[1], $non_matching_url, "Last arg changed");


$action_ast = {
    'args' => [
	{
	    'str' => $first_arg
	},
	{
	    'str' => $rel_url
	}
	]
};


$in_args = gen_js_rands( $action_ast->{'args'} );

($action, $args) = 
    choose_action($my_req_info, 
		  "replace", 
		  $action_ast->{'args'});


$out_args = gen_js_rands( $args );

is($action, "replace_url","Replace with relative_url");
is($out_args->[0], $in_args->[0], "First arg unchanged");
is($out_args->[1], $in_args->[1], "Replace URL is left alone");


$action_ast = {
    'args' => [
	{
	    'str' => $first_arg
	},
	{
	    'str' => $second_arg
	}
	]
};


$in_args = gen_js_rands( $action_ast->{'args'} );

($action, $args) = 
    choose_action($my_req_info, 
		  "replace_html", 
		  $action_ast->{'args'});


$out_args = gen_js_rands( $args );


is($action, "replace_html", "Replace with string");
is($out_args->[0], $in_args->[0], "First arg unchanged");
is($out_args->[1], $in_args->[1], "Replace text is left alone");


# float tests

$action_ast = {
    'args' => [
	{
	    'str' => $first_arg
	},
	{
	    'str' => $non_matching_url
	}
	]
};


$in_args = gen_js_rands( $action_ast->{'args'} );


($action, $args) = 
    choose_action($my_req_info, 
		  "float", 
		  $action_ast->{'args'});

$out_args = gen_js_rands( $args );


is($action, "float_html", "Float with non-matching domain");
is($out_args->[0], $in_args->[0], "First arg unchanged");
isnt($out_args->[1], $in_args->[1], "Last arg changed float, non-matching");


# fload with relative URL
$action_ast = {
    'args' => [
	{
	    'str' => $first_arg
	},
	{
	    'str' => $rel_url
	}
	]
};


$in_args = gen_js_rands( $action_ast->{'args'} );


($action, $args) = 
    choose_action($my_req_info, 
		  "float", 
		  $action_ast->{'args'});

$out_args = gen_js_rands( $args );


is($action, "float_url", "Float with relative_url");
is($out_args->[0], $in_args->[0], "First arg unchanged");
is($out_args->[1], $in_args->[1], "Float URL is left alone");

# float_html with string
$action_ast = {
    'args' => [
	{
	    'str' => $first_arg
	},
	{
	    'str' => $second_arg
	}
	]
};


$in_args = gen_js_rands( $action_ast->{'args'} );


($action, $args) = 
    choose_action($my_req_info, 
		  "float_html", 
		  $action_ast->{'args'});

$out_args = gen_js_rands( $args );



is($action, "float_html", "Float HTML with string");
is($out_args->[0], $in_args->[0], "First arg unchanged");
is($out_args->[1], $in_args->[1], "Float text is left alone");


# alert
$in_args = gen_js_rands( $action_ast->{'args'} );

($action, $args) = 
    choose_action($my_req_info, 
		  "alert", 
		  $action_ast->{'args'});

$out_args = gen_js_rands( $args );

is($action, "alert", "Alert");
is($out_args->[0], $in_args->[0], "Alert args unchanged");

# popup
$in_args = gen_js_rands( $action_ast->{'args'} );

($action, $args) = 
    choose_action($my_req_info, 
		  "popup", 
		  $action_ast->{'args'});

$out_args = gen_js_rands( $args );

is($action, "popup", "Popup");
is($out_args->[0], $in_args->[0], "Popup args unchanged");

# redirect
$in_args = gen_js_rands( $action_ast->{'args'} );

($action, $args) = 
    choose_action($my_req_info, 
		  "redirect", 
		  $action_ast->{'args'});

$out_args = gen_js_rands( $args );

is($action, "redirect", "Redirect");
is($out_args->[0], $in_args->[0], "Redirect args unchanged");

1;


