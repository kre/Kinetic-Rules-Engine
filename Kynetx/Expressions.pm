package Kynetx::Expressions;
# file: Kynetx/Expressions.pm
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
use utf8;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
use JSON::XS;
use Storable qw/dclone freeze/;
use Digest::MD5 qw/md5_hex/;
use Clone qw/clone/;

use Kynetx::Parser qw/:all/;
use Kynetx::JParser;
use Kynetx::Datasets;
use Kynetx::Environments qw/lookup_rule_env
    extend_rule_env/;
use Kynetx::Session qw/session_get
    session_defined
    session_within
    session_seen
    session_seen_compare
    session_seen_within
    session_history/;
use Kynetx::Operators;
use Kynetx::Modules;
use Kynetx::JavaScript;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
eval_prelude
eval_one_decl
eval_expr
eval_decl
den_to_exp
exp_to_den
infer_type
mk_den_str
typed_value
type_of
var_free_in_expr
eval_ineq
eval_pred
eval_emit
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

# make sure we get canonical freezes for good signatures.
$Storable::canonical = 1;

use constant FUNCTION_CALL_THRESHOLD => 1000;

sub eval_prelude {
    my ($req_info, $rule_env, $rule_name, $session, $pre) = @_;

    my $logger = get_logger();
#    $logger->debug("[pre] Got ", $#{ $pre }, " items.");

    $pre = [] unless defined $pre;


    my @vars = map {$_->{'lhs'}} @{ $pre};
#    $logger->debug("Prelude vars: ", sub {Dumper(@vars)});

    my @empty_vals = map {''} @vars;

    # creating an empty environment and then populating it later
    # ensures that functions can be recursive and that decls see each
    # other.


    $rule_env = extend_rule_env(\@vars, \@empty_vals, $rule_env);
#    $logger->debug("Prelude env before: ", sub {Dumper($rule_env)});

    my $js = '';

    foreach my $decl (@{ $pre }) {
	$js .= eval_one_decl($req_info, $rule_env, $rule_name, $session, $decl);
    }
#    $logger->debug("[eval_pre] Sending back $js");

    return ($js, $rule_env);
}


## we do this above and in eval_globals
##  assumes rule_env is pre-loaded with vars, side effects rule_env
sub eval_one_decl {
  my($req_info, $rule_env, $rule_name, $session, $decl) = @_;

  my $logger= get_logger();

  my($var, $val) = eval_decl($req_info, $rule_env, $rule_name, $session, $decl);

  # yes, this is cheating and breaking the abstraction, but it's fast...
  $rule_env->{$var} = $val;

#  $logger->debug("[eval_pre] $var -> ", sub {Dumper $val}) if (defined $val);

  # clone to avoid aliasing to the data structure in the env
  my  $nval = clone $val;
  $nval = Kynetx::Expressions::exp_to_den($nval);

#  $logger->debug("[eval_one_decl] after denoting:", sub{Dumper $val});
my   $jsval = Kynetx::JavaScript::gen_js_expr($nval);
  my $js = Kynetx::JavaScript::gen_js_var($var, $jsval);

  return $js
}

sub eval_decl {
    my ($req_info, $rule_env, $rule_name, $session, $decl) = @_;

    my $val = '0';

    my $logger = get_logger();

#    $logger->debug("[eval_decl]: ", sub {Dumper $decl->{'rhs'}});

    if ($decl->{'type'} eq 'expr' ) {

	my $r = eval_expr($decl->{'rhs'}, $rule_env, $rule_name, $req_info, $session);

	$val = den_to_exp($r);

#	$logger->debug("Before and After: ", sub {Dumper($r)}, sub{Dumper($val)});

#	$val = $r->{'val'} if (ref $r eq 'HASH');
#	$logger->debug("[decl] expr for ", $decl->{'lhs'}, ' -> ', sub{Dumper($val)} );

    } elsif ($decl->{'type'} eq 'here_doc') {

	$val = eval_heredoc($decl->{'rhs'});

	$logger->debug("[decl] here doc for ", $decl->{'lhs'} );
    }

    # JS is generated for all vars in the rule env
#    $logger->debug("Evaling " . $rule_name.":".$decl->{'lhs'});


    return ($decl->{'lhs'}, $val);

}




