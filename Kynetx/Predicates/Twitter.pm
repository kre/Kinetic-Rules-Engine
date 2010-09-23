package Kynetx::Predicates::Twitter;
# file: Kynetx/Predicates/Twitter.pm
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

use Log::Log4perl qw(get_logger :levels);

use Apache2::Const;

use Net::Twitter::Lite;
#use Net::Twitter::OAuth;
use Data::Dumper;




use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Util qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
authorized
authorize
eval_twitter
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use constant TWITTER_BASE_URL => 'http://twitter.com/';
use constant EXPIRE => '300'; # 300 seconds


my %predicates = (

);

sub get_predicates {
    return \%predicates;
}

my $actions = {
   'authorize' => {
       js => <<EOF,
function(uniq, cb, config) {
  \$K.kGrowl.defaults.header = "Authorize Twitter Access";
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(KOBJ_twitter_notice);
  cb();
}
EOF
       before => \&authorize
   },

};

sub get_actions {
    return $actions;
}


my $funcs = {};

sub authorized {
 my ($req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
 my $logger = get_logger();

 my $rid = $req_info->{'rid'};

 $logger->debug("Authorizing twitter access for rule $rule_name in $rid");

 my $result = 1;


# $logger->debug("Consumer tokens: ", Dumper $consumer_tokens);

 my $access_tokens = get_access_tokens($req_info, $rid, $session);

 
 if (defined $access_tokens && 
     defined $access_tokens->{'access_token'} &&
     defined $access_tokens->{'access_token_secret'}) {
   # pass the access tokens to Net::Twitter

#  $logger->debug("Validating authorization using access_token = " . $access_tokens->{'access_token'} . 
#		  " &  access_secret = " . $access_tokens->{'access_token_secret'} );


   my $nt = twitter($req_info, $session);

   # attempt to get the user's last tweet
   my $status = eval { $nt->verify_credentials() };
   if ($@ ) {
#     $logger->debug("not authorized: Dumper $status");
     $result = 0;
   } else {
#     $logger->debug("authorized: Dumper $status");
     $result = 1;
   }

 } else {
   $result = 0;
 }
 
 return $result;
 
}
$funcs->{'authorized'} = \&authorized;

sub user_id {
  my ($req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
  my $logger = get_logger();

  my $rid = $req_info->{'rid'};
  my $access_tokens =  get_access_tokens($req_info, $rid, $session);

  return $access_tokens->{'user_id'};

}
$funcs->{'user_id'} = \&user_id;

sub authorize {
 my ($req_info,$rule_env,$session,$config,$mods)  = @_;

 my $logger= get_logger();

 my $rid = $req_info->{'rid'};
 my $ruleset_name = $req_info->{"$rid:ruleset_name"};
 my $name = $req_info->{"$rid:name"};
 my $author = $req_info->{"$rid:author"};
 my $description = $req_info->{"$rid:description"};


 my $nt = twitter($req_info);

 my $base_cb_url = 'http://' . 
                   Kynetx::Configure::get_config('OAUTH_CALLBACK_HOST').
                   ':'.Kynetx::Configure::get_config('OAUTH_CALLBACK_PORT') . 
                   "/ruleset/twitter_callback/$rid?";

 my $version = $req_info->{'rule_version'} || 'prod';

 my $caller = 
 my $callback_url = mk_url($base_cb_url,
			   {'caller',$req_info->{'caller'}, 
			    "$rid:kynetx_app_version", $version});

 $logger->debug("requesting authorization URL with callback_url = $callback_url");
 my $auth_url = $nt->get_authorization_url(callback => $callback_url);
 
 session_store($rid, $session, 'twitter:token_secret', $nt->request_token_secret);


 $logger->debug("Got $auth_url ... sending user an authorization invitation");

 my $msg =  <<EOF;
<div id="KOBJ_twitter_auth">
<p>The application $name ($rid) from $author is requesting that you authorize Twitter to share your Twitter information with it.  </p>
<blockquote><b>Description:</b>$description</blockquote>
<p>
The application will not have access to your login credentials at Twitter.  If you click "Take me to Twitter" below, you will taken to Twitter and asked to authorize this application.  You can cancel at that point or now by clicking "No Thanks" below.  Note: if you cancel, this application may not work properly. After you have authorized this application, you will be redirected back to this page.
</p>
<div style="color: #000; background-color: #FFF; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"">
<a href="$auth_url">Take me to Twitter</a></div>

<div style="color: #FFF; background-color: #F33; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"" onclick="javascript:KOBJ.close_notification('#KOBJ_twitter_auth')">No Thanks!</div>
</div>
EOF

 my $js =  Kynetx::JavaScript::gen_js_var('KOBJ_twitter_notice',
		   Kynetx::JavaScript::mk_js_str($msg));

 return $js
 
}


sub process_oauth_callback {
  my($r, $method, $rid) = @_;

  my $logger = get_logger();

  # we have to contruct a whole request env and session
  my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);
  my $session = process_session($r);

  my $req = Apache2::Request->new($r);
  my $request_token = $req->param('oauth_token');
  my $verifier      = $req->param('oauth_verifier');
  my $caller        = $req->param('caller');

  $logger->debug("User returned from Twitter with oauth_token => $request_token &  oauth_verifier => $verifier & caller => $caller");

  my $nt = twitter($req_info);

  $logger->debug("Successfully created Twitter object");

  $nt->request_token($request_token);
  $nt->request_token_secret(session_get($rid, $session, 'twitter:token_secret'));


  # exchange the request token for access tokens
  my($access_token, $access_token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $verifier);

  $logger->debug("Exchanged request tokens for access tokens. access_token => $access_token & secret => $access_token_secret & user_id = $user_id & screen_name = $screen_name");

  store_access_tokens($rid, $session, 
        $access_token,
        $access_token_secret,
	$user_id,
        $screen_name
    );

  $logger->debug("redirecting newly authorized tweeter to $caller");
  $r->headers_out->set(Location => $caller);
}



my $func_name = {
		 'blocking' => {
		    "name" => "blocking" ,
		    "parameters" => [qw/page/],
		    "required" => [qw/none/],
		   },
		 'blocking_ids' => {
				    "name" => "blocking_ids" ,
				    "parameters" => [qw/none/],
				    "required" => [qw/none/],
				   },

		 'favorites' => {
				 "name" => "favorites" ,
				 "parameters" => [qw/id page/],
				 "required" => [qw/none/],
				},

		 'followers' => {
				 "name" => "followers" ,
				 "parameters" => [qw/id user_id screen_name cursor/],
				 "required" => [qw/none/],
				},

		 'followers_ids' => {
				     "name" => "followers_ids" ,
				     "parameters" => [qw/id user_id screen_name cursor/],
				     "required" => [qw/id/],
				    },

		 'friends' => {
			       "name" => "friends" ,
			       "parameters" => [qw/id user_id screen_name cursor/],
			       "required" => [qw/none/],
			      },

		 'friends_ids' => {
				   "name" => "friends_ids" ,
				   "parameters" => [qw/id user_id screen_name cursor/],
				   "required" => [qw/id/],
				  },

		 'friends_timeline' => {
					"name" => "friends_timeline" ,
					"parameters" => [qw/since_id max_id count page/],
					"required" => [qw/none/],
				       },

		 'friendship_exists' => {
					 "name" => "friendship_exists" ,
					 "parameters" => [qw/user_a user_b/],
					 "required" => [qw/user_a user_b/],
					},

		 'home_timeline' => {
				     "name" => "home_timeline" ,
				     "parameters" => [qw/since_id max_id count page/],
				     "required" => [qw/none/],
				    },

		 'mentions' => {
				"name" => "mentions" ,
				"parameters" => [qw/since_id max_id count page/],
				"required" => [qw/none/],
			       },

		 'public_timeline' => {
				       "name" => "public_timeline" ,
				       "parameters" => [qw/none/],
				       "required" => [qw/none/],
				      },

		 'rate_limit_status' => {
					 "name" => "rate_limit_status" ,
					 "parameters" => [qw/none/],
					 "required" => [qw/none/],
					},

		 'retweeted_by_me' => {
				       "name" => "retweeted_by_me" ,
				       "parameters" => [qw/since_id max_id count page/],
				       "required" => [qw/none/],
				      },

		 'retweeted_of_me' => {
				       "name" => "retweeted_of_me" ,
				       "parameters" => [qw/since_id max_id count page/],
				       "required" => [qw/none/],
				      },

		 'retweeted_to_me' => {
				       "name" => "retweeted_to_me" ,
				       "parameters" => [qw/since_id max_id count page/],
				       "required" => [qw/none/],
				      },

		 'retweets' => {
				"name" => "retweets" ,
				"parameters" => [qw/id count/],
				"required" => [qw/id/],
			       },

		 'saved_searches' => {
				      "name" => "saved_searches" ,
				      "parameters" => [qw/none/],
				      "required" => [qw/none/],
				     },

		 'sent_direct_messages' => {
					    "name" => "sent_direct_messages" ,
					    "parameters" => [qw/since_id max_id page/],
					    "required" => [qw/none/],
					   },

		 'show_friendship' => {
				       "name" => "show_friendship" ,
				       "parameters" => [qw/source_id source_screen_name target_id target_id_name/],
				       "required" => [qw/id/],
				      },

		 'show_saved_search' => {
					 "name" => "show_saved_search" ,
					 "parameters" => [qw/id/],
					 "required" => [qw/id/],
					},

		 'show_status' => {
				   "name" => "show_status" ,
				   "parameters" => [qw/id/],
				   "required" => [qw/id/],
				  },

		 'show_user' => {
				 "name" => "show_user" ,
				 "parameters" => [qw/id/],
				 "required" => [qw/id/],
				},

		 'trends_available' => {
					"name" => "trends_available" ,
					"parameters" => [qw/lat long/],
					"required" => [qw/none/],
				       },

		 'trends_location' => {
				       "name" => "trends_location" ,
				       "parameters" => [qw/woeid/],
				       "required" => [qw/woeid/],
				      },

		 'user_timeline' => {
				     "name" => "user_timeline" ,
				     "parameters" => [qw/id user_id screen_name since_id max_id count page/],
				     "required" => [qw/none/],
				    },

		 'users_search' => {
				    "name" => "users_search" ,
				    "parameters" => [qw/q per_page page/],
				    "required" => [qw/q/],
				   },

		 'search' => {
			      "name" => "search" ,
			      "parameters" => [qw/q callback lang rpp page since_id geocode show_user/],
			      "required" => [qw/q/],
			     },

		 'trends' => {
			      "name" => "trends" ,
			      "parameters" => [qw/none/],
			      "required" => [qw/none/],
			     },

		 'trends_current' => {
				      "name" => "trends_current" ,
				      "parameters" => [qw/exclude/],
				      "required" => [qw/none/],
				     },

		 'trends_daily' => {
				    "name" => "trends_daily" ,
				    "parameters" => [qw/date exclude/],
				    "required" => [qw/none/],
				   },

		 'trends_weekly' => {
				     "name" => "trends_weekly" ,
				     "parameters" => [qw/date exclude/],
				     "required" => [qw/none/],
				    },
		 'update' => {
			     "name" => "update",
			     "parameters" => [qw/status lat long place_id display_coordinates in_reply_to_status_id/],
			     "required" => [qw/status/]
			    }
};


sub eval_twitter {
  my ($req_info,$rule_env,$session,$rule_name,$function,$args)  = @_;
  my $logger = get_logger();
  $logger->debug("eval_twitter evaluation with function -> ", $function);
  my $f = $funcs->{$function};
  if (defined $f) {
    return $f->($req_info,$rule_env,$session,$rule_name,$function,$args);
  } else {

    my $nt = twitter($req_info, $session);

    my $name = $func_name->{$function}->{'name'};

    # construct the command and then get it


    my $tweets = eval {
      my $arg = '';
      if (ref $args eq 'ARRAY' && defined $args->[0]) {
	$arg = '$args->[0]';
      }
      my $command = "\$nt->$name(".$arg.");";
      $logger->debug("[eval_twitter] executing: $command");
      eval $command;
    };
  
    if ( $@ ) {
      # something bad happened; show the user the error
      if ($@ =~ /\b401\b/) {
	$logger->warn("Unauthorized access: $@");
      } elsif ($@ =~ /\b502\b/) {
	$logger->warn("Fail Whale: $@");
      } else {
	$logger->warn("$@");
      }
      $tweets = $@;
    }
#    $logger->debug("[eval_twitter] returning ", Dumper $tweets);

    return $tweets;

  }
}

sub twitter {
  my($req_info, $session) = @_;

  my $logger = get_logger();
  
  my $rid = $req_info->{'rid'};

  my $consumer_tokens=get_consumer_tokens($req_info);
#  $logger->debug("Consumer tokens: ", Dumper $consumer_tokens);
  my $nt = Net::Twitter::Lite->new(traits => [qw/API::REST OAuth/], %{ $consumer_tokens}) ;

  my $access_tokens =  get_access_tokens($req_info, $rid, $session);
  if (defined $access_tokens && 
      defined $access_tokens->{'access_token'} &&
      defined $access_tokens->{'access_token_secret'}) {

#    $logger->debug("Using access_token = " . $access_tokens->{'access_token'} . 
#		   " &  access_secret = " . $access_tokens->{'access_token_secret'} );


    $nt->access_token($access_tokens->{'access_token'});
    $nt->access_token_secret($access_tokens->{'access_token_secret'});
  }

  return $nt;

}

sub get_consumer_tokens {
  my($req_info) = @_;
  my $consumer_tokens;
  my $logger = get_logger();
  my $rid = $req_info->{'rid'};
  unless ($consumer_tokens = $req_info->{$rid.':key:twitter'}) {
    my $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $req_info);
#    $logger->debug("Got ruleset: ", Dumper $ruleset);
    $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{'twitter'};
  }
  return $consumer_tokens;
}

sub store_access_tokens {
  my ($rid, $session, $access_token, $access_token_secret, $user_id, $screen_name) = @_;

  my $r = session_store($rid, $session, 'twitter:access_tokens', {
        access_token        => $access_token,
        access_token_secret => $access_token_secret,
	user_id => $user_id,
        screen_name => $screen_name
    });

  return $r;
}

sub get_access_tokens {
  my ($req_info, $rid, $session)  = @_;

  my $consumer_tokens=get_consumer_tokens($req_info);

  my $access_tokens;
  if ($consumer_tokens->{'oauth_token'}) {
    $access_tokens = {
        access_token        => $consumer_tokens->{'oauth_token'},
        access_token_secret => $consumer_tokens->{'oauth_token_secret'},
	user_id => $consumer_tokens->{'user_id'} || '',
        screen_name => $consumer_tokens->{'screen_name'} || ''
    }
  } else {
    $access_tokens = session_get($rid, $session, 'twitter:access_tokens');
  }

  return $access_tokens;

}

1;
