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

# Note: 12 July 2017
# This is a gateway that bridged the gap between OAuth and the KRL system
# It's primary purpose was to provide the Resource Owner's hosted 'authorize' page
# as part of the OAuth dance, but as part of that. It needed to provide the login
# or 'authenticate' page for the User.
#
# The other half of the process was to collect the 'OAuth' Access Token and translate that into
# the native KRL engine KEN/Token scheme
# 
# If the token was invalid the workflow offered the choice of re-authorizing an app, performing a
# token refresh or stopping the whole process.
#
# Since this also acted as the gateway to a project we were working on, the workflow also offered 
# a plain login system to jump start the process and bring the user back into the project.
# As a cloud application engine that could host many applications by a multitude of developers
# (and a user could be subscribed to any number of these, with concurrent logins on multiple devices)
# There were a number of edge cases and ways to get into trouble.
# 
# Some of these cases we simplified out of existence and others we might have forced to work via
# some specific (or arcane) logic.  That being said, while the other files in this repo attempt to 
# hew closely to the OAuth flow, this file should be not be considered dogma and in the face of code
# that seems to be arbitrary, it may well be arbitrary--so don't panic.
# MEH

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
use Data::UUID;

use Mail::SendGrid;
use Mail::SendGrid::Transport::REST;

use Kynetx::Util;
use Kynetx::Modules::PCI;
use Kynetx::Persistence::KPDS;
use Kynetx::Memcached qw(:all);

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
  'a169x625.prod',
  'v1_wrangler.prod'
];
use constant DEFAULT_LOGO => "https://s3.amazonaws.com/Fuse_assets/img/fuse_logo-40.png";
use constant DEFAULT_FOOTER => "Pico Labs Accounts";
use constant UNKNOWN_APP_ICON => "https://s3.amazonaws.com/CloudOS_assets/unknown-app-icon.png";

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
    $logger->debug("Path info ", sub{Dumper $r->path_info()});
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
#    $logger->debug("Ken: $ken");
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
        "username" => lc($username)
      };
      my $found =  Kynetx::Persistence::KEN::ken_lookup_by_username($username)
                || Kynetx::Persistence::KEN::ken_lookup_by_username(lc($username));
      if ($found) {
        $json->{'available'} = 0
      } else {
        $json->{'available'} = 1
      }
      $logger->trace("HASH: ", sub {Dumper($json)});
      return $json;
  } elsif ($method eq 'create') {   
      $logger->debug("Creating account for ", sub{Dumper $params});
      $ken = create_account($params);
      if ($ken) {
        $template->param("DIALOG" => profile_page($ken,undef,$session_id));
        Kynetx::Persistence::KToken::delete_token($session_token,get_session_id($session));
        create_login_token($session,$ken);
      } else {
        my $error = "Unable to create account for (" . $params->{'email'} . ")";
        $template->param("DIALOG" => newaccount($params,$error));
      }
  } elsif ($method eq "forgot_password") {
    $template->param("DIALOG" => forgot_password($params));
  } elsif ($method eq "email_reset_link") {
    $template->param("DIALOG" => email_reset_link($params));
  } elsif ($method eq "reset_password") {
    $template->param("DIALOG" => reset_password($params));
  } elsif ($method eq "change_password") {
    $template->param("DIALOG" => change_password($params));
  } elsif ($method eq "deauthorize_app_confirm") {
    $template->param("DIALOG" => deauthorize_app_confirm($params));
  } elsif ($method eq "deauthorize_app") {
    my $error = deauthorize_app($ken, $params);
    $template->param("DIALOG" => profile_page($ken,$error));
  } elsif ($method eq 'logout') {
    if ($session_token) {
      Kynetx::Persistence::KToken::delete_token($session_token,get_session_id($session));
      my $location = _platform() . '/login';
#      return $location;
    }
    $template->param("DIALOG" => native_login($params));
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
#      $logger->debug("Ken: ", sub{Dumper $ken});
#      $logger->debug("List of tokens ", sub {Dumper Kynetx::Persistence::KToken::list_tokens($ken)});
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
  my $template = DEFAULT_TEMPLATE_DIR . "/login/create.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  my $eci = $params->{'developer_eci'};
  my $state = $params->{'client_state'};
  my $redirect = $params->{'uri_redirect'};
  my $base = Kynetx::Configure::get_config('oauth_server')->{'authorize'} || "oauth_not_configured";
  my $login_url = Kynetx::Util::mk_url($base, {
					       'client_id' => $eci,
					       'response_type' => 'code',
					       'state' => $state,
					       'redirect_uri' => $redirect 
					      }	
				      );
  $dialog->param('PLATFORM' => _platform());
  $dialog->param('ECI' => $eci );
  $dialog->param('STATE' =>  $state);
  $dialog->param('REDIRECT' =>  $redirect);
  $dialog->param("LOGIN_URL" => $login_url);
  $dialog->param('HIDDEN_FIELDS' => <<_EOF_
           <input type="hidden" name="developer_eci" value="$eci" >
   	   <input type="hidden" name="client_state" value="$state" >
  	   <input type="hidden" name="uri_redirect" value="$redirect" >
_EOF_
		);
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  $dialog->param('FORM_URL' => _platform() . "/login/oauth/create");
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
#    $logger->debug("params: ",sub {Dumper($params)});
    my @update_allowed = ('firstname', 'lastname', 'email');
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
      if (not has_default_ruleset($ken)) {
	  add_ruleset_to_account($ken,+DEFAULT_RULESET);	  
      }
      add_bootstrap_ruleset($ken,$developer_eci) unless (has_bootstrap_ruleset($ken,$developer_eci)) ;
  }
    
}

