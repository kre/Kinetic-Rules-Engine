package Kynetx::JavaScript;
# file: Kynetx/JavaScript.pm
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
use Storable qw(dclone);

use Kynetx::Parser qw/mk_expr_node/;
use Kynetx::Datasets q/:all/;
use Kynetx::Environments q/:all/;
use Kynetx::Session q/:all/;
use Kynetx::Operators q/:all/;
use Kynetx::Predicates q/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
gen_js_expr
gen_js_var
gen_js_prim
gen_js_rands
eval_js_pre
eval_one_decl
gen_js_callbacks
gen_js_afterload
gen_js_mk_cb_func
get_js_html
mk_js_str
eval_js_expr
eval_js_decl
den_to_exp
exp_to_den
infer_type
typed_value
escape_js_str
var_free_in_expr
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

# this is NOT a JavaScript evaluater.  Rather, it creates JS strings
# from Perly parse trees.  So, more like a pretty-printer.  


sub gen_js_expr {
    my $expr = shift;

#    my $logger = get_logger();

    case: for ($expr->{'type'}) {
	/str/ && do {


	  return mk_js_str($expr->{'val'});

#	  $logger->debug("Seeing ", Dumper $expr);
	  
# 	  unless (defined $expr->{'val'}) {
# #	    $logger->debug('returning empty string');
# 	    return "''" ;
#           }

# 	    $expr->{'val'} = escape_js_str($expr->{'val'});

# 	    # any string is potentially a JS template...
# 	    # relace tmpl vars with concats for JS
# 	    $expr->{'val'} =~ y/\n\r/  /; # remove newlines
# 	    $expr->{'val'} =~ s/#{([^}]*)}/'+$1+'/g;

# 	    return '\'' . $expr->{'val'} . '\'';
	};
	/num/ && do {
	    return  $expr->{'val'} ;
	};
	/JS/ && do {
	    return  $expr->{'val'} ;
	};
	/var/ && do {
	    return  $expr->{'val'} ;
	};
	/bool/ && do {
	    return  $expr->{'val'} ;
	};
	/array/ && do {
	    return  "[" . join(', ', @{ gen_js_rands($expr->{'val'}) }) . "]" ;
	};
	/hashraw/ && do {
	    return  gen_js_hash_lines($expr->{'val'});
	};
	/hash/ && do {
	    return  gen_js_hash($expr->{'val'});
	};
	/prim/ && do {
	    return gen_js_prim($expr);
	};
	/^ineq|pred$/ && do {
	    return gen_js_pred($expr);
	};
        /condexpr/ && do {
	    return gen_js_condexpr($expr);
	};
        /function/ && do {
	    return gen_js_function($expr);
	};
	# FIXME: need to eval these, not ignore them
	# no sense generating simple, most qualified, and counter preds for JS
 	/qualified/ && do {

	    my $rands = gen_js_rands($expr->{'args'});

	    my $v = gen_js_datasource($expr->{'source'},
				      $expr->{'predicate'},
				      $rands
		);
	    return $v;
	};
    } 
}

sub gen_js_var {
  my ($lhs, $rhs) = @_;
  return "var $lhs = $rhs;\n";
}

sub gen_js_prim {
    my $prim = shift;

    return '(' .join(' ' . $prim->{'op'} . ' ', @{ gen_js_rands($prim->{'args'}) }) . ')';

    
}

sub gen_js_condexpr {
    my $cond = shift;

    return gen_js_predexpr($cond->{'test'}) . ' ? ' . 
           gen_js_expr($cond->{'then'}) . ' : ' . 
	   gen_js_expr($cond->{'else'});

    
}

sub gen_js_function {
    my $func = shift;

#     my $logger = get_logger();

#     $logger->debug("Function: ", Dumper $func);

    my $decls = '';
    foreach my $d (@{ $func->{'decls'} }) {


      # note that this won't work for everything.  Functions that include KRL exprs that
      # are not translatable to JS without evaluation won't work.  

      my $rhs = mk_js_str('');
      if ($d->{'type'} eq 'expr') {
	$rhs = gen_js_expr($d->{'rhs'});
      } elsif ($d->{'type'} eq 'here_doc') {
	$rhs = gen_js_exp(exp_to_den(eval_heredoc($d->{'rhs'})));
      } 

      $decls .= gen_js_var($d->{'lhs'}, $rhs);
    }

    my $js = "function(".
              join(", ", @{ $func->{'vars'} }) .
	      ") {" .
	      $decls .
	      gen_js_expr($func->{'expr'}).
	      "}";

    return $js;

    
}

