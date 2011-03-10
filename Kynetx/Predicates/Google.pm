package Kynetx::Predicates::Google;

# file: Kynetx/Predicates/Google.pm
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
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;

use Kynetx::OAuth;
use Kynetx::Util;
use Kynetx::Configure;
use Kynetx::Memcached;
use Kynetx::Predicates::Google::OAuthHelper qw(get_authorization_message
          get_tokens_by_oauth_token
          get_token
          get_scope_from_token
          store_token
          set_auth_tokens
          get_access_tokens
          get_protected_resource
          trim_tokens
          blast_tokens
          post_protected_resource
);
use Kynetx::Predicates::Google::Calendar;
use Kynetx::Session qw(
    process_session
    session_cleanup
);

use LWP::UserAgent;
use URI::Escape;
use DateTime;
use DateTime::Format::RFC3339;
use DateTime::Format::ISO8601;
use Encode;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          process_oauth_callback
          get_arg_hash
          get_params
          eval_google
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
use constant NAMESPACE => "google";

my $tmp           = Kynetx::Configure::get_config('GOOGLE');
my $google_config = $tmp->{'google'};

my %predicates = ();

my $actions = {
    'authorize' => {
        js => <<EOF,
function(uniq, cb, config) {
  \$K.kGrowl.defaults.header = "Authorize Google Access";
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(KOBJ_google_notice);
  cb();
}
EOF
        before => \&authorize
    },

};

sub get_actions {
    return $actions;
}

sub get_predicates {
    return \%predicates;
}

my $funcs = {};

sub authorize {
    my ( $req_info, $rule_env, $session, $config, $mods, $args ) = @_;
    my $rid       = $req_info->{'rid'};
    my $logger    = get_logger();
    my $version   = $req_info->{'rule_version'} || 'prod';
    my $scope     = get_google_scope($args);
    my $endpoints = get_google_endpoints($scope);

    my $auth_url =
      get_authorization_message( $req_info, $rule_env, $session,   $args,
                                 'google',  $endpoints, $scope );

    my ( $divId, $msg ) = google_msg( $req_info, $scope, $auth_url );

    my $js =
      Kynetx::JavaScript::gen_js_var( $divId,
                                      Kynetx::JavaScript::mk_js_str($msg) );
    return $js;

}

sub authorized {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->debug( "Args: ",          sub { Dumper($args) } );
    my $rid    = $req_info->{'rid'};
    my $scope  = get_google_scope($args);
    $logger->trace( "Session tokens: ", sub { Dumper($session) } );
    $logger->debug( "Scope: ",          sub { Dumper($scope) } );
    my $access_token =
      get_token( $rid, $session, 'access_token', NAMESPACE, $scope );
    if ($access_token) {
        $logger->debug( "Found Access Token for: ",
                        NAMESPACE, " ", $scope->{'dname'} );
        my $treq = test_request( $req_info, $rule_env, $session, $scope );
        if ( $treq->is_success() ) {
            $logger->debug( "Authorized request for ",
                            NAMESPACE, " ", $scope->{'dname'}, ' (',
                            $treq->status_line, ')' );
            return 1;
        } else {
            $logger->warn( "Authorized request failed: ", $treq->message );
        }

    } else {
        $logger->debug( "No access token found for ",
                        NAMESPACE, " ", $scope->{'dname'} );
    }
    blast_tokens( $rid, $session, NAMESPACE, $scope );
    return 0;
}
$funcs->{'authorized'} = \&authorized;

sub get {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    my $scope  = get_google_scope($args);
    my $common = $google_config->{'params'}->{'common'};
    my $gparm;
    $gparm = get_params( $args, $gparm, $common );
    my $url = build_url( $req_info, $rule_env, $args, $gparm, $scope,'GET' );
    my $resp =
      get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url, $scope );
    return eval_response($resp);
}
$funcs->{'get'} = \&get;

sub raw_get {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    my $scope  = get_google_scope($args);
    my $scope_url;
    if ( $scope->{'surl'} ) {
        $scope_url = $scope->{'surl'};
    } else {
        $scope_url = $scope->{'url'};
    }
    my $uri = URI->new($args->[1]);
    if ( $uri =~ m/^$scope_url/ ) {
        $logger->debug("Scopes match");

        my $resp =
            get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $uri->as_string(), $scope );
        return $resp->content;
    } else {
        $logger->warn("Not authorized for scope: ",$scope->{'dname'});
    }

}
$funcs->{'rget'} = \&raw_get;

