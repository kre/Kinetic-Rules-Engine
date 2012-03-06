package Kynetx::Modules;
# file: Kynetx/Modules.pm
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
use Kynetx::Util;
use Kynetx::Expressions;
use Kynetx::Environments;
use Kynetx::Session;
use Kynetx::Actions::LetItSnow;
use Kynetx::Actions::JQueryUI;
use Kynetx::Actions::FlippyLoo;
use Kynetx::Rids qw/:all/;

use Data::Dumper;
$Data::Dumper::Indent = 1;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
lookup_module_env
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use Kynetx::Predicates::Demographics;
use Kynetx::Predicates::Location;
use Kynetx::Predicates::Weather;
use Kynetx::Predicates::Time;
use Kynetx::Predicates::Markets;
use Kynetx::Predicates::Referers;
use Kynetx::Predicates::Mobile;
use Kynetx::Predicates::MediaMarkets;
use Kynetx::Predicates::Useragent;
use Kynetx::Predicates::KPDS;
use Kynetx::Predicates::Page;
use Kynetx::Predicates::Math;
use Kynetx::Predicates::Amazon;
use Kynetx::Predicates::Google;
use Kynetx::Predicates::OData;
use Kynetx::Predicates::RSS;
use Kynetx::Predicates::Facebook;
use Kynetx::Modules::Twitter;
use Kynetx::Modules::Email;
use Kynetx::Modules::Event;
use Kynetx::Modules::HTTP;
use Kynetx::Modules::Twilio;
use Kynetx::Modules::URI;
use Kynetx::Modules::Address;
use Kynetx::Modules::PDS;
use Kynetx::Modules::This2That;
use Kynetx::Modules::OAuthModule;
use Kynetx::Modules::Random;


our $name_prefix = '@@module_';

