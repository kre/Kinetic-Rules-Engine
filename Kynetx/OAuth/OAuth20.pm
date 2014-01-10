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

use Apache2::Const qw(FORBIDDEN OK DECLINED :http M_GET M_POST);

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

my $unsafe_global;

sub handler {
    my $r = shift;
    $unsafe_global = '<ul>';
    Kynetx::Memcached->init();
    Kynetx::Util::config_logging($r);
    Log::Log4perl::MDC->put('site', 'OAuth2.0');
    Log::Log4perl::MDC->put('rule', '[OAuth Main]');
    my $logger=get_logger('Kynetx');
    my $login_info;
    my $session = login_session($r);
    my $login_page = base_login($r);

    $logger->debug("OAuth2.0 Main");
    $logger->debug("Args: ",$r->args);
    $logger->debug("unURI: ",$r->unparsed_uri());
    $logger->debug("path: ",$r->path_info());
    #Kynetx::Util::request_dump($r);
    my ($method,$path) = $r->path_info() =~ m!/([a-z+_]+)/*(.*)!;
    my $req = Apache2::Request->new($r);
    my $p = $req->param();    
    $logger->debug("Method: $method");
    $logger->debug("Path: $path");
    $logger->debug("params: ", sub {Dumper($p)});
    
    my $redirect = workflow($login_page,$session, $method, $path,$p);
    if ($redirect) {
      $r->headers_out->set(Location => $redirect);
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
  $logger->debug("Refresh delete: $oauth_token");
  my $oauth_eci = Kynetx::Persistence::KToken::get_token_by_token_name($oauth_token);
  my $result = Kynetx::Persistence::KToken::delete_token($oauth_eci);
  $logger->debug("delete result: ", sub {Dumper($result)});
  return _code_redirect($session_token,$params);
}

sub _code_redirect {
  my ($session_token,$params) = @_;
  my $logger = get_logger();
  my $eci=  $params->{'developer_eci'} ;
  my $state =  $params->{'client_state'};
  my $uri = $params->{'uri_redirect'};
  my $code = oauth_code($eci,$session_token);
  $logger->debug("eci: $eci");
  $logger->debug("state: $state");
  $logger->debug("uri: $uri");
  $logger->debug("uri: $uri");
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
  my $session_token = _logged_in($session);
  if ($session_token) {
    $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($session_token);
  }
  if ($method eq 'oauth') {
    if ($ken) {
      # check for oauth token
      $logger->debug("Is logged in: $ken");
      if ($path eq "signin") {
        $logger->debug("sign_in");
        my $oauth_token = _oauth_token($ken,$params);
        if ($oauth_token) {
          $logger->debug("SI Has oauth token: $oauth_token");
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
        $logger->debug("OAuth token: $oauth_token");
        if ($oauth_token) {
          # This guy has already authorized the app
          $logger->debug("Has oauth token: $oauth_token");
          return refresh_token($oauth_token,$session_token,$params);          
        } else {
          $template->param("DIALOG" => authorize_app($ken,$params));
        }
      }
    } else {
      # not logged in
      $logger->debug("Is logged in");
      $ken = _signin($session,$params);
      if ($ken) {
        # login passed correct user/pass
        # check for oauth token
        my $oauth_token = _oauth_token($ken,$params);
        if ($oauth_token) {
          my $session_token = _logged_in($session);
          return refresh_token($oauth_token,$session_token,$params);
        } else {
          # Present the application authorize page
          $template->param("DIALOG" => authorize_app($ken,$params));          
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
        
  } elsif ($method eq 'logout') {
    if ($session_token) {
      Kynetx::Persistence::KToken::delete_token($session_token,get_session_id($session));
      my $location = _platform() . '/login';
      return $location;
    }
  } elsif ($method eq 'local') {
    if ($path eq 'auth') {
      $ken = _signin($session,$params);
      if ($ken) {
        $template->param("DIALOG" => profile_page($ken));
      } else {
        my $error = "Username/Password combination not found";
        $template->param("DIALOG" => native_login($params,$error));
      }
    } else {
      if ($ken) {
        $template->param("DIALOG" => profile_page($ken));
      } else {
        $template->param("DIALOG" => native_login($params));
      }
    }
  } else {
    if ($ken) {
      $template->param("DIALOG" => profile_page($ken));
    } else {
      $template->param("DIALOG" => native_login($params));
    }
  }
  return undef;
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
	_set_host($dialog);
}

sub authorize_app {
  my ($ken,$params) = @_;
  my $logger = get_logger();
  $logger->debug("Present authorization page: ");
  $logger->debug("Params: ", sub {Dumper($params)});
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
	_set_host($dialog);
	return $dialog->output();
  
}

sub _logged_in {
  my ($session) = @_;
  my $logger = get_logger();
  $logger->debug("get token");
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
  my $token = Kynetx::Persistence::KToken::create_token($ken,LOGIN_TAG,"KMCP",$session);
  $logger->debug("Made token: ", sub {Dumper($token)});
  return $token;  
}


sub profile_page {
  my ($ken,$error) = @_;
  my $logger = get_logger();
  $logger->debug("Profile");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/profile.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param("PLATFORM" => _platform());
	my $username = Kynetx::Persistence::KEN::get_ken_value($ken,'username');
  $dialog->param("USERNAME" => $username);
  if ($error) {
    $dialog->param("PAGEFORM" => page_error($error));
  } else {
    $dialog->param("PAGEFORM" => profile_update($ken));
  }
	
	_set_host($dialog);
	return $dialog->output();
}

sub page_error {
  my ($error) = @_;
  my $logger = get_logger();
  $logger->debug("Profile");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/error.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	$dialog->param("PLATFORM" => _platform());
  $dialog->param("ERROR_TEXT" => $error);	
	_set_host($dialog);
	return $dialog->output();
}


sub profile_update {
  my ($ken) = @_;
  my $template = DEFAULT_TEMPLATE_DIR . "/login/update_profile.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  my $email = Kynetx::Persistence::KEN::get_ken_value($ken,'email');
  my $fname = Kynetx::Persistence::KEN::get_ken_value($ken,'firstname');
  my $lname = Kynetx::Persistence::KEN::get_ken_value($ken,'lastname');
  $dialog->param("EMAIL" => $email);
  $dialog->param("FNAME" => $fname);
  $dialog->param("LNAME" => $lname);
  _set_host($dialog);
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
	_set_host($dialog);
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
	_set_host($dialog);
	my $username = $params->{'user'};
	my $password = $params->{'pass'};
	$logger->debug("User: ", $username);
	$logger->debug("Password: ",$password);
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
    $logger->debug("Uname: $username");
    my $ken = Kynetx::Modules::PCI::_username($username);
    $logger->debug("Pword: $password");    
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
	_set_host($dialog);
	$dialog->param('ECI' => $params->{'developer_eci'} );
	$dialog->param('STATE' => $params->{'client_state'} );
	$dialog->param('REDIRECT' => $params->{'uri_redirect'} );
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
    $logger->debug("token: $token");
    my $ken = Kynetx::Persistence::KEN::ken_lookup_by_token($token);
    if ($ken) {
      my $username = Kynetx::Persistence::KEN::get_ken_value($ken,"username");
      $logger->debug("ken: $ken");
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
  $logger->debug("Request: ", sub {Dumper($req)});
  return $req->param($key);  
}

sub base_login {
  my ($r) = @_;
  my $logger = get_logger();
  my $template = DEFAULT_TEMPLATE_DIR . "/Login.tmpl";
	my $login_page = HTML::Template->new(filename => $template,die_on_bad_params => 0);	
	_set_host($login_page);
	return $login_page;
}

sub _set_host {
  my ($t) = @_;
  my $logger = get_logger();
  my $host = Kynetx::Configure::get_config("EVAL_HOST");
  my $prefix;
  if (Kynetx::Configure::get_config("RUN_MODE") eq "development") {
    $prefix = "http://"
  } else {
    $prefix = "https://"
  }
  my $template_host = $prefix . $host;
	$logger->debug("Eval $template_host");
	$t->param("THOST" => $template_host);
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
  
  
  my $session_cookie =
        "SESSION_ID=$session->{_session_id};path=/;domain=" .
        Kynetx::Configure::get_config('COOKIE_DOMAIN') .
        ';expires=' . $expires; #Mon, 31-Dec-2012 00:00:00 GMT';
  $logger->debug("Sending cookie: ", $session_cookie);
  $r->err_headers_out->add('Set-Cookie' => $session_cookie);
  _add_to_info("Cookie: $session_cookie");
  return $session;
}

sub get_session_id {
  my ($session) = @_;
  if (ref $session eq "HASH") {
    return $session->{'_session_id'}
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
  my $smode;
  if ($run_mode eq "production") {
    $smode = "https://"
  } else {
    $smode = "http://";
  }
  my $dn = $smode . Kynetx::Configure::get_config('LOGIN',$run_mode);
  return $dn;
}


1;