#
# evaluation of JS exprs on the server
#
#  dclone used to ensure we return a new copy, not a pointer to the env
sub eval_expr {
    my ($expr, $rule_env, $rule_name,$req_info, $session) = @_;

    my $logger = get_logger();
    $logger->trace("[javascript] expr: ", sub { Dumper($expr) });

    $rule_name ||= 'global';

    if ($expr->{'type'} eq 'str' ) {
        if ($expr->{'val'} =~ m/\#\{(.+)\}{1}?/) {
            $logger->trace("Bee sting: ",$1);
            return(eval_string($expr, $rule_env, $rule_name,$req_info, $session));
        } else {
	       return $expr;
        }
    } elsif($expr->{'type'} eq 'JS') {
	return  $expr ;
    } elsif($expr->{'type'} eq 'num') {
	return  $expr ;
    } elsif($expr->{'type'} eq 'regexp') {
	return  $expr ;
    } elsif($expr->{'type'} eq 'var') {
	my $v = lookup_rule_env($expr->{'val'},$rule_env);
	unless (defined $v) {
	    $logger->info("Variable '", $expr->{'val'}, "' is undefined");
	}
	$logger->trace($rule_name.':'.$expr->{'val'}, " -> ", $v, ' Type -> ', infer_type($v));

	# alas, closures are the only denoted vals in the env...
	if (ref $v eq 'HASH' && defined $v->{'type'} && $v->{'type'} eq 'closure') {
	  return $v;
	} else {
	  return  mk_expr_node(infer_type($v),$v);
	}
    } elsif($expr->{'type'} eq 'bool') {
	return  $expr ;
    } elsif($expr->{'type'} eq 'array') {
	return mk_expr_node('array',
			    eval_rands($expr->{'val'}, $rule_env, $rule_name, $req_info, $session)  ) ;
    } elsif($expr->{'type'} eq 'array_ref') {
	return eval_array_ref($expr, $rule_env, $rule_name, $req_info, $session);
    } elsif($expr->{'type'} eq 'hashraw') {
	return  mk_expr_node('hash',
			     eval_hash_raw($expr->{'val'}, $rule_env, $rule_name, $req_info, $session)  ) ;
    } elsif($expr->{'type'} eq 'hash') {
	return  mk_expr_node('hash',
			     eval_hash($expr->{'val'}, $rule_env, $rule_name, $req_info, $session)  ) ;
    } elsif($expr->{'type'} eq 'prim') {
	return eval_prim($expr, $rule_env, $rule_name, $req_info, $session);
    } elsif($expr->{'type'} eq 'operator') {
        $logger->trace('[javascript::eval_expr] ', sub {Dumper($expr)});
	   return Kynetx::Operators::eval_operator($expr, $rule_env, $rule_name, $req_info, $session);
    } elsif($expr->{'type'} eq 'condexpr') {
      my $test = eval_expr($expr->{'test'}, $rule_env, $rule_name, $req_info, $session);
      return
	true_value($test) ?
	  eval_expr($expr->{'then'}, $rule_env, $rule_name, $req_info, $session) :
	  eval_expr($expr->{'else'}, $rule_env, $rule_name, $req_info, $session)
    } elsif($expr->{'type'} eq 'function') {
      return mk_closure($expr, $rule_env);
    } elsif($expr->{'type'} eq 'simple') {
      # rearranges parse tree on the fly.  Should be removed after June 2010.
      return eval_application(mk_app_from_simple($expr), $rule_env, $rule_name,$req_info, $session);
    } elsif($expr->{'type'} eq 'app') {
      return eval_application($expr, $rule_env, $rule_name,$req_info, $session);
    } elsif($expr->{'type'} eq 'qualified') {
	my $den = eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
	# get the values
	for (@{ $den }) {
	    $_ = den_to_exp($_);
	}
	my $v = Kynetx::Modules::eval_module($req_info,
					     $rule_env,
					     $session,
					     $rule_name,
					     $expr->{'source'},
					     $expr->{'predicate'},
					     $den
					    );

	$logger->trace("[JS Expr] ", $expr->{'source'}, ":", $expr->{'predicate'}, " -> ", $v);

	return mk_expr_node(infer_type($v),$v);
    } elsif($expr->{'type'} eq 'persistent' ||
	    $expr->{'type'} eq 'trail_history'
	   ) {
      my $v = eval_persistent($req_info, $rule_env, $rule_name, $session, $expr);
      return mk_expr_node(infer_type($v),$v);
    } elsif($expr->{'type'} eq 'pred') {
      my $v = eval_pred($req_info, $rule_env, $session,
			$expr, $rule_name);
      return $v;
    } elsif($expr->{'type'} eq 'ineq') {
      my $v = eval_ineq($req_info, $rule_env, $session,
		     $expr, $rule_name);
      return $v;
    } elsif ($expr->{'type'} eq 'persistent_ineq') {
      my $name = $expr->{'var'};

      # check count
      my $count = 0;
      if ($expr->{'domain'} eq 'ent') {
	$count = session_get($req_info->{'rid'}, $session, $name);
      }

      $logger->debug('[persistent_ineq] ', "$name -> $count");

      my $v = ineq_test($expr->{'ineq'},
		     $count,
		     Kynetx::Expressions::den_to_exp(
			 Kynetx::Expressions::eval_expr($expr->{'expr'},
							$rule_env,
							$rule_name,
							$req_info,
							$session))
		    );


      # check date, if needed
      if ($v &&
	  defined $expr->{'within'} &&
	  session_defined($req_info->{'rid'}, $session, $name)) {

	my $tv = 1;
	if ($expr->{'domain'} eq 'ent') {
	  $tv = session_within($req_info->{'rid'},
			       $session,
			       $name,
			       Kynetx::Expressions::den_to_exp(
				   Kynetx::Expressions::eval_expr($expr->{'within'},
								  $rule_env,
								  $rule_name,
								  $req_info,
								  $session)),
			       $expr->{'timeframe'}
			      )
	}

	$v = $v && $tv;
      }
      return mk_expr_node(infer_type($v),$v);

    } elsif ($expr->{'type'} eq 'seen_timeframe') {
      my $name = $expr->{'var'};

      $logger->debug('[seen_timeframe] ', "$name");

      my $v;

      # check date, if needed
      if (defined $expr->{'within'} &&
	  session_defined($req_info->{'rid'}, $session, $name)) {

	if ($expr->{'domain'} eq 'ent') {
	  $v = session_seen_within($req_info->{'rid'},
				   $session,
				   $name,
				   $expr->{'regexp'},
				   Kynetx::Expressions::den_to_exp(
  				       Kynetx::Expressions::eval_expr($expr->{'within'},
								      $rule_env,
								      $rule_name,
								      $req_info,
								      $session)),
				   $expr->{'timeframe'}
				  )
	}
      } elsif (session_defined($req_info->{'rid'}, $session, $name)) {
	if ($expr->{'domain'} eq 'ent') {
	  # session_seen returns index (which can be 0)
	  $v = defined session_seen($req_info->{'rid'},
				    $session,
				    $name,
				    $expr->{'regexp'}
				   ) ? 1 : 0;
	}
      }
      return mk_expr_node(infer_type($v),$v);

    } elsif ($expr->{'type'} eq 'seen_compare') {
      my $name = $expr->{'var'};
      my $v;
      if ($expr->{'domain'} eq 'ent') {
	my($r1,$r2) =
	  $expr->{'op'} eq 'after' ? ($expr->{'regexp_1'},
				      $expr->{'regexp_2'})
	    : ($expr->{'regexp_2'},
	       $expr->{'regexp_1'});
	$v = session_seen_compare($req_info->{'rid'},
				  $session,
				  $name,
				  $r1,
				  $r2
				 ) ? 1 : 0; # ensure 0 returned for testing
      }
      return mk_expr_node(infer_type($v),$v);
    } elsif ($expr->{'type'} eq 'persistent') {
      my $name = $expr->{'name'};
      my $v;
      if ($expr->{'domain'} eq 'ent') {
	$v = session_defined($req_info->{'rid'}, $session, $name) &&
	  session_get($req_info->{'rid'}, $session, $name);

      }
      return mk_expr_node(infer_type($v),$v);
    } else {
      $logger->error("Unknown type in eval_expr: $expr->{'type'}");
    }

}




