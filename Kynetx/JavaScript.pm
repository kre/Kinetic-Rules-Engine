package Kynetx::JavaScript;
# file: Kynetx/JavaScript.pm
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
use utf8;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
use JSON::XS;
use Storable qw(dclone);

use Kynetx::Parser qw/mk_expr_node/;
use Kynetx::Datasets qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Operators qw/:all/;
use Kynetx::Expressions qw/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
gen_js_expr
gen_js_var
gen_js_var_list
gen_js_prim
gen_js_rands
gen_js_callbacks
gen_js_afterload
gen_js_mk_cb_func
gen_js_error
get_js_html
mk_js_str
escape_js_str
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

# this is NOT a JavaScript evaluater.  Rather, it creates JS strings
# from Perly parse trees.  So, more like a pretty-printer.

# refactor to allow for a default JS #fail expression if we 
# fail to create valid JS
sub gen_js_expr {
    my $expr = shift;

    my $logger = get_logger();
	$logger->trace("Seeing ", sub {Dumper $expr});
	
	my $jsexp = undef;
	local $_ = $expr->{'type'};
	
	if (/str/){
	  	$jsexp = mk_js_str($expr->{'val'});
	} elsif (/num/) {
	  	$jsexp = $expr->{'val'};
	} elsif (/JS/){
		$jsexp = $expr->{'val'};
	} elsif (/var/) {
		$jsexp = $expr->{'val'};
	} elsif (/regexp/) {
		$jsexp = $expr->{'val'};
	} elsif (/bool/) {
		$jsexp = $expr->{'val'};
	} elsif (/null/) {
		$jsexp = 'null';
	} elsif (/^undef$/) {
		$jsexp = 'null';
	} elsif (/^array$/) {
		$jsexp = "[" . join(', ', @{ gen_js_rands($expr->{'val'}) }) . "]";
	} elsif (/^array_ref$/) {
		$jsexp = gen_js_array_ref($expr->{'val'});
	} elsif (/hashraw/) {
		$jsexp = gen_js_hash_lines($expr->{'val'});
	} elsif (/hash/) {
		$jsexp = gen_js_hash($expr->{'val'});
	} elsif (/prim/) {
		$jsexp = gen_js_prim($expr);
	} elsif (/^ineq|pred$/) {
		$jsexp = gen_js_predexpr($expr);
	} elsif (/condexpr/) {
		$jsexp = gen_js_condexpr($expr);
	} elsif (/function/) {
		$jsexp = gen_js_function($expr);
	} elsif (/closure/) {
		$jsexp = gen_js_function($expr->{'val'});
	} elsif (/app/) {
	    my $app_name = gen_js_expr($expr->{'function_expr'});
	    my $args = "(" . join(', ', @{ gen_js_rands($expr->{'args'}) }) . ")" ;
		$jsexp = $app_name . $args;
	} elsif (/qualified/) {
		my $rands = gen_js_rands($expr->{'args'});
		$jsexp = gen_js_datasource($expr->{'source'},
				      $expr->{'predicate'},
				      $rands
		);		 
	};

    if (defined $jsexp) {
    	if ($jsexp eq '') {
    		#$logger->debug("Empty expression: ",$expr->{'type'});
    		return mk_js_str('UNTRANSLATABLE KRL EXPRESSION');
    	}
    	return $jsexp;
    } else {
#      $logger->debug("Can't translate type: ",$expr->{'type'});
      return mk_js_str('UNTRANSLATABLE KRL EXPRESSION');
    }
}

sub gen_js_var {
  my ($lhs, $rhs) = @_;
  return "var $lhs = $rhs;\n";
}

sub gen_js_var_list {
  my ($lhs_list, $rhs_list) = @_;

  my $logger=get_logger();
  return join(" ",
	      map {gen_js_var($lhs_list->[$_], $rhs_list->[$_])} (0..scalar(@{$lhs_list})-1)
	     );
}

sub gen_js_prim {
    my $prim = shift;

    if ( $prim->{'op'} eq 'NEG') {
      my $rands = gen_js_rands($prim->{'args'});
      return '-'.$rands->[0];
    } else {
      return '(' .join(' ' . $prim->{'op'} . ' ', @{ gen_js_rands($prim->{'args'}) }) . ')';
    }
}

sub get_js_error {
	my $message = shift;
	return '(console.log(' . $message . '))';
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
	$rhs = gen_js_expr(Kynetx::Expressions::exp_to_den(Kynetx::Expressions::eval_heredoc($d->{'rhs'})));
      }

      $decls .= gen_js_var($d->{'lhs'}, $rhs);
    }

    my $js = "function(".
              join(", ", @{ $func->{'vars'} }) .
	      ") {" .
	      $decls .
	      'return '. gen_js_expr($func->{'expr'}).
	      "}";

    return $js;


}

sub gen_js_rands {
    my ($rands) = @_;
    my $logger = get_logger();
    $logger->trace("Args: ", sub { join(", ", @{$rands}) });

    my @rands = map {gen_js_expr($_)} @{ $rands } ;


    return \@rands;

}