sub eval_module {
    my ( $req_info, $rule_env, $session, $rule_name, $source, $function, $args )
      = @_;

    my $logger = get_logger();

    #   $args->[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes
    # get the values

#    $logger->trace( "Datasource args ", sub { Dumper $args} );

    my $val   = '';
    my $preds = {};

    # see if there is a module defined function that matches
    # if so, cut this short.
    $val = lookup_module_env($source, $function, $rule_env);
    if (defined $val && Kynetx::Expressions::is_closure($val)) {
      # manufacture an application and apply it
      my $app = {'function_expr' => $val,
		 'type' => 'app',
		 'args' => $args}; 
#      $logger->debug("eval_module starting with ", sub {Dumper $app});
      $val = Kynetx::Expressions::eval_application($app,
						   $rule_env,
						   $rule_name,
						   $req_info,
						   $session);
#      $logger->debug("eval_module returning ", sub {Dumper $val});

      return $val;
    }

    #
    # the following code is ugly for historical reasons.  Ultimately,
    # we need to clean it up so that all modules have a common
    # function name and predicates are linked into that one function
    # and this big if-then-else can go away.  Data driven FTW!
    #
    
    # get the values, the code below doesn't like denoted values. 
    for (@{ $args }) {
      $_ = Kynetx::Expressions::den_to_exp($_);
    }


    if ( $source eq 'datasource' ) {    # do first since most common
        my $rs =
          Kynetx::Environments::lookup_rule_env( 'datasource:' . $function,
                                                 $rule_env );
        my $new_ds = Kynetx::Datasets->new($rs);
        $new_ds->load( $req_info, $args );
        $new_ds->unmarshal();
        if ( defined $new_ds->json ) {
            $val = $new_ds->json;
        } else {
            $val = $new_ds->sourcedata;
        }
    } elsif ( $source eq 'twitter' ) {
        $preds = Kynetx::Modules::Twitter::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Modules::Twitter::eval_twitter(
                                                $req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
        }
    } elsif ( $source eq 'page' ) {


        $preds = Kynetx::Predicates::Page::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::Page::get_pageinfo( $req_info, $function,
                                                           $args );
        }

    } elsif ( $source eq 'event' ) {


        $preds = Kynetx::Modules::Event::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::Event::get_eventinfo( $req_info, $function, $args );
        }

    } elsif ( $source eq 'math' ) {
        $preds = Kynetx::Predicates::Math::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Math::do_math( $req_info, $function, $args );
        }
    } elsif ( $source eq 'weather' ) {
        $preds = Kynetx::Predicates::Weather::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Weather::get_weather( $req_info, $function );
        }
    } elsif ( $source eq 'demographics' ) {
        $preds = Kynetx::Predicates::Demographics::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Demographics::get_demographics( $req_info,
                                                                  $function );
        }
    } elsif ( $source eq 'geoip' || $source eq 'location' ) {
        $preds = Kynetx::Predicates::Location::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Location::get_geoip( $req_info, $function );
        }
    } elsif ( $source eq 'stocks' || $source eq 'markets' ) {
        $preds = Kynetx::Predicates::Markets::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Markets::get_stocks( $req_info, $args->[0],
                                                       $function );
        }
    } elsif ( $source eq 'referer' ) {
        $preds = Kynetx::Predicates::Referers::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Referers::get_referer( $req_info, $function );
        }
    } elsif ( $source eq 'mediamarket' ) {
        $preds = Kynetx::Predicates::MediaMarkets::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::MediaMarkets::get_mediamarket( $req_info,
                                                                    $function );
        }
    } elsif ( $source eq 'useragent' ) {
        $preds = Kynetx::Predicates::Useragent::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::Useragent::get_useragent( $req_info,
                                                                 $function );
        }
    } elsif ( $source eq 'time' ) {
        $preds = Kynetx::Predicates::Time::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Time::get_time( $req_info, $function, $args );
        }
    } elsif ( $source eq 'http' ) {
        $preds = Kynetx::Modules::HTTP::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::HTTP::run_function( $req_info, $function,
                                                        $args );
        }
    } elsif ( $source eq 'uri' ) {
        $preds = Kynetx::Modules::URI::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::URI::run_function( $req_info, $function,
                                                        $args );
        }
    } elsif ( $source eq 'address' ) {
        $preds = Kynetx::Modules::Address::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::Address::run_function( $req_info, $function,
                                                        $args );
        }
    } elsif ( $source eq 'twilio' ) {
        $preds = Kynetx::Modules::Twilio::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::Twilio::run_function( $req_info, $function,
                                                        $args );
        }
    } elsif ( $source eq 'email' ) {
        $preds = Kynetx::Modules::Email::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::Email::run_function( $req_info, $function,
                                                         $args );
        }
    } elsif ( $source eq 'kpds' ) {
        $preds = Kynetx::Predicates::KPDS::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::KPDS::eval_kpds(
                                                $req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
        }
    } elsif ( $source eq 'amazon' ) {
        $preds = Kynetx::Predicates::Amazon::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::Amazon::eval_amazon($req_info,$rule_env,$session,$rule_name,$function,$args);
        }
    } elsif ($source eq 'rss') {
        $preds = Kynetx::Predicates::RSS::get_predicates();
        if (defined $preds->{$function}) {
            $val = $preds->{$function}->($req_info,$rule_env,$args);
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::RSS::eval_rss($req_info,$rule_env,$session,$rule_name,$function,$args);
        }
    } elsif ($source eq 'google') {
        $preds = Kynetx::Predicates::Google::get_predicates();
        if (defined $preds->{$function}) {
            $val = $preds->{$function}->($req_info,$rule_env,$args);
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::Google::eval_google($req_info,$rule_env,$session,$rule_name,$function,$args);
        }
    } elsif ($source eq 'facebook') {
        $preds = Kynetx::Predicates::Facebook::get_predicates();
        if (defined $preds->{$function}) {
            $val = $preds->{$function}->($req_info,$rule_env,$args);
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::Facebook::eval_facebook($req_info,$rule_env,$session,$rule_name,$function,$args);
        }
    } elsif ( $source eq 'snow' ) {
        $preds = Kynetx::Actions::LetItSnow::get_predicates();
        $val = $preds->{$function}->( $req_info, $rule_env, $args );
        $val ||= 0;
    } elsif ( $source eq 'jquery_ui' ) {
        $preds = Kynetx::Actions::JQueryUI::get_predicates();
        $val = $preds->{$function}->( $req_info, $rule_env, $args );
        $val ||= 0;
    } elsif ( $source eq 'flippy_loo' ) {
        $preds = Kynetx::Actions::FlippyLoo::get_predicates();
        $val = $preds->{$function}->( $req_info, $rule_env, $args );
        $val ||= 0;
    } elsif ( $source eq 'odata' ) {
        $preds = Kynetx::Predicates::OData::get_predicates();
        if (defined $preds->{$function}) {
            $val = $preds->{$function}->($req_info,$rule_env,$args);
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::OData::eval_odata($req_info,$rule_env,$session,$rule_name,$function,$args);
        }
    } elsif ( $source eq 'pds' ) {
        $preds = Kynetx::Modules::PDS::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::PDS::run_function( $req_info,$rule_env,$session,$rule_name,$function,$args );
        }    	
    } elsif ( $source eq 'random' ) {
        $preds = Kynetx::Modules::Random::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::Random::run_function( $req_info,$function,$args );
        }    	
    } elsif ( $source eq 'oauthmodule' ) {
        $preds = Kynetx::Modules::OAuthModule::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::OAuthModule::run_function( $req_info,$rule_env,$session,$rule_name,$function,$args );
        }    	
    } elsif ( $source eq 'keys' ) {
      # return the right key if it exists
      $val = Kynetx::Keys::get_key($req_info, $rule_env, $function);

      $logger->debug("Returning keys for $function");

      if ($val) {
	if ($args->[0]) {
	  $val = $val->{$args->[0]};
	}
      }  else {
	Kynetx::Errors::raise_error($req_info, 'warn',
				    "[keys] for $function not found",
				    {'rule_name' => $rule_name,
				     'genus' => 'module',
				     'species' => 'function undefined'
				    }
				   );

	$val = '';
      }
    } elsif ( $source eq 'meta' ) {
#      $logger->debug("Looking up $function in ", sub {Dumper $rule_env});
      if ($function eq 'rid') {
	$val = get_rid($req_info->{'rid'});
      } elsif ($function eq 'version') {
	$val = get_version($req_info->{'rid'});
      } elsif ($function eq 'callingRID') {
	$val = Kynetx::Environments::lookup_rule_env('_'.$function, $rule_env) || get_rid($req_info->{'rid'});
      } elsif ($function eq 'callingVersion') {
	$val = Kynetx::Environments::lookup_rule_env('_'.$function, $rule_env) || get_version($req_info->{'rid'});
      } elsif ($function eq 'moduleRID') {
	$val = Kynetx::Environments::lookup_rule_env('_'.$function, $rule_env) || get_rid($req_info->{'rid'});
      } elsif ($function eq 'moduleVersion') {
	$val = Kynetx::Environments::lookup_rule_env('_'.$function, $rule_env) || get_version($req_info->{'rid'});
      } elsif ($function eq 'inModule' ) {
	$val = Kynetx::Environments::lookup_rule_env('_'.$function, $rule_env) || 0;
      } elsif ($function eq 'hostname' ) {
	$val = Kynetx::Util::get_hostname();
      } elsif ($function eq 'rulesetName' ) {
	my $rid = get_rid($req_info->{'rid'});
	$val = $req_info->{"$rid:name"};
      } elsif ($function eq 'rulesetAuthor' ) {
	my $rid = get_rid($req_info->{'rid'});
	$val = $req_info->{"$rid:author"};
      } elsif ($function eq 'rulesetDescription' ) {
	my $rid = get_rid($req_info->{'rid'});
	$val = $req_info->{"$rid:description"};
      } else {
	$val = "No meta information for $function available";
      }

    } elsif ( $source eq 'this2that' ) {
        $preds = Kynetx::Modules::This2That::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Modules::This2That::run_function( $req_info,$function,$args );
        }    	
    } else {
	Kynetx::Errors::raise_error($req_info, 'warn',
				    "[module] named $source not found",
				    {'rule_name' => $rule_name,
				     'genus' => 'module',
				     'species' => 'module undefined'
				    }
				   );
    }

    $logger->trace("Datasource $source:$function -> ", sub {Dumper($val)});

#    return $val;
    return  Kynetx::Expressions::mk_expr_node(
    		 Kynetx::Expressions::infer_type($val),
    		 $val);

}

sub lookup_module_env {
  my ($name,$key,$env) = @_;
  my $logger = get_logger();
  $logger->debug("Find ($key) in [$name]");
  $name = $name || "";
  my $provided = Kynetx::Environments::lookup_rule_env($Kynetx::Modules::name_prefix . $name . '_provided', $env);
  #$logger->debug("Module's environment: ",sub {Dumper($provided)});

  my $r;
  if ($provided->{$key}) {
    my $mod_env = Kynetx::Environments::lookup_rule_env($Kynetx::Modules::name_prefix . $name, $env);
    $r = Kynetx::Environments::lookup_rule_env($key, $mod_env);
  }
#  $logger->debug("Returning val for $key in [$name]");
            
  return $r;
}

1;
