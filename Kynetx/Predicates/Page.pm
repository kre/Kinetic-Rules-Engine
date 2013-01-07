package Kynetx::Predicates::Page;
# file: Kynetx/Predicates/Page.pm
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
use Kynetx::Rids qw(:all);

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

    my $rid = get_rid($req_info->{'rid'});

    # no caching values in this datasource

    my $val = '';
    if($function eq 'var') {
	my $vals = decode_json($req_info->{'kvars'});
	$val = $vals->{$args->[0]};
    # } elsif ($function eq 'id') {
    # 	# we're really just generating JS here.
    # 	$val = "\$K('".$args->[0]."').html()";

    } elsif($function eq 'url') {


      return '' unless $req_info->{'caller'};
	my $parsed_url = URI->new($req_info->{'caller'});
	my $part = $args->[0];


	if(not defined $req_info->{'caller_url'}->{$part}) {
	    $req_info->{'caller_url'}->{'protocol'} = $parsed_url->scheme;
	    $req_info->{'caller_url'}->{'hostname'} = $parsed_url->host;
	    $req_info->{'caller_url'}->{'path'} = $parsed_url->path;

	    my $hostname = $parsed_url->host || "";
	    my @components = split(/\./, $hostname);
	    my $c2 = $components[-2];
	    my $c1 = $components[-1];
	    $req_info->{'caller_url'}->{'domain'} =
	          $c2 . '.' . $c1;
	    $req_info->{'caller_url'}->{'tld'} = $c1;

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

      $val = Kynetx::Modules::Event::get_eventinfo($req_info, $function, $args);

      # rulespaced env parameters
      # if (defined $req_info->{$args->[0]}) {
      # 	# event params don't have rid namespacing
      # 	$val = $req_info->{$args->[0]};
      # } elsif($rid && defined $req_info->{$rid.':'.$args->[0]}) {
      # 	$val = $req_info->{$rid.':'.$args->[0]};
      # } 

      $logger->debug("page:attr(", $args->[0], ") -> ", $val);

    } elsif($function eq 'params' || $function eq 'attrs') {

      $val = Kynetx::Modules::Event::get_eventinfo($req_info, $function, $args);

#       my %skip = (
# 		  rid => 1,
# 		  rule_version => 1,
# 		  txn_id  => 1,
# 		  kynetx_app_version => 1,
# 		  element => 1,

# 		  kvars => 1
# 		 );

# #      $logger->debug("Req info: ", sub {Dumper($req_info)});

#       my $rid = get_rid($req_info->{'rid'});

#       my $ps;
#       foreach my $pn (@{$req_info->{'param_names'}}) {
# 	# remove the prepended RID if it's there
# 	my $npn = $pn;
#         my $re = '^' . $rid . ':(.+)$';
# 	if ($pn =~ /$re/) {
# 	  $npn = $1;
# 	}
# #	$logger->debug("Using $npn as param name");
# 	$ps->{$npn} = $req_info->{$pn} unless $skip{$pn} || $skip{"$rid:$npn"};
#       }

      return $val;

    } else {
      $logger->error("Unknown function $function");
    }

    return $val;

}

1;
