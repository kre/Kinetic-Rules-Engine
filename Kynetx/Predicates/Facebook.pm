package Kynetx::Predicates::Facebook;

# file: Kynetx/Predicates/Google.pm
# file: Kynetx/Predicates/Referers.pm
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
use Data::Dumper;
use Storable qw/dclone freeze/;
use Digest::MD5 qw/md5_hex/;
use Clone qw/clone/;

use Kynetx::Expressions qw(mk_den_str);
use Kynetx::OAuth;
use Kynetx::Errors;
use Kynetx::Environments qw/:all/;
use Kynetx::Configure;
use Kynetx::Rids qw/:all/;
use Kynetx::Memcached qw(mset_cache);
use Kynetx::Session qw(
  process_session
  session_cleanup
);
use Kynetx::Predicates::Google::OAuthHelper qw(
  get_consumer_tokens
  make_callback_url
  get_token
  blast_tokens
  parse_callback
  get_access_tokens
  set_auth_tokens
  get_protected_resource
  post_protected_resource
  trim_tokens
  store_token
);

use Kynetx::Repository;
use LWP::UserAgent;
use URI::Escape ('uri_escape','uri_unescape');
use DateTime;
use DateTime::Format::RFC3339;
use DateTime::Format::ISO8601;
use Encode;
use HTTP::Request::Common;

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
          eval_facebook
          get_predicates
          authorize
          NAMESPACE
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use constant FB_AUTH_URL   => "https://graph.facebook.com/oauth/authorize";
use constant FB_ACCESS_URL => "https://graph.facebook.com/oauth/access_token";
use constant NAMESPACE     => "facebook";
use constant SESSION_CALLBACK_KEY => "oauth_callback";
my $fconfig_base    = Kynetx::Configure::get_config('FACEBOOK') || {'facebook' => {}};
my $fconfig    = $fconfig_base->{'facebook'};
my %predicates = ();

my $actions = {
    'authorize' => {
        js => <<EOF,
function(uniq, cb, config) {
  \$K.kGrowl.defaults.header = "Authorize Facebook Access";
  if(typeof config === 'object') {
    \$K.extend(\$K.kGrowl.defaults,config);
  }
  \$K.kGrowl(KOBJ_facebook_notice);
  cb();
}
EOF
        before => \&authorize
    },
    'post' => {
        js => '',
        before => \&post_to_facebook,
        after => []
      }

};

sub get_actions {
    return $actions;
}

sub get_predicates {
    return \%predicates;
}

my $funcs = {};

