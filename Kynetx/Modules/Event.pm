package Kynetx::Modules::Event;

# file: Kynetx/Modules/Event.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
  all => [
    qw(
      get_eventinfo
      )
  ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use JSON::XS;
use AnyEvent::HTTP;
use DateTime::Format::RFC3339;

use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Metrics::Datapoint;
use Kynetx::Rids qw(:all);
use Kynetx::Persistence::KToken;
use Kynetx::Persistence::SchedEv;
use Kynetx::Persistence::KEN;
use Kynetx::ExecEnv;
use Kynetx::Modules::HTTP;

use Data::Dumper;
$Data::Dumper::Indent = 1;

use constant DEFAULT_EVENT_SEND_TIMEOUT => Kynetx::Configure::get_config('DEFAULT_EVENT_SEND_TIMEOUT') || 6;


my $predicates = {};

sub get_predicates {
  return $predicates;
}

my $actions = { send => { directive => \&send_event }, };

sub get_actions {
  return $actions;
}

my $funcs = {};

sub get_eventinfo {

  # $field is on of the valid GeoIP record field names
  my ( $req_info, $function, $args, $session ) = @_;

  my $logger = get_logger();

  my @field_names = qw(
    param
    params
    attr
    attrs
    env
  );

  my $val = '';

  my $rid = get_rid( $req_info->{'rid'} );

  # no caching values in this datasource

  if ( $function eq 'env' ) {

    my %allowed = (
      ip     => 1,
      rid    => 1,
      txn_id => 1,
    );

    if ( !defined $allowed{ $args->[0] } ) {
      $logger->debug( $args->[0], " is not an allowed environment variable" );
      return 0;
    }

    # rulespaced env parameters
    if ( $rid && defined $req_info->{ $rid . ':' . $args->[0] } ) {
      $val = $req_info->{ $rid . ':' . $args->[0] };
    }
    elsif ( defined $req_info->{'rid'} && $args->[0] eq 'rid' ) {
      $val = get_rid( $req_info->{'rid'} );
    }
    elsif ( defined $req_info->{'rid'} && $args->[0] eq 'rule_version' ) {
      $val = get_version( $req_info->{'rid'} );
    }
    elsif ( defined $req_info->{ $args->[0] } ) {
      $val = $req_info->{ $args->[0] };
    }

  }
  elsif ( $function eq 'param' || $function eq 'attr' ) {

    $val = get_attr( $req_info, $rid, $args->[0] );

    $logger->trace( "event:attr(", $args->[0], ") -> ", sub {Dumper $val});

  }
  elsif ( $function eq 'params' || $function eq 'attrs' ) {

    my %skip = (
      rid                => 1,
      rule_version       => 1,
      txn_id             => 1,
      kynetx_app_version => 1,
      element            => 1,
      kvars              => 1,
      _generatedby       => 1,
      _type              => 1,
      _domain            => 1,
    );

    #      $logger->debug("Req info: ", sub {Dumper($req_info)});

    my $rid = get_rid( $req_info->{'rid'} );

    my $ps;
    my $names = Kynetx::Request::get_attr_names($req_info);
    foreach my $pn ( @{$names} ) {

      # remove the prepended RID if it's there
      my $name;
      my $re = '^' . $rid . ':(.+)$';
      if ( $pn =~ /$re/ ) {
        $name = $1;
      }
      else {
        $name = $pn;
      }
      $ps->{$name} = get_attr( $req_info, $rid, $pn ) unless $skip{$name} || $name =~ m/^_.+/;

    }

    $logger->trace( "event:attrs() -> ", sub { Dumper $ps} );

    return $ps;

  }
  elsif ( $function eq 'channel' ) {
    if ( $args->[0] eq 'id' ) {
      $val = $req_info->{'id_token'};
    }
    else {
      $logger->debug("Unknown channel operation: $args->[0]");
    }

  }
  elsif ( $function eq 'type' || $function eq 'name' ) {

    $val = Kynetx::Request::get_event_type( $req_info );

    $logger->trace( "event:type() -> ", $val);

  }
  elsif ( $function eq 'domain'  ) {

    $val = Kynetx::Request::get_event_domain( $req_info );

    $logger->trace( "event:domain() -> ", $val);

  }
  elsif ( defined $funcs->{$function} ) {
    my $f = $funcs->{$function};
    eval { $val = $f->( $req_info, $function, $args, $session ); };
    if ($@) {
      $logger->warn("Event error: $@");
      return undef;
    }
  }
  else {
    $logger->error("Unknown function $function");
  }

  return $val;

}

sub get_attr {
  my ( $req_info, $rid, $name ) = @_;

  # rulespaced env parameters

  my $logger = get_logger();

  my ( $val, $attr );

  $rid ||= get_rid( $req_info->{'rid'} );
  if ( $attr = Kynetx::Request::get_attr( $req_info, $name ) ) {

    # event params don't have rid namespacing
    $val = $attr;
  }
  elsif ( $attr = Kynetx::Request::get_attr( $req_info, $rid . ':' . $name ) ) {
    $val = $attr;
  }
  return $val;
}

sub send_event {
  my ( $req_info, $dd, $config, $args, $execenv ) = @_;

  # assume $args->[0] is a subscription map (SM)
  #   subscription_map =
  #    {"name":"Phil",
  # 	"phone":"8013625611",
  # 	"token":"072a3730-2e8a-012f-d2db-00163e411455",
  # 	"calendar":"https://www.google.com/calendar/..."
  #    };

  # Only some of the records in the SM matter to the event:send()
  # action as defined below. Of course, KRL can be used to manipulate the
  # SM in various ways.

  # The only thing a subscription map MUST contain is a token OR an ESL.
  # Everything else is optional.

  # You send events with the send action in the events space:

# 	    event:send(subscription_map, event_domain, event_type) with
# 		attrs  = ...	#  map of event attributes
# 		token_key = ...	#  key for token in SM, "token" is default
# 		esl_key = ...	#  key for ESL in SM, "esl" is default; if token and esl are both present, esl wins
# So, you could simply:

  #   event:send(subscription_map,
  # 	         "notification",
  # 	         "status"
  #   	        )

  my $logger = get_logger();

  my $sm = $args->[0];

  #  $logger->debug("Subscription map: ", sub { Dumper $sm });

  my $esl_key = $config->{'esl_key'} || '_UNDEFINED_KEY_';

  my $token =
       $sm->{'cid'}
    || $sm->{'eci'}
    || $sm->{ $config->{'cid_key'} }
    || $sm->{ $config->{'eci_key'} }
    || $sm->{'token'}
    || $sm->{ $config->{'token_key'} };

  my $esl =
       $sm->{'esl'}
    || $sm->{$esl_key}
    || mk_sky_esl($token);

  my $attrs = $config->{'attrs'};

  # merge in the domain and type
  $attrs->{'_domain'} = $args->[1];
  $attrs->{'_type'}   = $args->[2];
  $attrs->{'_async'}  = 1;

  $logger->debug("Sending event $args->[1]:$args->[2] to ESL $esl");
  _send_event( $attrs, $execenv, $esl );

}

sub send_scheduled_event {
  my ($schedId)  = @_;
  my $logger     = get_logger();
  my $schedEvent = Kynetx::Persistence::SchedEv::get_sched_ev($schedId);
  
  return undef unless ($schedEvent);
  
  my $lockdown = Kynetx::Configure::get_config('SCHEDEV_PERIOD') || 599;  
  my $last = $schedEvent->{'last'};
  if (defined $last) {
    my $fired = $last->{'fired'};
    my $elapsed = time() - $fired;
    if ($elapsed < $lockdown) {
      return undef
    }
  }

  # Create a subscription map
  #
  # 1. check that the ken is still valid
  # 2. create a token because sky uses tokens
  # 3. add a ttl to it to make it temporary
  #
  my $ken = $schedEvent->{'ken'};
  my $valid = Kynetx::Persistence::KEN::get_ken_value( $ken, '_id' );
  return undef unless ($valid);
  my $token = Kynetx::Persistence::KToken::create_token( $ken, '_schedev_', '_temporary_' );
  Kynetx::Persistence::KToken::set_ttl( $token, 'ttl5' );
  my $sm = { 'token' => $token };

  # Create an ExecEnv
  my $execenv = Kynetx::ExecEnv::build_exec_env();
  my $cv      = AnyEvent->condvar();
  $execenv->set_condvar($cv);

  # Build the esl
  my $esl = mk_sky_esl($token);

  $logger->trace("ESL: $esl");

  # Create the event attributes
  # merge in the domain and type
  my $attrs;
  $attrs->{'_domain'} = $schedEvent->{'domain'};
  $attrs->{'_type'}   = $schedEvent->{'event_name'};

  #$attrs->{'_async'} = 0;

  # merge stored attrs
  my $sched_attrs = $schedEvent->{'event_attrs'};
  if ( defined $sched_attrs && ref $sched_attrs eq "HASH" ) {
    for my $key ( keys %{$sched_attrs} ) {
      my $val = $sched_attrs->{$key};
      if ( ref $val ne "" ) {
        my $json;
        eval { $json = Kynetx::Json::encode_json($val); };
        if ( $@ && not defined $json ) {
          $logger->debug("JSON encoding error $@");
          $val = "__CONTENT_NOT_JSON_COMPLIANT__";
        }
        else {
          $val = $json;
        }
      }
      $attrs->{$key} = $val;
    }
  }
  my $method      = 'POST';
  my $credentials = undef;
  my $uri         = $esl;
  my $params      = $attrs;
  my $headers     = undef;
  my $responce =
    Kynetx::Modules::HTTP::mk_http_request( $method, $credentials, $uri,
    $params, $headers );

  $logger->trace( "Response: ", sub { Dumper($responce) } );
  return ( $schedEvent, $esl, $responce );
}

sub _send_event {
  my ( $attrs, $execenv, $esl ) = @_;
  my $logger  = get_logger();
  my $timeout = DEFAULT_EVENT_SEND_TIMEOUT;                         # seconds
  my $cv      = $execenv->get_condvar();
  $cv->begin;

  my $body = join(
    '&',
    map( "$_=" . URI::Escape::uri_escape_utf8( correct_bool( $attrs->{$_} ) ),
      keys %{$attrs} )
  );

  $logger->trace( "Body of event: ", sub { Dumper $body} );

  my $request;
  $request = AnyEvent::HTTP::http_request(
    'POST' => $esl,
    'headers' =>
      { 'content-type' => "application/x-www-form-urlencoded; charset=UTF-8" },
    'timeout' => $timeout,
    'body'    => $body,
    sub {
      my ( $body, $hdr ) = @_;

      #	$logger->debug("Making HTTP post to $esl");
      $execenv->set_result(
        $esl,
        {
          'status' => $hdr->{Status},
          'reason' => $hdr->{Reason},
          'body'   => $body,
        }
      );
      # my $ilogger = get_logger();
      # $ilogger->debug( "HDR: ", sub { Dumper($hdr) } );
      if ( $hdr->{Status} =~ /^2/ ) {
        $logger->debug(
          "------------------------ event:send() success for $esl");

        # this is where we would parse returned directives and add them to $dd
      }
      else {

        my $err_msg =
"------------------------ event:send() failed for $esl, ($hdr->{Status}) $hdr->{Reason}";
        $logger->debug($err_msg);

        # I'd like to do this, but don't have $session
        # Kynetx::Errors::raise_error($req_info,
        # 			      $session,
        # 			      'error',
        # 			      $err_msg
        # 			     );

      }
      undef $request;
      $cv->end;

    }
  );

}

sub mk_sky_esl {
  my ($token) = @_;

  return "http://" . join(
    "/", Kynetx::Configure::get_config('EVAL_HOST'),    # cs.kobj.net
    "sky",
    "event",
    $token,                                             # channel ID
    int( rand(999999999) )                              # eid
  );
}

sub scheduled_event_list {
  my ( $req_info, $function, $args, $session ) = @_;
  my $logger = get_logger();
  my $rid    = get_rid( $req_info->{'rid'} );
  if ( defined $session ) {
    my $ken = Kynetx::Persistence::KEN::get_ken( $session, $rid );
    my $key = { 'source' => $rid };
    my $list = Kynetx::Persistence::SchedEv::schedev_query( $ken, $key );
    return $list;
  }
  else {
    $logger->warn("Event list requested, but session not provided");
    return undef;
  }

}
$funcs->{'get_list'} = \&scheduled_event_list;

sub delete_scheduled_event {
  my ( $req_info, $function, $args, $session ) = @_;
  my $logger = get_logger();
  my $rid    = get_rid( $req_info->{'rid'} );
  my $sched_id = $args->[0];
  return undef unless ($sched_id);
  if ( defined $session ) {
    my $ken = Kynetx::Persistence::KEN::get_ken( $session, $rid );
    my $status = Kynetx::Persistence::SchedEv::delete_sched_ev( $sched_id, $ken,$rid );
    $logger->debug("Delete $sched_id ");
    return $status;
  }
  else {
    $logger->warn("Event list requested, but session not provided");
    return undef;
  }  
}
$funcs->{'delete'} = \&delete_scheduled_event;

sub get_schedev_history {
  my ( $req_info, $function, $args, $session ) = @_;
  my $logger = get_logger();
  my $rid    = get_rid( $req_info->{'rid'} );
  $logger->trace("Args: ", sub {Dumper($args)});
  my $sched_id = $args->[0];
  return undef unless ($sched_id);
  if ( defined $session ) {
    my $f = DateTime::Format::RFC3339->new();
    my $ken = Kynetx::Persistence::KEN::get_ken( $session, $rid );
    my $sched_ev = Kynetx::Persistence::SchedEv::get_sched_ev($sched_id);
    if ( (defined $sched_ev) && 
          ($sched_ev->{'source'} eq $rid) && 
          ($sched_ev->{'ken'} eq $ken) ) {
      my $history = $sched_ev->{'last'};
      my $fired = $history->{'fired'} || 0;
      my $dt = DateTime->from_epoch(epoch => $fired);
      $history->{'fired'} = Kynetx::Predicates::Time::new($req_info,$function,[$dt]);
      if (defined $sched_ev->{'expired'}) {
        my $mongo_time_obj = $sched_ev->{'expired'};
        $history->{'keep_until'} = $f->format_datetime($mongo_time_obj);
      } elsif (defined $sched_ev->{'next_schedule'}) {
        my $epoch = $sched_ev->{'next_schedule'};
        $dt = DateTime->from_epoch(epoch => $epoch);
        my $next = Kynetx::Predicates::Time::new($req_info,$function,[$dt]);
        $history->{'next'} = $next;
      }
      return $history;
    }
  }
  else {
    $logger->warn("Event History requested, but session not provided");
    return undef;
  }  
  return undef;
}
$funcs->{'get_history'} = \&get_schedev_history;

1;