sub has_default_ruleset {
  my ($ken) = @_;
  my $logger = get_logger();
  my $installed = Kynetx::Persistence::KPDS::get_rulesets($ken) || [];
#  $logger->debug("Default rulesets: ", sub {Dumper(+DEFAULT_RULESET)});
#  $logger->debug("Installed: ", sub {Dumper($installed)});
  if (defined +DEFAULT_RULESET && defined $installed && scalar @{ $installed })  {
      if  (Kynetx::Sets::has($installed, +DEFAULT_RULESET)) {
	  $logger->debug("Default rulesets are installed");
	  return 1
      } else {
	  $logger->debug("Default rulesets are NOT installed");
	  return 0
      }
  } else {
      return 0;
  }
}

sub has_bootstrap_ruleset {
  my ($ken, $developer_eci) = @_;
  my $logger = get_logger();
  my $dken = Kynetx::Persistence::KEN::ken_lookup_by_token($developer_eci);
  my $list = Kynetx::Persistence::KPDS::get_bootstrap($dken,$developer_eci);
  my $installed = Kynetx::Persistence::KPDS::get_rulesets($ken) || [];
#  $logger->debug("Bootstrap rulesets: ", sub {Dumper($list)});
#  $logger->debug("Installed: ", sub {Dumper($installed)});
  if (defined $list && defined $installed && scalar @{ $installed })  {
      if  (Kynetx::Sets::has($installed,$list)) {
	  $logger->debug("Bootstrap rulesets are installed");
	  return 1
      } else {
	  $logger->debug("Bootstrap rulesets are NOT installed");
	  return 0
      }
  } else {
      return 0;
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
  my $logger = get_logger();
  $logger->debug("Installing ", sub{ Dumper $rid });
  if (ref $rid eq "ARRAY") {
    @ridlist = @{$rid};
  } else {
    push(@ridlist,$rid);
  }
  my $installed = Kynetx::Persistence::KPDS::add_ruleset($ken,\@ridlist);
  $logger->debug("Installed rulesets: ", sub{ Dumper $installed->{'value'} });
}

sub create_account {
  my ($params) = @_;
  my $logger = get_logger();
  my $username = $params->{'username'} || $params->{'email'};
  my $password = $params->{'password'};
  my $firstname = $params->{'firstname'};
  my $lastname = $params->{'lastname'};
  my $email = $params->{'email'};
  my $type = 'PCI';
  my $oid = MongoDB::OID->new();
  my $new_id = $oid->to_string();
  my $userid = Kynetx::MongoDB::counter("userid");

  $logger->trace("$username $password $email");
  if ($username && $password && $email) {
    # check username 
    my $ken =  Kynetx::Persistence::KEN::ken_lookup_by_username($username)
            || Kynetx::Persistence::KEN::ken_lookup_by_username(lc($username));
    my $hash = Kynetx::Modules::PCI::_hash_password($password);
    if ($ken) {
      $logger->warn("$username is already in use");
      return undef;
    }
    my $created = DateTime->now->epoch;

    my $dflt = {
		"username" => lc($username),
		"firstname" => $firstname,
		"lastname" => $lastname,
		"password" => $hash,
		"created" => $created,
		"email" => lc($email),
		"_id" => $oid,
		"user_id" => $userid
	       };
    $ken = Kynetx::Persistence::KEN::new_ken($dflt);
    my $neci = Kynetx::Persistence::KToken::create_token($ken,"_LOGIN",$type);
    add_ruleset_to_account($ken,+DEFAULT_RULESET);	  
    return $ken;
  } else {
    return undef;
  }
}

sub _oauth_token {
  my ($ken,$params) = @_;
  my $logger = get_logger();
#  $logger->debug("Params: ",sub {Dumper($params)});
  my $developer_eci =  $params->{'developer_eci'};
  my $etype = "OAUTH-$developer_eci";
  my $var = {
    'endpoint_type' => $etype,
    'ken' => $ken
  };
#  $logger->debug("Key: ", sub {Dumper($var)});
  my $token = Kynetx::Persistence::KToken::token_query($var);
#  $logger->debug("token: ", sub {Dumper($token)});
  if ($token) {
    return $token->{"token_name"};
  }
  return undef;
}

sub _active_oauth_apps {
  my ($ken) = @_;
  my $logger = get_logger();
  my $var = {
    'endpoint_type' => qr/^OAUTH-.+/,
    'ken' => $ken
  };
#  $logger->debug("Key: ", sub {Dumper($var)});
  my $tokens = Kynetx::Persistence::KToken::get_all_tokens($var);

  my ($by_deci, $by_ktoken);
  for my $t (@{$tokens}) {
#      $logger->debug("Token ", sub {Dumper $t});
      if (! defined $by_deci->{$t->{"endpoint_type"}}  || 
	  $by_deci->{$t->{"endpoint_type"}}->{"created"} < $t->{"created"})
	{
	  $by_deci->{$t->{"endpoint_type"}} = $t;
      }
  }

  my $result;
  for my $deci (keys %{$by_deci}) {
      my $dk = $deci;
      $deci =~ s/^OAUTH-(.+)$/$1/;
      my $d_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($deci);
      my $callbacks = Kynetx::Persistence::KPDS::get_callbacks($d_ken,$deci);
      my $boostraps = Kynetx::Persistence::KPDS::get_bootstrap($d_ken,$deci);
      my $appinfo = Kynetx::Persistence::KPDS::get_app_info($d_ken,$deci);
      push(@{$result}, {"developer_eci" => $deci,
			"app_info" => $appinfo,
			"boostrap_rids" => $boostraps,
			"callbacks" => $callbacks,
			"token_name" => $by_deci->{$dk}->{"token_name"},
			"created" => $by_deci->{$dk}->{"created"},
			"last_active" => $by_deci->{$dk}->{"last_active"},
			"ktoken" => $by_deci->{$dk}->{"ktoken"},
			"endpoint_id" => $by_deci->{$dk}->{"endpoint_id"},
		       });
  }

  #$logger->debug("Result: ", sub{Dumper $result});

  if ($result) {
    return $result;
  }
  return undef;
}

sub delete_oauth_app {
  my ($ken, $developer_eci) = @_;
  my $logger = get_logger();

  $logger->debug("Deleting tokens for $developer_eci");

  my $var = {
    'endpoint_type' => qr/^OAUTH-.+/,
    'ken' => $ken
  };
  $logger->debug("Key: ", sub {Dumper($var)});
  my $tokens = Kynetx::Persistence::KToken::get_all_tokens($var);

  $developer_eci = "OAUTH-" . $developer_eci unless $developer_eci =~ m/^OAUTH-/;

  my $count = 0;
  for my $t (@{$tokens}) {
      $logger->debug("Seeing this token info ", sub {Dumper $t});
      if ($t->{"endpoint_type"} eq $developer_eci ) {
	  Kynetx::Persistence::KToken::delete_token($t->{"ktoken"});
	  $count++;
      }
  }

  $logger->debug("Deleted ($count) tokens for $developer_eci");
}


sub newaccount {
  my ($params, $error) = @_;
  my $logger = get_logger();
  $logger->debug("New account page: ");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/create.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);

  if ($error) {
      my $error_msg = '<strong>' . $error . '</strong>';
      $logger->debug("returning newaccount page with error ", $error_msg);
      $dialog->param("ERROR_MSG" => $error_msg);
      $dialog->param("DISPLAY_ERROR" => 1);
  }

  $dialog->param('PLATFORM' => _platform());
  $dialog->param('HIDDEN_FIELDS' => "");
  $dialog->param('LOGIN_URL' => _platform() . "/login");
  $dialog->param('FORM_URL' => _platform() . "/login/create");
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);


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
  my $username =   lc(Kynetx::Persistence::KEN::get_ken_value($ken,'username'));              
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
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  return $dialog->output();
  
}

