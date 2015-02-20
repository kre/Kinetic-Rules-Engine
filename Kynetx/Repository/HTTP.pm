package Kynetx::Repository::HTTP;
# file: Kynetx/Repository/HTTP.pm
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
    my $url = get_uri($rid_info);
    my $ua = LWP::UserAgent->new;
    my $agent_string = "Kynetx Rule Engine/" . Kynetx::Configure::get_version();
    $ua->agent($agent_string);
    my $req;
    if ($url) {
      $req = HTTP::Request->new(GET => $url);
    } else {
      $logger->warn("No URL target configured for ",get_rid($rid_info));
      return undef;
    }
    my $password = get_password($rid_info);
    my $username = get_username($rid_info);
    if (defined $url && defined $username) {
      # Use basic auth
      $req->authorization_basic($username, $password);
    }
    my $headers = get_header($rid_info);
    if (defined $headers && ref $headers eq "HASH") {
      foreach my $key (keys %{$headers}) {
        $req->header($key => $headers->{$key});
      }
    }
    my $res = $ua->request($req);
    my $result;
    if($res->is_success) {
      $result = encode("UTF-8",$res->decoded_content);
    } else {
      my $rid = Kynetx::Rids::get_rid($rid_info);
      $logger->warn("HTTP error retrieving ruleset ID $rid: ",  $res->status_line);
      return undef;
    }

}





1;