sub add {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    my $scope  = get_google_scope($args);
    my $scope_url;
    if ( $scope->{'surl'} ) {
        $scope_url = $scope->{'surl'};
    } else {
        $scope_url = $scope->{'url'};
    }
    my $common = $google_config->{'params'}->{'common'};
    my $gparm;
    $gparm = get_params( $args, $gparm, $common );
    my $url = build_url( $req_info, $rule_env, $args, $gparm, $scope,'POST' );
    my $content = build_post_content( $req_info, $rule_env, $args, $gparm, $scope );
    my $resp =
      post_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $scope, $url,$content );
    return eval_response($resp);

}
$funcs->{'add'} = \&add;

sub eval_google {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->debug( "eval_google evaluation with function -> ", $function );
    my $f = $funcs->{$function};
    if ( defined $f ) {
        return $f->( $req_info, $rule_env, $session, $rule_name, $function,
                     $args );
    } else {
        $logger->debug("Function $function not defined");
    }

}

sub eval_response {
    my ($resp) = @_;
    my $logger = get_logger();
    if ( $resp->is_success ) {
        my $ast = eval { Kynetx::Json::jsonToAst( $resp->content ) };
        if ($@) {
            $logger->debug("Invalid JSON format: ", sub {Dumper($@)});
            return $resp->content;
        }
        return $ast;
    } else {
        $logger->warn( "Protected resource request: ", $resp->status_line );
        return '';
    }

}

sub get_consumer_tokens {
    my ($req_info, $rule_env) = @_;
    my $consumer_tokens;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    unless ( $consumer_tokens = Kynetx::Keys::get_key($req_info, $rule_env, 'google')  ) {
        my $ruleset =
          Kynetx::Repository::get_rules_from_repository( $rid, $req_info );

        #    $logger->debug("Got ruleset: ", Dumper $ruleset);
        $consumer_tokens = $ruleset->{'meta'}->{'keys'}->{'google'};
	Kynetx::Keys::insert_key($req_info, $rule_env, 'google', $consumer_tokens);

    }
    return $consumer_tokens;
}

sub process_oauth_callback {
    my ( $r, $method, $rid ) = @_;
    my $logger = get_logger();
    $logger->debug("OAuth Callback");
    my $session   = process_session($r);
    my $dname     = set_auth_tokens( $r, $method, $rid, $session );
    my $scope     = get_scope_by_display_name($dname);
    my $req_info  = Kynetx::Request::build_request_env( $r, $method, $rid );
    my $req       = Apache2::Request->new($r);
    my $caller    = $req->param('caller');
    my $endpoints = get_google_endpoints($scope);
    my $rule_env = {};
    get_access_tokens( $req_info, $rule_env, $session, NAMESPACE, $endpoints, $scope );
    $logger->trace( "Session (with access token): ", sub { Dumper($session) } );
    my $test_response = test_request( $req_info, $rule_env, $session, $scope );

    if ( defined $test_response && $test_response->is_success() ) {

    #  If the callback test is valid, I am going to remove all of the old tokens
        $logger->info( "Rule $rid authorized for ",
                       NAMESPACE, " ", $scope->{'dname'} );
        trim_tokens( $rid, $session, NAMESPACE, $scope );
    } else {

        # If there was a failure, remove all of the tokens
        $logger->warn( "Auth failed for ", NAMESPACE, " ", $scope->{'dname'} );
        blast_tokens( $rid, $session, NAMESPACE, $scope );
    }

    $r->headers_out->set( Location => $caller );
    session_cleanup($session,$req_info);
}

sub test_request {
    my ( $req_info, $rule_env, $session, $scope ) = @_;
    my $logger = get_logger();
    my $rid    = $req_info->{'rid'};
    my $turl   = $scope->{'turl'};
    if ($turl) {
        return
          get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $turl,
                                  $scope );
    } else {
        $logger->warn( "No test URL defined for google scope: ",
                       $scope->{'dname'} );
    }
    return undef;
}