sub _logged_in {
  my ($session) = @_;
  my $logger = get_logger();
#  $logger->debug("get token for ", sub { Dumper $session } );
  my $token = Kynetx::Persistence::KToken::get_token($session,undef,"web");
  #$logger->debug("get token: ", sub {Dumper($token)});
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
  my $token = Kynetx::Persistence::KToken::create_token($ken,LOGIN_TAG, 'OAUTH',$session);
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
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  my $username = lc(Kynetx::Persistence::KEN::get_ken_value($ken,'username'));
  $dialog->param("USERNAME" => $username);
  $dialog->param("PAGEFORM" => profile_update($ken,$session_id,$error));
  $dialog->param('PLATFORM' => _platform());
  my $apps = _active_oauth_apps($ken);
  my @app_info_list;
  for my $app_info (@{$apps}) {
      push @app_info_list, {app_info_icon => $app_info->{"app_info"}->{"icon"} || UNKNOWN_APP_ICON,
			    app_info_name  => $app_info->{"app_info"}->{"name"} || "unknown",
			    app_info_description  => $app_info->{"app_info"}->{"description"} || "",
			    last_active  => DateTime->from_epoch(epoch => $app_info->{"last_active"})->strftime("%a, %d-%b-%Y 23:59:59 GMT") || "",
			    last_active_raw => $app_info->{"last_active"},
			    eci => $app_info->{"ktoken"},
			    eci_name => $app_info->{"token_name"},
			    developer_eci => $app_info->{"developer_eci"},
			   }
  }
  my @sorted_app_info_list  = sort {$b->{last_active_raw} cmp $a->{last_active_raw}}  @app_info_list;   
  # $logger->debug("Sorted list: ", sub { Dumper @sorted_app_info_list});
  $dialog->param('APP_LIST' => \@sorted_app_info_list);
  return $dialog->output();
}

