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
	#$logger->debug("Seeing ", sub {Dumper $expr});
	
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
    		$logger->debug("Empty expression: ",$expr->{'type'});
    		return mk_js_str('UNTRANSLATABLE KRL EXPRESSION');
    	}
    	return $jsexp;
    } else {
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
	      'return '. gen_js_expr($func->{'expr'}).
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
	$str =~ s/#{([^}]*)}/'+$1+'/g;
	$logger->trace("escaped: ",$str);
	utf8::decode($str);
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