sub gen_js_rands {
    my ($rands) = @_;

    my @rands = map {gen_js_expr($_)} @{ $rands } ;

#    my $logger = get_logger();
#    $logger->debug("Args: ", sub { join(", ", @rands) });

    return \@rands;

}

sub gen_js_hash {
    my ($hash_items) = @_;

    my $logger = get_logger();

#    $logger->debug(Dumper($hash_items));

    $hash_items = exp_to_den($hash_items);
#    $logger->debug(Dumper($hash_items));
    my @items;
    foreach my $k (keys %{ $hash_items->{'val'} }) {
#      $logger->debug("Seeing $k ", Dumper $hash_items->{'val'}->{$k}) 
#	if $k eq 'geo';
      push(@items, "'" . $k . "' :"  . gen_js_expr($hash_items->{'val'}->{$k}));
    }
    my $js =  '{' . join(",", @items) . '}';
#    $logger->debug($js);

    return $js;
}


sub gen_js_hash_lines {
    my ($hash_lines) = @_;

    my $logger = get_logger();

#   $logger->debug(Dumper($hash_lines));

    my @res = map {gen_js_hash_line($_)} @{ $hash_lines } ;
    $hash_lines = "{" . join(', ', @res) . "}" ;
    
    return $hash_lines;
}

sub gen_js_hash_line {
    my ($hash_line) = @_;

    return "'" . $hash_line->{'lhs'} ."' : " . gen_js_expr($hash_line->{'rhs'});


}

sub gen_js_datasource {
    my($source, $function, $args) = @_;
  
    my $val = '';

    if($source eq 'page') {
	if ($function eq 'id') {
	    $val = "K\$(".$args->[0].").innerHTML";
	}
    }

    return $val;

}


sub gen_js_pred {
    my $pred = shift;
    
    if($pred->{'op'} eq 'negation') {
	return '!' . gen_js_predexpr($pred->{'args'}->[0]) ;
    } else {
	return 
	    '(' . 
	    join(' ' . $pred->{'op'} . ' ', @{ gen_js_rands($pred->{'args'}) }) .
	    ')';
    }

    
}


# expressions below
sub gen_js_predexpr {
    my $expr = shift;

#    my $logger = get_logger();

    if($expr->{'type'} eq "ineq") {
	    return  '('. join(' ' . $expr->{'op'} . ' ', 
			@{ gen_js_rands($expr->{'args'}) }) . ')'  ;
# 	/seen_timeframe/ && do {
# 	    return join(' ', 
# 			('seen',
# 			 pp_string($expr->{'regexp'}),
# 			 'in',
# 			 pp_var_domain($expr->{'domain'}, 
# 				       $expr->{'var'}),
# 			 pp_timeframe($expr)
# 			));
# 	};
# 	/seen_compare/ && do {
# 	    return join(' ', 
# 			('seen',
# 			 pp_string($expr->{'regexp_1'}),
# 			 $expr->{'op'},
# 			 pp_string($expr->{'regexp_2'}), 
# 			 'in',
# 			 pp_var_domain($expr->{'domain'}, $expr->{'var'})
# 			));
# 	};
# 	/persistent_ineq/ && do {
# 	    if($expr->{'ineq'} eq '==' &&
# 	       $expr->{'expr'}->{'val'} eq 'true') {
# 		return join(' ', 
# 			    (pp_var_domain($expr->{'domain'}, $expr->{'var'}),
# 			     pp_timeframe($expr)
# 			    ));
# 	    } else {
# 		return join(' ', 
# 			    (pp_var_domain($expr->{'domain'}, $expr->{'var'}),
# 			     $expr->{'ineq'},
# 			     pp_expr($expr->{'expr'}),
# 			     pp_timeframe($expr)
# 			    ));
# 	    }
# 	};
     } elsif($expr->{'type'} eq "pred") {
       return gen_js_pred($expr);
     } else {
       return gen_js_expr($expr);
     }

}