sub post_to_facebook {
    my ( $req_info, $rule_env, $session, $config, $mods, $args,$vars ) = @_;
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $logger  = get_logger();
    my $version = $req_info->{'rule_version'} || 'prod';
    my $url     = build( 'post', $args );
    my $content = build_post_content($args);
    my $response =
      post_protected_resource( $req_info, $rule_env, $session, NAMESPACE, '', $url,
                               $content );
    my $v = $vars->[0] || '__dummy';
    my $resp = {
        $v => {'label' => $config->{'autoraise'} || '',
            'content' => $response->decoded_content(),
            'status_code' => $response->code(),
            'status_line' => $response->status_line(),
            'content_type' => $response->header('Content-Type'),
            'content_length' => $response->header('Content-Length'),
        }

    };

  $logger->trace("KRL response ", sub { Dumper $resp });
  $logger->debug("POST response: ", $resp->{'__dummy'}->{'status_line'});

  # side effect rule env with the response
  # should this be a denoted value?
  $rule_env = add_to_env($resp, $rule_env) unless $v eq '__dummy';

#  $logger->debug("Rule Env ", sub { Dumper $rule_env });


  my $js = '';
    if(defined $config->{'autoraise'}) {
    $logger->debug("facebook library autoraising event with label $config->{'autoraise'}");

    # make modifiers in right form for raise expr
    my $ms = [];
    foreach my $k (keys %{ $resp->{$v}} ) {
      push( @{$ms}, {'name' => $k,
             'value' => Kynetx::Expressions::mk_den_str($resp->{$v}->{$k}),
            })
    }

    # create an expression to pass to eval_raise_statement
    my $expr = {'type' => 'raise',
        'domain' => 'facebook',
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

sub build_post_content {
    my ($args) = @_;
    my $logger = get_logger();
    my $writes = $fconfig->{'writes'};
    my $by_connection;
    foreach my $key ( keys %$writes ) {
        if ( $writes->{$key}->{'parm'} ) {
            my $parms = $writes->{$key}->{'parm'};
            map { $by_connection->{$key}->{$_} = 1 } @$parms;
        }
    }
    my @temp;
    if ( ref $args->[0] eq 'HASH' ) {
        my $type = $args->[0]->{'connection'};
        foreach my $key ( keys %{ $args->[0] } ) {
            if ( $by_connection->{$type}->{$key} ) {
                push( @temp, $key . "=" . $args->[0]->{$key} );
            }
        }
    }
    return join( "&", @temp );
}

sub authorize {
    my ( $req_info, $rule_env, $session, $config, $mods, $args ) = @_;
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $logger  = get_logger();
    my $version = $req_info->{'rule_version'} || 'prod';
    my $scope   = get_scope($args);
    if ( Kynetx::Errors::mis_error($scope) ) {
        $logger->warn( "Authorize failure: ", $scope->{'DEBUG'} );
    }
    my $app_req = get_fb_app_info( $req_info, $rule_env, $session );
    my $app_info = Kynetx::Json::jsonToAst($app_req->{'_content'});

    # application info is no longer being passed in the regular contents
    $logger->debug( "Facebook application info for $rid: ",
                    sub { Dumper($app_info) } );

    my $app_name;
    my $app_link;
    if ($app_info) {
        $app_name = $app_info->{'name'};
        $app_link = $app_info->{'link'};
    }

    # Caller URL is not surviving the auth process, place it into the session
    my $caller  = $req_info->{'caller'};
    store_token($rid, $session, SESSION_CALLBACK_KEY, $caller, 'facebook');

    my $auth_url = get_fb_auth_url( $req_info, $rule_env, $session, NAMESPACE, $scope );

    $logger->debug( "Authorization URL: ", uri_unescape($auth_url ));

    my ( $divId, $msg ) =
      facebook_msg( $req_info, $auth_url, $app_name, $app_link );

    my $js =
      Kynetx::JavaScript::gen_js_var( $divId,
                                      Kynetx::JavaScript::mk_js_str($msg) );
    return $js;
}

sub authorized {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $logger = get_logger();
    my $access_token = get_token( $rid, $session, 'access_token', NAMESPACE );
    if ($access_token) {
        $logger->debug( "Found Access Token for: ", NAMESPACE );
        my $resp = test_response( $req_info, $rule_env, $session );
        if ( defined $resp && $resp->is_success() ) {
            $logger->info( "Rule $rid authorized for ", NAMESPACE );
            return 1;
        } else {
            $logger->warn( "Auth failed for ", NAMESPACE, ":$rid" );
            #blast_tokens( $rid, $session, NAMESPACE );
        }
    } else {
        $logger->debug( "No access token found for ", NAMESPACE );
    }
    #blast_tokens( $rid, $session, NAMESPACE, '' );
    return 0;
}
$funcs->{'authorized'} = \&authorized;

sub metadata {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger    = get_logger();
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $url       = build( $function, $args, $session, $rid );
    my $cachetime = get_cachetime($args);
    my $resp = get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url,
                                       $cachetime );
    return eval_response( $resp, $rid, $url, $cachetime );

}
$funcs->{'metadata'} = \&metadata;

sub picture {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger    = get_logger();
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $url       = build( $function, $args, $session, $rid );
    my $cachetime = get_cachetime($args);
    my $resp = get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url,
                                       $cachetime );
    return eval_response( $resp, $rid, $url, $cachetime );

}
$funcs->{'picture'} = \&picture;

sub search {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger    = get_logger();
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $url       = build( $function, $args, $session, $rid );
    my $cachetime = get_cachetime($args);
    $logger->debug( "Search URL: ", $url );
    my $resp = get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url,
                                       $cachetime );
    return eval_response( $resp, $rid, $url, $cachetime );

}
$funcs->{'search'} = \&search;

