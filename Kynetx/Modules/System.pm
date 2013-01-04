package Kynetx::Modules::System;
# file: Kynetx/Modules/System.pm
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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


my $predicates = {
};

sub get_predicates {
    return $predicates;
}

my $actions = {
};

sub get_actions {
    return $actions;
}



sub raise_system_event {
  my ($req_info, $rule_name, $event_type, $attributes
     ) = @_;
  my $logger = get_logger();

#  $logger->debug("Raising system event with type $event_type");

  # make modifiers in right form for raise expr
  my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
  my $ver = Kynetx::Rids::get_version($req_info->{'rid'});

  # create an expression to pass to eval_raise_statement
  my $expr = {'type' => 'raise',
	      'domain' => 'system',
	      'ruleset' => {'val'=>$rid.".".$ver, 'type' => 'str'},
	      'event' => Kynetx::Parser::mk_expr_node('str',$event_type),
	      'modifiers' => $attributes
	     };

  # these don't need to be real since we've pre-eval'd everything
  my $rule_env = Kynetx::Environments::empty_rule_env();
  my $session = {"_session_id" => "31831839173918379131"};

  my $js = Kynetx::Postlude::eval_raise_statement($expr,
						  $session,
						  $req_info,
						  $rule_env,
						  $rule_name
						 );

}



1;
