package Kynetx::Keys;
# file: Kynetx/Keys.pm
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

use Kynetx::JavaScript::AST qw/:all/;
use Kynetx::Environments qw/:all/;


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

  $logger->debug("Storing key $key -> $value");

  my $generate_js  = {'errorstack' => 1,
		      'googleanalytics' => 1,
		     };
		     
  my $js = '';

  my $rid = $req_info->{'rid'};

  $req_info->{$rid.':key:'.$key} = $value;

  $rule_env = extend_rule_env(mk_key($rid,$key),
			      $value, 
			      $rule_env);


  if ($generate_js->{$key}) {
    $js = KOBJ_ruleset_obj($rid). ".keys.$key = '" .
      $value . "';\n";
  }

  # this is how things used to be...
  # if ($k eq 'twitter') {
  #   $req_info->{$rid.':key:twitter'} = $ruleset->{'meta'}->{'keys'}->{$k};
  # } elsif ($k eq 'amazon') {
  #   $req_info->{$rid.':key:amazon'} = $ruleset->{'meta'}->{'keys'}->{$k};
  # } else { # googleanalytics, errorstack
  #   $js .= KOBJ_ruleset_obj($ruleset->{'ruleset_name'}). ".keys.$k = '" .
  # 	$ruleset->{'meta'}->{'keys'}->{$k} . "';\n";
  # }
  
  return ($js, $rule_env);

}

sub get_key {
  my ($req_info, $rule_env, $key) = @_;
  my $rid = $req_info->{'rid'};

#  return $req_info->{$rid.':key:'.$key};

  return lookup_rule_env(mk_key($rid,$key), 
			 $rule_env);


}

sub mk_key {
  my ($rid, $key) = @_;
  return join(':', @{[$name_prefix,$rid,$key]});
}

1;