sub get {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $url    = build( $function, $args, $session, $rid );
    $logger->trace( "GET URL: ", $url );
    my $cachetime = get_cachetime($args);
    my $resp = get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url,
                                       $cachetime );
    return eval_response( $resp, $rid, $url, $cachetime );
}
$funcs->{'get'} = \&get;

sub permissions {
	my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $url    = build( $function, $args, $session, $rid );
    my $cachetime = get_cachetime($args);
    my $resp = get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url,
                                       $cachetime );
    return eval_response( $resp, $rid, $url, $cachetime );		
}
$funcs->{'permissions'} =\&permissions;

sub fql {
	my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $url    = build( $function, $args, $session, $rid );
    my $cachetime = get_cachetime($args);
    my $resp = get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url,
                                       $cachetime );
    return eval_response( $resp, $rid, $url, $cachetime );		
}
$funcs->{'fql'} =\&fql;


sub ids {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $url    = build( $function, $args, $session, $rid );
    $logger->debug( "GET URL: ", $url );
    my $cachetime = get_cachetime($args);
    my $resp = get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $url,
                                       $cachetime );
    return eval_response( $resp, $rid, $url, $cachetime );
}
$funcs->{'ids'} = \&ids;

sub mediator {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    return config_info( $function, $args );
}
$funcs->{'fields'}      = \&mediator;
$funcs->{'feed'}        = \&mediator;
$funcs->{'connections'} = \&mediator;
$funcs->{'writes'}      = \&mediator;

sub config_info {
    my ( $function, $args ) = @_;
    my $default = 'objects';
    my $target;
    if ( $function eq 'fields' ) {
        $target = 'properties';
    } elsif ( $function eq 'feed' ) {
        $target = 'feed';
    } elsif ( $function eq 'connections' ) {
        $target = 'connections';
    } elsif ( $function eq 'writes' ) {
        $default = $function;
        $target  = 'parm';
    }
    my $num_args = scalar @$args;
    if ( $num_args == 1 ) {
        my $f = $args->[0];
        if ( ref $f eq '' ) {
            my $obj = $fconfig->{$default}->{$f};
            if ($obj) {
                return $obj->{$target};
            } else {
                return Kynetx::Errors::merror("Facebook object ($f) not found");
            }
        }
    }
    return Kynetx::Errors::merror("Invalid $function request");

}