sub deauthorize_app_confirm {
  my ($params,$error) = @_;

  my $logger = get_logger();

  my $template = DEFAULT_TEMPLATE_DIR . "/login/deauthorize_app_confirm.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  my $platform =  _platform();
  my $deci = $params->{"developer_eci"};
  my $ain = $params->{"app_info_name"};

#  $logger->debug("Params in deauthorize_app_confirm() ", sub {Dumper $params});


  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);

  $dialog->param('APP_INFO_NAME' => $ain);
  $dialog->param('HIDDEN_FIELDS' => <<_EOF_
<input type="hidden" name="developer_eci" value="$deci" >
<input type="hidden" name="app_info_name" value="$ain" >
_EOF_
                );

  $dialog->param("FORM_URL" => "$platform/login/deauthorize_app");

  return $dialog->output();
}

sub deauthorize_app {
  my ($ken, $params,$error) = @_;

  my $logger = get_logger();
#  $logger->debug("Params in deauthorize_app ", sub {Dumper $params});

  delete_oauth_app($ken, $params->{"developer_eci"});

  my $msg = "<p>Application " . $params->{"app_info_name"} . " has been deauthorized</p>";

  my $new_error = <<_EOF_;
$error $msg
_EOF_

  return $new_error;

}

# not used...
sub page_error {
  my ($error) = @_;
  my $logger = get_logger();
  $logger->trace("Profile");
  my $template = DEFAULT_TEMPLATE_DIR . "/login/error.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  $dialog->param("PLATFORM" => _platform());
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  $dialog->param("ERROR_TEXT" => $error);	
  $dialog->param('PLATFORM' => _platform());
  return $dialog->output();
}


