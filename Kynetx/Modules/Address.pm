package Kynetx::Modules::Address;
# file: Kynetx/Modules/Address.pm
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
use Geo::StreetAddress::US;
use Data::Dumper;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
};

my $default_actions = {
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



sub run_function {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();
    my $addr_str = $args->[0];
    my $resp = '';
    my $found;
    return $resp unless ($addr_str && ref $addr_str eq '');
    my $href = Geo::StreetAddress::US->parse_location($addr_str);
    map {$found->{$_} = 1} keys %$href;
    $logger->debug("Address struct: ", sub {Dumper($href)});
    if($function eq 'all') {
      return $href;
    } elsif ($found->{$function}) {
      my $result = $href->{$function};
      if ($result) {
          return $result;
      } else {
          return '';
      }
    } else {
      $logger->warn("Unknown function '$function' called in Address library");
    }

    return $resp;
}



1;