sub build {
    my ( $function, $args, $session, $rid ) = @_;
    my $logger = get_logger();
    my $url    = $fconfig->{'urls'}->{'base'};
    if ( $function eq 'metadata' ) {
        my $fbid = get_id( $args, $session, $rid );
        return "$url/$fbid?metadata=1";
    } elsif ( $function eq 'post' ) {
        my $fbid = get_id( $args, $session, $rid );
        my $c = get_connection($args);
        $url .= "/$fbid/$c";
        return $url;
    } elsif ( $function eq 'get' ) {
        my $fbid    = get_id( $args, $session, $rid );
        my $p       = get_paging($args);
        my $c       = get_connection($args);
        my $f       = get_field_list($args);
        my @qparams = ();
        if ($p) {
            push( @qparams, $p );
        }
        if ($f) {
            push( @qparams, $f );
        }
        $url .= "/$fbid";
        if ( defined $c ) {
            if ( Kynetx::Errors::mis_error($c) ) {
                $logger->debug( $c->{'DEBUG'} );
                $logger->trace( $c->{'TRACE'} );
            } else {
                $url .= "/$c";
            }
        }
        my $q = join( '&', @qparams );
        if ($q) {
            $url .= '?' . $q;
        }

        return $url;
    } elsif ( $function eq 'picture' ) {
        my $fbid = get_id( $args, $session, $rid );
        $url .= "/$fbid/picture";
        my @qparams = ();
        my $ptype = get_type( $args, $function );
        if ($ptype) {
            push(@qparams,$ptype);
        }
        my $ssl = get_use_ssl($args,$function);
        if ($ssl) {
        	push(@qparams,$ssl);
        }
        my $q = join('&',@qparams);
        if ($q) {
        	$url .= '?' . $q;
        }
        return $url;
    } elsif ( $function eq 'search' ) {
        my $type = get_type( $args, $function );
        my $fbid = get_id( $args, $session, $rid );
        my $q    = get_query_string($args);
        my $p    = get_paging($args);

        # special case for searching users news feed
        if ( $type eq "type=home" ) {
            if ($q) {
                $url .= "/$fbid/home?$q";
            }
        } else {
            $url .= "/search?$q&$type";
        }
        if ($p) {
            $url .= "&$p";
        }
        return $url;
    } elsif ( $function eq 'ids' ) {
        my $ids = get_ids($args);
        if ($ids) {
            $url .= "/?$ids";
            return $url;
        }
    } elsif ( $function eq 'permissions') {
    	$url = $fconfig->{'urls'}->{'fql'};
    	my $query = get_permissions_query($args);
    	$url .= "?format=json&query=" . $query;
    	return $url;
    } elsif ($function eq 'fql') {
    	$url = $fconfig->{'urls'}->{'fql'};
    	my $query = get_fql_query($args);
    	$url .="?format=json&query=" . $query;
    	return $url;
    }
}

sub get_fql_query {
	my ($args) = @_;
	my $logger = get_logger();
	if (ref $args->[0] eq "") {
		return $args->[0];
	}	
}

sub get_permissions_query{
	my ($args) = @_;
	my $logger = get_logger();
	my @perms = ();
	my $shash = $fconfig->{'scope'};
	if (ref $args->[0] eq "ARRAY") {
		my $specifics = $args->[0];
		foreach my $key (@$specifics) {
			if ($shash->{$key}) {
				push(@perms,$key);
			}
		}
	} else {
		foreach my $key (keys %$shash) {
			$logger->trace("$key");
			push(@perms,$key);
		}
	}
	my $plist = join(",",@perms);
	my $fql_query = "select $plist from permissions where uid=me()";
	$logger->trace("Query: ", $fql_query);
	return $fql_query;
}

sub get_ids {
    my ($args) = @_;
    my $logger = get_logger();
    if ( ref $args->[0] eq 'HASH' ) {
        my $f_arg = $args->[0]->{'ids'};
        if ($f_arg) {
            if ( ref $f_arg eq '' ) {
                return "ids=$f_arg";
            } elsif ( ref $f_arg eq "ARRAY" ) {
                my $str = join( ",", @$f_arg );
                return "ids=$str";
            } else {
                $logger->warn("param ids expects a string or an array");
            }
        }
    }
}

sub get_field_list {
    my ($args) = @_;
    my $logger = get_logger();
    if ( ref $args->[0] eq 'HASH' ) {
        my $f_arg = $args->[0]->{'fields'};
        if ($f_arg) {
            if ( ref $f_arg eq '' ) {
                return "fields=$f_arg";
            } elsif ( ref $f_arg eq "ARRAY" ) {
                my $str = join( ",", @$f_arg );
                return "fields=$str";
            } else {
                $logger->warn("param fields expects a string or an array");
            }
        }
    }
}

sub get_cachetime {
    my ($args) = @_;
    my $logger = get_logger();
    if ( defined $args->[1] && ref $args->[1] eq '' && $args->[1] > 0 ) {
        return $args->[1];
    } else {
        return undef;
    }
}