sub profile_update {
  my ($ken,$session_id,$error) = @_;
  my $template = DEFAULT_TEMPLATE_DIR . "/login/update_profile.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  my $email = Kynetx::Persistence::KEN::get_ken_value($ken,'email');
  my $fname = Kynetx::Persistence::KEN::get_ken_value($ken,'firstname');
  my $lname = Kynetx::Persistence::KEN::get_ken_value($ken,'lastname');
  if ($session_id) {
    $dialog->param('L_SESSION' => $session_id)
  }
  $dialog->param("EMAIL" => $email); 
  $dialog->param("FNAME" => $fname);
  $dialog->param("LNAME" => $lname);
  $dialog->param('PLATFORM' => _platform());
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  $dialog->param("ERROR_MSG" => $error);

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
  $dialog->param('FORM_URL' => _platform() . "/login/local/auth");
  $dialog->param('HIDDEN_FIELDS' => "");
  $dialog->param('CREATE_URL' => _platform() . "/login/newaccount");
  $dialog->param("FORGOT_URL" => _platform() . "/login/forgot_password");
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  return $dialog->output();
}

sub forgot_password {
  my ($params,$error) = @_;
  my $template = DEFAULT_TEMPLATE_DIR . "/login/forgot_password.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  $dialog->param("PLATFORM" => _platform());
  if ($error) {
      my $error_msg = '<strong>' . $error . '</strong>';
      $dialog->param("LOGIN_ERROR" => $error_msg);
      my $username = $params->{'user'};
  }

  # my $email = Kynetx::Persistence::KEN::get_ken_value($ken,'email');
  # my $n = 2;
  # # replace all but the first n and last n chars (ignoring domain name) with *
  # $email =~ s/^(.{$n})(.*)@(.*)(.{$n})\.(.+)$/$1."*" x length($2)."@". "*" x length($3) . $4. "." . $5/e;


  $dialog->param('LOGIN_URL' => _platform() . "/login");
  $dialog->param('FORM_URL' => _platform() . "/login/email_reset_link");
  $dialog->param('HIDDEN_FIELDS' => "");
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  return $dialog->output();
}

