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
use Kynetx::Dispatch; #qw/clear_rid_list_by_ken/;
use Kynetx::Environments qw/add_to_env/;
use Kynetx::Modules::Random;
use Kynetx::Persistence::DevLog;
use Digest::SHA qw/hmac_sha1 hmac_sha1_hex hmac_sha1_base64
				hmac_sha256 hmac_sha256_hex hmac_sha256_base64/;
use Crypt::RC4::XS;
use Email::MIME;
use MIME::Base64 ();
use Encode;
use Kynetx::Keys qw/:all/;
#use Kynetx::Persistence::DevLog qw/:all/;

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
	auth_ken
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use constant CREDENTIALS => "system_credentials";
use constant EXPIRES_IN => "ttl1";


# format of list_tokens is array of {'cid' => val, 'name' => val}
my $predicates = {
  'is_related' => sub {
    my ($req_info, $rule_env, $args) = @_;
    my $logger = get_logger();
    my $source = $args->[0];
    my $collection = $args->[1];
    my @group = ();
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($source);
    my $ken_tokens = Kynetx::Persistence::KToken::list_tokens($ken);
    my %hash; map {$hash{$_->{'cid'}}++}  @{$ken_tokens};
    my @ktokens = keys %hash;
    if (ref $collection eq "ARRAY") {
      @group = @{$collection};
    } elsif (defined $collection && ref $collection eq "") {
      push(@group, $collection);
    }
    my $set = Kynetx::Sets::intersection(\@ktokens,\@group);
    if (scalar @{$set} >= 1) {
      return 1
    } else {
      return 0;
    }
  }
};


sub get_resources {
    return {};
}


my $actions = { 
	'register_app' => {
		'js' =>'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&register_app,
		'after'  => []
	},
	'delete_app' => {
		'js' =>'NO_JS',    # this action does not emit JS, used in build_one_action
		'before' => \&delete_oauth_app,
		'after'  => []
	},
};


sub get_actions {
    return $actions;
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
    my $keys = _key_filter($args);
    if (pci_authorized($req_info, $rule_env, $session, $keys)) {
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
	my $name = '_LOGIN';
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
	    } elsif ($key eq "cloudnumber") {
		$dflt->{"username"} = $options->{$key};
	    } else {
		$dflt->{$key} = $options->{$key};
	    }
	    	
	}
	# Check that the final username is unique
	my $found = Kynetx::Persistence::KEN::ken_lookup_by_username($dflt->{'username'});
	if ($found) {
	    $logger->warn($dflt->{'username'}, " is already in use");
	    return undef;
	}
	if (defined $parent) {
	    $logger->trace("Parent: ", sub {Dumper($parent)});
	    $dflt->{'parent'} = $parent;
	    Kynetx::Persistence::KPDS::link_dependent_cloud($parent,$new_id);
	    $name = $options->{'label'} || '_CHILD';
	} else {
	    $userid = Kynetx::MongoDB::counter("userid");
	    $dflt->{"user_id"} = $userid;
	    $logger->trace("user id: ", sub {Dumper($userid)});
	}
	my $ken = Kynetx::Persistence::KEN::new_ken($dflt);
	my $neci =  Kynetx::Persistence::KToken::create_token($ken,$name,$type);
	my $struc = {
		     "nid" => $userid,
		     "cid" => $neci,
		     "eci" => $neci
		    };
	return $struc;
    } else {
	$logger->debug("Not authorized to create account");
    }
    return undef;
}
$funcs->{'new_cloud'} = \&new_account;
$funcs->{'new_pico'} = \&new_account;



sub delete_account {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
	my $keys = _key_filter($args);
	if (pci_authorized($req_info, $rule_env, $session, $keys)) {
	    my $eci = $args->[0];
	    my $valid = Kynetx::Persistence::KToken::is_valid_token($eci);
	    if (defined $valid and ref $valid eq "HASH") {
    		$logger->trace("Valid: ", sub {Dumper($valid)});
    		my $cascade = 0;
    		my $ken = $valid->{'ken'};
    		# Check to see if any dependent clouds should be deleted
    		if (defined $args->[1] && ref $args->[1] eq "HASH") {
    			$cascade =  $args->[1]->{"cascade"};
			if (JSON::XS::is_bool $cascade) {
			  $cascade = $cascade ? 1 : 0;
			}

    		}
    		Kynetx::Persistence::KPDS::delete_cloud($ken,$cascade);
    		return 1;
	    } else {
    		$logger->debug("ECI: $eci not valid ", sub {Dumper($valid)});
		return 0;
	    }
	} else {
	    $logger->debug("Not authorized to delete account");
	    return 0;
	}
}
$funcs->{'delete_cloud'} = \&delete_account;
$funcs->{'delete_pico'} = \&delete_account;

