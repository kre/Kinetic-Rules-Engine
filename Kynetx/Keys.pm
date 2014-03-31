package Kynetx::Keys;
# file: Kynetx/Keys.pm
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

use Kynetx::JavaScript::AST qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Rids qw/:all/;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

our $name_prefix = '@@keys_';


sub process_keys {
  my($req_info, $rule_env, $ruleset) = @_;
  my $logger = get_logger();

  my $js = '';

  my $this_js;
  # set up JS
  $js .= KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) . " =  " . KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) . " || {};\n";
  $js .= KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) .  ".keys = " . KOBJ_ruleset_obj($ruleset->{'ruleset_name'}) . ".keys || {};\n";

  $logger->debug("Found keys; generating JS for $ruleset->{'ruleset_name'}");
  foreach my $k (keys %{ $ruleset->{'meta'}->{'keys'} }) {
     ($this_js, $rule_env) = insert_key($req_info, 
					$rule_env, 
					$k, 
					$ruleset->{'meta'}->{'keys'}->{$k});
     $js .= $this_js;
  }

  return($js, $rule_env);
}


sub insert_key {
  my ($req_info, $rule_env, $key, $value) = @_;

  my $logger = get_logger();

  my $rid = get_rid($req_info->{'rid'});

  $logger->debug("Storing key $key");


  my $generate_js  = {'errorstack' => 1,
		      'googleanalytics' => 1,
		     };
		     
  my $js = '';

# OLD way
#  $req_info->{$rid.':key:'.$key} = $value;

  $rule_env = extend_rule_env(mk_key($key), # rid no longer needed
			      $value, 
			      $rule_env);


  if ($generate_js->{$key}) {
    $js = KOBJ_ruleset_obj($rid). ".keys.$key = '" .
      $value . "';\n";
  }

  return ($js, $rule_env);

}

sub get_key {
  my ($req_info, $rule_env, $key) = @_;

  # my $logger = get_logger();
  # $logger->debug("Rid: $rid, Key: $key");

#  return $req_info->{$rid.':key:'.$key};

  return lookup_rule_env(mk_key($key), 
			 $rule_env);


}

sub mk_key {
  my ($key) = @_;
#  my $logger = get_logger();
#  $logger->info("Key: $key Np: $name_prefix");
  # don't need the rid now that we're in rule_envs
  return join(':', @{[$name_prefix,$key]});
}

1;