sub eval_prim {
    my ($prim, $rule_env, $rule_name, $req_info, $session) = @_;

    my $vals = eval_rands($prim->{'args'}, $rule_env, $rule_name, $req_info, $session);

#    my $logger = get_logger();

#    $logger->debug("[eval_prim] ", sub {Dumper $vals});

    my $val0 = den_to_exp($vals->[0]);
    my $val1 = den_to_exp($vals->[1]);

    # FIXME: Add operators
    # FIXME: Do we need more than binary?
    # FIXME: return result shold be constructed using mk_expr_node
    case: for ($prim->{'op'}) {
	/\+/ && do {

	    if($vals->[0]->{'type'} eq 'str' || $vals->[1]->{'type'} eq 'str' ) {
		return {'type' => 'str',
			'val' => $val0 . $val1};
	    } else {
		return {'type' => 'num',
			'val' => $val0 + $val1};
	    }
	};
	/-/ && do {
	    return {'type' => 'num',
		    'val' => $val0 - $val1};
	};
	/\*/ && do {
	    return {'type' => 'num',
		    'val' => $val0 * $val1};
	};
	/\// && do {
	    return {'type' => 'num',
		    'val' => $val0 / $val1};
	};
	/\%/ && do {
	    return {'type' => 'num',
		    'val' => $val0 % $val1};
	};
    }

    return 0;


}