sub eval_js_pre {
    my ($req_info, $rule_env, $rule_name, $session, $pre) = @_;

    my $logger = get_logger();
#    $logger->debug("[pre] Got ", $#{ $pre }, " items.");

    $pre = [] unless defined $pre;


    my @vars = map {$_->{'lhs'}} @{ $pre};
#    $logger->debug("Prelude vars: ", Dumper(@vars));

    my @empty_vals = map {''} @vars;

    $rule_env = extend_rule_env(\@vars, \@empty_vals, $rule_env);
#    $logger->debug("Prelude env before: ", Dumper($rule_env));

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

  my($var, $val) = eval_js_decl($req_info, $rule_env, $rule_name, $session, $decl);
  # yes, this is cheating and breaking the abstraction, but it's fast...
  $rule_env->{$var} = $val;

  $logger->debug("[eval_pre] $var -> $val") if (defined $val);

  $val = Kynetx::JavaScript::exp_to_den($val);
#  $logger->debug("[eval_one_decl] after denoting:", Dumper $val);
  $val = Kynetx::JavaScript::gen_js_expr($val);
  my $js = gen_js_var($var, $val);

#   my $t = infer_type($val);
#   if($t eq 'str') {
#     $val = mk_js_str($val);
#   } elsif ($t eq 'hash' || $t eq 'array') {
#     $val = encode_json($val);
#   }
#   $logger->debug("[decl] $var has type: $t");

#   my $js = gen_js_var($var,$val);

  return $js
}


sub gen_js_callbacks {
    my ($callbacks,$txn_id,$type,$rule_name,$rid) = @_;

    return join("", map {gen_js_callback($_,$txn_id,$type,$rule_name,$rid)} @{ $callbacks });

}

sub gen_js_callback {
    my ($cb,$txn_id,$type,$rule_name,$rid) = @_;

    my $logger = get_logger();
    
    # if it's not click | change don't do anything!
    if($cb->{'type'} eq 'click' || $cb->{'type'} eq 'change') {
	$logger->debug('[callbacks] ',$cb->{'attribute'}." -> ".$cb->{'value'}." for $rid [$rule_name]");

	return 
	    "KOBJ.obs(".
	     mk_js_str($cb->{'type'}).",".
	     mk_js_str($cb->{'attribute'}).",".
	     mk_js_str($txn_id).",".
	     mk_js_str($cb->{'value'}).",".
	     mk_js_str($type).",".
	     mk_js_str($rule_name).",".
	     mk_js_str($rid).
	    ");\n";
    }

    return '';

}

sub gen_js_afterload {

    # separate all args by newline and put in an prototye Event
    my $js = join("\n",@_);
    return <<EOF;
Event.observe(window, 'load', function() {
$js
});

EOF

}

sub gen_js_mk_cb_func {
    my $cb_func_name = shift;

    # separate all args by newline and put in an prototye Event
    my $js = join("\n",@_);
    return <<EOF;
function $cb_func_name () {
$js
};

EOF

    
}



