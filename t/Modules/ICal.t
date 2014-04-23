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
use warnings;

use Test::More;
use Test::LongString;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Modules::ICal qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;



my $preds = Kynetx::Modules::ICal::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;
my ($source,$result,$args,$function,$description);


# check that predicates at least run without error
# my @dummy_arg = (0);
# foreach my $pn (@pnames) {
#     ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
#     $test_count++;
# }

my $trips = [
	     {
	      "url"=>"http://maps.google.com/maps?saddr=40.334671,-111.686813",
	      "dtend"=>"20140419T024441+0000",
	      "dtstart"=>"20140419T023924+0000",
	      "comment"=>"273090",
	      "summary"=>"Trip of 4.1 miles"
	     },
	     {
	      "url"=>"http://maps.google.com/maps?saddr=40.32578,-111.734885",
	      "dtend"=>"20140419T164554+0000",
	      "comment"=>"273350",
	      "dtstart"=>"20140419T164337+0000",
	      "summary"=>"Trip of 5.2 miles"
	     },
	     {
	      "url"=>"http://maps.google.com/maps?saddr=40.278139,-111.657351",
	      "dtend"=>"20140417T151705+0000",
	      "comment"=>"271563",
	      "dtstart"=>"20140417T150313+0000",
	      "summary"=>"Trip of 3.3 miles"
	     },
	     {
	      "url"=>"http://maps.google.com/maps?saddr=40.327397,-111.729678",
	      "dtend"=>"20140419T170113+0000",
	      "comment"=>"273355",
	      "dtstart"=>"20140419T165246+0000",
	      "summary"=>"Trip of 15.4 miles"
	     },
	 ];

my $vcal = <<_EOF_;
BEGIN:VCALENDAR
VERSION:2.0
PRODID:Data::ICal 0.21
X-WR-CALDESC:Trips made in F-150
X-WR-CALNAME:My Trips Calendar
BEGIN:VEVENT
COMMENT:273090
DTEND:20140419T024441Z
DTSTART:20140419T023924Z
SUMMARY:Trip of 4.1 miles
URL:http://maps.google.com/maps?saddr=40.334671,-111.686813
END:VEVENT
BEGIN:VEVENT
COMMENT:273350
DTEND:20140419T164554Z
DTSTART:20140419T164337Z
SUMMARY:Trip of 5.2 miles
URL:http://maps.google.com/maps?saddr=40.32578,-111.734885
END:VEVENT
BEGIN:VEVENT
COMMENT:271563
DTEND:20140417T151705Z
DTSTART:20140417T150313Z
SUMMARY:Trip of 3.3 miles
URL:http://maps.google.com/maps?saddr=40.278139,-111.657351
END:VEVENT
BEGIN:VEVENT
COMMENT:273355
DTEND:20140419T170113Z
DTSTART:20140419T165246Z
SUMMARY:Trip of 15.4 miles
URL:http://maps.google.com/maps?saddr=40.327397,-111.729678
END:VEVENT
END:VCALENDAR
_EOF_


$description = "Initial ical_from_array test";
$source = 'ical';
$function = 'from_array';
$args = [$trips,
	 {"name" => "My Trips Calendar",
	  "desc" => "Trips made in F-150"
	 }
	 
];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
#diag $result, "\n";
is_string_nows($result,$vcal,$description);
$test_count++;




ok(1,"dummy test");
$test_count++;


done_testing($test_count);



1;


