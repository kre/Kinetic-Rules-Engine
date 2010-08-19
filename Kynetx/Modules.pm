package Kynetx::Modules;

# file: Kynetx/Modules.pm
#
# Copyright 2007-2010, Kynetx Inc.  All rights reserved.
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
use Kynetx::Util;
use Kynetx::Expressions;
use Kynetx::Environments;
use Kynetx::Session;
use Kynetx::Actions::LetItSnow;
use Kynetx::Actions::JQueryUI;
use Kynetx::Actions::FlippyLoo;

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
use Kynetx::Predicates::Twitter;
use Kynetx::Predicates::KPDS;
use Kynetx::Predicates::Page;
use Kynetx::Predicates::Math;
use Kynetx::Predicates::Amazon;
use Kynetx::Predicates::Google;
use Kynetx::Predicates::OData;
use Kynetx::Predicates::RSS;
use Kynetx::Predicates::Facebook;
use Kynetx::Modules::HTTP;

sub eval_module {
    my ( $req_info, $rule_env, $session, $rule_name, $source, $function, $args )
      = @_;

    my $logger = get_logger();

    #   $args->[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes
    # get the values

    $logger->trace( "Datasource args ", sub { Dumper $args} );

    my $val   = '';
    my $preds = {};

    #
    # the following code is ugly for historical reasons.  Ultimately,
    # we need to clean it up so that all modules have a common
    # function name and predicates are linked into that one function
    # and this big if-then-else can go away.  Data driven FTW!
    #

    if ( $source eq 'datasource' ) {    # do first since most common
            #$val = Kynetx::Datasets::get_datasource($rule_env,$args,$function);
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
        $preds = Kynetx::Predicates::Twitter::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Twitter::eval_twitter(
                                                $req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
        }
    } elsif ( $source eq 'page' || $source eq 'event' ) {
        $preds = Kynetx::Predicates::Page::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val = Kynetx::Predicates::Page::get_pageinfo( $req_info, $function,
                                                           $args );
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
            $val =
              Kynetx::Predicates::Amazon::eval_amazon(
                                                $req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
        }
    } elsif ( $source eq 'rss' ) {
        $preds = Kynetx::Predicates::RSS::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::RSS::eval_rss($req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
        }
    } elsif ( $source eq 'google' ) {
        $preds = Kynetx::Predicates::Google::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Google::eval_google(
                                                $req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
        }
    } elsif ( $source eq 'facebook' ) {
        $preds = Kynetx::Predicates::Facebook::get_predicates();
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::Facebook::eval_facebook(
                                                $req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
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
        if ( defined $preds->{$function} ) {
            $val = $preds->{$function}->( $req_info, $rule_env, $args );
            $val ||= 0;
        } else {
            $val =
              Kynetx::Predicates::OData::eval_odata(
                                                $req_info,  $rule_env, $session,
                                                $rule_name, $function, $args );
        }
    } else {
        $logger->warn("Datasource for $source not found");
    }

    $logger->trace( "Datasource $source:$function -> ", sub { Dumper($val) } );

    return $val;

}

1;