sub email_reset_link {
  my ($params,$error) = @_;

  my $logger = get_logger();

  my $template = DEFAULT_TEMPLATE_DIR . "/login/login_message.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  my $platform =  _platform();
  my $acct_system_owner_email =  Kynetx::Configure::get_config('ACCT_SYSTEM_OWNER_EMAIL') || 'noreply@kynetx.com';


  my $reset_email = $params->{'reset-email'};
  $logger->debug("Seeing ", sub{Dumper $reset_email});
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
  $dialog->param('MSG' => <<_EOF_);
<p>Your reset link has been sent to</p>
<p><code>$reset_email</code></p>
<p>The message will come from <code>$acct_system_owner_email</code>. It may end up in your SPAM folder.</p>
<p>(<a href="$platform/login/forgot_password">send again</a>)
_EOF_

  # put all the checking, etc. here...
  my $ken =  Kynetx::Persistence::KEN::ken_lookup_by_email($reset_email) 
          || Kynetx::Persistence::KEN::ken_lookup_by_email(lc($reset_email));
  $logger->debug("Ken: ", $ken);
  if ($ken) { # account exists
      my $ug = new Data::UUID;
      my $key = $ug->create_str();
      my $memd = get_memd();
      my $reset_obj = {"timestamp" => time, 
		       "email" => lc($reset_email), 
		       "ken" => $ken,
		       "key" => $key
		      };
      
      $logger->debug("Reset obj: ", sub { Dumper $reset_obj });
      $memd->set($key, $reset_obj);

      my $acct_system_owner =  Kynetx::Configure::get_config('ACCT_SYSTEM_OWNER') || "Kynetx";
      my $acct_system_owner_email =  Kynetx::Configure::get_config('ACCT_SYSTEM_OWNER_EMAIL') || 'noreply@kynetx.com';

      my $password_reset_link = "$platform/login/reset_password?key=$key";

      my $msg = <<_EOF_;
Someone (hopefully you) has requested a password reset from $acct_system_owner. 

To reset your password, click on the following link:

$password_reset_link

If you did not request a password reset from $acct_system_owner, please ignore this message. 
_EOF_

      $reset_email =~ s/\+/%2B/g;
      my $sg = Mail::SendGrid->new( from => $acct_system_owner_email,
				    to => lc($reset_email),
				    subject => "Reset your $acct_system_owner password",
				    text => $msg,
				  );

      #disable click tracking filter for this request
      $sg->disableClickTracking();

      #set a category
      $sg->header->setCategory('password_reset');

      #add unique arguments
      $sg->header->addUniqueIdentifier( customer => $key );

      $logger->debug("un/password: /", Kynetx::Configure::get_config('SENDGRID_USERNAME'), "/", Kynetx::Configure::get_config('SENDGRID_PASSWORD'), "/");

      my $trans = Mail::SendGrid::Transport::REST->new( username =>  Kynetx::Configure::get_config('SENDGRID_USERNAME'), 
							password =>  Kynetx::Configure::get_config('SENDGRID_PASSWORD') );

      my $error = $trans->deliver($sg);
      if ($error) {
	  $logger->debug("Sendgrid error in password reset for $reset_email:" , $error);
	  $dialog->param('MSG' => <<_EOF_);
<h3>Something went wrong! </h3>
<p>We were unable to send an email to <code>$reset_email</code>.</p>
<p>(<a href="$platform/login/forgot_password">Try again</a>)
_EOF_

      }

  }

  return $dialog->output();
}

sub reset_password {
  my ($params,$error) = @_;

  my $logger = get_logger();

  my $key = $params->{'key'};
  $logger->debug("Seeing ", sub{Dumper $key});
  my $memd = get_memd();
  my $reset_obj = $memd->get($key);
  $logger->debug("Reset obj: ", sub { Dumper $reset_obj });

  my $dialog;
  if (! defined $reset_obj || _reset_expired($reset_obj) ) {

      my $template = DEFAULT_TEMPLATE_DIR . "/login/login_message.tmpl";
      $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);

      my $forgot_url = _platform() . "/login/forgot_password";
      $dialog->param('MSG' => <<_EOF_);
<p>Your password was <strong>not reset</strong> because the reset link is expired.</p>
<p>Please <a href="$forgot_url">try again</a></p>
_EOF_

  } else {
      my $template = DEFAULT_TEMPLATE_DIR . "/login/reset_password.tmpl";
      $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);

      my $platform =  _platform();
      $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
      $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
      $dialog->param('FORM_URL' => "/login/change_password");
      $dialog->param('LOGIN_URL' => _platform() . "/login");

      $dialog->param('HIDDEN_FIELDS' => <<_EOF_
<input type="hidden" name="key" value="$key" >
_EOF_
		    );
  }
  return $dialog->output();

}