sub account_authorized {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless (
	 pci_authorized($req_info, $rule_env, $session, $keys) ||
	 developer_authorized($req_info,$rule_env,$session,['cloud','auth']));
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my ($ken,$password);
	# With 2 arguments, first arg must be a token
	if (defined $arg2) {
		$password = $arg2;
		if (ref $arg1 eq "") {
			# Default arguments are <username>,<password>
			my $username = $arg1;
#			$logger->debug("Username: ", $username);
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
#	$logger->debug(" Ken: $ken");
#	$logger->debug("Pass: $password");
	my $result = auth_ken($ken,$password);
	if ($result) {
	  if (pci_authorized($req_info, $rule_env, $session, $keys)) {
	    $logger->debug("System auth'd return user_id");
	    my $nid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');
	    return {
	      'nid' => $nid
	    };
	  } else {
	    return 1;
	  }
	} else {
	  return 0
	}
}
$funcs->{'auth'} = \&account_authorized;

sub set_account_password {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys) ||
	 developer_authorized($req_info,$rule_env,$session,['cloud','auth']));
	my ($ken,$new_password,$old_password);
  if (scalar @{$args} ==2) {
    # use the current session
    my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
    $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    $new_password = $args->[1];
    $old_password = $args->[0];
  } elsif (scalar @{$args}==3) {
    my $uid = $args->[0];
		if (ref $uid eq "") {
			# Default arguments are <username>,<password>
			my $username = $uid;
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_username($username);
		} elsif (ref $uid eq "HASH") {
			if ($uid->{'username'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_username($uid->{'username'});
			} elsif ($uid->{'user_id'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($uid->{'user_id'});
			} elsif ($uid->{'eci'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($uid->{'eci'});
			}
		}
    $new_password = $args->[2];
    $old_password = $args->[1];
  } else {
    $logger->warn("Set Password args invalid: ", sub {join(",",@{$args})});
    return undef;
  }
  my $p_match = auth_ken($ken,$old_password);
  if ($p_match) {
    set_password($ken, $new_password);
    # my $hash = _hash_password($new_password);
    # return Kynetx::Persistence::KEN::set_authorizing_password($ken,$hash);
  } else {
    $logger->debug("Failed to authenticate");
    return 0;
  }
  
}
$funcs->{'set_password'} = \&set_account_password;

sub reset_account_password {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys));
	my ($ken,$new_password);
  if (scalar @{$args} ==1) {
    # use the current session
    my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
    $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    $new_password = $args->[0];
  } elsif (scalar @{$args}==2) {
    my $uid = $args->[0];
		if (ref $uid eq "") {
			# Default arguments are <username>,<password>
			my $username = $uid;
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_username($username);
		} elsif (ref $uid eq "HASH") {
			if ($uid->{'username'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_username($uid->{'username'});
			} elsif ($uid->{'user_id'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($uid->{'user_id'});
			} elsif ($uid->{'eci'}) {
				$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($uid->{'eci'});
			}
		}
    $new_password = $args->[1];
  } else {
    $logger->warn("Reset Password args invalid: ", sub {join(",",@{$args})});
    return undef;
  }
  return set_password($ken,$new_password);
  
  
}
$funcs->{'reset_password'} = \&reset_account_password;

sub set_password {
  my ($ken,$new_password) = @_;
  my $hash = _hash_password($new_password);
  return Kynetx::Persistence::KEN::set_authorizing_password($ken,$hash);
}

sub check_username {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	$logger->debug("pre Args: ", sub {Dumper($args)});
	my $keys = _key_filter($args);
	$logger->debug("Keys: ", sub {Dumper($keys)});
	$logger->debug("Args: ", sub {Dumper($args)});
	return 0 unless ( pci_authorized($req_info, $rule_env, $session,$keys));
  my $uid = $args->[0];
  $logger->debug("Check for username ($uid)");
  if (defined $uid) {
    my $ken = _username($uid);
    if ($ken) {
      return 1;
    }
  }
  return 0;
}
$funcs->{'exists'} = \&check_username;

sub _username {
  my ($uid) = @_;
  my $ken;
  if (defined $uid) {
    $ken = Kynetx::Persistence::KEN::ken_lookup_by_username($uid);    
  }
  return $ken;
}

sub list_children {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys));
    my $ken;
    my $uid = $args->[0];
    if (defined $uid) {
	if (ref $uid eq "HASH") {
	    if ($uid->{'username'}) {
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_username($uid->{'username'});
	    } elsif ($uid->{'user_id'}) {
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($uid->{'user_id'});
	    } elsif ($uid->{'eci'}) {
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($uid->{'eci'});
	    }      
	} else {
	    if ($uid =~ m/^\d+$/) {
		#ll("userid");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($uid);
	    } else {
		#ll("eci");
		$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($uid);
	    }      
	}
    } else {
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
    }

    #$logger->debug("Ken in list_children ", sub{Dumper $ken});
  
    if ($ken) {
	my $blob = ();
	my $key = ['dependents'];
	my $children = Kynetx::Persistence::KPDS::get_kpds_element($ken,['dependents']);
	if (defined $children && ref $children eq "ARRAY") {
#	    $logger->debug("Children from KPDS elements ", sub{Dumper $children});
	    foreach my $child (@{$children}) {
		my $username = Kynetx::Persistence::KEN::get_ken_value($child,'username');
		my $token = Kynetx::Persistence::KToken::get_default_token($child);
		$token = Kynetx::Persistence::KToken::get_oldest_token($child) unless ($token);
		my $label = Kynetx::Persistence::KToken::token_query({'ktoken' => $token})->{'token_name'};
		my $tmp = [$token,$username,$label];
		push(@{$blob},$tmp);
	    }
	    return $blob;
	}
	return $children;
    }
  
  return undef;
}
$funcs->{'list_children'} = \&list_children;

sub list_parent {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys));
    my $uid = $args->[0];
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($uid);
    my $parent = Kynetx::Persistence::KEN::get_ken_value($ken,'parent');
    if (defined $parent){
	my $token = Kynetx::Persistence::KToken::get_default_token($parent);
	$token = Kynetx::Persistence::KToken::get_oldest_token($parent) unless ($token);
	my $username = Kynetx::Persistence::KEN::get_ken_value($parent,'username');
	my $label = Kynetx::Persistence::KToken::token_query({'ktoken' => $token})->{'token_name'};
	my $tmp = [$token,$username,$label];
	return $tmp;
    }
    return undef;
  
}
$funcs->{'list_parent'} = \&list_parent;

