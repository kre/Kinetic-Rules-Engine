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

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use Geo::IP;
use Cache::Memcached;
use LWP::Simple;
use LWP::UserAgent;
use JSON::XS;
use APR::Pool ();

use Kynetx::Test qw/:all/;
use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;
use Kynetx::Json qw/:all/;
use Kynetx::Rules qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Util qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Modules qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Persistence qw/:all/;
use Kynetx::Response qw/:all/;
use Kynetx::Rids qw/:all/;


use Kynetx::FakeReq;

use Log::Log4perl::Level;
#use Log::Log4perl::Appender::FileLogger;
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $r = Kynetx::Test::configure();


my $rid = 'cs_test';

# test choose_action and args



my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();


my $my_req_info = Kynetx::Test::gen_req_info($rid);

#diag Dumper $rule_env;

my $session = Kynetx::Test::gen_session($r, $rid);


my $krl_src;
my $js;
my $test_count;
my $config;
my $config2;
my $options;

#diag "_____________________________START TEST____________________________";
sub local_gen_req_info {
  my($rid) = @_;

  return Kynetx::Test::gen_req_info($rid,
				    {'ip' =>  '72.21.203.1',
				     'txn_id' => 'txn_id',
				     'caller' => 'http://www.google.com/search',
				    });
}

my $dummy_final_req_info = undef;
my $final_req_info = {};


#diag Dumper gen_req_info();

# $Amazon_req_info->{'ip'} = '72.21.203.1'w; # Seattle (Amazon)
# $Amazon_req_info->{'rid'} = $rid;
# $Amazon_req_info->{'txn_id'} = 'txn_id';
# $Amazon_req_info->{'caller'} = 'http://www.google.com/search';

my (@test_cases, $json, $krl,$result);

sub doer {
	my ($req_info,$krl,$session,$options) = @_;
	my $logger = get_logger();
	my $rs = Kynetx::Parser::parse_ruleset($krl);
	diag Dumper $rs if $options->{"diag"};

	my $rid_info = mk_rid_info($req_info,$rs->{'ruleset_name'});

	
	$req_info->{'eventtype'} = $options->{"eventtype"} || 'pageview';
	$req_info->{'domain'} =  $options->{"domain"} || 'web';
	
	Kynetx::Rules::stash_ruleset($req_info,
		Kynetx::Rules::optimize_ruleset($rs));
		
	my $ev = Kynetx::Events::mk_event($req_info);
	my $schedule = Kynetx::Scheduler->new();
	
	Kynetx::Events::process_event_for_rid(
		$ev,
		$req_info,
		$session,
		$schedule,
		$rid_info
	);

	my $dd = Kynetx::Response->create_directive_doc($req_info->{'eid'});
	
	my $js = Kynetx::Rules::process_schedule($r,
		$schedule,
		$session,
		time,
		$req_info,
		$dd
	);
	
	#$logger->debug("Final javascript: $js");	

	my $result = $options->{"directives"} ? $dd->directives() : nows($js);
	
	return $result;
}
# test module configuration

my $module_rs;
my $mod_rule_env;
my $empty_rule_env = empty_rule_env();

#goto ENDY;

$krl =  << "_KRL_";
ruleset dueling_notifies {
  meta {
    use module a144x88 alias foo with dflt = "Calling ruleset"
  }
  global {
  }
  rule test0 is active {
    select using ".*" setting()
    {
    	notify("Header","Message");
    	foo:nartify("cHeader","cMessage") with w="mod by Action";
    }  
    
  }
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'dueling_notifies');
$result = doer($my_req_info, $krl, $session);

cmp_deeply($result,re(qr/kGrowl.*Header.,.Message/),"Regular action fired correctly");
$test_count++;

cmp_deeply($result,re(qr/kGrowl.*kGrowl/),"defaction fired");
$test_count++;

cmp_deeply($result,re(qr/Callingruleset/),"meta configure overwrites default");
$test_count++;

cmp_deeply($result,re(qr/modbyAction/),"defaction modifier overwrites default");
$test_count++;

