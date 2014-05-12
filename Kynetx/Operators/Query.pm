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
  my $domain = $expr->{'obj'}->{'domain'};
  my $inModule = Kynetx::Environments::lookup_rule_env('_inModule', $rule_env) || 0;
  my $moduleRid = Kynetx::Environments::lookup_rule_env('_moduleRID', $rule_env);
  my $rid = Kynetx::Rids::get_rid($req_info->{'rid'});
  if ($inModule) {
    $logger->debug("Evaling persistent in module: $moduleRid");
  }
  if (defined $moduleRid) {
    $rid = $moduleRid;
  }
  $logger->debug("Get the full object");
  my $p_object = Kynetx::Persistence::get_persistent_var($domain,
                 $rid,
                 $session,
                 $expr->{'obj'}->{'name'}) || 0;
  $logger->debug("Found: ", sub {Dumper($p_object)});

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
        my $ken = Kynetx::Persistence::KEN::get_ken($session,$rid);
        my $results = do_queries($domain,$rid,$ken,\@keypath,$c_den);
        #my $results = Kynetx::MongoDB::get_list(_base_key($domain,$rid,$ken,\@keypath,$c_den));
        
      }
  }
  $logger->warn("Bad format in query expression");
  return undef;

}

sub do_queries {
  my ($domain,$rid,$ken,$keypath,$c_den) = @_;
  foreach my $condition (@{$c_den->{'conditions'}}) {
    my ($collection,$base) = _base_key($domain,$rid,$ken,$keypath);
    add_conditions_key($base,$condition);
    my $query = Kynetx::MongoDB::get_list($collection,$base);
    $logger->debug("Found: ", scalar @{$query},sub {Dumper $condition});
  }
  
}

sub _conditions_key {
  my ($base,$cond) = @_;
  my $logger = get_logger();
  my @c;    
  my $skey = $cond->{'search_key'};
  my $operator = $cond->{'operator'};
  my $value = $cond->{'value'};
  push(@{$base},{'hashkey' => {'$all' => $skey}});
  push(@{$base},{'value' => {$operator => $value}});
}


sub _parse_results {
  my ($results,$keypath,$conditions) = @_;
  my $logger = get_logger();
  my $matches;
  my $target = 1;
  my $type = $conditions->{'requires'};
  my $index = 0;
  if (defined $keypath && ref $keypath eq "ARRAY") {
    $index = scalar @{$keypath};
  }
  $logger->debug("Keypath: ", sub {Dumper($keypath)});
  foreach my $val (@{$results}) {
    my $path = $val->{'hashkey'};    
    my @key = @{$path}[0 .. $index];    
    my $key = join('_,_',@key);
    $matches->{$key}++;
  }  
  $logger->debug("Matches: ", sub {Dumper($matches)});
  if ($type eq '$and') {
    $target = unique_conditions($conditions);
  }
  my @results;
  foreach my $match (keys %{$matches}) {
    $logger->debug("Num: $matches->{$match} target: $target");
    if ($matches->{$match} >= $target) {
      my @key = split(/_,_/,$match);
      $logger->debug("Key: ", sub {Dumper(@key)});
      push(@results,\@key);
    }
  }
  return \@results;
}

sub condition_signature {
  my ($condition) = @_;
  my $path = $condition->{'search_key'};
  my $key = join("--",@{$path});
  return $key;
}

sub unique_conditions {
  my ($conditions) = @_;
  my $count;
  foreach my $cond (@{$conditions->{'conditions'}}) {
    $count->{condition_signature($cond)}++;
  }
  return scalar keys %{$count};
}

sub _base_key {
  my ($domain,$rid,$ken,$base_path) = @_;
  my $logger = get_logger();
  $rid = Kynetx::Rids::get_rid($rid);
  my $root;
  my @r_conditions;
  my $collection;
  $logger->debug("Domain: $domain");
  if ($domain eq "ent") {
    $collection = +Kynetx::Persistence::Entity::COLLECTION;
  }
  if ($domain eq "ent") {
    $root = {
        "ken" => $ken,
        "rid" => $rid};
    $collection = +Kynetx::Persistence::Entity::COLLECTION;
  } else {
    $root = {
        "rid" => $rid};
        $collection = +Kynetx::Persistence::Application::COLLECTION;
  }
  push(@r_conditions, $root);
  if (ref $base_path eq "ARRAY" && (scalar @{$base_path} >0)){
    push(@r_conditions,{'hashkey' => {'$all' => $base_path}});
  }
  return ($collection,\@r_conditions);
}


sub _search_key {
  my ($conditions) = @_;
  return $conditions->{'search_key'};
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
