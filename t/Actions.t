#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
plan tests => 24;
use Test::LongString;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use APR::URI;
use APR::Pool ();
use LWP::Simple;

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;


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


# replace tests
($action, $args) = 
    choose_action($my_req_info, 
		  "replace", 
		  [$first_arg, $non_matching_url]);

is($action, "replace_html","Replace with non-matching domain");
is($args->[0], $first_arg, "First arg unchanged");
isnt($args->[1], $non_matching_url, "Last arg changed");


($action, $args) = 
    choose_action($my_req_info, 
		  "replace", 
		  [$first_arg, $rel_url]);

is($action, "replace_url","Replace with relative_url");
is($args->[0], $first_arg, "First arg unchanged");
is($args->[1], $rel_url, "Replace URL is left alone");


($action, $args) = 
    choose_action($my_req_info, 
		  "replace_html", 
		  [$first_arg, $second_arg]);

is($action, "replace_html", "Replace with string");
is($args->[0], $first_arg, "First arg unchanged");
is($args->[1], $second_arg, "Replace text is left alone");


# float tests
($action, $args) = 
    choose_action($my_req_info, 
		  "float", 
		  [$first_arg, $non_matching_url]);

is($action, "float_html", "Float with non-matching domain");
is($args->[0], $first_arg, "First arg unchanged");
isnt($args->[1], $non_matching_url, "Last arg changed");


($action, $args) = 
    choose_action($my_req_info, 
		  "float", 
		  [$first_arg, $rel_url]);

is($action, "float_url", "Float with relative_url");
is($args->[0], $first_arg, "First arg unchanged");
is($args->[1], $rel_url, "Float URL is left alone");

($action, $args) = 
    choose_action($my_req_info, 
		  "float_html", 
		  [$first_arg, $second_arg]);

is($action, "float_html", "Float with string");
is($args->[0], $first_arg, "First arg unchanged");
is($args->[1], $second_arg, "Float text is left alone");


# alert
($action, $args) = 
    choose_action($my_req_info, 
		  "alert", 
		  [$first_arg]);

is($action, "alert", "Alert");
is($args->[0], $first_arg, "Alert args unchanged");

# popup
($action, $args) = 
    choose_action($my_req_info, 
		  "popup", 
		  [$first_arg]);

is($action, "popup", "Popup");
is($args->[0], $first_arg, "Popup args unchanged");

# redirect
($action, $args) = 
    choose_action($my_req_info, 
		  "redirect", 
		  [$first_arg]);

is($action, "redirect", "Redirect");
is($args->[0], $first_arg, "Redirect args unchanged");

1;