sub get_account_username {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys) ||
	 developer_authorized($req_info,$rule_env,$session,['cloud','auth']));
	my $ken;
	my $arg0 = $args->[0];
  if (! defined $arg0) {
		my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
		$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	} else {
		# Check to see if it is an eci or a userid
		if ($arg0 =~ m/^\d+$/) {
			ll("userid $arg0");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg0);
		} else {
			ll("eci $arg0");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg0);
		}					
	}
	if (defined $ken) {
	  return Kynetx::Persistence::KEN::get_ken_value($ken,'username');
	}
	return undef;
}
$funcs->{'get_username'} = \&get_account_username;
$funcs->{'cloudnumber'} = \&get_account_username;

sub get_account_email {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys));
	my $ken;
	my $arg0 = $args->[0];
  if (! defined $arg0) {
		my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
		$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	} else {
		# Check to see if it is an eci or a userid
		if ($arg0 =~ m/^\d+$/) {
			ll("userid $arg0");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg0);
		} else {
			ll("eci $arg0");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg0);
		}					
	}
	if (defined $ken) {
	  return Kynetx::Persistence::KEN::get_ken_value($ken,'email');
	}
	return undef;
}
$funcs->{'get_email'} = \&get_account_email;

sub get_account_profile {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys));
    my $ken;
    my $arg0 = $args->[0];
    if (! defined $arg0) {
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
    } else {
	# Check to see if it is an eci or a userid
	if ($arg0 =~ m/^\d+$/) {
	    ll("userid $arg0");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg0);
	} else {
	    ll("eci $arg0");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg0);
	}					
    }
    if (defined $ken) {
	my $prfl = {"username" => Kynetx::Persistence::KEN::get_ken_value($ken,'username'),
		   "email" => Kynetx::Persistence::KEN::get_ken_value($ken,'email'),
		   "firstname" => Kynetx::Persistence::KEN::get_ken_value($ken,'firstname'),
		   "lastname" => Kynetx::Persistence::KEN::get_ken_value($ken,'lastname'),
		  };
	return $prfl
    }
    return undef;
}
$funcs->{'get_profile'} = \&get_account_profile;

sub set_parent {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless ( pci_authorized($req_info, $rule_env, $session, $keys));
	my $eci = $args->[0];
	my $new_owner_eci = $args->[1];
	$logger->debug("T eci: $eci");
	$logger->debug("D eci: $new_owner_eci");	
	if ($eci && $new_owner_eci) {
	  my $target_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
  	my $new_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($new_owner_eci);
  	my $parent = Kynetx::Persistence::KEN::get_ken_value($target_ken,'parent');
  	$logger->debug("T ken: $target_ken");
  	$logger->debug("D ken: $new_ken");	
  	$logger->debug("Parent ken: $parent");	
  	if ($target_ken && $new_ken) {
    	if ($parent eq $new_ken) {
    	  return $new_owner_eci;
    	} else {
    	  Kynetx::Persistence::KPDS::link_dependent_cloud($new_ken,$target_ken);
    	  if ($parent) {
    	    Kynetx::Persistence::KPDS::unlink_dependent_cloud($parent,$target_ken);
    	  }    	  
    	  return Kynetx::Persistence::KToken::get_default_token($new_ken);
    	}  	  
  	} else {
  	  $logger->debug("No aaccount associated with ECI");
  	  return undef;
  	}
	  
	} else {
	  $logger->debug("set_parent requires two ecis");
	  return undef;
	}
  
}
$funcs->{'set_parent'} = \&set_parent;

############################# Rulesets

sub add_ruleset_to_account {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
	   developer_authorized($req_info,$rule_env,$session,['ruleset','create']));
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my @ridlist = ();
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
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
	if ($ken && scalar @{$args} >= 1) {
	  
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');
		my $installed = Kynetx::Persistence::KPDS::add_ruleset($ken,\@ridlist);
		Kynetx::Dispatch::clear_rid_list_by_ken($ken);
				
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
	my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
			 developer_authorized($req_info,$rule_env,$session,['ruleset','destroy']));
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	my @ridlist = ();
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
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
	if ($ken && scalar @{$args} >= 1) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');
		my $installed = Kynetx::Persistence::KPDS::remove_ruleset($ken,\@ridlist);
		Kynetx::Dispatch::clear_rid_list_by_ken($ken);
		foreach my $orid (@ridlist) {
		  Kynetx::Persistence::SchedEv::delete_entity_sched_ev($ken,$orid)
		}
		return {
			'nid' => $userid,
			'rids' => $installed->{'value'}
		}
	}
	return undef;
	
}
$funcs->{'delete_ruleset'} = \&remove_ruleset_from_account;