sub get_connection {
    my ($args) = @_;
    my $logger = get_logger();
    if ( ref $args->[0] eq 'HASH' ) {
        my $connection = $args->[0]->{'connection'};
        my $type       = $args->[0]->{'type'};
        if ( $type && $connection ) {
            my $obj = $fconfig->{'objects'}->{$type};
            if ($obj) {
                my $temp = $obj->{'connections'};
                my $type_hash;
                map { $type_hash->{$_} = 1 } @$temp;
                if ( $type_hash->{$connection} ) {
                    return $connection;
                } else {
                    $logger->debug( "get connection, ",
                                    $connection, $type, " ",
                                    sub { Dumper($type_hash) } );
                    return Kynetx::Errors::merror("$connection invalid for object $type");
                }
            } else {
                $logger->warn("Invalid Facebook object ($type)");
            }
            return $connection;
        } elsif ($connection) {
            return $connection;
        }
        return;

    }
    return undef;
}

sub get_use_ssl {
	my ($args,$target) = @_;
	my $logger = get_logger();
	$logger->trace("Target: $target");
	my $ahash = $args->[0];
	my $ssl_string = $fconfig->{$target}->{'ssl'};
	$logger->trace("SSL string: $ssl_string");
	if (ref $ahash eq "HASH" && defined $ahash->{$ssl_string}) {
		my $use="0";
		if ($ahash->{$ssl_string}) {
			$use = "1";
		}
		return $ssl_string . '=' . $use;
	}
	return undef;
	
}

sub get_paging {
    my ($args)    = @_;
    my $logger    = get_logger();
    my $page_opts = $fconfig->{'paging'};
    my @parry;
    my $lpart = $args->[0];
    if ( ref $lpart eq 'HASH' ) {
        foreach my $element (@$page_opts) {
            if ( $lpart->{$element} ) {
                my $val = $element . "=" . $lpart->{$element};
                push( @parry, $val );
            }
        }
    }
    if (@parry) {
        return join( "&", @parry );
    } else {
        return undef;
    }

}

sub get_query_string {
    my ($args) = @_;
    my $logger = get_logger();
    my $q_part = $args->[0];
    if ( ref $q_part eq 'HASH' ) {
        my $qstring = $q_part->{'q'};
        if ($qstring) {
            return "q=$qstring";
        }
    }
    return '';

}

sub get_type {
    my ( $args, $ttype ) = @_;
    my $logger = get_logger();
    my $types  = $fconfig->{$ttype}->{'type'};
    if ( defined $types ) {
        my $type_part = $args->[0];

        #$logger->debug("Find type in: ", sub {Dumper($type_part)});
        my $type_hash;
        map { $type_hash->{$_} = 1 } @$types;

        #$logger->debug("type hash: ", sub {Dumper($type_hash)});
        if ( ref $type_part eq 'HASH' ) {
            my $type = $type_part->{'type'};

            #$logger->debug("Is HASH: ", $type);
            if ( $type_hash->{$type} ) {
                return 'type=' . $type;
            }

        } elsif ( $type_part && ( ref $type_part eq '' ) ) {
            if ( $type_hash->{$type_part} ) {
                return 'type=' . $type_part;
            }
        }
    } elsif ( $ttype eq 'object ' ) {
    } else {
        $logger->warn("No config found for $ttype->type");
        return '';
    }
}

sub get_id {
    my ( $args, $session, $rid ) = @_;
    my $logger  = get_logger();
    my $id_part = $args->[0];
    $logger->trace( "Get id: ", sub { Dumper($id_part) } );
    if ( defined $id_part ) {
        if ( ref $id_part eq '' ) {

            # Funny characters
            $id_part =~ m/(\w+)/;
            return $1;
        } elsif ( ref $id_part eq "HASH" ) {
            my $fbid = $id_part->{'id'};
            if ( defined $fbid ) {
                return $fbid;
            }
        }
    }
    my $token = get_token( $rid, $session, 'access_token', NAMESPACE )|| "";
    $token =~ m/\d+\|\w+-(\d+)|.+/;
    my $fbid = $1;
    $logger->trace( "Found id: ", $fbid, " in token" );
    if ($fbid) {
        return $fbid;
    } else {
        return "me";
    }

}

