package Kynetx::Test;
# file: Kynetx/Test.pm
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
use strict;
#use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Log::Log4perl qw(get_logger :levels);
use IPC::Lock::Memcached;

use Kynetx::Environments qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Persistence qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Request qw(:all);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
getkrl
trim
nows
mk_config_string
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my $re_rid;

sub getkrl {
    my $filename = shift;

    open(KRL, "< $filename") || die "Can't open file $filename: $!\n";
    my $first_line = <KRL>;
    local $/ = undef;
    my $krl = <KRL>;
    close KRL;
    if ($first_line =~ m%^\s*//.*%) {
	return ($first_line,$krl);
    } else {
	return ("No comment", $first_line . $krl);
    }

}

# Perl trim function to remove whitespace from the start and end of the string
sub trim {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub nows {
    my $str = shift;
    $str =~ y/\n\t\r //d;
    return $str;
}


sub configure {
    # configure KNS
    Kynetx::Configure::configure();

    Kynetx::Memcached->init();

    return new Kynetx::FakeReq();
}

sub gen_req_info {
    my($rid, $options, $event_attrs) = @_;
    my $req_info;
    $re_rid = $rid;
    $req_info->{'ip'} =  '72.21.203.1';
#    $req_info->{'caller'} = 'http://www.windley.com/';
#    $req_info->{'pool'} = APR::Pool->new;
    $req_info->{'txn_id'} = '1234';
    $req_info->{$rid.':kinetic_app_version'} = 'dev';
    $req_info->{'eid'} = '0123456789abcdef';


    Kynetx::Request::add_event_attr($req_info, 'msg', 'Hello World!');
#    Kynetx::Request::add_event_attr($req_info, 'caller', 'http://www.windley.com/');

    $req_info->{'caller'} = 'http://www.windley.com/';

    # $req_info->{'param_names'} = ['msg','caller'];
    # $req_info->{'msg'} = 'Hello World!';

    foreach my $k (keys %{ $options}) {
      $req_info->{$k} = $options->{$k}; 
    }

    foreach my $k (keys %{ $event_attrs}) {
      Kynetx::Request::add_event_attr($req_info, $k, $options->{$k});
    }

    my $ver = $options->{'ridver'} || 'prod';

    $req_info->{'rid'} = mk_rid_info($req_info,$rid, {'version' => $ver});


    return $req_info;
}

sub gen_rule_env {
  my($options) = @_;

  my $rule_env = empty_rule_env();
  
  $rule_env =  extend_rule_env(
			       ['city','tc','temp','booltrue','boolfalse','a','b','c'],
			       ['Blackfoot','15',20,'true','false','10','11',[5,6,4]],
			       $rule_env);

  $rule_env = extend_rule_env('store',{
				       "store"=> {
						  "book"=> [
							    {
							     "category"=> "reference",
							     "author"=> "Nigel Rees",
							     "title"=> "Sayings of the Century",
							     "price"=> 8.95,
							     "ratings"=> [
									  1,
									  3,
									  2,
									  10
									 ]
							    },
							    {
							     "category"=> "fiction",
							     "author"=> "Evelyn Waugh",
							     "title"=> "Sword of Honour",
							     "price"=> 12.99,
							     "ratings" => [
									   "good",
									   "bad",
									   "lovely"
									  ]
							    },
							    {
							     "category"=> "fiction",
							     "author"=> "Herman Melville",
							     "title"=> "Moby Dick",
							     "isbn"=> "0-553-21311-3",
							     "price"=> 8.99
							    },
							    {
							     "category"=> "fiction",
							     "author"=> "J. R. R. Tolkien",
							     "title"=> "The Lord of the Rings",
							     "isbn"=> "0-395-19395-8",
							     "price"=> 22.99
							    }
							   ],
						  "bicycle"=> {
							       "color"=> "red",
							       "price"=> 19.95
							      }
						 }
				      },$rule_env);



  return extend_rule_env($options, $rule_env);
}

sub gen_session {
    my($r, $rid, $options) = @_;
    my $session = process_session($r, $options->{'sid'});
    my $test_hash = {
		'a' => '1.1',
		'b' => {
			'c' => '2.1',
			'e' => '2.2',
			'f' => {
				'g' => ['3.a','3.b','3.c','3.d'],
				'h' => 5
			}
		},
		'd' =>'1.3'	
	};
	
	
    Kynetx::Persistence::save_persistent_var("ent",$rid, $session, 'archive_pages_old', 3);
    my $three_days_ago = DateTime->now->add( days => -3 );
    Kynetx::Persistence::touch_persistent_var("ent",$rid, $session, 'archive_pages_old', $three_days_ago);

    Kynetx::Persistence::save_persistent_var("ent",$rid, $session, 'my_count', 2);

    Kynetx::Persistence::save_persistent_var("ent",$rid, $session, 'archive_pages_now', 2);
    Kynetx::Persistence::save_persistent_var("ent",$rid, $session, 'archive_pages_now2', 3);

    Kynetx::Persistence::delete_persistent_var("ent",$rid, $session, 'my_trail');
    Kynetx::Persistence::add_trail_element("ent",$rid, $session, 'my_trail', "http://www.windley.com/foo.html");
    Kynetx::Persistence::add_trail_element("ent",$rid, $session, 'my_trail', "http://www.kynetx.com/foo.html");
    Kynetx::Persistence::add_trail_element("ent",$rid, $session, 'my_trail', "http://www.windley.com/bar.html");
	
	Kynetx::Persistence::save_persistent_var("ent",$rid, $session, 'tHash', $test_hash);

    Kynetx::Persistence::delete_persistent_var("ent",$rid, $session, 'my_flag');

    return $session;
}

sub gen_app_session {
    my($r, $req_info, $options) = @_;

    my $logger = get_logger();

    $logger->debug("Generating test app session for get_rid($req_info->{'rid'})");

    my $rid = get_rid($req_info->{'rid'});

    # NOTE: NONE OF THIS WORKS!!!

    # set up app session, the place where app vars store data
    $req_info->{'appsession'} = eval {
	# since we generate from the RID, we get the same one...
	my $key = Digest::MD5::md5_hex($rid);
	$logger->debug("Key for $rid is $key");
	Kynetx::Session::tie_servers({},$key);
      };

    if ($@) {
      $logger->debug("Didn't get session $@");
    }


    Kynetx::Persistence::save_persistent_var("ent",$rid, $req_info->{'appsession'}, 'app_count_old', 3);
    my $three_days_ago = DateTime->now->add( days => -3 );
    Kynetx::Persistence::touch_persistent_var("ent",$rid, $req_info->{'appsession'}, 'app_count_old', $three_days_ago);

    Kynetx::Persistence::save_persistent_var("ent",$rid, $req_info->{'appsession'}, 'app_count', 2);

    Kynetx::Persistence::save_persistent_var("ent",$rid, $req_info->{'appsession'}, 'app_count_now', 2);
    Kynetx::Persistence::save_persistent_var("ent",$rid, $req_info->{'appsession'}, 'app_count_now2', 3);

    Kynetx::Persistence::delete_persistent_var("ent",$rid, $req_info->{'appsession'}, 'app_trail');
    Kynetx::Persistence::add_trail_element("ent",$rid, $req_info->{'appsession'}, 'app_trail', "http://www.windley.com/foo.html");
    Kynetx::Persistence::add_trail_element("ent",$rid, $req_info->{'appsession'}, 'app_trail', "http://www.kynetx.com/foo.html");
    Kynetx::Persistence::add_trail_element("ent",$rid, $req_info->{'appsession'}, 'app_trail', "http://www.windley.com/bar.html");


    Kynetx::Persistence::delete_persistent_var("ent",$rid, $req_info->{'appsession'}, 'app_flag');

}

sub mk_config_string {
  my($a) = @_;
  my @items;
  foreach my $h ( @{ $a }) {
    my $k = (keys %{ $h })[0]; #singleton hashes
    my $v = (ref $h->{$k} eq 'HASH' && defined $h->{$k}->{'type'}) ?
      $h->{$k} :
      Kynetx::Expressions::typed_value($h->{$k});
    push(@items,
	 Kynetx::JavaScript::gen_js_hash_item(
                        $k,
			$v)
           );
    }
  return  '{' . join(",", @items) . '}';
}



1;
