package Kynetx::Repository::XDI;
# file: Kynetx/Repository/XDI.pm
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
use APR::URI;
use Encode;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Data::Dumper;
$Data::Dumper::Indent = 1;
use XDI;
use XDI::Connection;


use Kynetx::Memcached qw(:all);
use Kynetx::Json qw(:all);
use Kynetx::Predicates::Page;
use Kynetx::Rules;
use Kynetx::Rids qw(:all);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

# $sversion allows modules to specify the version of the ruleset that is requested
# $text requests the krl not the ast
sub get_ruleset {
    my ($rid_info) = @_;
    my $logger = get_logger();
    my $ruleset;
    my $xdi_uri = get_uri($rid_info);
    $xdi_uri =~ s/xri:\/\///;
    $logger->debug("XDI statement: $xdi_uri");
    my $from = get_username($rid_info);
    my $from_graph = Kynetx::Configure::get_config('xdi')->{'inumber'};	
    my $xdi = new XDI ( {
			'from' => $from,
			'from_graph' => $from_graph
		});
		my $target = $from;
		my $secret = get_password($rid_info);
		my $lc = $rid_info->{'link_contract'};
		my $c = $xdi->connect({
			'target' => $target,
			'secret' => $secret
		});
    my $msg = $c->message();
		if (defined $lc) {
		  $msg->link_contract($lc);
		}
    $msg->get($xdi_uri);
    my $graph = $c->post($msg);
    my $element = XDI::get_literal($graph,$xdi_uri);
    $logger->debug("XDI result: ",sub {Dumper($element)});
    return $element;
}





1;