sub eval_facebook {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $logger = get_logger();
    $logger->debug( "eval_facebook evaluation with function -> ", $function );
    my $f = $funcs->{$function};
    if ( defined $f ) {
        my $result =
          $f->( $req_info, $rule_env, $session, $rule_name, $function, $args );
        if ( Kynetx::Errors::mis_error($result) ) {
            $logger->warn("Facebook request failed");
            $logger->debug( "fail: ", $result->{'DEBUG'} || '' );
            $logger->trace( "fail detail: ", $result->{'TRACE'} || '' );
            return [];
        } else {
            return $result;
        }
    } else {
        $logger->debug("Function $function not defined");
    }

}

sub eval_response {
    my ( $resp, $rid, $url, $cache ) = @_;
    my $logger     = get_logger();
    my $fb_prefix  = $fconfig->{'urls'}->{'base'};
    my $dont_cache = $fb_prefix . '/me';
    if ( $url =~ m/^$dont_cache.*/ ) {
        $cache = 0;
    }
    if ( $resp->is_success ) {
        if ($cache) {
            my $key     = $rid . ":" . $url;
            my $content = $resp->content;
            $logger->debug( "cache call: ", $key, " ", $content, " ", $cache );
            mset_cache( $key, $content, $cache );
        }
        my $ast = eval { Kynetx::Json::jsonToAst( $resp->content ) };
        if ($@) {
            $logger->warn( "Invalid JSON format: ", sub { Dumper($@) } );
            return $resp->content;
        }
        if ( is_empty_response($ast) ) {
            $logger->info("Facebook returned empty string");
        }
        return $ast;
    } elsif ( $resp->is_redirect ) {
        ### for pictures, FB returns a redirect location
        if ( $resp->code() == 302 ) {
            if ($cache) {
                my $key     = $rid . ":" . $url;
                my $content = $resp->header('location');
                $logger->debug( "cache redirect: ",
                                $key, " ", $content, " ", $cache );
                mset_cache( $key, $content, $cache );
            }
            return $resp->header('location');
        } else {
            $logger->warn( "Request redirect: (",
                           $resp->status_line, ") ",
                           $resp->header('location') );
        }
    } else {
        my $not_success = facebook_error_message($resp);
        return
          Kynetx::Errors::merror( $not_success,
                "Facebook responded with error: (" . $resp->status_line . ")" );
    }

}

sub facebook_error_message {
    my ($response) = @_;
    my $ast = eval { Kynetx::Json::jsonToAst( $response->content ) };
    if ($@) {
        return Kynetx::Errors::merror(
                      "Failure parsing Facebook error: " . $response->content );
    }
    if ( $ast->{'error'} ) {
        return Kynetx::Errors::merror(
               $ast->{'error'}->{'type'} . ":" . $ast->{'error'}->{'message'} );
    }
}