$krl =  << "_KRL_";
ruleset foobar {
  meta {
    use module a144x84 alias foo with c = "STU"
  }
  global {
  }
  rule test0 is active {
    select using ".*" setting()
      pre {
        tc = weather:tomorrow_cond_code();
      city = geoip:city();

    }   
    {
    	notify("Header","Message");
    	foo:x("looby loo") with dave = city and w = tc;
    }  
    
  }
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'foobar');
$result = doer($my_req_info, $krl, $session);

cmp_deeply($result,re(qr/varfarb=.loobyloofiddyfiddyfappap/),"defaction decl expressed correctly");
$test_count++;

$krl =  << "_KRL_";
ruleset postbar {
  meta {
    use module a144x84 alias foo with c = "STU"
  }
  global {
  }
  rule test0 is active {
    select using ".*" setting()
      pre {
        tc = time:now();
    	}   
    	{
    		notify("Header","Message");
    		foo:cpost(tc);
    	}  
    
  	}
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'postbar');
$result = doer($my_req_info, $krl, $session);

cmp_deeply($result,re(qr/varstink=.yes./),"Post action emits no JS");
$test_count++;


$krl =  << "_KRL_";
ruleset inline {
  meta {
    name "defAction"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = "Hello"
   provide x
  
  }
 
  dispatch {
  }
 
  global {
     a = function(x) {5 + x};
     x = defaction (y) {
       configure using w = "FOO" and blue = "fiddyfiddyfappap"
        farb = y + blue;
        every {
         notify(w,blue);
         alert(farb);
        }
     };
  }
  rule test0 is active {
    select using ".*" setting()
      pre {
        tc = time:now();
    	}   
    	{
    		notify("Header","Message");
    		x(tc);
    	}  
    
  	}
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'inline');
$result = doer($my_req_info, $krl, $session);

cmp_deeply($result,re(qr/varfarb=.\d{4}.\d{2}.\d{2}T\d{2}.\d{2}.\d{2}.\d{2}.\d{2}fiddyfiddyfappap/),"inline defaction");
$test_count++;

cmp_deeply($result,re(qr/kGrowl\(msg,config\).+alert\(msg\)/),"inline defaction actions expressed correctly");
$test_count++;

$krl =  << "_KRL_";
ruleset use_nulls {
  meta {
    name "defAction"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = null
   provide x
  
  }
 
  dispatch {
  }
 
  global {
     a = function(x) {5 + x};
     n = defaction (y) {
       configure using w = null
        farb = y + w;
        loob = w.isnull() => "null" | "notnull";
        every {
         notify(loob,farb);
        }
     };
  }
  rule test0 is active {
    select using ".*" setting()
      pre {
        tc = time:now();
    	}   
    	{
    		n(tc);
    	}  
    
  	}
}
_KRL_



$my_req_info->{'rid'} = mk_rid_info($my_req_info,'use_nulls');
$result = doer($my_req_info, $krl, $session);

$krl =  << "_KRL_";
ruleset send_directive_nulls {
  meta {
    name "defAction"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = null
   provide x
  
  }
 
  dispatch {
  }
 
  global {
     n = defaction (y) {
       configure using w = null
        farb = y + w;
        every {
         send_directive("say") 
         	with should_be_null = w and
         	     arg_val = y;
        }
     };
  }
  rule test0 is active {
    select using ".*" setting()
      pre {
        tc = time:now();
    	}   
    	{
    		n(tc);
    	}  
    
  	}
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'send_directive_nulls');
$result = doer($my_req_info, $krl, $session);
cmp_deeply($result,re(qr/varfarb=null/),"Null value passed to send_directive");
$test_count++;