#
# evaluation of JS exprs on the server
#
#  dclone used to ensure we return a new copy, not a pointer to the env
sub eval_js_expr {
    my ($expr, $rule_env, $rule_name,$req_info, $session) = @_;

    my $logger = get_logger();
    $logger->trace("[javascript] expr: ", sub { Dumper($expr) });

    $rule_name ||= 'global';

    if ($expr->{'type'} eq 'str' ) {
        if ($expr->{'val'} =~ m/\#\{(.+)\}{1}?/) {
            $logger->trace("Bee sting: ",$1);
            return(eval_js_beesting($expr, $rule_env, $rule_name,$req_info, $session));
        } else {
	       return $expr;
        }
    } elsif($expr->{'type'} eq 'num') {
	return  $expr ;
    } elsif($expr->{'type'} eq 'regexp') {
	return  $expr ;
    } elsif($expr->{'type'} eq 'var') {
	my $v = lookup_rule_env($expr->{'val'},$rule_env);
	unless (defined $v) {
	    $logger->warn("Variable '", $expr->{'val'}, "' is undefined");
	}
	$logger->trace($rule_name.':'.$expr->{'val'}, " -> ", $v, ' Type -> ', infer_type($v));
	return  mk_expr_node(infer_type($v),$v);
    } elsif($expr->{'type'} eq 'bool') {
	return  $expr ;
    } elsif($expr->{'type'} eq 'array') {
	return mk_expr_node('array',
			    eval_js_rands($expr->{'val'}, $rule_env, $rule_name, $req_info, $session)  ) ;
    } elsif($expr->{'type'} eq 'hashraw') {
	return  mk_expr_node('hash',
			     eval_js_hash($expr->{'val'}, $rule_env, $rule_name, $req_info, $session)  ) ;
    } elsif($expr->{'type'} eq 'prim') {
	return eval_js_prim($expr, $rule_env, $rule_name, $req_info, $session);
    } elsif($expr->{'type'} eq 'operator') {
        $logger->trace('[javascript::eval_js_expr] ', Dumper($expr));
	   return Kynetx::Operators::eval_operator($expr, $rule_env, $rule_name, $req_info, $session);
    } elsif($expr->{'type'} eq 'condexpr') {
	return eval_predicates($req_info, $rule_env, $session, $expr->{'test'}, $rule_name) ?
	       eval_js_expr($expr->{'then'}, $rule_env, $rule_name, $req_info, $session) :
	       eval_js_expr($expr->{'else'}, $rule_env, $rule_name, $req_info, $session)
    } elsif($expr->{'type'} eq 'function') {
	return mk_expr_node('closure',
			    {'vars' => $expr->{'vars'},
			     'decls' => $expr->{'decls'},
			     'expr' => $expr->{'expr'},
			     'env' => $rule_env});
    } elsif($expr->{'type'} eq 'qualified') {
	my $den = eval_js_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
	# get the values
	for (@{ $den }) {
	    $_ = den_to_exp($_);
	}
	my $v = eval_datasource($req_info,
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
    }

}




sub eval_js_prim {
    my ($prim, $rule_env, $rule_name, $req_info, $session) = @_;

    my $vals = eval_js_rands($prim->{'args'}, $rule_env, $rule_name, $req_info, $session);
   

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
sub eval_js_rands {
    my $logger = get_logger();
    my ($rands, $rule_env, $rule_name, $req_info, $session) = @_;
    $logger->trace("[javascript] rands: ", Dumper($rands));
    my @rands = map {eval_js_expr($_, $rule_env, $rule_name, $req_info, $session)} @{ $rands } ;

    return \@rands;

}

sub eval_js_hash {
    my ($hash_lines, $rule_env, $rule_name, $req_info, $session) = @_;

    my $hash = {};
    foreach my $hl (@{ $hash_lines} ) {
	$hash->{$hl->{'lhs'}} = 
	    eval_js_expr($hl->{'rhs'}, $rule_env, 
			 $rule_name, $req_info, $session);
    }

    return $hash;

}

sub eval_js_decl {
    my ($req_info, $rule_env, $rule_name, $session, $decl) = @_;

    my $val = '0';

    my $logger = get_logger();


    if ($decl->{'type'} eq 'expr') {

	my $r = eval_js_expr($decl->{'rhs'}, $rule_env, $rule_name, $req_info, $session);
	$val = $r->{'val'} if (ref $r eq 'HASH');
#	$logger->debug("[decl] expr for ", $decl->{'lhs'}, ' -> ', sub{Dumper($val)} );

    } elsif ($decl->{'type'} eq 'here_doc') {

	$val = eval_heredoc($decl->{'rhs'});

	$logger->debug("[decl] here doc for ", $decl->{'lhs'} );
    }

    # JS is generated for all vars in the rule env
#    $logger->debug("Evaling " . $rule_name.":".$decl->{'lhs'});


    return ($decl->{'lhs'}, $val);


}



sub eval_datasource {
    my($req_info,$rule_env,$session,$rule_name,$source, $function, $args) = @_;


    my $logger = get_logger();
  
 #   $args->[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes
      # get the values
    
    $logger->debug("Pred args ", Dumper $args);

    my $val = '';

    $logger->debug("Datasource $source:$function...");

    if($source eq 'weather') {
	$val = Kynetx::Predicates::Weather::get_weather($req_info,$function);
    } elsif ($source eq 'geoip' || $source eq 'location') {
	$val = Kynetx::Predicates::Location::get_geoip($req_info,$function);
    } elsif ($source eq 'stocks' || $ source eq 'markets') {
	$val = Kynetx::Predicates::Markets::get_stocks($req_info,$args->[0],$function);
    } elsif ($source eq 'referer') {
	$val = Kynetx::Predicates::Referers::get_referer($req_info,$function);
    } elsif ($source eq 'mediamarket') {
	$val = Kynetx::Predicates::MediaMarkets::get_mediamarket($req_info,$function);
    } elsif ($source eq 'useragent') {
	$val = Kynetx::Predicates::Useragent::get_useragent($req_info,$function);
    } elsif ($source eq 'page') {
	$val = Kynetx::Predicates::Page::get_pageinfo($req_info,$function,$args);
    } elsif ($source eq 'math') {
	$val = Kynetx::Predicates::Math::do_math($req_info,$function,$args);
    } elsif ($source eq 'twitter') {
	$val = Kynetx::Predicates::Twitter::eval_twitter($req_info,$rule_env,$session,$rule_name,$function,$args);
    } elsif ($source eq 'datasource') {
      #$val = Kynetx::Datasets::get_datasource($rule_env,$args,$function);
      my $rs = lookup_rule_env('datasource:'.$function,$rule_env);
      my $new_ds = Kynetx::Datasets->new($rs);
      $new_ds->load($req_info,$args);
      $new_ds->unmarshal();
      if (defined $new_ds->json) {
        $val = $new_ds->json;
      } else {
        $val = $new_ds->sourcedata;
      }
      
    } else {
      $logger->warn("Datasource for $source not found");
    }

    return $val;

}

sub eval_persistent {
    my($req_info, $rule_env, $rule_name, $session, $expr) = @_;


    my $logger = get_logger();
    my $v = 0;


    if($expr->{'domain'} eq 'ent') {
	if(defined $expr->{'offset'}) {

	    my $idx = den_to_exp(
		eval_js_expr($expr->{'offset'}, 
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




sub eval_heredoc {
    my ($val) = @_;
# we do this all when we emit the JS now
#    $val = escape_js_str($val);
#    $val =~ s/'/\\'/g;  #' - for syntax highlighting
#    $val =~ s/#{([^}]*)}/'+$1+'/g;
    return $val;
}



#
# evaluation of JS exprs on the server
#
sub den_to_exp {
    my ($expr) = @_;

    return $expr unless (ref $expr eq 'HASH' && defined $expr->{'type'});
    case: for ($expr->{'type'}) {
	/str|num|regexp/ && do {
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


	
    } 

}

sub exp_to_den {
    my ($expr) = @_;

#    my $logger = get_logger();

#    $logger->debug("exp_to_den: $expr");

    if (ref $expr eq 'HASH' && defined $expr->{'type'}) {
      my @keys = sort keys %{ $expr };
      # this is a looser test that
      #   defined $expr->{'val'}
      # since it allows the val to be undef
      if ($keys[1] eq 'val') {
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
    } elsif($v =~ m/^K\$\(.*\)/) {
	$t = 'JS';
    } else {
	$t = 'str';
    }
    return $t;

}


#
# utility functions
#
sub mk_js_str {
    my $logger = get_logger();
    $logger->trace("passed: ",int @_, " args");
    if(defined $_[0]) {
	my $str = join(" ",@_);
	$logger->trace("joined: ",$str);
	$str = escape_js_str($str);
	$str =~ y/\n\r/  /; # remove newlines
	$str =~ s/#{([^}]*)}/'+$1+'/g;
	$logger->trace("escaped: ",$str);
	return "'". $str . "'";
    } else {
	return "''";
    }
}

sub escape_js_str {
    my ($val) = @_;
    $val =~ s/'/\\'/g if defined $val;  #' - for syntax highlighting
    return $val;
}

sub mk_dev_str {
	if ( defined $_[0] ) {
		my $str = join( " ", @_ );
		$str = escape_js_str($str);
		$str =~ s/#{([^}]*)}/'+$1+'/g;
		return "'" . $str . "'";
	}
	else {
		return "''";
	}	
}

sub typed_value {
  my($val) = @_;
  unless (ref $val eq 'HASH' && defined $val->{'type'}) {
    $val = Kynetx::Parser::mk_expr_node(infer_type($val),$val);
  }
  return $val
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
	return  var_free_in_expr($var, $expr->{'obj'});
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

#  $logger->debug("Vars in here_doc for $rhs: ", Dumper @vars);

  my $found = 0;

  foreach my $v (@vars) {
    $found = 1 if $v eq $var;
  }

  return $found;

}

sub eval_js_beesting {
    my ($expr, $rule_env, $rule_name,$req_info, $session) = @_;
    my $logger = get_logger();
    $expr->{'val'} =~ m/(.*)\#\{(.+)\}{1}?(.*)/;
    my $bee_expr = Kynetx::Parser::parse_expr($2);
    $logger->trace("parsed beesting: ", sub {Dumper($bee_expr)} );
    my $val = $1.eval_js_expr($bee_expr,$rule_env, $rule_name,$req_info, $session)->{'val'}.$3;
    return (eval_js_expr({'val' => $val, 'type' => 'str'}, $rule_env, $rule_name,$req_info, $session));
    
}
