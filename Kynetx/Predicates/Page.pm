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


my %predicates = ( );

sub get_predicates {
    return \%predicates;
}


sub get_pageinfo {
    # $field is on of the valid GeoIP record field names
    my ($req_info, $function, $args) = @_;

    my @field_names = qw(
var
env
url
id
);

    # no caching values in this datasource

    my $val = '';
    if($function eq 'var') {
	my $vals = decode_json($req_info->{'kvars'});
	$val = $vals->{$args->[0]};
    } elsif ($function eq 'id') {
	# we're really just generating JS here.
	$val = "K\$('".$args->[0]."').innerHTML";
	
    } elsif($function eq 'url') {

	my $parsed_url = APR::URI->parse($req_info->{'pool'}, $req_info->{'caller'});
	my $part = $args->[0];


	if(not defined $req_info->{'caller_url'}->{$part}) {
	    $req_info->{'caller_url'}->{'protocol'} = $parsed_url->scheme;
	    $req_info->{'caller_url'}->{'hostname'} = $parsed_url->hostname;
	    $req_info->{'caller_url'}->{'path'} = $parsed_url->path;

	    my $hostname = $parsed_url->hostname;
	    my ($domain, $tld) = $hostname =~ /.*\.(.+)\.(.+)$/;
	    $domain .= ".$tld";
	    $req_info->{'caller_url'}->{'domain'} = $domain;
	    $req_info->{'caller_url'}->{'tld'} = $tld;

	    if ($parsed_url->port) { 
		$req_info->{'caller_url'}->{'port'} = $parsed_url->port;
	    } else { 
		$req_info->{'caller_url'}->{'port'} = 80;
	    }

	    $req_info->{'caller_url'}->{'query'} = $parsed_url->query;
	    
	    my $logger = get_logger();

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

      # FIXME: should namespace params so that this can't be used to grab random
      #        req_info items.

      # rulespaced env parameters
      if($req_info->{'rid'} && defined $req_info->{$req_info->{'rid'}.':'.$args->[0]}) {
	$val = $req_info->{$req_info->{'rid'}.':'.$args->[0]};
      }

    }

    return $val;

}

1;
