package Kynetx::Modules::PCI;
# file: Kynetx/Modules/PCI.pm
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

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Kynetx::Util qw(ll);
use Kynetx::Rids qw/:all/;
use Kynetx::Environments qw/:all/;

use Digest::SHA qw/hmac_sha1 hmac_sha1_hex hmac_sha1_base64
				hmac_sha256 hmac_sha256_hex hmac_sha256_base64/;
use Crypt::RC4::XS;
use Email::MIME;
use Encode;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	get_predicates
	get_resources
	get_actions
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use constant CREDENTIALS => "system_credentials";


my $predicates = {
};

my $default_actions = {
};



sub get_resources {
    return {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}

my $funcs = {};



sub run_function {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
    my $logger = get_logger();
    my $resp = undef;
    $logger->trace("run_function called with $function");
    my $f = $funcs->{$function};
    if (defined $f) {
    	eval {
    		$resp = $f->( $req_info,$rule_env,$session,$rule_name,$function,$args );
    	};
    	if ($@) {
    		$logger->warn("PCI error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module PCI");
    }

    return $resp;
}

############################# Accounts


sub new_account {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
	if (system_authorized($req_info, $rule_env, $session)) {
		my $pken = Kynetx::Persistence::KEN::get_ken($session,'');
		my $oid = MongoDB::OID->new();
	    my $new_id = $oid->to_string();
	    my $username = "_$new_id";
	    my $created = DateTime->now->epoch;
	    my $dflt = {
	        "username" => $username,
	        "_id" => $oid,
	        "firstname" => "",
	        "lastname" => "",
	        "password" => "*",
	        "created" => $created
	    };
	    my ($parent,$options,$userid);
	    my $type = 'PCI';
	    if (defined $args->[0] && ref $args->[0] eq "") {
	    	my $eci = $args->[0];
	    	my $valid = Kynetx::Persistence::KToken::is_valid_token($eci);
	    	if (defined $valid and ref $valid eq "HASH") {
	    	$logger->trace("Valid: ", sub {Dumper($valid)});
	    		$parent = $valid->{"ken"};
	    	}
	    	if ($args->[1] && ref $args->[1] eq "HASH") {
	    		$options = $args->[1];
	    	}
	    } elsif (defined $args->[0] && ref $args->[0] eq "HASH") {
	    	$options = $args->[0];
	    	$parent = undef;
	    } else {
	    	$logger->debug("Invalid parameters for new_account");
	    	return undef;
	    }
	    foreach my $key (keys %{$options}) {
	    	next if ($key eq "_id");
	    	if ($key eq "password") {
	    		my $pass = $options->{$key};
	    		if ($pass eq "") {
	    			$dflt->{$key} = "*";
	    		} else {
	    			$dflt->{$key} = _hash_password($pass);
	    		}
	    		
	    	} else {
	    		$dflt->{$key} = $options->{$key};
	    	}
	    	
	    }
	    if (defined $parent) {
	    	$logger->trace("Parent: ", sub {Dumper($parent)});
	    	$dflt->{'parent'} = $parent;
	    	Kynetx::Persistence::KPDS::link_dependent_cloud($parent,$new_id);
	    } else {
	    	$userid = Kynetx::MongoDB::counter("userid");
	    	$dflt->{"user_id"} = $userid;
	    	$logger->trace("user id: ", sub {Dumper($userid)});
	    }
	    my $ken = Kynetx::Persistence::KEN::new_ken($dflt);
	    my $neci =  Kynetx::Persistence::KToken::create_token($ken,"_LOGIN",$type);
	    my $struc = {
	    	"nid" => $userid,
	    	"cid" => $neci
	    };
	    return $struc;
	} else {
		$logger->debug("Not authorized to create account");
	}
	return undef;
}
$funcs->{'new_cloud'} = \&_new_cloud;



sub delete_account {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
	if (system_authorized($req_info, $rule_env, $session)) {
		my $eci = $args->[0];
    	my $valid = Kynetx::Persistence::KToken::is_valid_token($eci);
    	if (defined $valid and ref $valid eq "HASH") {
    		$logger->trace("Valid: ", sub {Dumper($valid)});
    		my $cascade;
    		my $ken = $valid->{'ken'};
    		# Check to see if any dependent clouds should be deleted
    		if (defined $args->[1] && ref $args->[1] eq "HASH") {
    			$cascade =  $args->[1]->{"cascade"};
    		}
    		Kynetx::Persistence::KPDS::delete_cloud($ken,$cascade);
    	} else {
    		$logger->debug("ECI: $eci not valid ", sub {Dumper($valid)});
    	}
	} else {
		$logger->debug("Not authorized to delete account");
	}
}
$funcs->{'delete_cloud'} = \&delete_account;

sub account_authorized {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	return 0 unless (developer_authorized($req_info,$rule_env,$session,['cloud','auth']));
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my ($ken,$password);
	# With 2 arguments, first arg must be a token
	if (defined $arg2) {
		$password = $arg2;
		if (ref $arg1 eq "") {
			# Default arguments are <username>,<password>
			my $username = $arg1;
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_username($username);
		} elsif (ref $arg1 eq "HASH") {
			if ($arg1->{'username'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_username($arg1->{'username'});
			} elsif ($arg1->{'user_id'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1->{'user_id'});
			} elsif ($arg1->{'eci'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1->{'eci'});
			}
		}
		
	} else {
		$password = $arg1;
		my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
		$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);				 
	}	
	$logger->warn("Unable to locate KEN: ",sub {Dumper($arg1)}) unless ($ken);
	$logger->trace(" Ken: $ken");
	$logger->trace("Pass: $password");
	return _auth_ken($ken,$password);
}
$funcs->{'auth'} = \&account_authorized;

############################# Rulesets

sub add_ruleset_to_account {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	return 0 unless (developer_authorized($req_info,$rule_env,$session,['ruleset','create']));
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my @ridlist = ();
	my $ken;
	if (defined $arg2) {
		if (ref $arg2 eq "ARRAY") {
			@ridlist = @{$arg2};
		} elsif (ref $arg2 eq "") {
			push(@ridlist,$arg2);
		}
	}	
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
		#ll("userid");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
		#ll("eci");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}
	if ($ken && length(@ridlist) >= 1) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');
		my $installed = Kynetx::Persistence::KPDS::add_ruleset($ken,\@ridlist);
		return {
			'nid' => $userid,
			'rids' => $installed->{'value'}
		}
	}
	return undef;
	
}
$funcs->{'new_ruleset'} = \&add_ruleset_to_account;

sub remove_ruleset_from_account {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	return 0 unless (developer_authorized($req_info,$rule_env,$session,['ruleset','destroy']));
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my @ridlist = ();
	my $ken;
	if (defined $arg2) {
		if (ref $arg2 eq "ARRAY") {
			@ridlist = @{$arg2};
		} elsif (ref $arg2 eq "") {
			push(@ridlist,$arg2);
		}
	}	
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
		#ll("userid");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
		#ll("eci");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}
	if ($ken && length(@ridlist) >= 1) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');
		my $installed = Kynetx::Persistence::KPDS::remove_ruleset($ken,\@ridlist);
		return {
			'nid' => $userid,
			'rids' => $installed->{'value'}
		}
	}
	return undef;
	
}
$funcs->{'delete_ruleset'} = \&remove_ruleset_from_account;

