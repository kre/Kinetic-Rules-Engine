package Kynetx::OAuth::OAuth20;

# file: Kynetx/OAuth/OAuth20.pm
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
use lib qw(/web/lib/perl);
use utf8;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
$Data::Dumper::Indent = 1;

use HTML::Template;
use JSON::XS;
use Cache::Memcached;
use DateTime::Format::ISO8601;
use Benchmark ':hireswallclock';
use Encode qw(from_to);

use Kynetx::Util;
use Kynetx::Modules::PCI;
use Kynetx::Persistence::KPDS;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Apache2::Const qw(FORBIDDEN OK DECLINED :http M_GET M_POST M_OPTIONS);

no warnings 'redefine';

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
        query_param
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use constant DEFAULT_TEMPLATE_DIR => Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR');
use constant LOGIN_TAG => "__login__";
use constant DEFAULT_RULESET => [
  'a169x625.prod'
];

my $unsafe_global;

sub handler {
    my $r = shift;
    $unsafe_global = '<ul>';
    Kynetx::Memcached->init();
    Kynetx::MongoDB->init();
    Kynetx::Util::config_logging($r);
    Log::Log4perl::MDC->put('site', 'OAuth2.0');
    Log::Log4perl::MDC->put('rule', '[OAuth Main]');
    my $logger=get_logger('Kynetx');
    if ($r->method_number == Apache2::Const::M_OPTIONS) {
      $logger->debug("Preflight");
      return  Apache2::Const::OK
    }
    my $login_info;
    my $session = login_session($r);
    my $login_page = base_login($r);
    $login_page->param('SMODE' => _smode());

    $logger->debug("OAuth2.0 Main");
    $logger->debug("Session: ", sub {Dumper($session)});
    #Kynetx::Util::request_dump($r);
    my ($method,$path) = $r->path_info() =~ m!/([a-z+_]+)/*(.*)!;
    my $req = Apache2::Request->new($r);
    my $p = $req->param();    
    $logger->debug("Method: $method");
    $logger->debug("Path: $path");
#    $logger->debug("params: ", sub {Dumper($p)});
#    $logger->debug("Args: ",$r->args);
#    $logger->debug("unURI: ",$r->unparsed_uri());
#    $logger->debug("path: ",$r->path_info());
    
    my $result = workflow($login_page,$session, $method, $path,$p);
    
    if (defined $result && ref $result eq "HASH") {
      return _respond($r,$result);
    } elsif ($result) {
      $r->headers_out->set(Location => $result);
      return Apache2::Const::HTTP_MOVED_TEMPORARILY;
    }
    
    $r->content_type('text/html');
    print $login_page->output;
    $logger->debug("return ok");	  
    return Apache2::Const::OK;
}

sub refresh_token {
  my ($oauth_token,$session_token,$params) = @_;
  my $logger = get_logger();
#  $logger->trace("Refresh delete: $oauth_token");
#  my $oauth_eci = Kynetx::Persistence::KToken::get_token_by_token_name($oauth_token);
#  my $result = Kynetx::Persistence::KToken::delete_token($oauth_eci);
#  $logger->trace("delete result: ", sub {Dumper($result)});
  return _code_redirect($session_token,$params);
}

sub _code_redirect {
  my ($session_token,$params) = @_;
  my $logger = get_logger();
  my $eci=  $params->{'developer_eci'} ;
  my $state =  $params->{'client_state'};
  my $uri = $params->{'uri_redirect'};
  my $code = oauth_code($eci,$session_token);
  _bootstrap($session_token,$eci);
  $logger->debug("session token: $session_token");
  $logger->debug("state: $state");
  $logger->trace("uri: $uri");
  $logger->trace("uri: $uri");
  my $location = Kynetx::Util::mk_url($uri,{
     'code' => $code,
     'state' => $state
  });
  return $location;
}

sub workflow {
  my ($template,$session, $method, $path,$params) = @_;
  my $logger = get_logger();
  my $ken;
  my $session_id;
  my $session_token = _logged_in($session);
  $logger->debug("Session token: $session_token");
  if ($session_token) {
    $session_id = get_session_id($session);
    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($session_token);
    $logger->debug("Ken: $ken");
    $logger->debug("session id: $session_id");
  }
  if ($method eq 'oauth') {
    if ($ken) {
      # check for oauth token
      $logger->trace("Is logged in: $ken");
      if ($path eq "signin") {
        $logger->debug("sign_in");
        my $oauth_token = _oauth_token($ken,$params);
        if ($oauth_token) {
          $logger->trace("SI Has oauth token: $oauth_token");
          # This guy has already authorized the app
          return refresh_token($oauth_token,$session_token,$params);
          
        } else {
          # Present the application authorize page
          $template->param("DIALOG" => authorize_app($ken,$params));          
        }
      } elsif ($path eq "allow"){
         $logger->debug("allow");
         return _code_redirect($session_token,$params);
              
      } else {
        # could be link from app
        # Present the application authorize page
        $logger->debug("Path is not specific");
        my $oauth_token = _oauth_token($ken,$params);
        $logger->trace("OAuth token: $oauth_token");
        if ($oauth_token) {
          # This guy has already authorized the app
          $logger->trace("Has oauth token: $oauth_token");
          return refresh_token($oauth_token,$session_token,$params);          
        } else {
          $template->param("DIALOG" => authorize_app($ken,$params));
        }
      }
    } else {
      # not logged in
      $logger->debug("not logged in");
      $ken = _signin($session,$params);
      if ($ken) {
        # login passed correct user/pass
        # check for oauth token
        $logger->debug("Password verified for $ken");
        my $oauth_token = _oauth_token($ken,$params);
        if ($oauth_token) {
          my $session_token = _logged_in($session);
          return refresh_token($oauth_token,$session_token,$params);
        } else {
          # Present the application authorize page
          $template->param("DIALOG" => authorize_app($ken,$params));          
        }
      } elsif ($path eq "newuser"){
        $logger->debug("CREATE NEW USER");
        if ($ken) {
          my $error = "Log out before you try to create a new account";
          $template->param("DIALOG" => profile_page($ken,$error));
        } else {
          $template->param("DIALOG" => oauth_account($params));  
        }  
      } elsif ($path eq 'create') {   
        $ken = create_account($params);
        if ($ken) {
          $template->param("DIALOG" => authorize_app($ken,$params));
          Kynetx::Persistence::KToken::delete_token($session_token,get_session_id($session));
          create_login_token($session,$ken);
        } else {
          my $error = "Unable to create account for (" . $params->{'new_user_name'} . ")";
          $template->param("DIALOG" => native_login($params,$error));
        }
      } else {
        # Neither logged in nor credentials
        if ($path eq "signin") {
          my $error = "Username/Password combination not found";
          $template->param("DIALOG" => oauth_login_page($params,$error));
        } else {
          $template->param("DIALOG" => oauth_login_page($params));
        }
      }
      
    }
  } elsif ($method eq 'newaccount') {  
      if ($ken) {
        my $error = "Log out before you try to create a new account";
        $template->param("DIALOG" => profile_page($ken,$error));
      } else {
        $template->param("DIALOG" => newaccount($params));  
      }
  } elsif ($method eq 'check_username') {         
      my $username = $params->{'username'};
      $logger->debug("Username: $username");
       my $json = {
        "username" => $username
      };
      my $found = Kynetx::Persistence::KEN::ken_lookup_by_username($username);
      if ($found) {
        $json->{'available'} = 0
      } else {
        $json->{'available'} = 1
      }
      $logger->trace("HASH: ", sub {Dumper($json)});
      return $json;
  } elsif ($method eq 'create') {   
      $ken = create_account($params);
      if ($ken) {
        $template->param("DIALOG" => profile_page($ken,undef,$session_id));
        Kynetx::Persistence::KToken::delete_token($session_token,get_session_id($session));
        create_login_token($session,$ken);
      } else {
        my $error = "Unable to create account for (" . $params->{'new_user_name'} . ")";
        $template->param("DIALOG" => native_login($params,$error));
      }
  } elsif ($method eq 'logout') {
    if ($session_token) {
      Kynetx::Persistence::KToken::delete_token($session_token,get_session_id($session));
      my $location = _platform() . '/login';
      return $location;
    }
  } elsif ($method eq 'update') {
    if ($ken) {
      set_profile($ken,$params);
      $template->param("DIALOG" => profile_page($ken,undef,$session_id));
    } else {
      $template->param("DIALOG" => native_login($params));
    }
  } elsif ($method eq 'local') {
    if ($path eq 'auth') {
      $ken = _signin($session,$params);
      if ($ken) {
        $template->param("DIALOG" => profile_page($ken,undef,$session_id));
      } else {
        my $error = "Username/Password combination not found";
        $template->param("DIALOG" => native_login($params,$error));
      }
    } else {
      if ($ken) {
        $template->param("DIALOG" => profile_page($ken,undef,$session_id));
      } else {
        $template->param("DIALOG" => native_login($params));
      }
    }
  } else {
    if ($ken) {
      $template->param("DIALOG" => profile_page($ken,undef,$session_id));
    } else {
      $template->param("DIALOG" => native_login($params));
    }
  }
  return undef;
}

sub oauth_account {
  my ($params) = @_;
  my $logger = get_logger();
  $logger->debug("OAuth account page: ");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/oauth_create.tmpl";
	my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	my $developer_eci = $params->{'developer_eci'};
	my $state = $params->{'client_state'};
	my $redirect = $params->{'uri_redirect'};
	my $base = Kynetx::Configure::get_config('oauth_server')->{'authorize'} || "oauth_not_configured";
	my $login_url = Kynetx::Util::mk_url($base, {
	 'client_id' => $developer_eci,
	 'response_type' => 'code',
	 'state' => $state,
	 'redirect_uri' => $redirect 
	}	);
	$dialog->param('PLATFORM' => _platform());
	$dialog->param('ECI' => $developer_eci );
	$dialog->param('STATE' =>  $state);
	$dialog->param('REDIRECT' =>  $redirect);
	$dialog->param("OAUTH_LOGIN_LINK" => $login_url);
	return $dialog->output();
}


sub set_profile {
  my ($ken,$params) = @_;
  my $logger = get_logger();
  my $form_token = $params->{'login_session'};
  my $session_token = Kynetx::Persistence::KToken::get_token_by_endpoint_id($form_token);
  my $session_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($session_token);
  $logger->trace("        Ken: $ken");
  $logger->trace("Session Ken: $session_ken");
  if ($session_ken eq $ken) {
    $logger->trace("params: ",sub {Dumper($params)});
    my @update_allowed = ('first_name', 'last_name', 'email');
    foreach my $element (@update_allowed) {
      my $string = $element;
      if (defined $params->{$element}) {
        $string .= ":" . $params->{$element};
        Kynetx::Persistence::KEN::set_ken_value($ken,$element,$params->{$element})
      }
      $logger->trace("$string");
    }
  }
  
}

sub _bootstrap {
  my ($user_eci,$developer_eci) =@_;
  my $logger = get_logger();
  my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($user_eci);
  if ($ken) {
    add_bootstrap_ruleset($ken,$developer_eci) unless (has_bootstrap_ruleset($ken,$developer_eci)) ;
  }
    
}

sub has_bootstrap_ruleset {
  my ($ken, $developer_eci) = @_;
  my $logger = get_logger();
  my $dken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
  my $list = Kynetx::Persistence::KPDS::get_bootstrap($dken,$developer_eci);
  my $installed = Kynetx::Persistence::KPDS::get_rulesets($ken);
  $logger->debug("Boot: ", sub {Dumper($list)});
  $logger->debug("Inst: ", sub {Dumper($installed)});
  if  (Kynetx::Sets::has($list,$installed)) {
    return 1
  } else {
    return 0
  }  
}

sub add_bootstrap_ruleset {
  my ($ken, $developer_eci) = @_;
  my $logger = get_logger();
  my $dken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
  my $list = Kynetx::Persistence::KPDS::get_bootstrap($dken,$developer_eci);
  if (defined $list) {
    add_ruleset_to_account($ken,$list);
  } else {
    $logger->debug("No bootstrap ruleset(s) defined for $dken/$developer_eci")
  }
  
  
}

sub add_ruleset_to_account {
  my ($ken, $rid) = @_;
  my @ridlist = ();
  if (ref $rid eq "ARRAY") {
    @ridlist = @{$rid};
  } else {
    push(@ridlist,$rid);
  }
  my $installed = Kynetx::Persistence::KPDS::add_ruleset($ken,\@ridlist);
}

sub create_account {
  my ($params) = @_;
  my $logger = get_logger();
  my $username = $params->{'username'};
  my $password = $params->{'password'};
  my $email = $params->{'email'};
  my $type = 'PCI';
  $logger->trace("$username $password $email");
  if ($username && $password && $email) {
    # check username 
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_username($username);
    my $hash = Kynetx::Modules::PCI::_hash_password($password);
    if ($ken) {
      $logger->warn("$username is already in use");
      return undef;
    }
    my $created = DateTime->now->epoch;
    my $dflt = {
      "username" => $username,
      "firstname" => "",
      "lastname" => "",
      "password" => $hash,
      "created" => $created,
      "email" => $email
	    };
	  $ken = Kynetx::Persistence::KEN::new_ken($dflt);
	  Kynetx::Persistence::KToken::create_token($ken,"_LOGIN",$type);
	  add_ruleset_to_account($ken,+DEFAULT_RULESET);	  
	  return $ken;
  } else {
    return undef;
  }
}

sub _oauth_token {
  my ($ken,$params) = @_;
  my $logger = get_logger();
  $logger->debug("Params: ",sub {Dumper($params)});
  my $developer_eci =  $params->{'developer_eci'};
  my $etype = "OAUTH-$developer_eci";
  my $var = {
    'endpoint_type' => $etype,
    'ken' => $ken
  };
  $logger->debug("Key: ", sub {Dumper($var)});
  my $token = Kynetx::Persistence::KToken::token_query($var);
  $logger->debug("token: ", sub {Dumper($token)});
  if ($token) {
    return $token->{"token_name"};
  }
  return undef;
}

sub newaccount {
  my ($params) = @_;
  my $logger = get_logger();
  $logger->debug("New account page: ");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/create.tmpl";
	my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param('PLATFORM' => _platform());
	return $dialog->output();
}

sub authorize_app {
  my ($ken,$params) = @_;
  my $logger = get_logger();
  $logger->debug("Present authorization page: ");
  $logger->trace("Params: ", sub {Dumper($params)});
  my $template = DEFAULT_TEMPLATE_DIR . "/login/oapp_auth.tmpl";
	my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	my $developer_eci = $params->{'developer_eci'};
	my $state = $params->{'client_state'};
	my $redirect = $params->{'uri_redirect'};
	my $d_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
  my $app_info = Kynetx::Persistence::KPDS::get_app_info($d_ken,$developer_eci);
	my $username =   Kynetx::Persistence::KEN::get_ken_value($ken,'username');              
  $dialog->param('USERNAME' => $username );
  $dialog->param('APP_NAME' => $app_info->{'name'});
  $dialog->param('ICON' => $app_info->{'icon'});
  $dialog->param('DESC' => $app_info->{'description'});
  my $info_page = $app_info->{'info_page'} || "#";
  $dialog->param('INFO_PAGE' => $info_page);
	$dialog->param('ECI' => $developer_eci );
	$dialog->param('STATE' =>  $state);
	$dialog->param('REDIRECT' =>  $redirect);
	$dialog->param('PLATFORM' => _platform());
	return $dialog->output();
  
}

sub _logged_in {
  my ($session) = @_;
  my $logger = get_logger();
  $logger->debug("get token for $session");
  my $token = Kynetx::Persistence::KToken::get_token($session,undef,"web");
  $logger->debug("get token: ", sub {Dumper($token)});
  if (defined $token && ref $token eq "HASH") {
    return $token->{'ktoken'}
  }
  return undef;
}

sub create_login_token {
  my ($session,$ken) = @_;
  my $logger = get_logger();
  $logger->debug("Ken: $ken ", sub {Dumper($session)});
  Kynetx::Persistence::KToken::delete_token(undef,get_session_id($session));
  my $token = Kynetx::Persistence::KToken::create_token($ken,LOGIN_TAG,"KMCP",$session);
  $logger->debug("Made token: ", sub {Dumper($token)});
  return $token;  
}


sub profile_page {
  my ($ken,$error,$session_id) = @_;
  my $logger = get_logger();
  $logger->debug("Profile");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/nprofile.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param("PLATFORM" => _platform());
	my $username = Kynetx::Persistence::KEN::get_ken_value($ken,'username');
  $dialog->param("USERNAME" => $username);
  if ($error) {
    $dialog->param("PAGEFORM" => page_error($error));
  } else {
    $dialog->param("PAGEFORM" => profile_update($ken,$session_id));
  }
	$dialog->param('PLATFORM' => _platform());
	return $dialog->output();
}

sub page_error {
  my ($error) = @_;
  my $logger = get_logger();
  $logger->trace("Profile");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/error.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param("PLATFORM" => _platform());
  $dialog->param("ERROR_TEXT" => $error);	
	$dialog->param('PLATFORM' => _platform());
	return $dialog->output();
}


sub profile_update {
  my ($ken,$session_id) = @_;
  my $template = DEFAULT_TEMPLATE_DIR . "/login/update_profile.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  my $email = Kynetx::Persistence::KEN::get_ken_value($ken,'email');
  my $fname = Kynetx::Persistence::KEN::get_ken_value($ken,'first_name');
  my $lname = Kynetx::Persistence::KEN::get_ken_value($ken,'last_name');
  if ($session_id) {
    $dialog->param('L_SESSION' => $session_id)
  }
  $dialog->param("EMAIL" => $email);
  $dialog->param("FNAME" => $fname);
  $dialog->param("LNAME" => $lname);
  $dialog->param('PLATFORM' => _platform());
  return $dialog->output();
}

sub native_login {
  my ($params,$error) = @_;
  my $template = DEFAULT_TEMPLATE_DIR . "/login/native_login.tmpl";
	my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param("PLATFORM" => _platform());
	if ($error) {
	  my $error_msg = '<strong>' . $error . '</strong>';
	  $dialog->param("LOGIN_ERROR" => $error_msg);
	  my $username = $params->{'user'};
	  if ($username) {
	    $dialog->param("STICKY_USER" => $username)
	  }
	}
	$dialog->param('PLATFORM' => _platform());
	return $dialog->output();
}

sub oauth_code {
  my ($d_eci, $user_eci) = @_;
  my $d_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($d_eci);
  my $secret = Kynetx::Persistence::KPDS::get_developer_secret($d_ken,$d_eci);
  my $code = Kynetx::Modules::PCI::_construct_oauth_code($d_eci,$secret,$user_eci);
  return $code;
}


sub oauth_signin_page {
  my ($session,$params) = @_;
  my $logger = get_logger();
  $logger->debug("Present authorization page: ");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/oauth_signin.tmpl";
	my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param('PLATFORM' => _platform());
	my $username = $params->{'user'};
	my $password = $params->{'pass'};
	$logger->trace("User: ", $username);
	$logger->trace("Password: ",$password);
	my $developer_eci = $params->{'developer_eci'};
	my $state = $params->{'client_state'};
	my $redirect = $params->{'uri_redirect'};
	my $d_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
	my $ken;
	
	if (my $login_token = _logged_in($session)) {
	  $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($login_token);
	} else {
	  $ken = _authenticate($username,$password);
	}
	if ($ken) {
	  	  
	  my $app_info = Kynetx::Persistence::KPDS::get_app_info($d_ken,$developer_eci);
	                 
	  $dialog->param('USERNAME' => $username );
	  $dialog->param('APP_NAME' => $app_info->{'name'});
	  $dialog->param('ICON' => $app_info->{'icon'});
	  $dialog->param('DESC' => $app_info->{'description'});
	  my $info_page = $app_info->{'info_page'} || "#";
	  $dialog->param('INFO_PAGE' => $info_page);
	} else {
	  my $error = "Bad username/password combination";
	  return oauth_login_page($params,$error);
	}
	$dialog->param('ECI' => $params->{'developer_eci'} );
	$dialog->param('STATE' =>  $state);
	$dialog->param('REDIRECT' =>  $redirect);
	return $dialog->output();
  
}

sub _validate_password {
  my ($username,$password) = @_;
  my $logger = get_logger();
  if ($username) {
    $logger->trace("Uname: $username");
    my $ken = Kynetx::Modules::PCI::_username($username);
    $logger->trace("Pword: $password");    
    if ($ken) {
      if (Kynetx::Modules::PCI::auth_ken($ken,$password)){
        return $ken
      };
    }
    return undef;
  }
  
}

sub _signin {
  my ($session,$params) = @_;
  my $logger = get_logger();
	my $username = $params->{'user'};
	my $password = $params->{'pass'};
	$logger->debug("User: ", $username);
	$logger->debug("Password: ",$password);
	my $ken = _validate_password($username,$password);
	if ($ken) {
	  $logger->debug("Found user ken ($ken)");
	  create_login_token($session,$ken);
	  return $ken;
	} else {
	  return undef;
	}
}


sub oauth_login_page {
  my ($params,$error) = @_;
  my $template = DEFAULT_TEMPLATE_DIR . "/login/oauth_login.tmpl";
	my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param('PLATFORM' => _platform());
	$dialog->param('ECI' => $params->{'developer_eci'} );
	$dialog->param('STATE' => $params->{'client_state'} );
	$dialog->param('REDIRECT' => $params->{'uri_redirect'} );
	my $base = Kynetx::Configure::get_config('oauth_server')->{'authorize'} || "oauth_not_configured";
	$base .= '/newuser';
	my $create_url = Kynetx::Util::mk_url($base, {
	 'client_id' => $params->{'developer_eci'},
	 'response_type' => 'code',
	 'state' => $params->{'client_state'},
	 'redirect_uri' => $params->{'uri_redirect'} 
	}	);
	$dialog->param("OAUTH_CREATE" => $create_url);
	if ($error) {
	  my $error_msg = '<strong>' . $error . '</strong>';
	  $dialog->param("LOGIN_ERROR" => $error_msg)
	}
	return $dialog->output();
  
}



sub username_available {
  my ($r,$username) = @_;
  
  my $json = {
    "username" => $username
  };
  my $found = Kynetx::Persistence::KEN::ken_lookup_by_username($username);
  if ($found) {
    $json->{'available'} = 0
  } else {
    $json->{'available'} = 1
  }
  _respond($r,$json);
}


sub _respond {
  my ($r, $json) = @_;
  $r->content_type("application/json");
  $r->print(Kynetx::Json::astToJson($json));
  return OK;
}

sub show_account {
  my ($html_template,$token) = @_;
  my $logger = get_logger();
  my $div;
  if ($token) {
    $logger->trace("token: $token");
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($token);
    if ($ken) {
      my $username = Kynetx::Persistence::KEN::get_ken_value($ken,"username");
      $logger->trace("ken: $ken");
      $html_template->param("LOGGED_IN" => 1);
      $html_template->param("USERNAME" => $username);
      
    }
  } 
  
}

sub query_param {
  my ($qstring,$key) = @_;
  $qstring = URI::Escape::uri_unescape($qstring);
  my $params;
  my @pairs = split(/\&/,$qstring);
  $params = Kynetx::Util::from_pairs(\@pairs);
  return $params->{$key};
}

sub post_param {
  my ($r,$key) = @_;
  my $logger= get_logger();
  my $req = Apache2::Request->new($r);
  $logger->trace("Request: ", sub {Dumper($req)});
  return $req->param($key);  
}

sub base_login {
  my ($r) = @_;
  my $logger = get_logger();
  my $template = DEFAULT_TEMPLATE_DIR . "/Login.tmpl";
	my $login_page = HTML::Template->new(filename => $template,die_on_bad_params => 0);	
	$login_page->param('SMODE' => _smode());
	return $login_page;
}

sub login_session {
  my ($r) = @_;
  my $logger = get_logger();
  my $cookie = $r->headers_in->{'Cookie'};
  _add_to_info("Found: $cookie");
  $cookie =~ s/^.*[;]?SESSION_ID=(\w*)[;]?.*$/$1/ if(defined $cookie);
  my $session;
  #Force constant to eval as string
  my $regstr = "" . LOGIN_TAG;
  if (defined $cookie && $cookie =~ m/^$regstr/) {
    $logger->debug("Found cookie: $cookie");
    $session = { "_session_id" => $cookie};
  } else {
    $logger->debug("No cookie, creating..");
    $session = { "_session_id" =>  login_session_id()};
  }
  
  # create expires timestamp
  my $dt = DateTime->now;
  $dt = $dt->add(days => 364);
  my $expires = $dt->strftime("%a, %d-%b-%Y 23:59:59 GMT");
  
  
#  my $session_cookie =
#        "SESSION_ID=$session->{_session_id};path=/;domain=" .
#        Kynetx::Configure::get_config('COOKIE_DOMAIN') .
#        ';expires=' . $expires; #Mon, 31-Dec-2012 00:00:00 GMT';
  my $session_cookie =
        "SESSION_ID=$session->{_session_id};path=/;domain=" .
        Kynetx::Configure::get_config('COOKIE_DOMAIN');
  $logger->debug("Sending cookie: ", $session_cookie);
  $r->err_headers_out->add('Set-Cookie' => $session_cookie);
  _add_to_info("Cookie: $session_cookie");
  return $session;
}

sub get_session_id {
  my ($session) = @_;
  if (ref $session eq "HASH") {
    return $session->{'_session_id'}
  } else {
    return $session;
  }
}

sub login_session_id {
  my $length = 32;
  my $tmp = substr(Digest::MD5::md5_hex(Digest::MD5::md5_hex(time(). {}. rand(). $$)), 0, $length);
  my $id = LOGIN_TAG . $tmp;
  return $id;
}

sub _add_to_info {
  my ($val) = @_;
  $unsafe_global .= '<li>' . $val . '</li>';
}

sub _close_info {
  my ($template) = @_;
  $unsafe_global .= '</ul>';
  $template->param("LOGIN_INFO" => $unsafe_global);
}


sub _platform {
  my $run_mode = Kynetx::Configure::get_config('RUN_MODE');
  my $smode = _smode();
  my $host = Kynetx::Configure::get_config('LOGIN',$run_mode);
  $host = Kynetx::Configure::get_config("EVAL_HOST") unless ($host);
  my $dn = $smode . $host;
  return $dn;
}

sub _smode {
  my $run_mode = Kynetx::Configure::get_config('RUN_MODE');
  my $smode;
  if ($run_mode eq "development") {
    $smode = "http://";
  } else {    
    $smode = "https://"
  }
  return $smode;
}


1;
