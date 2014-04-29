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

use Clone qw(clone);

use Kynetx::Environments qw/:all/;
use Kynetx::Memcached qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Persistence qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Modules::PCI qw(:all);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
getkrl
trim
nows
mk_config_string
gen_root_env
platform
gen_user
rword
) ],
vars => [
  qw(
    $root_env
    $username
    $user_ken
    $user_eci
    $dev_ken
    $dev_eci
    $dev_env
    $dev_secret
    $description
    $result
    @results
    $expected
    $args
    $uuid_re
    $platform
  )
]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} },@{$EXPORT_TAGS{'vars'}}) ;


our (
  $root_env,
  $username, 
  $user_ken,
  $user_eci, 
  $dev_ken,
  $dev_eci,
  $dev_env, 
  $dev_secret,
  $description,
  $result,
  @results,
  $expected,
  $args,
  $platform
);

our $uuid_re = "^[A-F|0-9]{8}\-[A-F|0-9]{4}\-[A-F|0-9]{4}\-[A-F|0-9]{4}\-[A-F|0-9]{12}\$";

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
    $req_info->{'eventtype'} = 'hello';
    $req_info->{'domain'} = 'discovery';


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

sub gen_user {
  my ($req_info,$rule_env,$session,$uname) = @_;
  my $js;
  # This system key auto expires
  my $rule_name = "test_gen_user";
  unless (Kynetx::Modules::PCI::pci_authorized($req_info,$rule_env,$session,$rule_name,"foo",[])) {
    my $system_key = Kynetx::Modules::PCI::create_system_key();
    if (Kynetx::Modules::PCI::check_system_key($system_key)){
      my $keys = {'root' => $system_key};
      ($js, $rule_env) = 
       Kynetx::Keys::insert_key(
        $req_info,
        $rule_env,
        'system_credentials',
        $keys);    
    } else {
      return undef;
    }
  }
  my $args = {
    "username" => $uname,
    "firstname" => "Test",
    "lastname" => "Test.pm",
    "password" => "*",
  };
  my $account = Kynetx::Modules::PCI::new_account($req_info,$rule_env,$session,$rule_name,"foo",[$args]);
  my $eci = $account->{'cid'};
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
  if ($ken) {
    return $ken
  }
  return undef;
}

sub flush_test_user {
  my ($ken,$username) = @_;
  Kynetx::MongoDB::flush_user($ken,$username);
  
}

sub gen_root_env {
  my ($req_info, $rule_env,$session) = @_;
  my $rule_name = "test_env";
  my $system_key = Kynetx::Modules::PCI::create_system_key();
  if (Kynetx::Modules::PCI::check_system_key($system_key)) {
    my $keys =  { 'root' => $system_key };
    my ($js,$root_env)=  Kynetx::Keys::insert_key(
      $req_info,
      $rule_env,
      'system_credentials',
      $keys);
    if (Kynetx::Modules::PCI::pci_authorized($req_info,$root_env,$session,$rule_name,"foo",[])) {
      return $root_env;
    } else {
      return undef;
    }
  } else {
    return undef;
  }
  
}

