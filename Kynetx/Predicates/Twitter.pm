package Kynetx::Predicates::Twitter;
# file: Kynetx/Predicates/Twitter.pm
# file: Kynetx/Predicates/Referers.pm
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

use Net::Twitter;
use Data::Dumper;


use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_predicates
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my %predicates = (
);

sub get_predicates {
    return \%predicates;
}

#sub twitter { shift->{twitter} ||= Net::Twitter->new(traits => [qw/API::REST OAuth/], %consumer_tokens) }

sub authorized {
 my ($req_info,$rule_env,$session)  = @_;


 my $logger->get_logger();

 my $rid = $req_info-{'rid'};

 my $result = 1;

 my $consumer_tokens = $req_info->{'key:twitter'};
 my $nt = Net::Twitter->new(traits => [qw/API::REST OAuth/], %{ $consumer_tokens}) ;

 my $access_tokens = session_get($rid, $session, 'twitter:access_tokens');
 
 if (defined $access_tokens) {
   # pass the access tokens to Net::Twitter
    $nt->access_token($access_tokens->{'access_token'});
    $nt->access_token_secret($access_tokens->{'access_token_secret'});

    # attempt to get the user's last tweet
    my $status = eval { $nt->user_timeline({ count => 1 }) };
    if ( $@ ) {
      $result = 0;
    } else {
      $result = 1;
    }

 } else {
   $result = 0;
 }
 
 return $result;
 
}

sub authorize {
 my ($req_info,$rule_env,$session,$config,$mods)  = @_;

 my $logger->get_logger();

 my $rid = $req_info-{'rid'};
 my $ruleset_name = $req_info->{"$rid:ruleset_name"};
 my $name = $req_info->{"$rid:name"};
 my $author = $req_info->{"$rid:author"};
 my $description = $req_info->{"$rid:description"};

 my $consumer_tokens = $req_info->{'key:twitter'};
 my $nt = Net::Twitter->new(traits => [qw/API::REST OAuth/], %{ $consumer_tokens}) ;

 my $self; #what is this really?

 $logger->debug("requesting authorization URL");
 my $auth_url = $self->twitter->get_authorization_url(callback => Kynetx::Configure::get_config('EVAL_SERVER')."/rulesets/twitter_callback/$rid?caller=$req_info->{'caller'}");


 $logger->debug("Got $auth_url; sending use a authorization invitation");

 my $js =  <<EOF;
my KOBJ_twitter_notice = '<div id="KOBJ_twitter_auth">
<p>The application $name ($rid) from $author is requesting that you authorize Twitter to share your Twitter information with it.  </p>
<blockquote><b>Description:</b>$description</blockquote>
<p>
The application will not have access to your login credentials at Twitter.  If you click "OK" below, you will taken to Twitter and asked to authorize this application.  You can cancel at that point or by clicking "Close" below.  Note: if you choose not to proceed, this application may not work properly. After you have authorized this application, you will be redirected back to this page.
</p>
<p align="center">
<a href="$auth_url">OK</a> <span class="">Close</span>
</p>
</div>';
EOF

 return $js;
 
}

sub process_oauth_callback {
  my($r, $method, $rid) = @_;

  my $logger->get_logger();

  # we have to contruct a whole request env and session
  my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);
  my $ruleset = Kynetx::Rules::get_rules_from_repository($rid, $req_info);
  my $session = process_session($r);

  my $req = Apache2::Request->new($r);
  my $request_token = $req->param('oauth_token');
  my $verifier      = $req->param('oauth_verifier');
  my $caller        = $req->param('caller');

  $logger->debug("User returned from Twitter with oauth_token => $request_token &  oauth_verifier => $verifier & caller => $caller");

  my $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{'twitter'};
  my $nt = Net::Twitter::OAuth->new(traits => [qw/API::REST OAuth/], %{$consumer_tokens});

  # exchange the request token for access tokens
  my($access_token, $access_token_secret, $user_id, $screen_name) = $nt->request_access_token(verifier => $verifier);

  $logger->debug("Exchanged request tokens for access tokens. access_token => $access_token & secret => $access_token_secret & user_id = $user_id & screen_name = $screen_name");

  session_store($rid, $session, 'twitter:access_tokens', {
        access_token        => $access_token,
        access_token_secret => $access_token_secret,
	user_id => $user_id,
        screen_name => $screen_name
    });

  $logger->debug("redirecting newly authorized tweeter to $caller");
  $r->headers_out->set(Location => $caller);
  return Apache2::Const::REDIRECT;
}

1;