# warning: this returns a ref to an array, not an array!
sub eval_rands {
    my ($rands, $rule_env, $rule_name, $req_info, $session) = @_;

    my $logger = get_logger();
    $logger->trace("[javascript] rands: ", sub {Dumper($rands)});
    my @rands = map {eval_expr($_, $rule_env, $rule_name, $req_info, $session)} @{ $rands } ;

    return \@rands;

}


sub eval_application {
  my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;

  my $logger = get_logger();


  # the trick to getting this right is managing env extension correctly

  #$logger->debug("Env in eval_application: ", sub { Dumper $rule_env});

 # $logger->debug("Evaluation function...", sub { Dumper $expr} );


  my $closure = eval_expr($expr->{'function_expr'},
			  $rule_env,
			  $rule_name,
			  $req_info,
			  $session
			 );

  unless ($closure->{'type'} eq 'closure') {
    $logger->warn("Function not found in ", $rule_name);
    return mk_expr_node('str', '');
  }

  $req_info->{$closure->{'val'}->{'sig'}} = 0
    unless defined $req_info->{$closure->{'val'}->{'sig'}};
  if ($req_info->{$closure->{'val'}->{'sig'}} > FUNCTION_CALL_THRESHOLD) {
    $logger->warn("Function call threshold exceeded...deep recursion?");
    return mk_expr_node('num', 0);
  }

#  $logger->debug("Evaling args ", sub {Dumper $expr->{'args'}});


  my $args = Kynetx::Expressions::eval_rands($expr->{'args'},
					      $rule_env,
					      $rule_name,
					      $req_info,
					      $session
					     );
#  $logger->debug("Got result for args: ", sub {Dumper $expr->{'args'}});

  # values in the env are expressed
  my $nargs = [ map {den_to_exp($_)} @{ $args } ];

#  $logger->debug("Executing function with args ", sub {Dumper $nargs});

  my $closure_env = extend_rule_env($closure->{'val'}->{'vars'},
				    $nargs,
				    $closure->{'val'}->{'env'});


  # this extends the env a second time
  my($js, $decls_env) =  eval_prelude($req_info,
				      $closure_env,
				      $rule_name,
				      $session,
				      $closure->{'val'}->{'decls'});

#  $logger->debug("Env: ", Dumper $decls_env);
#  $logger->debug("Env lookup: ", lookup_rule_env('n', $decls_env));

  $req_info->{$closure->{'val'}->{'sig'}}++;

  return eval_expr($closure->{'val'}->{'expr'},
		   $decls_env,
		   $rule_name,
		   $req_info,
		   $session
		  );


}


sub eval_hash_raw {
    my ($hash_lines, $rule_env, $rule_name, $req_info, $session) = @_;

    my $hash = {};
    foreach my $hl (@{ $hash_lines} ) {
	$hash->{$hl->{'lhs'}} =
	    eval_expr($hl->{'rhs'}, $rule_env,
			 $rule_name, $req_info, $session);
    }

    return $hash;

}


