package Kynetx::Modules::RuleEnv;
# file: Kynetx/Modules/RuleEnv.pm
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
use Data::Dumper;


use Kynetx::Repository;
use Kynetx::Rids;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



  # my $re_key = "rule_env_".$module_sig;
  # my $pr_key = "provided_".$module_sig;
  # my $js_key = "js_".$module_sig;
  # my $module_cache = $memd->get_multi($re_key, $pr_key, $js_key);


  # my $module_rule_env = $module_cache->{$re_key};
  # my $provided = $module_cache->{$pr_key} || {};
  # my $js = $module_cache->{$js_key} || '';

sub get_module_cache {
  my($module_sig, $memd) = @_;

  return $memd->get_multi(get_re_key($module_sig), get_pr_key($module_sig), get_js_key($module_sig));
}

sub get_re_key {
  my($module_sig) = @_;
  return "rule_env_".$module_sig;
}

sub get_pr_key {
  my($module_sig) = @_;
  return "provided_".$module_sig;
}

sub get_js_key {
  my($module_sig) = @_;
  return "js_".$module_sig;
}


sub get_msig_list {
  my ($req_info, $memd) = @_;

  # build a list of module sigs associated with a calling rid/version
  my $msig_list_cache_key = get_msig_cache_key($req_info);


  return $memd->get($msig_list_cache_key);

}

sub get_msig_cache_key {
  my ($req_info) = @_;

  return "msigs_".Kynetx::Repository::make_ruleset_key(
	      Kynetx::Rids::get_rid($req_info->{'rid'}),
	      Kynetx::Rids::get_version($req_info->{'rid'})
	     );

}

sub set_module_cache {
  my($module_sig, $req_info, $memd, $js, $provided, $module_rule_env) = @_;
  $memd->set(get_js_key($module_sig), $js);
  $memd->set(get_pr_key($module_sig), $provided);
  $memd->set(get_re_key($module_sig), $module_rule_env);

  my $msig_list = get_msig_list($req_info, $memd);
  $msig_list->{$module_sig} = 1;

  # build a list of module sigs associated with a calling rid/version
  my $msig_list_cache_key = get_msig_cache_key($req_info);

  $memd->set($msig_list_cache_key, $msig_list);
}


# delete all the module caches associated with a rid
sub delete_module_caches {
  my($req_info, $memd) = @_;

  my $logger = get_logger();

  my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
  my $version = Kynetx::Rids::get_version($req_info->{'rid'});

  my $msig_list_cache_key = get_msig_cache_key($req_info);

  my $msig_list = get_msig_list($req_info, $memd);

  if (defined $msig_list) {
    $logger->debug("Flushing module environments for $rid.$version with module signatures ", sub {Dumper $msig_list});
    foreach my $sig (keys %{$msig_list}) {

      $memd->delete(get_re_key($sig));
      $memd->delete(get_pr_key($sig));
      $memd->delete(get_js_key($sig));
    }
    $memd->delete($msig_list_cache_key);
  }

}

1;
