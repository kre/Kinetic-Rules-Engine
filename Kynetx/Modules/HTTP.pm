package Kynetx::Modules::HTTP;
# file: Kynetx/Modules/HTTP.pm
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

use URI::Escape;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Kynetx::Environments qw/:all/;
use Kynetx::Parser qw/mk_expr_node/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my $predicates = {
};

my $default_actions = {
  'post' => {'js' => '',
	     'before' => \&do_post,
	     'after' => []
	     },
  'get' => {'js' => '',
	     'before' => \&do_get,
	     'after' => []
	     },
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


sub do_get {
  my ($req_info,$rule_env,$session,$config,$mods,$args,$vars)  = @_;
  my $logger = get_logger();
  $logger->debug("As Action");
  return do_http('GET',$req_info,$rule_env,$session,$config,$mods,$args,$vars);

}

sub do_post {
  my ($req_info,$rule_env,$session,$config,$mods,$args,$vars)  = @_;
  return do_http('POST',$req_info,$rule_env,$session,$config,$mods,$args,$vars);
}

sub do_http {

  my ($method, $req_info,$rule_env,$session,$config,$mods,$args,$vars)  = @_;

  my $logger = get_logger();


  my $response = mk_http_request($method,
				 $config->{'credentials'},
				 $args->[0],
				 $config->{'params'} || $config->{'body'},
				 $config->{'headers'},
				);

  my $v = $vars->[0] || '__dummy';

  my $resp = {$v => {'label' => $config->{'autoraise'} || '',
		     'content' => $response->decoded_content(),
		     'status_code' => $response->code(),
		     'status_line' => $response->status_line(),
		     'content_type' => $response->header('Content-Type'),
		     'content_length' => $response->header('Content-Length') || 0,
		    }
	     };

  if (defined $config->{'response_headers'}) {
    foreach my $h (@{ $config->{'response_headers'} } ) {
      $resp->{$v}->{lc($h)} = $response->header(uc($h));
    }
  }
  $logger->trace("KRL response ", sub { Dumper $resp });

  my $r_status;
  if ($resp) {
  	$r_status = $resp->{'__dummy'}->{'status_line'};
  }
  $logger->debug("Response status: ", sub { Dumper $r_status });

  # side effect rule env with the response
  # should this be a denoted value?
  $rule_env = add_to_env($resp, $rule_env) unless $v eq '__dummy';

#  $logger->debug("Rule Env ", sub { Dumper $rule_env });


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
		'domain' => 'http',
		'rid' => $config->{'rid'},
		'event' => mk_expr_node('str',lc($method)),
		'modifiers' => $ms,
	       };
    $js .= Kynetx::Postlude::eval_raise_statement($expr,
						  $session,
						  $req_info,
						  $rule_env,
						  $config->{'rule_name'});
  }
}

sub mk_http_request {
  my($method, $credentials, $uri, $params, $headers) = @_;

  my $logger = get_logger();

  my $ua = kynetx_ua($credentials);


  $logger->debug("Method is $method & URI is $uri");

  my $req;
  my $response;
  if (uc($method) eq 'POST') {

    $req = new HTTP::Request 'POST', $uri;

#    $response = $ua->post($uri);

    my $content;
    if (defined $headers->{'content-type'}) {
      $content = $params;
      $req->header('content-type' => $headers->{'content-type'});
    } else {
      $content = join('&', map("$_=".uri_escape_utf8($params->{$_}), keys %{ $params }));
      $logger->debug("Encoded content: $content");
      $req->header('content-type' => "application/x-www-form-urlencoded");
       
    }


    $req->content($content);
    $req->header('content-length' => length($content));

  } elsif (uc($method) eq 'GET') {
    my $full_uri = Kynetx::Util::mk_url($uri,  $params);
    $req = new HTTP::Request 'GET', $full_uri;
    $response = $ua->get($full_uri, $headers);
    $logger->debug("http:get (uri): ", $full_uri);

  } else {
    $logger->warn("Bad method ($method) called in do_http");
    return '';
  }

  $logger->trace("Headers ", Dumper $headers);

  foreach my $k (keys %{ $headers }) {
  	$logger->trace("HKey: $k", " => ",$headers->{$k});
    $req->header($k => $headers->{$k});
  }

  $logger->trace("Request ", Dumper $req);

  $response = $ua->request($req);

  # $logger->debug("Vars ", sub { Dumper $vars });
  # $logger->debug("Mods ", sub { Dumper $mods });
  # $logger->debug("Config ", sub { Dumper $config });
  # $logger->debug("Response ", sub { Dumper $response });

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
	my($credentials, $uri, $params, $headers,$rheaders);
    my $logger = get_logger();

    my $resp = '';
    if($function eq 'get') {
      $uri = $args->[0];
      $params = $args->[1];
      $headers = $args->[2];
      $rheaders = $args->[3];
      $credentials = undef;
	  if (defined $args->[1] && ref $args->[1] eq "HASH"){
	  	$logger->trace("Second arg to http:get hash, Check for named arguments");
	  	$params = $args->[1]->{'params'} || $params;
	  	$headers = $args->[1]->{'headers'} || $headers;
	  	$credentials = $args->[1]->{'credentials'} || $credentials;
	  	$rheaders = $args->[1]->{'response_headers'} || $rheaders;	  	
	  }
#	  $logger->debug("Params: ", sub {Dumper($params)});
#	  $logger->debug("Headers: ", sub {Dumper($headers)});
#	  $logger->debug("Credentials: ", sub {Dumper($credentials)});
#	  $logger->debug("Response Headers: ", sub {Dumper($rheaders)});
      my $response = mk_http_request('GET', $credentials, $uri, $params, $headers);
      $resp = {'content' => $response->decoded_content() || '',
	       'status_code' => $response->code() || '',
	       'status_line' => $response->status_line() || '',
	       'content_type' => $response->header('Content-Type') || '',
	       'content_length' => $response->header('Content-Length') || '',
	      };

      if (defined $rheaders) {
	foreach my $h (@{ $rheaders } ) {
	  $resp->{lc($h)} = $response->header(uc($h));
	}
      }

    } else {
      $logger->warn("Unknown function '$function' called in HTTP library");
    }

    return $resp;
}

1;