sub eval_hash {
    my ($hash, $rule_env, $rule_name, $req_info, $session) = @_;

    my $new_hash = {};
    foreach my $k (keys %{ $hash } ) {
	$new_hash->{$k} =
	    eval_expr($hash->{$k}, $rule_env,
			 $rule_name, $req_info, $session);
    }

    return $new_hash;

}



sub eval_array_ref {
  my($expr, $rule_env, $rule_name, $req_info, $session) = @_;

  my $logger = get_logger();


  my $v = lookup_rule_env($expr->{'val'}->{'var_expr'},$rule_env);

  unless (defined $v) {
	    $logger->warn("Variable '", $expr->{'val_expr'}, "' is undefined");
	  }

  unless (ref $v eq 'ARRAY') {
	    $logger->warn("Variable '", $expr->{'val_expr'}, "' is not an array");
	  } else {

	    $logger->trace("Using array ", sub {Dumper $v}, " with index ",sub {Dumper  $expr->{'val'}->{'index'}});

	    my $dval = eval_expr($expr->{'val'}->{'index'},
				 $rule_env,
				 $rule_name,
				 $req_info,
				 $session);
	    return typed_value($v->[den_to_exp($dval)])

	  }

}


sub eval_persistent {
    my($req_info, $rule_env, $rule_name, $session, $expr) = @_;


    my $logger = get_logger();
    my $v = 0;


    if($expr->{'domain'} eq 'ent') {
	if(defined $expr->{'offset'}) {

	    my $idx = den_to_exp(
		eval_expr($expr->{'offset'},
			     $rule_env,
			     $rule_name,
			     $req_info,
			     $session) );


	    $v = session_history($req_info->{'rid'},
				 $session,
				 $expr->{'name'},
				 $idx);
	    $logger->debug("[persistent trail] $expr->{'name'} at $idx -> $v");

	} else {
	    # FIXME: not sure I like setting to 0 by default
	    $v = session_get($req_info->{'rid'}, $session, $expr->{'name'}) || 0;
	    $logger->debug("[persistent] $expr->{'name'} -> $v");
	}

    }

    return $v;

}


sub eval_pred {
    my($req_info, $rule_env, $session, $pred, $rule_name) = @_;

    my $logger = get_logger();

#    $logger->debug("[eval_pred] ", Dumper $pred);

    my @results =
	map {Kynetx::Expressions::eval_expr($_, $rule_env, $rule_name, $req_info, $session)}
	  @{ $pred->{'args'} };

    @results = map {den_to_exp($_)} @results;

#    $logger->debug("[eval_pred] Rand values: ", Dumper @results);

    $logger->debug("Complex predicate: ", $pred->{'op'});

    if($pred->{'op'} eq '&&') {
	my $first = shift @results;
	for (@results) {
	    $first = $first && $_;
	}
	return mk_expr_node('num',$first);

    } elsif($pred->{'op'} eq '||') {
	my $first = shift @results;
	for (@results) {
	    $first = $first || $_;
	}
	return mk_expr_node('num',$first);
    } elsif($pred->{'op'} eq 'negation') {
      if ($results[0]) {
	return
	    mk_expr_node('num', 0);
      } else {
	return
	    mk_expr_node('num', 1);

      }
    } else {
	$logger->warn("Invalid predicate");
    }
    return 0;

}

sub eval_ineq {
    my($req_info, $rule_env, $session, $pred, $rule_name) = @_;

    my $logger = get_logger();

    my @results =
	map {Kynetx::Expressions::eval_expr($_, $rule_env, $rule_name, $req_info, $session)}
	  @{ $pred->{'args'} };

    if (ineq_test($pred->{'op'}, den_to_exp($results[0]), den_to_exp($results[1]))) {
      return Kynetx::Parser::mk_expr_node('num',1);
    }  else {
      return Kynetx::Parser::mk_expr_node('num',0);
    }

}

sub true_value {
  my ($d) = @_;

  my $e = den_to_exp($d);

  return
    ($d->{'type'} eq 'bool' && $e eq 'true') || $e;

}