sub get_google_endpoints {
    my ($scope) = @_;
    my $logger  = get_logger();
    $logger->debug("scope: ", sub {Dumper($scope)});
    my $gurls   = $google_config->{'urls'};
    if ( !defined $scope ) {
        return $gurls;
    }
    my $rtu;
    if ( ref $scope eq 'HASH' ) {
        $rtu = get_request_token_url($scope);
    } else {
        $rtu = $gurls->{'request_token_url'};
    }

    $logger->debug( "Request Token Url: ", $rtu );
    my $urls = {
                 'request_token_url' => $rtu,
                 'access_token_url'  => $gurls->{'access_token_url'},
                 'authorization_url' => $gurls->{'authorization_url'}
    };
    return $urls;
}

sub get_google_scope {
    my ($args) = @_;
    my $logger = get_logger();
    if ( !defined $google_config ) {
        $google_config = Kynetx::Configure::get_config('GOOGLE')->{'google'};
    }
    $logger->trace( "gconfig: ", sub { Dumper($google_config) } );
    my $key = $args->[0];
    if ( defined $google_config->{'scope'}->{ lc($key) } ) {
        my $scope = $google_config->{'scope'}->{ lc($key) };
        return $scope;
    } else {
        return Kynetx::Util::merror("No scope defined for: $key");
    }

}

sub get_scope_by_display_name {
    my ($dname) = @_;
    my $logger = get_logger();
    $logger->debug("Find scope for: $dname");
    my $scopes = $google_config->{'scope'};
    foreach my $key (%$scopes) {
        my $scope = $scopes->{$key};
        if ( $scope && $scope->{'dname'} eq $dname ) {
            return $scope;
        }
    }
}

sub get_request_token_url {
    my ($scope) = @_;
    my $logger = get_logger();
    my $url;
    if ( defined $scope->{'surl'} ) {
        $url = $scope->{'surl'};
    } else {
        $url = $scope->{'url'};
    }
    my $rtu =
      $google_config->{'urls'}->{'request_token_url'} . '?scope=' . $url;
    return $rtu;
}

sub google_msg {
    my ( $req_info, $scope, $auth_url ) = @_;
    my $rid          = $req_info->{'rid'};
    my $ruleset_name = $req_info->{"$rid:ruleset_name"};
    my $name         = $req_info->{"$rid:name"};
    my $author       = $req_info->{"$rid:author"};
    my $description  = $req_info->{"$rid:description"};
    my $scope_name   = $scope->{'dname'};
    my $divId        = "KOBJ_google_notice";

    my $msg = <<EOF;
<div id="$divId">
<p>The application $name ($rid) from $author is requesting that you authorize Google $scope_name to share your personal information with it.  </p>
<blockquote><b>Description: </b>$description</blockquote>
<p>
The application will not have access to your login credentials at Google.  If you click "Take me to Google" below, you will taken to Google and asked to authorize this application.  You can cancel at that point or now by clicking "No Thanks" below.  Note: if you cancel, this application may not work properly. After you have authorized this application, you will be redirected back to this page.
</p>
<div style="color: #000; background-color: #FFF; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"">
<a href="$auth_url">Take me to Google</a></div>

<div style="color: #FFF; background-color: #F33; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"" onclick="javascript:KOBJ.close_notification('#$divId')">No Thanks!</div>
</div>
EOF

    return ( $divId, $msg );

}

sub nonce {
    my @a = ( 'A' .. 'Z', 'a' .. 'z', 0 .. 9 );
    my $nonce = '';
    for ( 0 .. 31 ) {
        $nonce .= $a[ rand( scalar(@a) ) ];
    }

    return $nonce;
}