sub _installed_rulesets {
	my ($sken,$rid,$args) = @_;
	my $logger = get_logger();
	my $ken;
	if (defined $args->[0]) {
		# eci
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($args->[0]);
	} else {
		# current user
		$ken = $sken;
	}
	if ($ken) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');
		my $installed = Kynetx::Persistence::KPDS::get_rulesets($ken);
		return {
			'nid' => $userid,
			'rids' => $installed
		};	
	} else {
		$logger->debug("No entity found");
		return undef;
	}
	
}


sub installed_rulesets {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	return 0 unless (developer_authorized($req_info,$rule_env,$session,['ruleset','show']));
    my $rid = get_rid($req_info->{'rid'});		
	my $sken = Kynetx::Persistence::KEN::get_ken($session,$rid);	
	return _installed_rulesets($sken,$rid,$args);
}
$funcs->{'list_ruleset'} = \&installed_rulesets;
$funcs->{'list_rulesets'} = \&installed_rulesets;

############################# ECI
sub new_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	return 0 unless (developer_authorized($req_info,$rule_env,$session,['eci','create']));
	my $ken;
	my ($token_name,$type);
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	if (! defined $arg1) {
		my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
		$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	} else {
		# Check to see if it is an eci or a userid
		if ($arg1 =~ m/^\d+$/) {
			#ll("userid");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
		} else {
			#ll("eci");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
		}			
		
		if (defined $arg2 && ref $arg2 eq "HASH") {
				$token_name = $arg2->{'name'};
				$type = $arg2->{'eci_type'};
		} 
	}
	$token_name |= "Generic ECI channel";
	$type |= 'PCI';
	if ($ken) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');	
		my $eci =  Kynetx::Persistence::KToken::create_token($ken,$token_name,$type);	
		return {
			"nid" => $userid,
			"name" => $token_name,
			"cid" => $eci
		}
	}
	return undef;
}
$funcs->{'new_eci'} = \&new_eci;