sub ineq_test {
    my($op, $rand0, $rand1) = @_;

    my $logger = get_logger();
#    $logger->debug("[ineq_test] $rand0 $op $rand1");

    if ($op eq '<=') {
	return $rand0 <= $rand1;
    } elsif($op eq '>=') {
	return $rand0 >= $rand1;
    } elsif($op eq '<') {
	return $rand0 < $rand1;
    } elsif($op eq '>') {
	return $rand0 > $rand1;
    } elsif($op eq '==') {
	return $rand0 == $rand1;
    } elsif($op eq '!=') {
	return $rand0 != $rand1;
    } elsif($op eq 'neq') {
	    return ! ($rand0 eq $rand1);
    } elsif($op eq 'eq') {
	return $rand0 eq $rand1;
    } elsif($op eq 'like') {

      # Note: this relies on the fact that a regular expression looks like a string inside
      # the KRL AST.

      # for backward compatibility, make strings look like KRL regexp
      $rand1 = "/$rand1/" unless $rand1 =~ m#^/[^/]+/#;

      # FIXME: This is code that should be shared with replace in Operators.pm


      my $pattern = '';
      my $modifiers;
      ($pattern, $modifiers) = $rand1 =~ m#/(.+)/(i|g){0,2}#;

      $modifiers = $modifiers || '';

      my $embedable_modifiers = $modifiers;
      $embedable_modifiers =~ s/g//;

      my $re = qr/(?$embedable_modifiers)$pattern/;
#	my $re = qr!$rand1!;

      $logger->debug("Matching string $rand0 with $pattern & modifiers $modifiers: $re");

      # g modifier does nothing here...
      return $rand0 =~ /$re/;

    }
}



sub eval_heredoc {
    my ($val) = @_;

    # we post process when we emit the JS now, so no need to modify this further
    return $val;
}

sub eval_emit {
    my ($val) = @_;

    # we post process when we emit the JS now, so no need to modify this further
    return $val;
}



#
# evaluation of JS exprs on the server
#
sub den_to_exp {
    my ($expr) = @_;

#    my $logger = get_logger();

    return $expr unless (ref $expr eq 'HASH' && defined $expr->{'type'});
    case: for ($expr->{'type'}) {
	/str|num|regexp|JS/ && do {
	    return $expr->{'val'};
	};

	/bool/ && do {
	    return $expr->{'val'} eq 'true' ? 1 : 0;
	};

	/hash/ && do {
	    for my $k (keys %{ $expr->{'val'} }) {

	      $expr->{'val'}->{$k} = den_to_exp($expr->{'val'}->{$k});
	    }
	    return $expr->{'val'}
	};


	/array/ && do {
	    return [ map {den_to_exp($_)} @{ $expr->{'val'} } ];
	};

	/closure/ && do {
	  return $expr;
	};



    }

}

sub exp_to_den {
    my ($expr) = @_;

    my $logger = get_logger();

#    $logger->debug("exp_to_den:", sub { Dumper $expr});

    if (ref $expr eq 'HASH' && defined $expr->{'type'}) {
      my @keys = sort keys %{ $expr };
      # this is a looser test that
      #   defined $expr->{'val'}
      # since it allows the val to be undef
      if ($keys[1] eq 'val' ) {
	return $expr
      }
    }

    my $type = infer_type($expr);
#    $logger->debug("exp_to_den: type is $type");
    if(ref $expr eq 'HASH') {
	foreach my $k (keys %{ $expr }) {
	    $expr->{$k} = exp_to_den($expr->{$k});
	}
	return {'type' => $type,
		'val' => $expr}

    } elsif(ref $expr eq 'ARRAY') {
	my @res = map {exp_to_den($_)} @{ $expr };
	$expr = \@res;
	return {'type' => $type,
		'val' => $expr}
    } else {
	return {'type' => $type,
		'val' => $expr}
#return $expr
    }

}

# crude type inference for prims
sub infer_type {
    my ($v) = @_;
    my $t;

    return 'str' unless defined $v;

    if($v =~ m/^(\d*\.\d+|[1-9]\d+|\d)$/) { # crude type inference for primitives
	$t = 'num' ;
    } elsif($v =~ m/^(true|false)$/) {
	$t = 'bool';
    } elsif(ref $v eq 'HASH') {
	$t = 'hash';
    } elsif(ref $v eq 'ARRAY') {
	$t = 'array';
    } elsif($v =~ m/^\$K\(.*\)/) {
	$t = 'JS';
    } else {
	$t = 'str';
    }
    return $t;
}

