package Kynetx::Predicates::Page;
# file: Kynetx/Predicates/Page.pm
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


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
get_pageinfo
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use JSON::XS;

use Kynetx::Util qw(:all);
use Kynetx::Memcached qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;


my %predicates = ( );

sub get_predicates {
    return \%predicates;
}


sub get_pageinfo {
    # $field is on of the valid GeoIP record field names
    my ($req_info, $function, $args) = @_;

    my $logger = get_logger();

    my @field_names = qw(
var
env
url
);

#id


    # no caching values in this datasource

    my $val = '';
    if($function eq 'var') {
	my $vals = decode_json($req_info->{'kvars'});
	$val = $vals->{$args->[0]};
    # } elsif ($function eq 'id') {
    # 	# we're really just generating JS here.
    # 	$val = "\$K('".$args->[0]."').html()";

    } elsif($function eq 'url') {

	my $parsed_url = APR::URI->parse($req_info->{'pool'}, $req_info->{'caller'});
	my $part = $args->[0];


	if(not defined $req_info->{'caller_url'}->{$part}) {
	    $req_info->{'caller_url'}->{'protocol'} = $parsed_url->scheme;
	    $req_info->{'caller_url'}->{'hostname'} = $parsed_url->hostname;
	    $req_info->{'caller_url'}->{'path'} = $parsed_url->path;

	    my $hostname = $parsed_url->hostname;
	    my @components = split(/\./, $hostname);
	    $req_info->{'caller_url'}->{'domain'} =
	          $components[-2] . '.' . $components[-1];
	    $req_info->{'caller_url'}->{'tld'} = $components[-1];

	    if ($parsed_url->port) {
		$req_info->{'caller_url'}->{'port'} = $parsed_url->port;
	    } else {
	      if ($parsed_url->scheme eq 'http') {
		$req_info->{'caller_url'}->{'port'} = 80;
	      } else {
		$req_info->{'caller_url'}->{'port'} = 443;
	      }
	    }

	    $req_info->{'caller_url'}->{'query'} = $parsed_url->query;


	    if($logger->is_debug()) {
		foreach my $k (keys %{ $req_info->{'caller_url'} }) {
		    $logger->debug("Referer piece ($k): " .
				   $req_info->{'caller_url'}->{$k}, "\n"
			) if $req_info->{'caller_url'}->{$k};
		}
	    }

	}

	$val = $req_info->{'caller_url'}->{$part};

    } elsif($function eq 'env') {

	my %allowed = (
	    caller => 1,
	    ip => 1,
	    referer => 1,
	    rid => 1,
	    rule_version => 1,
	    title => 1,
	    txn_id  => 1,
	    g_id => 1,
	    );

	# FIXME: uncomment after Azigo implements ruleset changes
	#return '' unless $allowed{$args->[0]};

	# rulespaced env parameters
	if($req_info->{'rid'} && defined $req_info->{$req_info->{'rid'}.':'.$args->[0]}) {
	    $val = $req_info->{$req_info->{'rid'}.':'.$args->[0]};
	} elsif(defined $req_info->{$args->[0]}) {
	    $val = $req_info->{$args->[0]};
	}

    } elsif($function eq 'param') {

      # rulespaced env parameters
      if($req_info->{'rid'} && defined $req_info->{$req_info->{'rid'}.':'.$args->[0]}) {
	$val = $req_info->{$req_info->{'rid'}.':'.$args->[0]};
      } else {
	# event params don't have rid namespacing
	$val = $req_info->{$args->[0]};
      }

    } elsif($function eq 'params') {

      my %skip = (
		  rid => 1,
		  rule_version => 1,
		  txn_id  => 1,
		  kynetx_app_version => 1,
		  element => 1,
		  kvars => 1
		 );

#      $logger->debug("Req info: ", sub {Dumper($req_info)});

      my $rid = $req_info->{'rid'};

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

    } else {
      $logger->error("Unknown function $function");
    }

    return $val;

}

1;