sub process_oauth_callback {
    my ( $r, $method, $rid, $eid ) = @_;
    my $oauth_status = "true";
    my $logger = get_logger();
    $logger->debug( "\n-------------------OAuth Callback ", NAMESPACE,"---------------------: " );
    my $session = process_session($r);
    set_auth_tokens( $r, $method, $rid, $session, NAMESPACE );
    my $callback_hash = parse_callback( $r, $method, $rid, NAMESPACE );
    my $req_info = $callback_hash->{'req_info'};
    if ( $rid ne $callback_hash->{'rid'} ) {
        $logger->warn( "Callback rid mis-match, expected: ",
                       $rid, " got: ", $callback_hash->{'rid'} );
    }
    my $rule_env = {};
    my $token_response = get_access_tokens( $req_info, $rule_env, $session, NAMESPACE, get_endpoints(),
                       $callback_hash );
    #$logger->debug("Token response: ", sub {Dumper($token_response)});
    my $resp = test_response( $req_info, $rule_env, $session );
    if ( defined $resp && $resp->is_success() ) {
        $logger->info( "Rule $rid authorized for ", NAMESPACE );
        trim_tokens( $rid, $session, NAMESPACE );
    } else {
    	$oauth_status = 'false';
        $logger->warn( "Auth failed for ", NAMESPACE, ":$rid" );
    }
    my $caller_from_session = get_token($rid,$session,SESSION_CALLBACK_KEY,NAMESPACE);
    my $caller_from_req_info = $req_info->{'caller'};
    my $caller ="";
    if (! $caller_from_session) {
    	$logger->debug("Raise event to $caller_from_req_info");
    	# request info is not passed to the process_event method and RequestRec ($r)
    	# doesn't allow access to the content.  pnotes is the mod_apache method
    	# for attaching perl variables to the RequestRec object (notes is for strings only)
    	#
    	# Variables are passed by ref not a copy
    	my $eventname = $caller_from_req_info;
    	my $k = {
    		'auth' => $oauth_status,
    		'callback_request' => $req_info->{'uri'},
    		'access_token_response' => $token_response->decoded_content(),
    		'atr_code' => $token_response->code,
    		'atr_msg' => $token_response->message,
    	};
    	$r->pnotes('K' => $k);    
    	Kynetx::Events::process_event($r,'oauth_callback',$eventname,$rid,$eid,$req_info->{'kynetx_app_version'});
    }
    $logger->debug("Issue redirect to: ", $caller_from_session);
    $logger->debug("req_info: ", $caller_from_req_info);
    $r->headers_out->set( Location => $caller );
    my $redirect = $r->headers_out->get("Location");
    if ($caller ne $redirect) {
        $logger->debug("Unable to redirect from $redirect to $caller");
    }
    session_cleanup($session,$req_info);
}

sub test_response {
    my ( $req_info, $rule_env, $session ) = @_;
    my $logger   = get_logger();
    my $test_url = get_endpoints()->{'test_url'};
    my $resp =
      get_protected_resource( $req_info, $rule_env, $session, NAMESPACE, $test_url );
    $logger->trace( "Test request: ", sub { Dumper($resp) } );
    return $resp;
}

sub fake_callback {
    my $fake_string =
'http://64.55.47.131:8082/ruleset/fb_callback/a144x22/frooFruHappytime/Bar';

    return $fake_string;
}

sub get_scope {
    my ($args) = @_;
    my $logger = get_logger();
    $logger->trace( "Get scope for request ", sub { Dumper($args) } );
    unless ( defined $fconfig->{'scope'} ) {
        return Kynetx::Errors::merror("Facebook config file not initialized properly");
    }
    my $key = $args->[0];
    my @sarray;
    if ( ref $key eq 'ARRAY' ) {
        my $scope_r;
        my $scope_hash = $fconfig->{'scope'};
        foreach my $element (@$key) {
            $scope_r = "$element ->";
            if ( defined $scope_hash->{$element} ) {
                push( @sarray, $element );
                $scope_r .= " Y";
            } else {
                $scope_r .= " N";
            }
            $logger->debug($scope_r);
        }
        return join( ",", @sarray );
    } elsif ( ref $key eq '' && defined $fconfig->{'scope'}->{$key} ) {
        return $key;
    } else {
        return Kynetx::Errors::merror("No scope defined for: $key");
    }

}

sub get_endpoints {
    unless ( defined $fconfig->{'urls'} ) {
        return Kynetx::Errors::merror("Facebook config file not initialized properly");
    }
    return $fconfig->{'urls'};
}

sub facebook_msg {
    my ( $req_info, $auth_url, $app_name, $app_link ) = @_;
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);
    my $ruleset_name = $req_info->{"$rid:ruleset_name"};
    my $name         = $req_info->{"$rid:name"};
    my $author       = $req_info->{"$rid:author"};
    my $description  = $req_info->{"$rid:description"};
    my $link         = "";
    if ( !$app_link ) {
        $app_link = 'onclick="return false;';
    }
    my $divId = "KOBJ_facebook_notice";

    my $msg = <<EOF;