sub get_params {
    my ( $args, $google_params, $defaults ) = @_;
    my $logger        = get_logger();
    my $passed_params = get_arg_hash($args);
    $logger->trace( "default params: ", sub { Dumper($defaults) } );
    $logger->trace( "passed params: ",  sub { Dumper($passed_params) } );
    foreach my $key ( keys %$defaults ) {
        if ( defined $passed_params->{$key} ) {
            my $val = undef;
            if ( ref $defaults->{$key} eq 'ARRAY' ) {
                 $val =
                  validate_array( $passed_params->{$key}, $defaults->{$key} );
            } elsif ( $defaults->{$key} =~ m/<(\w+)>/ ) {
                my $match = $1 || "";
              case: for ($match) {
                    /qstring/ && do {
                        $val = validate_qstring( $passed_params->{$key} );
                    };
                    /_string/ && do {
                        $val = validate_nospace( $passed_params->{$key} );
                    };
                    /timestamp/ && do {
                        $val = validate_timestamp( $passed_params->{$key} );
                    };
                    /bool/ && do {
                        $val = validate_boolean( $passed_params->{$key} );
                    };
                    /int/ && do {
                        $val = validate_int( $passed_params->{$key} );
                    };
                    /ord/ && do {
                        $val = validate_ord( $passed_params->{$key} );
                    };
                    /card/ && do {
                        $val = validate_card( $passed_params->{$key} );
                    };

                }
            }
            $logger->trace( "returned: ", $val );
            if ( defined $val ) {
                $google_params->{$key} = $val;
            }
        } else {
            my $dvalue = default_value($key);
            if ($dvalue) {
                $google_params->{$key} = $dvalue;
            }
        }
    }
    return $google_params;

}

sub default_value {
    my ($var)    = @_;
    my $logger   = get_logger();
    my $defaults = $google_config->{'default'};
    my $val      = $defaults->{$var};
    if ($val) {
        $logger->debug( "using default value ($val) for: ", $var );
        return $val;
    } else {
        return undef;
    }

}

sub validate_array {
    my ( $val, $arry ) = @_;
    my $logger = get_logger();
    my %found;
    map { $found{$_} = 1 } @$arry;
    if ( $found{$val} ) {
        return $val;
    } else {
        return undef;
    }
}

sub validate_qstring {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( defined $arg ) {
        return uri_escape($arg);
    } else {
        return undef;
    }
}

sub validate_nospace {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( defined $arg ) {
        $arg =~ s/\s/_/g;
        return uri_escape($arg);
    } else {
        return undef;
    }

}

sub validate_boolean {
    my ($arg) = @_;
    if ( defined $arg ) {
        if ( lc($arg) eq 'true' ) {
            return 'true';
        } else {
            return 'false';
        }
    } else {
        return undef;
    }
}

sub validate_timestamp {
    my ($arg)  = @_;
    my $logger = get_logger();
    my $f      = DateTime::Format::RFC3339->new();
    my $dt     = DateTime::Format::ISO8601->parse_datetime($arg);
    if ( defined $arg ) {
        my $ts = $f->format_datetime($dt);
        $logger->debug("Validate: ", $ts);
        return $ts;
    } else {
        return undef;
    }
}

sub validate_int {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( $arg =~ m/^\d+/ ) {
        return $arg;
    } else {
        return undef;
    }

}

sub validate_ord {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( defined validate_int($arg) && $arg >= 1 ) {
        return $arg;
    } else {
        return undef;
    }
}

sub validate_card {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( defined validate_int($arg) && $arg >= 0 ) {
        return $arg;
    } else {
        return undef;
    }
}

sub get_arg_hash {
    my ($args) = @_;
    if ( ref $args eq 'ARRAY' ) {
        foreach my $element (@$args) {
            if ( ref $element eq 'HASH' ) {
                return $element;
            }
        }
    }
}

sub build_url {
    my ( $req_info, $rule_env, $args, $common, $scope,$http_method ) = @_;
    my $target = $scope->{'dname'};
    if (! defined $http_method) {
        $http_method = 'GET';
    }
    if ( $target eq 'Calendar' ) {
        return
          Kynetx::Predicates::Google::Calendar::build( $req_info, $rule_env,
                                                       $args, $common,$http_method );
    } else {
        return undef;
    }

}

sub build_post_content {
    my ( $req_info, $rule_env, $args, $common, $scope ) = @_;
    my $target = $scope->{'dname'};
    if ( $target eq 'Calendar' ) {
        return
          Kynetx::Predicates::Google::Calendar::build_post_content( $req_info, $rule_env,
                                                       $args, $common );
    } else {
        return undef;
    }

}
1;