sub _installed_rulesets {
	my ($ken) = @_;
	my $logger = get_logger();
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
	my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
			 developer_authorized($req_info,$rule_env,$session,['ruleset','show']));
	my $rid = get_rid($req_info->{'rid'});		
#	$logger->debug("Session and RID: ", sub{Dumper $session}, sub{Dumper $rid});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);;
	my $arg1 = $args->[0];
#	$logger->debug("KEN and ECI: ", $ken, $arg1);
	if (defined $arg1) {
		if ($arg1 =~ m/^\d+$/) {
			#ll("userid");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
		} else {
			#ll("eci");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
		}		
	}	
	return _installed_rulesets($ken);
}
$funcs->{'list_ruleset'} = \&installed_rulesets;
$funcs->{'list_rulesets'} = \&installed_rulesets;

############################# Logging

sub logging_eci {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger = get_logger();
    my $keys = _key_filter($args);
    my $auth = pci_authorized($req_info, $rule_env, $session, $keys);
    $logger->debug("Logging eci auth: $auth");
    return 0 unless ($auth);
    my $ken;
    my ($token_name,$type);
    my $arg1 = $args->[0];
    $logger->debug("Use: $arg1");
    if (! defined $arg1) {
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
    } else {
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
	    ll("userid $arg1");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
	    ll("eci $arg1");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}					
    }
    $logger->debug("Found KEN: $ken");
    if ($ken) {
	return Kynetx::Persistence::DevLog::create_logging_eci($ken);
    }
    return undef;
}
$funcs->{'set_logging'} = \&logging_eci;

sub clear_logging {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
    my $ken;
    my ($token_name,$type);
    my $arg1 = $args->[0];
    if (! defined $arg1) {
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
    } else {
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
	    ll("userid $arg1");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
	    ll("eci $arg1");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}					
    }
    if ($ken) {
	return Kynetx::Persistence::DevLog::clear_logging_eci($ken);
    }
    return undef;
	
}
$funcs->{'clear_logging'} = \&clear_logging;


sub get_logging {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
    my $ken;
    my ($token_name,$type);
    my $arg1 = $args->[0];
    if (! defined $arg1) {
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
    } else {
	# Check to see if it is an eci or a userid
	if ($arg1 =~ m/^\d+$/) {
	    ll("userid $arg1");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
	} else {
	    ll("eci $arg1");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
	}					
    }
    #ll("Ken: ", $ken);
    if ($ken) {
	my $status = Kynetx::Persistence::DevLog::has_logging($ken);
	# ll("Status: ", $status );
	return $status;
    }
    return undef;
	
}
$funcs->{'logging_enabled'} = \&get_logging;

sub get_log_messages {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
		     developer_authorized($req_info,$rule_env,$session,['ruleset','log'])  );
    my $ken;
    my ($token_name,$type);
    my $arg1 = $args->[0];
    $logger->debug("logging eci: $arg1");
    #	my $list = Kynetx::Persistence::DevLog::get_active($arg1);
    my $list = Kynetx::Persistence::DevLog::get_all_msg($arg1);
    if (defined $list) {
	return $list;  
    }
    return undef;	
}
$funcs->{'get_logs'} = \&get_log_messages;

sub flush_log_messages {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
		     developer_authorized($req_info,$rule_env,$session,['ruleset','log'])  );
    my $ken;
    my ($token_name,$type);
    my $arg1 = $args->[0];
    #$logger->debug("log eci: $arg1");
    #	my $list = Kynetx::Persistence::DevLog::get_active($arg1);
    my $list = Kynetx::Persistence::DevLog::flush($arg1);
    if (defined $list) {
	return $list;  
    }
    return undef;	
}
$funcs->{'flush_logs'} = \&flush_log_messages;




############################# ECI
sub new_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger = get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
	                 developer_authorized($req_info,$rule_env,$session,['eci','create']));
	my $ken;
	my ($token_name,$type,$attributes,$policy);
	my $arg1 = $args->[0];
	my $arg2 = $args->[1];
	if (! defined $arg1) {
		my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
		$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	} else {
		# Check to see if it is an eci or a userid
		if ($arg1 =~ m/^\d+$/) {
			ll("userid $arg1");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($arg1);
		} else {
			ll("eci $arg1");
			$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
		}			
		
		if (defined $arg2 && ref $arg2 eq "HASH") {
				$token_name = $arg2->{'name'};
				$type = $arg2->{'eci_type'};
				$attributes = $arg2->{'attributes'};
				$policy = $arg2->{'policy'};
		} 
	}
	$token_name ||= "Generic ECI channel";
	$type ||= 'PCI';
	if ($ken) {
		my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');	
		my $eci =  Kynetx::Persistence::KToken::create_token($ken,
								     $token_name,
								     $type,
								     undef, # new ECI, don't pass in session
								     $attributes,
								     $policy);
		return {
			"nid" => $userid,
			"name" => $token_name,
			"cid" => $eci
		}
	}
	return undef;
}
$funcs->{'new_eci'} = \&new_eci;

sub get_eci_attributes {
  my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
  my $eci = $args->[0];
  return Kynetx::Persistence::KToken::get_eci_attributes($eci);	
}
$funcs->{'get_eci_attributes'} = \&get_eci_attributes;