sub destroy_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	return 0 unless (developer_authorized($req_info,$rule_env,$session,['eci','destroy']));
	my $ken;
	my $arg1 = $args->[0];
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	if ($ken) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');	
		Kynetx::Persistence::KToken::delete_token($arg1);	
		return {
			"nid" => $userid,
			"cid" => $arg1
		}
	}
	return undef;
}
$funcs->{'delete_eci'} = \&destroy_eci;


sub list_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	return 0 unless (developer_authorized($req_info,$rule_env,$session,['eci','show']));
	my $ken;
	my $arg1 = $args->[0];
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	if ($ken) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');	
		my $channels = Kynetx::Persistence::KToken::list_tokens($ken);
		#ll("List: ", sub {Dumper($channels)});	
		return {
			"nid" => $userid,
			"channels" => $channels
		}
	}
	return undef;
}
$funcs->{'list_eci'} = \&list_eci;

############################# Security/Authorizations

sub _dev_permissions {
	my ($ken,$devkey,$permkey,$value) = @_;
	my $is_dev = Kynetx::Persistence::KPDS::get_developer_permissions($ken,$devkey,[]);
	return unless (defined $is_dev);
	if (defined $value) {
		$value = $value ? 1 : 0;
		Kynetx::Persistence::KPDS::set_developer_permissions($ken,$devkey,$permkey,$value);
	} 
	return Kynetx::Persistence::KPDS::get_developer_permissions($ken,$devkey,$permkey);
}

sub set_permissions {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	return unless (system_authorized($req_info, $rule_env, $session));
	my $logger = get_logger();
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my $ken;
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
		#ll("userid");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
		#ll("eci");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}
	my $dev_key = $arg2;
	my $ppath = $args->[2];
	if (defined $ppath && ref $ppath eq "ARRAY") {
		return _dev_permissions($ken,$dev_key,$ppath,1);
	} 
	return undef	
	
}
$funcs->{'set_permissions'} = \&set_permissions;

sub clear_permissions {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	return unless (system_authorized($req_info, $rule_env, $session));
	my $logger = get_logger();
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my $ken;
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
		#ll("userid");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
		#ll("eci");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}
	my $dev_key = $arg2;
	my $ppath = $args->[2];
	if (defined $ppath && ref $ppath eq "ARRAY") {
		$logger->trace("Clear perm");
		return _dev_permissions($ken,$dev_key,$ppath,0);
	} 
	return undef	
	
}
$funcs->{'clear_permissions'} = \&clear_permissions;

sub get_permissions {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my $ken;
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
		#ll("userid");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
		#ll("eci");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}
	my $dev_key = $arg2;
	my $ppath = $args->[2];
	if (defined $ppath && ref $ppath eq "ARRAY") {
		return _dev_permissions($ken,$dev_key,$ppath);
	} 
	return 0	
	
}
$funcs->{'get_permissions'} = \&get_permissions;

sub developer_key {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $ken;
	my $token = $args->[0];
	if (defined $token ) {
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($token);
	} else {
		my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
		$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	}
	$logger->trace("Create developer key for $ken");
	return undef unless ($ken);
	my $syskey = syskey();
	if (system_authorized($req_info, $rule_env, $session)) {		
		my $t = time();
		my $r = int(rand($t));
		my $nonce = "$t" ^ "$r"; 
		my $data = $ken . $nonce;
		my $digest = hmac_sha256_base64($data,$syskey);
		_default_permissions($ken,$digest);
		return $digest;
	} else {
		$logger->warn("Account not authorized for developer keys");
	}
	return undef;
}
$funcs->{'create_developer_key'} = \&developer_key;



sub _default_permissions {
	my ($ken,$devkey,$istest) = @_;
	my $logger = get_logger();
	my $p = Kynetx::Configure::get_config('permissions');
	if (defined $p && defined $p->{'developer'}) {
		foreach my $developer_cloud_context (keys %{$p->{'developer'}}) {
			my $context = $p->{'developer'}->{$developer_cloud_context};
			foreach my $permission (keys %{$context}) {
				my $val = $context->{$permission};
				# dont let test permissions affect production
				if (defined $istest) {
					$val *= -1;
				}
				my $keypath = [$developer_cloud_context, $permission];
				Kynetx::Persistence::KPDS::set_developer_permissions($ken,$devkey,$keypath,$val);
			}
		}
	}
}