sub change_password {
  my ($params,$error) = @_;

  my $logger = get_logger();

  my $template = DEFAULT_TEMPLATE_DIR . "/login/login_message.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  my $platform =  _platform();

  my $login_url = _platform() . "/login/";
  my $forgot_url = _platform() . "/login/forgot_password";
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);

  my $key = $params->{'key'};
  my $p1 = $params->{'password'};
  my $p2 = $params->{'re-enter-password'};
  $logger->debug("Got: ", $key, ":", $p1, ":", $p2 );
  
  my $memd = get_memd();
  my $reset_obj = $memd->get($key);
  $logger->debug("Reset obj: ", sub { Dumper $reset_obj });
  
      # my $reset_obj = {"timestamp" => time, 
      # 		       "email" => $reset_email, 
      # 		       "ken" => $ken,
      # 		       "key" => $key
      # 		      };
      

  if (_reset_expired($reset_obj) ) {
      $dialog->param('MSG' => <<_EOF_);
<p>Your password was <strong>not reset</strong> because the reset link is expired.</p>
<p>Please <a href="$forgot_url">try again</a></p>
_EOF_
  } elsif ($p1 ne $p2) {
      $dialog->param('MSG' => <<_EOF_);
<p>Your password was <strong>not reset</strong> because the passwords you supplied did not match.</p>
<p>Please <a href="$forgot_url">try again</a></p>
_EOF_
  } else {

      my $ken = $reset_obj->{"ken"};
      my $res = Kynetx::Modules::PCI::set_password($ken, $p1);
      $memd->delete($key); # you can only use it once
      $logger->debug("Set password returned ", $res);
      $dialog->param('MSG' => <<_EOF_);
<p>Your password has been reset</p>
<p>Please <a href="$login_url">login</a></p>
_EOF_
      
  }

  return $dialog->output();
}

sub _reset_expired {
  my ($reset_obj) = @_;
  my $expire_seconds = 3600; # one hour
  return time > ($reset_obj->{"timestamp"} + $expire_seconds)
}

sub oauth_code {
  my ($d_eci, $user_eci) = @_;
  my $d_ken = Kynetx::Persistence::KEN::ken_lookup_by_token($d_eci);
  my $secret = Kynetx::Persistence::KPDS::get_developer_secret($d_ken,$d_eci);
  my $code = Kynetx::Modules::PCI::_construct_oauth_code($d_eci,$secret,$user_eci);
  return $code;
}


sub _validate_password {
  my ($username,$password) = @_;
  my $logger = get_logger();
  if ($username) {
    $logger->trace("Uname: $username");
    my $ken =  Kynetx::Modules::PCI::_username($username) 
            || Kynetx::Modules::PCI::_username(lc($username));
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
#	$logger->debug("Password: ",$password);
	my $ken = _validate_password($username,$password);
	if ($ken) {
	  #$logger->debug("Found user ken ($ken)");
	  create_login_token($session,$ken);
	  return $ken;
	} else {
	  return undef;
	}
}


sub oauth_login_page {
  my ($params,$error) = @_;
  my $logger = get_logger();
  my $template = DEFAULT_TEMPLATE_DIR . "/login/native_login.tmpl";
  my $dialog = HTML::Template->new(filename => $template,die_on_bad_params => 0);
  $dialog->param('PLATFORM' => _platform());
  $dialog->param('ECI' => $params->{'developer_eci'} );
  $dialog->param('STATE' => $params->{'client_state'} );
  $dialog->param('REDIRECT' => $params->{'uri_redirect'} );
  my $eci = $params->{'developer_eci'};
  my $state = $params->{'client_state'};
  my $redirect = $params->{'uri_redirect'};
      

  $dialog->param('HIDDEN_FIELDS' => <<_EOF_
           <input type="hidden" name="developer_eci" value="$eci" >
   	   <input type="hidden" name="client_state" value="$state" >
  	   <input type="hidden" name="uri_redirect" value="$redirect" >
_EOF_
		);
  $dialog->param('FORM_URL' => _platform() . "/login/oauth/signin");
  my $base = Kynetx::Configure::get_config('oauth_server')->{'authorize'} || "oauth_not_configured";
  $base .= '/newuser';
  my $create_url = Kynetx::Util::mk_url($base, {
						'client_id' => $eci,
						'response_type' => 'code',
						'state' => $state,
						'redirect_uri' => $redirect 
					       }	
				       );
  $dialog->param("CREATE_URL" => $create_url);
  $dialog->param("FORGOT_URL" => _platform() . "/login/forgot_password");
  $dialog->param('LOGO_IMG_URL' => DEFAULT_LOGO);
  $dialog->param('FOOTER_TEXT' => DEFAULT_FOOTER);
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
  my $found =  Kynetx::Persistence::KEN::ken_lookup_by_username($username)
            || Kynetx::Persistence::KEN::ken_lookup_by_username(lc($username));
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
