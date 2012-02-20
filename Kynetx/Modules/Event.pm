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

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_eventinfo
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use JSON::XS;

use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Rids qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my $predicates = {
};

sub get_predicates {
    return $predicates;
}


my $actions = {
    send => {
      directive => \&send_event
    },
};

sub get_actions {
    return $actions;
}


sub get_eventinfo {
    # $field is on of the valid GeoIP record field names
    my ($req_info, $function, $args) = @_;

    my $logger = get_logger();

    my @field_names = qw(
param
params
attr
attrs
env
);

    my $val = '';

    my $rid = get_rid($req_info->{'rid'});

    # no caching values in this datasource

    if($function eq 'env') {

	my %allowed = (
	    ip => 1,
	    rid => 1,
	    txn_id  => 1,
	    );

	if ( ! defined $allowed{$args->[0]} ) {
	  $logger->debug($args->[0], " is not an allowed environment variable");
	  return 0;
	} ;


	# rulespaced env parameters
	if($rid && defined $req_info->{$rid.':'.$args->[0]}) {
	    $val = $req_info->{$rid.':'.$args->[0]};
	} elsif(defined $req_info->{'rid'} && $args->[0] eq 'rid') {
	    $val = get_rid($req_info->{'rid'});
	} elsif(defined $req_info->{'rid'} && $args->[0] eq 'rule_version') {
	    $val = get_version($req_info->{'rid'});
	} elsif(defined $req_info->{$args->[0]}) {
	    $val = $req_info->{$args->[0]};
	}

    } elsif($function eq 'param' || $function eq 'attr') {

      # rulespaced env parameters
      if (defined $req_info->{$args->[0]}) {
	# event params don't have rid namespacing
	$val = $req_info->{$args->[0]};
      } elsif($rid && defined $req_info->{$rid.':'.$args->[0]}) {
	$val = $req_info->{$rid.':'.$args->[0]};
      } 

      $logger->debug("event:attr(", $args->[0], ") -> ", $val);

    } elsif($function eq 'params' || $function eq 'attrs') {

      my %skip = (
		  rid => 1,
		  rule_version => 1,
		  txn_id  => 1,
		  kynetx_app_version => 1,
		  element => 1,
		  kvars => 1
		 );

#      $logger->debug("Req info: ", sub {Dumper($req_info)});

      my $rid = get_rid($req_info->{'rid'});

      my $ps;
      foreach my $pn (@{$req_info->{'param_names'}}) {
	# remove the prepended RID if it's there
	my $npn = $pn;
        my $re = '^' . $rid . ':(.+)$';
	if ($pn =~ /$re/) {
	  $npn = $1;
	}
#	$logger->debug("Using $npn as param name");
	$ps->{$npn} = $req_info->{$pn} unless $skip{$pn} || $skip{"$rid:$npn"};
      }

      return $ps;

    } elsif($function eq 'channel') {
      if ($args->[0] eq 'id') {
	$val = $req_info->{'id_token'};
      } else {
	$logger->debug("Unknown channel operation: $args->[0]");
      }
      

    } else {
      $logger->error("Unknown function $function");
    }

    return $val;

}


sub send_event {
  my($req_info, $config, $args) = @_;

  # assume $args->[0] is array of subscription maps

  # A subscription list is an array of subscription maps (SM):

  #   subscriptions =
  #     [{"name":"Phil",
  # 	"phone":"8013625611",
  # 	"token":"072a3730-2e8a-012f-d2db-00163e411455",
  # 	"calendar":"https://www.google.com/calendar/..."
  # 	"type" : "alert"
  #      },
  #      {"name":"John",
  # 	"phone":"8016023200",
  # 	"token":"fc435280-2b40-012f-cfea-00163e411455",
  # 	"calendar":"https://www.google.com/calendar/..."
  #      }
  #     ];

  # How you get a subscription list depends on a lot of things. It can
  #   contain many things, but only some of them matter to the event:send()
  #     action as defined below. Of course, KRL can be used to manipulate the
  # 	subscription list in various ways.

  # 	  The only thing a subscription map MUST contain is a token OR an ESL.
  # 	    Everything else is optional.

  # 	      You send events with the send action in the events space:

  # 	    event:send(subscriptions, event_domain, event_type) with
  # 		attrs  = ...	#  map of event attributes
  # 	        domain_key = ... # key in SM giving domain for this event, overrides event_domain if override = true; default "domain"
  # 		type_key = ... # key in SM giving type for this event,overrides event_type if override = true; defaul "type"
  # 		override = ... # boolean, false means use specified event for all subscribers; default false
  # 		attrs  = ... #  map of event attributes
  # 		token_key = ...	#  key for token in SM, "token" is default
  # 		esl_key = ...	#  key for ESL in SM, "esl" is default; if token and esl are both present, esl wins
  # 		attr_key = ... #  key for attributes in SM, merged w/ attr; overrides specified attr if override = true

  # 	  So, you could simply:


  #   event:send(channel_id,
  # 	         "notification",
  # 	         "status"
  #   	        ) 


}

1;