sub set_eci_attributes {
  my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
  my $eci = $args->[0];
  my $attrs = $args->[1];
  return Kynetx::Persistence::KToken::set_eci_attributes($eci, $attrs);	
}
$funcs->{'set_eci_attributes'} = \&set_eci_attributes;


sub get_eci_policy {
  my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
  my $eci = $args->[0];
  return Kynetx::Persistence::KToken::get_eci_policy($eci);	
}
$funcs->{'get_eci_policy'} = \&get_eci_policy;

sub set_eci_policy {
  my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
  my $eci = $args->[0];
  my $policy = $args->[1];
  return Kynetx::Persistence::KToken::set_eci_policy($eci, $policy);	
}
$funcs->{'set_eci_policy'} = \&set_eci_policy;





sub destroy_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
			 developer_authorized($req_info,$rule_env,$session,['eci','destroy']));
	
	my $arg1 = $args->[0];
	my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);
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
	my $logger=get_logger();
	my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
			 developer_authorized($req_info,$rule_env,$session,['eci','show']));
	my $ken;
	my $arg1 = $args->[0];
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
	}	
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

sub list_eci_by_name {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger=get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
	 developer_authorized($req_info,$rule_env,$session,['eci','show']));
	my $ken;
	my $arg1 = $args->[0];
	my $name = $args->[1];
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
	}	
	if ($ken) {
		my $channels = Kynetx::Persistence::KToken::get_token_by_ken_and_label($ken,$name);
		return $channels;
	}
	return undef;
}
$funcs->{'list_eci_by_name'} = \&list_eci_by_name;


sub get_primary_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger=get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
	 developer_authorized($req_info,$rule_env,$session,['eci','show']));
	my $ken;
	my $arg1 = $args->[0];
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
	}	
	if ($ken) {
    my $primary = Kynetx::Persistence::KToken::get_default_token($ken);
    $primary = Kynetx::Persistence::KToken::get_oldest_token($ken) unless ($primary);
    return $primary;
	}
	return undef;
}
$funcs->{'session_token'} = \&get_primary_eci;
$funcs->{'login_eci'} = \&get_primary_eci;


sub get_oauth_token_eci {
	my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
	my $logger=get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
	 developer_authorized($req_info,$rule_env,$session,['oauth','access_token']));
	my $ken;
	my $oauth_token = $args->[0];
  my $primary = Kynetx::Persistence::KToken::get_token_by_token_name($oauth_token);
  return $primary
}
$funcs->{'oauth_eci'} = \&get_oauth_token_eci;

sub get_developer_oauth_eci {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger=get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
		     developer_authorized($req_info,$rule_env,$session,['oauth','access_token']));
    my $developer_eci = $args->[0];
    my $type = 'OAUTH-' . $developer_eci;
    my $primary = Kynetx::Persistence::KToken::get_token_by_token_type($type);
    return $primary
}
$funcs->{'list_oauth_eci'} = \&get_developer_oauth_eci;

############################# OAuth Apps


# actions
sub register_app {
    my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;

    my $logger = get_logger();
    $logger->debug("Creating new OAuth app");
    my $keys = _key_filter([$config->{"credentials"}]);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
    
    my ($ken,$token_name,$token_type,$attributes,$policy);
    my $account_id = $args->[0];

    $logger->debug("Account ID: ", $account_id);

#    my $options = $args->[1];
    if (! defined $account_id) {
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
    } else {
	# Check to see if it is an eci or a userid
	if ($account_id =~ m/^\d+$/) {
	    ll("userid $account_id");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($account_id);
	} else {
	    ll("eci $account_id");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($account_id);
	}			
    }

    
    $token_name = "OAuth Developer Token";
    $token_type = "OAUTH";
    
    if ($ken) {
	my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');	
	my $token =  Kynetx::Persistence::KToken::create_token($ken,
							       $token_name,
							       $token_type,
							       undef, # new ECI, don't pass in session
							       {}, # no attributes
							       {}  # no policy
							      );

	my $developer_secret = _generate_developer_key($ken);
	my $permission =  _dev_permissions($ken,$developer_secret, ['oauth','access_token'], 1);

	my $app_info;
	if (defined $config && ref $config eq "HASH") {

	    $app_info = {"icon" => $config->{"icon"},
			 "name"=> $config->{"name"},
			 "description"=> $config->{"description"},
			 "info_url"=> $config->{"info_url"},
			 "declined_url" => $config->{"declined_url"},
			};

	    if (defined $config->{"callbacks"}) {
		Kynetx::Persistence::KPDS::add_callback($ken, $token, $config->{"callbacks"});
	    }
	    if (defined $config->{"bootstrap"}) {
		Kynetx::Persistence::KPDS::add_bootstrap($ken, $token, $config->{"bootstrap"});
	    }
	} 

	$app_info->{"developer_secret"} =  $developer_secret; # add even if no config

	my $app_info_result = Kynetx::Persistence::KPDS::add_app_info($ken, $token, $app_info);

	if ( defined $vars->[0] ) {
	    my $resp = {$vars->[0]             => $token,
			$vars->[1] || "secret" => $developer_secret
		       };
	    $rule_env = add_to_env( $resp, $rule_env );
	}
    }
}