sub gen_dev_env {
  my ($req_info, $rule_env,$session,$eci) = @_;
  my $rule_name = "dev_env";
  my $secret = Kynetx::Modules::PCI::developer_key($req_info,$rule_env,$session,$rule_name,"foo",[$eci]);
  my $dev_cred = {
    'developer_eci' => $eci,
    'developer_secret' => $secret
  };
  my ($js, $dev_env) = 
        Kynetx::Keys::insert_key(
          $req_info,
          $rule_env,
          'system_credentials',
          $dev_cred);
  if (Kynetx::Modules::PCI::developer_authorized($req_info,$dev_env,$session,['cloud', 'auth'])) {
    return ($dev_env,$secret);
  } else {
    return undef;
  }
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

sub platform {
  my $platform = '127.0.0.1';
  $platform = 'qa.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'qa');
  $platform = 'cs.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'production');
  $platform = 'kibdev.kobj.net' if (Kynetx::Configure::get_config('RUN_MODE') eq 'sandbox');
  return $platform;
}

sub rword {
  my $dict_path = "/usr/share/dict/words";
  my @DICTIONARY;
  open DICT, $dict_path;
  @DICTIONARY = <DICT>;
  my $word = $DICTIONARY[rand(@DICTIONARY)];
  chomp($word);
  close DICT;
  return $word;
}

sub add_test_rule {
  my ($req_info,$rule_env,$session,$user_eci,$rid) = @_;
  my $rule_name = "add_test_rule";
  my $function_name = "_null_";
  return Kynetx::Modules::PCI::add_ruleset_to_account($req_info,$rule_env,$session,$rule_name,"foo",[$user_eci,$rid]);
}


sub enchilada {
  my ($rid,$rulename,$rules) = @_;
  my $test_environment;
  
  ### Defaults
  $rid = "test_rid" unless ($rid);
  $rulename = "test_rulename" unless ($rulename);
  
  $test_environment->{'rid'} = $rid;
  $test_environment->{'rulename'} = $rulename;
    
  my $eid = time;
  $test_environment->{'eid'} = $eid;
  
  ### Environments
  my $request_info = gen_req_info($rid);
  my $rule_env = gen_rule_env();
  my $r = configure();
  my $session = gen_session($r,$rid);
  my $anon = Kynetx::Persistence::KEN::get_ken($session,$rid);
  
  $test_environment->{'req_info'} = $request_info;
  $test_environment->{'rule_env'} = $rule_env;
  $test_environment->{'r'} = $r;
  $test_environment->{'session'} = $session;
  $test_environment->{'anonymous_user'} = $anon;
  
  $test_environment->{'platform'} = platform();
  
  ### Users
  my $username = rword();
  my $password = rword();
  
  $test_environment->{'username'} = $username;
  $test_environment->{'password'} = $password;
  
  my $root_env = gen_root_env($request_info,$rule_env,$session);
  my $user_ken = gen_user($request_info,$root_env,$session,$username);
  my $user_eci = Kynetx::Persistence::KToken::get_oldest_token($user_ken);
  
  $test_environment->{'root_env'} = $root_env;
  $test_environment->{'user_ken'} = $user_ken;
  $test_environment->{'user_eci'} = $user_eci;
  
  my $sky_request = make_sky_request_info($request_info,$user_eci,'web','pageview');
  
  $test_environment->{'sky_request_info'} = $sky_request;
  
  if ($rules && ref $rules eq "ARRAY") {    
    my $args = [$user_eci,@{$rules}];
    Kynetx::Modules::PCI::add_ruleset_to_account($request_info,$root_env,$session,$rulename,"foo",$args);    
  }
  
  return $test_environment;
}

sub make_sky_request_info {
  my ($req_info,$id_token,$domain,$eventtype) = @_;
  my $sky_info = clone $req_info;
  $sky_info->{'_api'} = 'sky';
  $sky_info->{'domain'} = $domain || 'web';
  $sky_info->{'eventtype'} = $eventtype || 'submit';
  $sky_info->{'id_token'} = $id_token;
  return $sky_info;
}

sub validate_env {
  my ($test_env) = @_;
  my $num_tests = 0;
  my $req_info = $test_env->{'req_info'};
  my $rule_env = $test_env->{'root_env'};
  my $session = $test_env->{'session'};
  my $rulename = $test_env->{'rulename'};
  
  my ($description,$result,$expected);
  
  $description = "Validate root environment";
  $result = Kynetx::Modules::PCI::pci_authorized($req_info,$rule_env,$session,$rulename,"foo",[]);
  Test::More::is($result,1,$description);
  $num_tests++;
  
  $description = "KEN and ECI match";
  my $ken = $test_env->{'user_ken'};
  my $eci = $test_env->{'user_eci'};
  my $eken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
  Test::More::is($ken,$eken,$description);
  $num_tests++;
}

# twitter query because it returns gloriously complicated json
sub twitter_query_map {
  my ($my_req_info,$rule_env,$session,$twitter_id) = @_;
  $twitter_id = "13524182" unless ($twitter_id); # dave wiegel
  
  my $anontoken = {
	 'access_token' => '100844323-XqQfRm33tQqp54mmhKCfNF9VIOaxVISrIYTOTXOy',
	 'access_token_secret' => 'QdGk4MGc2RiNuD5MHjL5GVk9m1h3SsooGeMWfUQb7f0'
  };
  my $turl = 'https://api.twitter.com/1.1/statuses/user_timeline.json';
  my $num_t = 50;
  
  my $args = ['anon', {
		'url' => $turl,
		'params' => {
			'include_entities' => 'true',
			'include_rts' => 'true',
			'user_id' => $twitter_id,
			'count' => $num_t,
			'trim_user' => 1
		},
		'access_tokens' => $anontoken
	}];
	
	$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,'twitter_test','get',$args);
	my $twit_array = Kynetx::Json::decode_json($result->{'content'});
  my $t_hash;
  my $i = 0;
  foreach my $tweet (@{$twit_array}) {
     $t_hash->{'a' . $i++} = $tweet;
  }
  
  return $t_hash;
}

1;