sub mk_den_str {
    my ($v) = @_;

    return {'type' => 'str',
	    'val' => $v}
}

# this hash identifies all literal values
my %literal_types = ('str' => 1,
		     'num' => 1,
		     'bool' => 1,
		     'regexp' => 1,
		     'array' => 1,
		     'hash' => 1,
		    );

sub typed_value {
  my($val) = @_;
  unless (ref $val eq 'HASH' &&
	  defined $val->{'type'} &&
	  $literal_types{$val->{'type'}}
	 ) {
    $val = Kynetx::Parser::mk_expr_node(infer_type($val),$val);
  }
  return $val
}

sub mk_closure {
  my ($expr, $env)  = @_;
  my $sig = md5_hex(freeze $expr);

  return mk_expr_node('closure',
		      {'vars' => $expr->{'vars'},
		       'decls' => $expr->{'decls'},
		       'expr' => $expr->{'expr'},
		       'env' => $env,
		       'sig' => $sig
		      });
}

sub var_free_in_expr {
    my ($var, $expr) = @_;

#    my $logger = get_logger();
#    $logger->debug("Rule env: ", sub { Dumper($rule_env) });

    if ($expr->{'type'} eq 'str' ) {
	return 0;
    } elsif($expr->{'type'} eq 'num') {
	return  0;
    } elsif($expr->{'type'} eq 'regexp') {
	return  0;
    } elsif($expr->{'type'} eq 'var') {
#        $logger->debug("Comparing $expr->{'val'} and $var");
        return ($expr->{'val'} eq $var);
    } elsif($expr->{'type'} eq 'bool') {
	return  0;
    } elsif($expr->{'type'} eq 'array') {
      return at_least_one($expr->{'val'}, $var);
    } elsif($expr->{'type'} eq 'prim' ||
	    $expr->{'type'} eq 'pred' ||
	    $expr->{'type'} eq 'qualified') {
	return at_least_one($expr->{'args'}, $var);
    } elsif($expr->{'type'} eq 'operator') {
	return  var_free_in_expr($var, $expr->{'obj'}) ||
 	        at_least_one($expr->{'args'}, $var);
    } elsif($expr->{'type'} eq 'here_doc') {
	return  var_free_in_here_doc($var, $expr->{'rhs'});
    } elsif($expr->{'type'} eq 'condexpr') {
      	return at_least_one([$expr->{'test'},
			     $expr->{'then'},
			     $expr->{'else'}], $var);
    } else {
        return 1;
    }

}

sub at_least_one {
  my($a, $var) = @_;
  my $r = 0;
  foreach my $e (@{$a}) {
    $r ||= var_free_in_expr($var, $e);
  }
  return $r
}

sub var_free_in_here_doc {
  my ($var, $rhs) = @_;

  my $logger = get_logger();

  my @vars = ($rhs =~ /#{([^}]+)}/g);

#  $logger->debug("Vars in here_doc for $rhs: ", sub {Dumper @vars});

  my $found = 0;

  foreach my $v (@vars) {
    $found = 1 if $v eq $var;
  }

  return $found;

}

sub eval_string {
    my ($expr, $rule_env, $rule_name,$req_info, $session) = @_;
    my $logger = get_logger();
    $expr->{'val'} =~ m/(.*)\#\{(.+)\}{1}?(.*)/s;
    my $bee_expr = Kynetx::Parser::parse_expr($2);
    $logger->trace("parsed beesting: ", sub {Dumper($bee_expr)} );
    my $val = $1.eval_expr($bee_expr,$rule_env, $rule_name,$req_info, $session)->{'val'}.$3;
    return (eval_expr({'val' => $val, 'type' => 'str'}, $rule_env, $rule_name,$req_info, $session));

}

sub type_of {
  my $dval = shift;
  return $dval->{'type'};
}

sub is_closure {
  my $val = shift;
  return (ref $val eq 'HASH' && defined $val->{'type'} && $val->{'type'} eq 'closure');
}

# rearranges parse tree on the fly.  Should be removed after June 2010.
sub mk_app_from_simple {
  my $expr = shift;

  return {'args' => $expr->{'args'},
	  'type' => 'app',
	  'function_expr' => mk_expr_node('var',$expr->{'predicate'})
	 };
}

1;
