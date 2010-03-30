package Kynetx::Test;
# file: Kynetx/Test.pm
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
use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Kynetx::Environments qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
getkrl
trim
nows
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


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
    my($rid, $options) = @_;
    my $req_info;
    $req_info->{'ip'} =  '72.21.203.1';
    $req_info->{'caller'} = 'http://www.windley.com/';
    $req_info->{'pool'} = APR::Pool->new;
    $req_info->{'txn_id'} = '1234';
    $req_info->{'rid'} = $rid;

    foreach my $k (keys %{ $options}) {
      $req_info->{$k} = $options->{$k};
    }

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

    session_store($rid, $session, 'archive_pages_old', 3);
    my $three_days_ago = DateTime->now->add( days => -3 );
    session_touch($rid, $session, 'archive_pages_old', $three_days_ago);

    session_store($rid, $session, 'my_count', 2);

    session_store($rid, $session, 'archive_pages_now', 2);
    session_store($rid, $session, 'archive_pages_now2', 3);

    session_delete($rid, $session, 'my_trail');
    session_push($rid, $session, 'my_trail', "http://www.windley.com/foo.html");
    session_push($rid, $session, 'my_trail', "http://www.kynetx.com/foo.html");
    session_push($rid, $session, 'my_trail', "http://www.windley.com/bar.html");


    session_clear($rid, $session, 'my_flag');

    return $session;
}



1;