sub delete_oauth_app {
    my ( $req_info, $rule_env, $session, $config, $mods, $args, $vars ) = @_;
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	
    my $token = $args->[0];
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($token);
    if ($ken) {
	my $userid = Kynetx::Persistence::KEN::get_ken_value($ken,'user_id');	
#	$logger->debug("Deleting app: ", $token);

	Kynetx::Persistence::KPDS::delete_app($ken, $token);
    }
}

sub list_apps {
    my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
    my $logger = get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));

    my $account_id = $args->[0];
    #$logger->debug("Account ID: ", $account_id);

    my $ken;
    if (! defined $account_id) {
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	$ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
    } else {
	# Check to see if it is an eci or a userid
	if ($account_id =~ m/^\d+$/) {
	    #ll("userid $account_id");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_userid($account_id);
	} else {
	    #ll("eci $account_id");
	    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($account_id);
	}			
    }

    if ($ken) {
	return Kynetx::Persistence::KPDS::get_all_apps($ken);
    }
    return undef;
}
$funcs->{'list_apps'} = \&list_apps;


sub add_oauth_callback {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	my $developer_eci = $args->[0];
	my $arg2 = $args->[1];
	my @callbacks = ();
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	if (defined $arg2) {
		if (ref $arg2 eq "ARRAY") {
			@callbacks = @{$arg2};
		} elsif (ref $arg2 eq "") {
			push(@callbacks,$arg2);
		}
	}	
	# callbacks must be installed to an eci
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	if ($ken && scalar @{$args} >= 1) {
		my $installed = Kynetx::Persistence::KPDS::add_callback($ken,$developer_eci,\@callbacks);
		return $installed->{'value'};
	}
	return undef;
	
}
$funcs->{'add_callback'} = \&add_oauth_callback;

sub add_oauth_bootstrap {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	my $developer_eci = $args->[0];
	my $arg2 = $args->[1];
	my @bootstrap = ();
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	if (defined $arg2) {
		if (ref $arg2 eq "ARRAY") {
			@bootstrap = @{$arg2};
		} elsif (ref $arg2 eq "") {
			push(@bootstrap,$arg2);
		}
	}	
	# callbacks must be installed to an eci
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	if ($ken && scalar @{$args} >= 1) {
		my $installed = Kynetx::Persistence::KPDS::add_bootstrap($ken,$developer_eci,\@bootstrap);
		return $installed->{'value'};
	}
	return undef;
	
}
$funcs->{'add_bootstrap'} = \&add_oauth_bootstrap;

sub list_oauth_bootstrap {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	return 0 unless (pci_authorized($req_info,$rule_env,$session));
	my $rid = get_rid($req_info->{'rid'});		
	my $arg1 = $args->[0];
	my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);	
	if ($ken) {
	  return Kynetx::Persistence::KPDS::get_bootstrap($ken,$arg1);
	} 
	return undef;
	
}
$funcs->{'list_bootstrap'} = \&list_oauth_bootstrap;

sub remove_oauth_bootstrap {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	my $developer_eci = $args->[0];
	my $arg2 = $args->[1];
	my $ken;
	my @bootstrap = ();
	if (defined $arg2) {
		if (ref $arg2 eq "ARRAY") {
			@bootstrap = @{$arg2};
		} elsif (ref $arg2 eq "") {
			push(@bootstrap,$arg2);
		}
	}	
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	if ($ken && scalar @{$args} >= 1) {
		my $installed = Kynetx::Persistence::KPDS::remove_bootstrap($ken,$developer_eci,\@bootstrap);
		return $installed->{'value'};
	}
	return undef;
	
}
$funcs->{'remove_bootstrap'} = \&remove_oauth_bootstrap;

sub add_oauth_app_info {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	my $developer_eci = $args->[0];	
	my $app_info= $args->[1];;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	if ($ken && scalar @{$args} >= 1) {
		return Kynetx::Persistence::KPDS::add_app_info($ken,$developer_eci,$app_info);
	}
	return undef;
	
}
$funcs->{'add_appinfo'} = \&add_oauth_app_info;

sub add_oauth_secret {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	my $developer_eci = $args->[0];	
	my $secret = $args->[1];;
	my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
	my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);		
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	if ($ken && scalar @{$args} >= 1) {
		return Kynetx::Persistence::KPDS::set_developer_secret($ken,$developer_eci,$secret);
	}
	return undef;
	
}
$funcs->{'add_oauth_secret'} = \&add_oauth_secret;


sub remove_callback {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	my $developer_eci = $args->[0];
	my $arg2 = $args->[1];
	my $ken;
	my @callbacks = ();
	if (defined $arg2) {
		if (ref $arg2 eq "ARRAY") {
			@callbacks = @{$arg2};
		} elsif (ref $arg2 eq "") {
			push(@callbacks,$arg2);
		}
	}	
	$ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	if ($ken && scalar @{$args} >= 1) {
		my $installed = Kynetx::Persistence::KPDS::remove_callback($ken,$developer_eci,\@callbacks);
		return $installed->{'value'};
	}
	return undef;
	
}
$funcs->{'remove_callback'} = \&remove_callback;

sub remove_oauth_app_info {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
  my $keys = _key_filter($args);
	return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys));
	my $developer_eci = $args->[0];
	my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	if ($ken && $developer_eci) {
		my $installed = Kynetx::Persistence::KPDS::remove_app_info($ken,$developer_eci);
		return $installed->{'value'};
	}
	return undef;
	
}
$funcs->{'remove_appinfo'} = \&remove_oauth_app_info;