sub _hash_password {
	my ($string) = @_;
	my $soid = Kynetx::Configure::get_config('PCI_PASSWORD');
	my $salt = get_pass_phrase($soid);
	my $digest = hmac_sha256_base64($string,$salt);
	return $digest;	
}


sub _auth_ken {
	my ($ken,$string) = @_;
	my $hashed = Kynetx::Persistence::KEN::get_authorizing_password($ken);
	my $passed = _hash_password($string);
	if ($hashed eq $passed) {
		return 1;
	}
	return 0;
	
}

sub create_system_key {
	my $syskey = syskey();
	my $id = make_pass_phrase();
	my $phrase = get_pass_phrase($id);
	my $data = $id . '||' . $phrase;
	my $encrypted = RC4($syskey,$data);
	$encrypted = unpack('H*', $encrypted);
	return MIME::Base64::encode_base64url($encrypted);
	
}

sub check_system_key {
	my ($key) = @_;
	my $logger = get_logger();
	$logger->trace("Key in: " ,$key);
	my $syskey = syskey();
	my $de64 = MIME::Base64::decode_base64url($key);
	my $packed = pack('H*', $de64);
	my $decoded = RC4($syskey,$packed);
	$logger->trace("Decoded: " ,$decoded);
	my ($id,$phrase) = split(/\|\|/,$decoded);
	my $test = get_pass_phrase($id);
	$logger->trace("Pass phrase: " ,$test);
	if (defined $test && $test eq $phrase) {
		return 1;
	} else {
		return 0;
	}
}

sub system_authorized {
	my ($req_info, $rule_env, $session) = @_;	
	my $logger = get_logger();
	my $keys = Kynetx::Keys::get_key($req_info,$rule_env,CREDENTIALS);
	if (defined $keys and ref $keys eq "HASH") {
		my $super_key = $keys->{'root'};
		return check_system_key($super_key);
		
	} else {
		return 0;
	}
}

sub developer_authorized {
	my ($req_info, $rule_env, $session, $permission_path) = @_;
	my $logger = get_logger();
	my $keys = Kynetx::Keys::get_key($req_info,$rule_env,CREDENTIALS);
	if (defined $keys and ref $keys eq "HASH") {
		my $token = $keys->{'developer_eci'};
		my $cred = $keys->{'developer_secret'};
		my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($token);
		my $permission = Kynetx::Persistence::KPDS::get_developer_permissions($ken,$cred,$permission_path);	
		$logger->trace("Permission for $token: ", sub {Dumper($permission)});
		return $permission;
	} else {
		return 0;
	}
		
}

sub syskey {
	my ($istest) = @_;
	my $logger = get_logger();
	my $salt = Kynetx::Configure::get_config('PCI_KEY');
	my $phrase = get_pass_phrase();
	my $syskey = unpack ('H*', "$salt" ^ "$phrase");
	$logger->trace("Actual: $syskey");
	$syskey = hmac_sha256_base64($syskey,$salt);
	$logger->trace("Test: $syskey");
	return $syskey;
}




sub get_pass_phrase {
	my ($did) = @_;
	my $logger = get_logger();
	my $collection = 'dictionary';
	if (! defined $did) {
		$did = Kynetx::Configure::get_config('PCI_PHRASE');
	}
	my $mongoid = MongoDB::OID->new("value" => $did);
	my $mongo_key = {
		"_id" => $mongoid
	};
	$logger->trace("Dictionary id: ", sub {Dumper($mongo_key)});
	my $result = Kynetx::MongoDB::get_value($collection,$mongo_key);
	$logger->trace("Dictionary entry: ", sub {Dumper($result)});
	if (defined $result) {
		return $result->{'passphrase'};
	}
	return undef;
}

sub make_pass_phrase {
	my $word1 = Kynetx::Modules::Random::rword();
	my $word2 = Kynetx::Modules::Random::rword();
	my $oid = MongoDB::OID->new();
	my $phrase = Encode::encode("latin1", $word1 . $word2);
	my $key = {
		"_id" => $oid
	};
	my $value = {'passphrase' => $phrase};
	my $result = Kynetx::MongoDB::update_value('dictionary', $key,$value,1,0,1);
	if (defined $result && ref $result eq "HASH") {
		my $id = $result->{'upserted'};
		return $id->to_string()
	}
	return undef;
}

1;
