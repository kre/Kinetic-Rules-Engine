#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
#plan tests => 24;
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

use Data::Dumper;
$Data::Dumper::Indent = 1;


# test choose_action

my $my_req_info;
$my_req_info->{'caller'} = 'http://www.windley.com';
$my_req_info->{'pool'} = APR::Pool->new;

my $rel_url = "/kynetx/newsletter_invite.inc";
my $non_matching_url = "http://frag.kobj.net/widgets/weather.pl?zip=84042";
my $first_arg = "kobj_test"; 
my $second_arg = "This is a string";
my $given_args;

my($action,$args,$krl_src, $krl, $name, $url, @test_cases);


sub add_testcase {
    my($str, $expected, $req_info, $url_changed, $desc, $diag) = @_;
    my $krl = Kynetx::Parser::parse_action($krl_src);
 
    chomp $str;
    diag("$str = ", Dumper($krl)) if $diag;

    push(@test_cases, {'expr' => $krl,
		       'expected' => $expected,
		       'name' => $krl->{actions}->[0]->{action}->{name},
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


plan tests => 0 + (@test_cases * 3);



# now test each test case twice
foreach my $case (@test_cases) {
#    diag(Dumper($case->{'url'}));

    my $in_args = gen_js_rands( $case->{'args'} );
#    diag("In ", Dumper($in_args));

    ($action, $args) = 
	choose_action($case->{'req_info'}, 
		      $case->{'name'},
		      $case->{'args'});

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


diag("Safe to ignore warnings about unrecognized escapes");

1;