<div id="$divId">
<p>The application</p>
<p><a href="$app_link" target="_blank" $link title="Open the application's Facebook page" style="color: white;font-weight:bold">$name ($rid)</a></p>
<p> from $author is requesting that you authorize Facebook to share your personal information with it.  </p>
<blockquote><b>Description:</b>$description</blockquote>
<p>
The application will not have access to your login credentials at Facebook.  If you click "Take me to Facebook" below, you will taken to Facebook and asked to authorize this application.  You can cancel at that point or now by clicking "No Thanks" below.  Note: if you cancel, this application may not work properly. After you have authorized this application, you will be redirected back to this page.
</p>
<div style="color: #000; background-color: #FFF; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"">
<a href="$auth_url">Take me to Facebook</a></div>

<div style="color: #FFF; background-color: #F33; -moz-border-radius: 5px; -webkit-border-radius: 5px; padding: 10px;margin:10px;text-align:center;font-size:18px;"cursor": "pointer"" onclick="javascript:KOBJ.close_notification('#$divId')">No Thanks!</div>
</div>
EOF

    return ( $divId, $msg );

}

sub get_fb_app_info {
    my ( $req_info, $rule_env, $session ) = @_;
    my $logger        = get_logger();
    my $consumer_keys = get_consumer_tokens( $req_info, $rule_env, $session, NAMESPACE );
    my $app_id        = $consumer_keys->{'consumer_key'};
    my $app_secret    = $consumer_keys->{'consumer_secret'};
    my $base          = $fconfig->{'urls'}->{'base'};
    my $app_url       = "$base/$app_id";
    my $resp          = get_facebook_resource($app_url);
}

sub get_fb_auth_url {
    my ( $req_info, $rule_env, $session, $namespace, $scope ) = @_;
    my $logger = get_logger();
    my $consumer_keys = get_consumer_tokens( $req_info, $rule_env, $session, NAMESPACE );
    my $callback = make_callback_url( $req_info, NAMESPACE );
    $logger->debug("Authorization URL callback: ",uri_unescape($callback));
    my $auth_url = get_endpoints()->{'authorization_url'};
    $auth_url .= '?client_id=' . $consumer_keys->{'consumer_key'};
    $auth_url .= '&redirect_uri=' . $callback;
    $auth_url .= '&scope=' . $scope;
    $auth_url .= '&type=web_server';
    return $auth_url;
}

sub get_facebook_resource {
    my ($url) = @_;
    my $logger = get_logger();
    my $hreq  = HTTP::Request->new( GET => $url );
    my $ua    = LWP::UserAgent->new;
    my $resp  = $ua->request($hreq);
    my $count = 1;
    if ( $resp->is_error ) {
        $logger->warn( "Facebook server error: ",
                       $resp->code, " : ", $resp->status_line );

    }
    while ( $resp->is_redirect ) {
        $logger->debug( "Redirect (", $count++, ")" );
        my $r_url = URI->new( $resp->header("location") );
        $hreq->uri($r_url);
        $resp = $ua->simple_request($hreq);
    }
    if ( $resp->is_success ) {
        return $resp;
    }

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
    my ( $args, $params, $defaults ) = @_;
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
                $params->{$key} = $val;
            }
        } else {
            my $dvalue = default_value($key);
            if ($dvalue) {
                $params->{$key} = $dvalue;
            }
        }
    }
    return $params;

}

sub is_empty_response {
    my ($response) = @_;
    my $logger = get_logger();
    if ( ref $response eq 'HASH' and defined $response->{'data'} ) {
        my $data = $response->{'data'};
        if ( ref $data eq 'ARRAY' and @$data ) {
            return 0;
        } else {
            $logger->debug( "Is empty: ", sub { Dumper($response) } );
            return 1;
        }
    }
    return 0;
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
        return $f->format_datetime($dt);
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

1;
