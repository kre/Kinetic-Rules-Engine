package Kynetx::Dispatch;
# file: Kynetx/Dispatch.pm
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

use JSON::XS;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
simple_dispatch
extended_dispatch
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;


sub simple_dispatch {
    my($req_info, $rids) = @_;

    my $logger = get_logger();
    $logger->debug("Returning dispatch sites for $rids");

    my $r = {};

    my @rids = split(/;/,$rids);
    

    foreach my $rid (@rids) {

	my $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $req_info);


	if( defined $ruleset && $ruleset->{'dispatch'} ) {
	    $logger->debug("Processing dispatch block for $rid");
#	    $logger->debug(sub() {Dumper($ruleset->{'dispatch'})});
	    $r->{$rid} = [];
	    foreach my $d (@{ $ruleset->{'dispatch'} }) {
	      push(@{ $r->{$rid} }, $d->{'domain'});
	    }
	}    
    }

#    $logger->debug(Dumper $r);

    $r = encode_json($r);
#    $logger->debug($r);

    return $r;

}

sub extended_dispatch {
    my($req_info, $rids) = @_;

    my $logger = get_logger();
    $logger->debug("Returning dispatch sites for $rids");

    my $r = {};

    my @rids = split(/;/,$rids);
    

    
    foreach my $rid (@rids) {
	$req_info->{'rid'} = $rid;

	my $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $req_info);

	$r->{$rid} = {};

	if( defined $ruleset && $ruleset->{'dispatch'} ) {
	    $logger->debug("Processing dispatch block for $rid");
#	    $logger->debug(sub() {Dumper($ruleset->{'dispatch'})});
	    foreach my $d (@{ $ruleset->{'dispatch'} }) {
#	      $logger->debug("Seeing ", sub{Dumper $d});
	      if (defined $d->{'domain'}) {
		push(@{ $r->{$rid}->{'domains'} }, $d->{'domain'});
	      } elsif (defined $d->{'iframe'}) {
		push(@{ $r->{$rid}->{'iframes'} }, $d->{'iframe'});
	      } 
	    }
	}   

# 	foreach my $rule (@{ $ruleset->{'rules'} }) {
# 	  my $events =  flatten_event_expr($rule->{'pagetype'}->{'event_expr'}) ;
# 	  $logger->debug("Events: for $rule->{'name'} ", sub {Dumper $events});

# 	  $events = [] unless $events; # for old rules that haven't been recompiled.
# 	  foreach my $e (@{$events}) {
# 	    my $domain = get_domain($e);
# 	    my $dispatch_info = get_dispatch_info($e);

# #	    $logger->debug("Domain: $domain, DI: ", sub {Dumper $dispatch_info});
# 	    push(@{ $r->{$domain}->{$rid} }, $dispatch_info);
# 	    $logger->debug("R: ", sub {Dumper $r});
# 	  }
# 	}

	foreach my $d ( keys %{$ruleset->{'rule_lists'} }) {
	  foreach my $t ( keys %{$ruleset->{'rule_lists'}->{$d} } ) {
	    if (defined $ruleset->{'rule_lists'}->{$d}->{$t}->{'filters'}) {
	    $r->{$rid}->{'events'}->{$d}->{$t} = 
	      $ruleset->{'rule_lists'}->{$d}->{$t}->{'filters'};
	    }
#	    $logger->debug("Seeing ($d, $t): ", sub {Dumper $ruleset->{'rule_lists'}->{$d}->{$t}->{'filters'}});
	  }
	}


    }

    $r = encode_json($r);
#    $logger->debug($r);

    return $r;

}

sub flatten_event_expr {
  my($expr) = @_;

  if ($expr->{'type'} eq 'prim_event') {
    return [$expr];
  } elsif ($expr->{'type'} eq 'complex_event') {

    my @args = ($expr->{'op'} eq 'notbetween' ||
		$expr->{'op'} eq 'between') ? 
	  ($expr->{'first'}, $expr->{'mid'}, $expr->{'last'}) :
	  @{ $expr->{'args'} } ;
    my @r;
    foreach my $a (@args) {
       push @r,  @{flatten_event_expr($a)};
    }
    return \@r;
  }

}

sub get_domain {
  my($expr) = @_;

  if (ref $expr eq 'HASH' && defined $expr->{'domain'}) {
    return $expr->{'domain'};
  } else {
    return 'web';
  }
}

sub get_dispatch_info {
  my($expr) = @_;

  my $logger = get_logger();
  $logger->debug("Expr is a ", sub {Dumper $expr});
  
  return {'hello' => 'world'} unless (ref $expr eq 'HASH');
  if ($expr->{'op'} eq 'pageview') {
    return {'pattern' => $expr->{'pattern'},
	    'type' => $expr->{'op'}};
  } elsif ($expr->{'op'} eq 'submit' ||
	   $expr->{'op'} eq 'change' ||
	   $expr->{'op'} eq 'click'
	  ) {
    return {'elem' => $expr->{'elem'},
	    'type' => $expr->{'op'}};
  } else {
    return {};
  }
}

1;
