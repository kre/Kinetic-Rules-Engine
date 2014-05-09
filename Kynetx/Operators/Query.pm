package Kynetx::Operators::Query;
# file: Kynetx/Operators/Query.pm
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

use HTML::Query qw(Query);
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Storable qw(dclone);

use Kynetx::Expressions;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
    query
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub query {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();


    $logger->debug("Query: ", sub {Dumper($expr)});
    my $obj = $expr->{'obj'};
    if ($obj->{'type'} eq "persistent") {
      $logger->debug("Persistent query");
      return optimized_hash_query($expr, $rule_env, $rule_name, $req_info, $session);
    } else {

      $obj =
          Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);
      my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
      $logger->debug("obj: ", sub {Dumper($obj)});
      $logger->debug("rands: ", sub {Dumper($rands)});
      my $selector = make_selector($rands->[0],$rule_env, $rule_name,$req_info, $session);
      my $format = "as_HTML";
      if ($rands->[1]->{'val'}){
        $format = "as_text";
      }
      my $source = make_source($obj);
      my $q = HTML::Query->new($source );
      my @elements = $q->query($selector)->$format;
      return Kynetx::Expressions::typed_value(\@elements);
  }
}

sub optimized_hash_query {
  my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
  my $logger = get_logger();
  $logger->debug("Get the full object");
  my $p_object = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);
  $logger->debug("Found: ", ref $p_object);
  my $domain = $p_object->{'domain'};
  my $inModule = Kynetx::Environments::lookup_rule_env('_inModule', $rule_env) || 0;
  my $moduleRid = Kynetx::Environments::lookup_rule_env('_moduleRID', $rule_env);
  my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
  if ($inModule) {
    $logger->debug("Evaling persistent in module: $moduleRid");
  }
  if (defined $moduleRid) {
    $rid = $moduleRid;
  }
  my $coll_name = +Kynetx::Persistence::Application::COLLECTION;
  if ($domain eq "ent") {
    $coll_name = +Kynetx::Persistence::Entity::COLLECTION;
  }
  $logger->debug("Collection: $coll_name");
  my $p_rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
  my $path_to_key = $p_rands->[0];
  my $conditions = $p_rands->[1];
  $logger->debug("Path: ",ref $path_to_key);
  $logger->debug("Conditions: ",ref $conditions);
  $logger->debug("rands: ", sub {Dumper($p_rands)});
  if (defined $path_to_key && defined $conditions) {
    if ($path_to_key->{'type'} eq "array" &&
      $conditions->{'type'} eq "hash") {
        my @keypath;
        foreach my $pathelement (@{$path_to_key->{'val'}}) {
          my $obj =
              Kynetx::Expressions::eval_expr($pathelement, $rule_env, $rule_name,$req_info, $session);
          my $clean = $obj->{'val'};
          push(@keypath,$clean);
        }
        $logger->debug("Hash path: ", sub {Dumper(@keypath)});

        my $c_obj =
            Kynetx::Expressions::eval_expr($conditions, $rule_env, $rule_name,$req_info, $session);
        $logger->debug("Conditions: ", sub{Dumper($c_obj)});
        my $c_den = Kynetx::Expressions::den_to_exp($c_obj);
        $logger->debug("Denoted: ", sub {Dumper($c_den)});
      }
  }
  $logger->warn("Bad format in query expression");
  return undef;

}

sub make_source {
    my ($obj) = @_;
    my $logger = get_logger();
    my @sources;
    if ($obj->{'type'} eq 'str') {
        push(@sources,"text" => $obj->{'val'});
    } elsif ($obj->{'type'} eq 'array') {
        foreach my $element (@{$obj->{'val'}}) {
            push(@sources,"text" => \$element);
        }
    }
    return \@sources;
}

sub make_selector {
    my ($rand,$rule_env, $rule_name,$req_info, $session) = @_;
    my @selector;
    my $logger = get_logger();
    if ($rand->{'type'} eq 'str') {
        push (@selector, $rand->{'val'});
    } elsif ($rand->{'type'} eq 'array') {
        foreach my $element (@{$rand->{'val'}}) {
            my $obj =
                Kynetx::Expressions::eval_expr($element, $rule_env, $rule_name,$req_info, $session);
            my $clean = $obj->{'val'};
            push(@selector,$clean);
        }

    }
    return join(",",@selector);
}

1;
