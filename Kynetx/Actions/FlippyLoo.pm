package Kynetx::Actions::FlippyLoo;
# file: Kynetx/Actions/LetItSnow.pm
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

use Kynetx::Rids qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


my $default_actions = {
    flippyloo => {
       'js' => <<EOF,
function(uniq, cb, config, sel, content) {
    KOBJ.flippylooMain();
    cb();
}
EOF
      'after' => [\&handle_delay]
    }
};


sub get_resources {
    return {
        "http://static.kobj.net/kjs-frameworks/flippy_loo/1.0/obFlippyloo.js" => { "type" => "js" }
    };
}

sub get_actions {
    return $default_actions;
}

my %predicates = ( );

sub get_predicates {
    return \%predicates;
}

sub handle_delay {
 my ($js,$req_info,$rule_env,$session,$config,$mods)  = @_;

 if (defined $mods && $mods->{'delay'}) {
   my $rule_name = $config->{'rule_name'};
   my $delay_cb =
     ";KOBJ.logger('timer_expired', '" .
       $req_info->{'txn_id'} . "'," .
	 "'none', '', 'success', '" .
	   $rule_name . "','".
	     get_rid($req_info->{'rid'}) .
	       "');";

   $js .= $delay_cb;  # add in automatic log of delay expiration

   $js = "setTimeout(function() { $js },  ($mods->{'delay'} * 1000) ); \n";
 }

 return $js;

}


1;
