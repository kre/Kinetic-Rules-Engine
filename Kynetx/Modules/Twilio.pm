package Kynetx::Modules::Twilio;
# file: Kynetx/Modules/Twilio.pm
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
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Kynetx::Environments qw/:all/;
use Kynetx::Predicates::Google::OAuthHelper qw(
    get_consumer_tokens
);
use Kynetx::Directives qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use constant NAMESPACE     => "twilio";

my $predicates = {
};

my $default_actions = {
  'say' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'text'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'say',
			 $config);
               }
	   },
  'play' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'url'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'play',
			 $config);
        }
     },
  'sms' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'text'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'sms',
			 $config);
        }
	 },
  'record' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'action'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'record',
			 $config);
        }
	 },
  'hangup' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          send_directive($req_info,
			 $dd,
			 'hangup',
			 $config);
        }
	 },
  'redirect' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'url'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'redirect',
			 $config);
        }
	 },
  'reject' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          send_directive($req_info,
			 $dd,
			 'reject',
			 $config);
        }
	 },
  'pause' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'length'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'pause',
			 $config);
        }
	 },
  'gather_start' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'action'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'gather_start',
			 $config);
        }
	 },
  'gather_stop' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          send_directive($req_info,
			 $dd,
			 'gather_stop',
			 $config);
        }
	 },
  'dial' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'number'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'dial',
			 $config);
        }
	 },
  'dial_conference' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'name'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'dial_conference',
			 $config);
        }
	 },
  'dial_start' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          send_directive($req_info,
			 $dd,
			 'dial_start',
			 $config);
        }
	 },
  'dial_stop' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          send_directive($req_info,
			 $dd,
			 'dial_stop',
			 $config);
        }
     },
  'number' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'number'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'number',
			 $config);
        }
	 },
  'raw_response' => {
        directive => sub {
          my $req_info = shift;
	  my $dd = shift;
          my $config = shift;
          my $args = shift;
          $config->{'xml'} = $args->[0];
          send_directive($req_info,
			 $dd,
			 'raw_response',
			 $config);
        }
	 },

  'place_call' => {'js' => '',
	     'before' => \&do_place_call,
	     'after' => []
	     },
};

sub do_place_call {
  my ($req_info,$rule_env,$session,$config,$mods,$args,$vars)  = @_;
  my $logger = get_logger();
  my $params = {
      'Called' => $args->[0],
      'Caller' => $args->[1],
      'Url'    => $args->[2],
  };
  my $twilio_tokens =
    Kynetx::Predicates::Google::OAuthHelper::get_consumer_tokens(
    	$req_info,
    	$rule_env,
    	$session,
    	'twilio');
  my $auth_token = $twilio_tokens->{'auth_token'};
  my $account_sid = $twilio_tokens->{'account_sid'};
  my $post_url = 'https://'. $account_sid . ':' . $auth_token . '@api.twilio.com/2010-04-01/Accounts/'. $account_sid . '/Calls.json';
  $logger->debug("Twilio request: $post_url");
  my $response = mk_http_request('POST',$config->{'credentials'},$post_url,$params);
  $logger->debug("Response: ", sub {Dumper($response)});
  my $v = $vars->[0] || '__dummy';

  my $resp = {$v => {'label' => $config->{'autoraise'} || '',
             'content' => $response->decoded_content(),
             'status_code' => $response->code(),
             'status_line' => $response->status_line(),
             'content_type' => $response->header('Content-Type'),
             'content_length' => $response->header('Content-Length'),
            }
         };
  $rule_env = add_to_env($resp, $rule_env) unless $v eq '__dummy';
  my $js = '';
  if(defined $config->{'autoraise'}) {
    $logger->debug("http library autoraising event with label $config->{'autoraise'}");

    # make modifiers in right form for raise expr
    my $ms = [];
    foreach my $k (keys %{ $resp->{$v}} ) {
      push( @{$ms}, {'name' => $k,
             'value' => Kynetx::Expressions::mk_den_str($resp->{$v}->{$k}),
            })
    }

    # create an expression to pass to eval_raise_statement
    my $expr = {'type' => 'raise',
        'domain' => 'twilio',
        'rid' => $config->{'rid'},
        'event' => 'post',
        'modifiers' => $ms,
           };
    $js .= Kynetx::Postlude::eval_raise_statement($expr,
                          $session,
                          $req_info,
                          $rule_env,
                          $config->{'rule_name'});
  }
}




sub get_resources {
    return {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}


sub mk_http_request {
  my($method, $credentials, $uri, $params) = @_;

  my $logger = get_logger();

  my $ua = kynetx_ua($credentials);

  $logger->debug("Method is $method & URI is $uri");

  my $response;
  if (uc($method) eq 'POST') {
    $response = $ua->post($uri, Content=>$params);
  } elsif (uc($method) eq 'GET') {
    my $full_uri = Kynetx::Util::mk_url($uri,  $params);
    $response = $ua->get($full_uri);
  } else {
    $logger->warn("Bad method ($method) called in do_http");
    return '';
  }

  $logger->debug("Response ", sub { Dumper $response });

  return $response;
}

sub kynetx_ua {
  my $credentials = shift;
  my $ua = LWP::UserAgent->new();
  $ua->agent(Kynetx::Configure::get_config('HTTP_USER_AGENT')  || "Kynetx/1.0");
  $ua->timeout(Kynetx::Configure::get_config('HTTP_TIMEOUT')  || 5); # default limit to 5 sec
  if (defined $credentials) {
    $ua->credentials($credentials->{'netloc'},
		     $credentials->{'realm'},
		     $credentials->{'username'},
		     $credentials->{'password'});
  }
  return $ua;
}

sub run_function {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();

    my $resp = '';
    if($function eq 'get') {
      my $response = mk_http_request('GET', undef, $args->[0], $args->[1]);
      $resp = {'content' => $response->decoded_content(),
	       'status_code' => $response->code(),
	       'status_line' => $response->status_line(),
	       'content_type' => $response->header('Content-Type'),
	       'content_length' => $response->header('Content-Length'),
	      };
    } else {
      $logger->warn("Unknown function '$function' called in HTTP library");
    }

    return $resp;
}

1;