sub list_callback {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	return 0 unless (pci_authorized($req_info,$rule_env,$session));
  my $rid = get_rid($req_info->{'rid'});		
	my $arg1 = $args->[0];
	my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);	
	if ($ken) {
	  return Kynetx::Persistence::KPDS::get_callbacks($ken,$arg1);
	} 
	return undef;
	
}
$funcs->{'list_callback'} = \&list_callback;

sub get_oauth_app_info {
	my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	return 0 unless (pci_authorized($req_info,$rule_env,$session));
  my $rid = get_rid($req_info->{'rid'});		
	my $arg1 = $args->[0];
	my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($arg1);	
	if ($ken) {
	  return Kynetx::Persistence::KPDS::get_app_info($ken,$arg1);
	} 
	return undef;
	
}
$funcs->{'get_appinfo'} = \&get_oauth_app_info;

sub make_request_uri {
    my ($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;	
    my $logger=get_logger();
    my $keys = _key_filter($args);
    return 0 unless (pci_authorized($req_info, $rule_env, $session, $keys) ||
		     developer_authorized($req_info,$rule_env,$session,['eci','show']));
    my $eci = $args->[0];
    my $cb = $args->[1];
    my $params;
  
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($eci);
    if (defined $ken) {
	$params->{'response_type'}= 'code';
	$params->{'client_id'} = $eci;
	$params->{"state"} = _state_value();
	if ($cb) {
	    $params->{"redirect_uri"} = $cb;
	}
	my $base = Kynetx::Configure::get_config('oauth_server')->{'authorize'} || "oauth_not_configured";
	return Kynetx::Util::mk_url($base,$params);
    } else {
	return undef;
    }
}
$funcs->{'request_uri'} = \&make_request_uri;

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
  my $keys = _key_filter($args);
	return unless (pci_authorized($req_info, $rule_env, $session, $keys));
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
  my $keys = _key_filter($args);
	return unless (pci_authorized($req_info, $rule_env, $session, $keys));
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

sub oauth_authorization_code {
  my($req_info,$rule_env,$session,$rule_name,$function,$args) = @_;
	my $logger = get_logger();
	$logger->debug("OAuth code");
  my $keys = _key_filter($args);
  return unless (pci_authorized($req_info, $rule_env, $session, $keys));
  
  my $developer_eci = $args->[0];
  my $user_eci = $args->[1];
  my $developer_secret = $args->[2];
  return _construct_oauth_code($developer_eci,$developer_secret,$user_eci);  
}
$funcs->{'OAuth_code'} = \&oauth_authorization_code;

sub _construct_oauth_code {
  my ($developer_eci,$developer_secret,$user_eci) = @_;
  my $t = time();
  my $syskey = syskey();
  my $oauth_key = "$syskey" ^ "$developer_eci";
  my $raw_token = $t . "|" . $developer_eci . "|" . $developer_secret . "|" . $user_eci;
  return _obfuscate($oauth_key,$raw_token);
}

sub deconstruct_oauth_code {
  my ($developer_eci,$code) = @_;
  my $logger = get_logger();
  my $syskey = syskey();
  my $oauth_key = "$syskey" ^ "$developer_eci";
	my $decoded = _fuscate($oauth_key,$code);	
  my @val = split(/\|/,$decoded);
  return \@val;  
}

sub _obfuscate {
  my ($key,$string) = @_;
  my $encr = RC4($key,$string);
  my $encrypted = unpack('H*', $encr);
  my $b64 = MIME::Base64::encode_base64url($encrypted);
  return $b64;
}

sub _fuscate {
  my ($key,$estring) = @_;
  my $de64 = MIME::Base64::decode_base64url($estring);
  my $packed = pack('H*', $de64);
  my $decoded = RC4($key,$packed);
  return $decoded;
}

sub create_oauth_token {
  my ($developer,$user,$secret) = @_;
  my $logger=get_logger();
  my $t = time();
  my $data = $developer . '|' . $user;
  my $digest = hmac_sha256($data,$secret);
  my $b64 = MIME::Base64::encode_base64url($digest);
  my $t64 = MIME::Base64::encode_base64url($t);
  my $token = $b64 . '|' . $t64;
  $logger->debug("Digest: $b64");
  return $token;
}

sub create_oauth_indexed_eci {
  my ($ken,$token_name,$developer_eci) = @_;
  my $type = 'OAUTH-' . $developer_eci;
  
  my $obj = Kynetx::Persistence::KToken::update_token_name($ken,$token_name,$type);
  if ($obj && ref $obj eq "HASH") {
    return $obj->{'ktoken'}
  }  elsif ($obj) {
    return $obj;
  }
  return undef;
}



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
	my $keys = _key_filter($args);
	if (pci_authorized($req_info, $rule_env, $session, $keys)) {		
	    return _generate_developer_key($ken);
	} else {
	    $logger->warn("Account not authorized for developer keys");
	}
	return undef;
}
$funcs->{'create_developer_key'} = \&developer_key;

sub _generate_developer_key {
    my ($ken) = @_;
    my $t = time();
    my $r = int(rand($t));
    my $nonce = "$t" ^ "$r"; 
    my $data = $ken . $nonce;
    my $syskey = syskey();
    my $digest = hmac_sha256_base64($data,$syskey);
    _default_permissions($ken,$digest);
    return $digest;
}