ENDY:
$krl =  << "_KRL_";
ruleset inline {
  meta {
    name "defAction"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = "Hello"
   provide x
  
  }
 
  dispatch {
  }
 
  global {
     a = function(x) {5 + x};
     x = defaction (y) {
       configure using w = "FOO" and blue = "fiddyfiddyfappap"
        farb = y + blue;
        every {
         //notify(w,blue);
         emit <|
         	alert(farb);
         |>;         
        }
     };
  }
  rule test0 is active {
    select using ".*" setting()
      pre {
        tc = time:now();
    	}   
    	{
    		emit <|
    			alert("Regular emit");
    		|>;
    		x(tc);
    	}  
    
  	}
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'inline');
$result = doer($my_req_info, $krl, $session);

cmp_deeply($result,re(qr/.+alert\(.Regularemit.\).+alert\(farb\)/),"emit defaction");
$test_count++;

#diag "####################################################";
### choose 
$krl =  << "_KRL_";
ruleset inline2 {
  meta {
    name "defAction"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = "Hello"
   provide x
  }
 
  global {
     a = function(x) {5 + x};
     x = defaction (y) {
        farb = (y + "blue");
        choose farb {
          brightblue => send_directive("brightblue");
          babyblue => send_directive("babyblue");
        }
     };
  }
  rule test1 is active {
    select when mail received
    {
      x("bright");
    }
  }
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'inline2');
$options = {"eventtype" => "received", 
	    "domain" => "mail",
	    "directives" => 1,
	    "diag" => 0,
	   };
$result = doer($my_req_info, $krl, $session, $options);

is($result->[0]->type(),"brightblue"," choose brightblue in defaction");
$test_count++;



$krl =  << "_KRL_";
ruleset inline2 {
  meta {
    name "defAction"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = "Hello"
   provide x
  }
 
  global {
     a = function(x) {5 + x};
     x = defaction (y) {
        farb = (y + "blue");
        choose farb {
          brightblue => send_directive("brightblue");
          babyblue => send_directive("babyblue");
        }
     };
  }
  rule test1 is active {
    select when mail received
    {
      x("baby");
    }
  }
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'inline2');
$options = {"eventtype" => "received", 
	    "domain" => "mail",
	    "directives" => 1,
	    "diag" => 0,
	   };
$result = doer($my_req_info, $krl, $session, $options);

is($result->[0]->type(),"babyblue"," choose babyblue in defaction");
$test_count++;



$krl =  << "_KRL_";
ruleset inline2 {
  meta {
    name "defAction"
    description <<
      For testing composable actions in modules
      System tests depend on this ruleset.  
    >>
 
   configure using c = "Hello"
   provide x
  }
 
  global {
     a = function(x) {5 + x};
     x = defaction (y) {
        farb = (y + "blue");
        send_directive("babyblue");
     };
  }
  rule test1 is active {
    select when mail received
    pre {
      cvar = "bright";
      dvar = "blue";
    }
    choose cvar + dvar {
          brightblue => send_directive("brightblue");
          babyblue => x("baby");
    }
  }
}
_KRL_

$my_req_info->{'rid'} = mk_rid_info($my_req_info,'inline2');
$options = {"eventtype" => "received", 
	    "domain" => "mail",
	    "directives" => 1,
	    "diag" => 1,
	   };
$result = doer($my_req_info, $krl, $session, $options);

is($result->[0]->type(),"brightblue"," choose brightblue in defaction");
$test_count++;




done_testing($test_count);

session_cleanup($session);

sub mk_reg_exp {
  my $val = shift;

  $val = nows($val);

  # quote special for RE
  $val =~ s/\\/\\\\/g;
  $val =~ s/\+/\\\+/g;
  $val =~ s/\(/\\\(/g;
  $val =~ s/\)/\\\)/g;
  $val =~ s/\[/\\\[/g;
  $val =~ s/\]/\\\]/g;
  $val =~ s/\{/\\\{/g;
  $val =~ s/\}/\\\}/g;
  $val =~ s/\^/\\\^/g;
  $val =~ s/\$/\\\$/g;
  $val =~ s/\|/\\\|/g;

  # now make RE substitutions
  $val =~ s/%uniq%/\\d+/g;

  $val =  $val ;

  return $val;
}

1;