sub gen_js_hash {
    my ($hash_items) = @_;

    my $logger = get_logger();

#    $logger->debug(Dumper($hash_items));

    $hash_items = Kynetx::Expressions::exp_to_den($hash_items);
#    $logger->debug(Dumper($hash_items));
    my @items;
    foreach my $k (keys %{ $hash_items->{'val'} }) {
#      $logger->debug("Seeing $k ", Dumper $hash_items->{'val'}->{$k})
#	if $k eq 'geo';
      push(@items, gen_js_hash_item($k, $hash_items->{'val'}->{$k}));
#"'" . $k . "' :"  . gen_js_expr($hash_items->{'val'}->{$k}));
    }
    my $js =  '{' . join(",", @items) . '}';
#    $logger->debug($js);

    return $js;
}

sub gen_js_hash_item {
  my ($name, $val) = @_;
  return "'" . $name . "' :"  . gen_js_expr($val);
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

    return  gen_js_expr($hash_line->{'lhs'}) ." : " . gen_js_expr($hash_line->{'rhs'});


}


sub gen_js_array_ref {
  my $array_ref = shift;

  return  $array_ref->{'var_expr'} . '['. gen_js_expr($array_ref->{'index'}) . ']';


}

sub gen_js_datasource {
    my($source, $function, $args) = @_;

    my $val = '';

    if($source eq 'page') {
		if ($function eq 'id') {
	    	$val = "\$K(".$args->[0].").html()";
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

#      $logger->debug("Expr ", sub {Dumper $expr });
      if ($expr->{'op'} eq 'like') {
	if ($expr->{'args'}->[1]->{'type'} eq 'str') {
	  $expr->{'args'}->[1]->{'val'} = '/' . $expr->{'args'}->[1]->{'val'} . '/';
	  $expr->{'args'}->[1]->{'type'} = 'regexp'
	}
	return gen_js_expr($expr->{'args'}->[0]) . '.match(' . gen_js_expr($expr->{'args'}->[1]) . ')';
      } elsif ($expr->{'op'} eq '><') {

	my $array_js = '($KOBJ.inArray(' .
	                     gen_js_expr($expr->{'args'}->[1]) . ',' .
	                     gen_js_expr($expr->{'args'}->[0]) . ') != -1) ';

	my $v1 = gen_js_expr($expr->{'args'}->[1]);
	$v1 =~ s/'([\w\d]+)'/$1/;


# need local scoping for the new var
#(function(){var tmp = {"a": 1, "b" : 2};return typeof(tmp.a) !== 'undefined'}())

	my $map_js = '(function(){var tmp = ' . 
                         gen_js_expr($expr->{'args'}->[0]) . 
                       ';return (typeof(tmp.' . $v1 . ") !== 'undefined')}())";

	if ($expr->{'args'}->[0]->{'type'} eq 'array') {
	  return $array_js;
	} elsif ($expr->{'args'}->[0]->{'type'} eq 'hash') {
	  return $map_js;
	} else {

	  return '((' . gen_js_expr($expr->{'args'}->[0]) . ' instanceof Array) ? ' .
	    $array_js . ' : '  . $map_js . ')'

      
	}

      } elsif ($expr->{'op'} eq '<=>' || $expr->{'op'} eq 'cmp') {

	my $a = gen_js_expr($expr->{'args'}->[0]) ;
        my $b = gen_js_expr($expr->{'args'}->[1]) ;
 
	return 
          "($a < $b ? -1 : ($a > $b ? 1 : 0))"

	
      } else {
	return  '('. join(' ' . gen_js_ineq_op($expr->{'op'}) . ' ',
			  @{ gen_js_rands($expr->{'args'}) }) . ')'  ;
      }
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

sub gen_js_ineq_op {
  my $op = shift;

  if ($op eq 'eq') {
    return '=='
  } elsif ($op eq 'neq') {
    return '!='
  } elsif ($op eq 'like') {
    return '=='  # this is wrong!!! we shouldn't ever get here, but generate JS in case
  } else {
    return $op
  }
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
# utility functions
#
sub mk_js_str {
    my $logger = get_logger();
    $logger->trace("passed: ",int @_, " args");
    if(defined $_[0]) {
	my $str = join(" ",@_);
	$logger->trace("joined: ",$str);
	$str = escape_js_str($str);

	# for things that look like vars, replace with the var and concatenatino
	$str =~ s/#{([A-Za-z0-9_]*)}/'+$1+'/g;

	# for everything else, try to eval the expression;
	# doesn't always work because there's no rule_env
#	$str = Kynetx::Expressions::den_to_exp(Kynetx::Expressions::eval_str($str));

	$str =~ s/#{([^}]*)}/'+'UNTRANSLATABLE KRL EXPRESSION'+'/g;
	

#	$logger->debug("escaped: ",sub { Dumper $str});
	# #utf8::decode($str);
	# $str = Kynetx::Util::str_out($str);
	return "'". $str . "'";
    } else {
	return "''";
    }
}

sub escape_js_str {
    my ($val) = @_;
    if (defined $val) {
      $val =~ s/'/\\'/g ;  #' - for syntax highlighting
      $val =~ s/\n/\\n/g;
      $val =~ s/\r/\\r/g;
    }
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


1;