# the default for kns_config.yml
# permissions: 
#   developer : 
#     cloud : 
#       create : 0
#       destroy : 0
#       auth : 1
#     ruleset : 
#       create : 0
#       destroy : 0
#       show : 1
#     eci : 
#       create : 1
#       destroy : 1
#       show : 1


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
	$string = $string || '';
	my $digest = hmac_sha256_base64($string,$salt);
	return $digest;	
}


sub auth_ken {
	my ($ken,$string) = @_;
	my $logger = get_logger();
	my $hashed = Kynetx::Persistence::KEN::get_authorizing_password($ken);
	my $passed = _hash_password($string);
	$logger->debug("hash: $hashed");
	$logger->debug("Pass: $passed");
	if ($hashed eq $passed) {
		return 1;
	}
	return 0;
	
}

sub create_system_key {
  my ($conf_key) = @_;
  my $logger=get_logger();
  $logger->debug("Make system key");
	my $syskey = syskey();
	my $id = make_pass_phrase($conf_key);
	return undef unless (defined $id);
  $logger->debug("Make system key from $id");
	my $phrase = get_pass_phrase($id);
	#$logger->info("System: ",$^O);
	$phrase = encode('utf8',$phrase);
	my $data = $id . '||' . $phrase;
	my $encrypted = RC4($syskey,$data);
	$encrypted = unpack('H*', $encrypted);
	return MIME::Base64::encode_base64url($encrypted);
	
}

sub check_system_key {
	my ($key) = @_;
	return 0 unless (defined $key);
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
		$logger->info("*** system credential check failed ***");
	}
}

sub _has_credentials {
  my $args = shift;
  my $logger = get_logger();
  my @new_args = ();
  my $found = 0;
  my $key = 0;
  if (defined $args and ref $args eq "ARRAY") {
    foreach my $arg (@{$args}) {
      if (ref $arg eq "HASH") {
        my $super_key = $arg->{'root'};
        if (defined $super_key) {
          $found = 1;
          $key = check_system_key($super_key);
        } else {
          push(@new_args,$arg);
        }
      }
    }
    if ($found) {
      $logger->debug("Found");
      $args = \@new_args;
    }
  }
  return $key;
}

sub _key_filter {
  my ($args) = @_;
  my $logger=get_logger();
  my @new_args = ();
  my $key = undef;
  if (defined $args and ref $args eq "ARRAY") {
    foreach my $arg (@{$args}) {
      if (ref $arg eq "HASH") {
        my $super_key = $arg->{'root'};
        if (defined $super_key) {
          $key = $arg;
        } 
      } else {
        push(@new_args,$arg);
      }
    }
    if ($key) {
      $logger->debug("has key: ", sub {Dumper($args)});
      $logger->debug("new args: ", sub {Dumper(@new_args)});
      @{$args} = @new_args;
      #$args = \@new_args;
      $logger->debug("post key: ", sub {Dumper($args)});
    }
  }
  return $key;
}

sub pci_authorized {
	my ($req_info, $rule_env, $session,$explicit) = @_;	
	my $logger = get_logger();
	my $keys = Kynetx::Keys::get_key($req_info,$rule_env,CREDENTIALS);
	if (defined $keys and ref $keys eq "HASH") {
	    my $super_key = $keys->{'root'};
	    if (defined $super_key) {
		return check_system_key($super_key);		
	    }		
	} elsif (defined $explicit and ref $explicit eq "HASH") {
	  my $super_key = $explicit->{'root'};
	  if (defined $super_key) {
	      return check_system_key($super_key);		
	  }
	}
	
	return 0;
}

sub developer_authorized {
	my ($req_info, $rule_env, $session, $permission_path) = @_;
	my $logger = get_logger();
	my $keys = Kynetx::Keys::get_key($req_info,$rule_env,CREDENTIALS);
	# $logger->debug("Keys: ", sub {Dumper($keys)});
	if (defined $keys and ref $keys eq "HASH") {
		my $token = $keys->{'developer_eci'} || '';
		my $cred = $keys->{'developer_secret'};
		if ($token) {
		    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($token);
		    my $permission = Kynetx::Persistence::KPDS::get_developer_permissions($ken,$cred,$permission_path);	
		    return $permission;
		} else {
		    $logger->info("Developer not authorized; no developer ECI supplied");
		    return 0;
		}
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
	$syskey = hmac_sha256_base64($syskey,$salt);
	return $syskey;
}

sub _primary_eci {
  my ($ken) = @_;
  
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
  my ($conf_key) = @_;
  my $logger=get_logger();
  if (defined $conf_key) {
		  my $salt = Kynetx::Configure::get_config('PCI_KEY');
		  return undef unless ($conf_key eq $salt);
	}	
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
		my $id_val = $id->to_string();
		$logger->debug("Make passphrase ($id_val) $phrase expire");
		Kynetx::MongoDB::set_ttl('dictionary',EXPIRES_IN,$id_val) unless (defined $conf_key);
		return $id_val;
	}		
	return undef;
}

sub _state_value {
  my @chars = ("A".."Z","a".."z",0..9,"_");
  my $string;
  $string .= $chars[rand @chars] for 0..9;
  return $string;
}

1;
