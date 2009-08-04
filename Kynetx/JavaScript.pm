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

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
use JSON::XS;

use Kynetx::Datasets q/:all/;
use Kynetx::Environments q/:all/;
use Kynetx::Session q/:all/;
use Kynetx::Operators q/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
gen_js_expr
gen_js_prim
gen_js_rands
eval_js_pre
gen_js_callbacks
gen_js_afterload
gen_js_mk_cb_func
get_js_html
mk_js_str
eval_js_expr
den_to_exp
exp_to_den
infer_type
escape_js_str
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

# this is NOT a JavaScript evaluater.  Rather, it creates JS strings
# from Perly parse trees.  So, more like a pretty-printer.  


sub gen_js_expr {
    my $expr = shift;

    case: for ($expr->{'type'}) {
	/str/ && do {
	    $expr->{'val'} = escape_js_str($expr->{'val'});
	    return '\'' . $expr->{'val'} . '\'';
	};
	/num/ && do {
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

sub gen_js_prim {
    my $prim = shift;

    return '(' .join(' ' . $prim->{'op'} . ' ', @{ gen_js_rands($prim->{'args'}) }) . ')';

    
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
	push(@items, "'" . $k . "' :"  . gen_js_expr($hash_items->{'val'}->{$k}));
    }
    my $js =  '{' . join(",", @items) . '}';
#    $logger->debug($js);

    return $js;
}


sub gen_js_hash_lines {
    my ($hash_lines) = @_;

    my $logger = get_logger();

   $logger->debug(Dumper($hash_lines));

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


    foreach my $decl (@{ $pre }) {
	my($var, $val) = eval_js_decl($req_info, $rule_env, $rule_name, $session, $decl);
	# yes, this is cheating and breaking the abstraction, but it's fast...
	$rule_env->{$var} = $val;
    }

#    my @results = map {eval_js_decl($req_info, $rule_env, $rule_name, $session, $_)} @{ $pre };

#    $logger->debug("Results of prelude: ", Dumper($rule_env));

    # unzip the results
#    my @vars;
#    my @vals;
#    foreach my $r (@results) {
#	my($var, $val) = @{$r};
#	push(@vars, $var);
#	push(@vals, $val);
#    }
   
#    return extend_rule_env(\@vars, 
#			   \@vals, 
#			   $rule_env);
    return $rule_env;
}




sub gen_js_callbacks {
    my ($callbacks,$txn_id,$type,$rule_name) = @_;

    return join("", map {gen_js_callback($_,$txn_id,$type,$rule_name)} @{ $callbacks });

}

sub gen_js_callback {
    my ($cb,$txn_id,$type,$rule_name) = @_;

    my $logger = get_logger();
    
    # if it's not click don't do anything!
    if($cb->{'type'} eq 'click') {
	$logger->debug('[callbacks]',$cb->{'attribute'}." -> ".$cb->{'value'}.",");

	return 
	    "KOBJ.obs(".
	     mk_js_str($cb->{'attribute'}).",".
	     mk_js_str($txn_id).",".
	     mk_js_str($cb->{'value'}).",".
	     mk_js_str($type).",".
	     mk_js_str($rule_name).
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
sub eval_js_expr {
    my ($expr, $rule_env, $rule_name,$req_info, $session) = @_;

    my $logger = get_logger();
#    $logger->debug("Rule env: ", sub { Dumper($rule_env) });

    case: for ($expr->{'type'}) {
	/str/ && do {
	    return $expr;
	};
	/num/ && do {
	    return  $expr ;
	};
	/regexp/ && do {
	    return  $expr ;
	};
	/var/ && do {
	    my $v = lookup_rule_env($expr->{'val'},$rule_env);
	    unless (defined $v) {
		$logger->warn("Variable '", $expr->{'val'}, "' is undefined");
	    }
	    $logger->debug($rule_name.':'.$expr->{'val'}, " -> ", $v, ' Type -> ', infer_type($v));
	    return  {'type' => infer_type($v),
                     'val' =>  $v};
	};
	/bool/ && do {
	    return  $expr ;
	};
	/array/ && do {
	    return  { 'type' => 'array',
		      'val' => eval_js_rands($expr->{'val'}, $rule_env, $rule_name, $req_info, $session)  } ;
	};
	/hash/ && do {
	    return  { 'type' => 'hash',
		      'val' => eval_js_hash($expr->{'val'}, $rule_env, $rule_name, $req_info, $session)  } ;
	};
	/prim/ && do {
	    return eval_js_prim($expr, $rule_env, $rule_name, $req_info, $session);
	};

	/operator/ && do {
	    return  Kynetx::Operators::eval_operator($expr, $rule_env, $rule_name, $req_info, $session);
	};
 	/qualified/ && do {

	    my $den = eval_js_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);

	    # get the values
	    for (@{ $den }) {
		$_ = den_to_exp($_);
	    }

	    my $v = eval_datasource($req_info,
				    $rule_env,
				    $rule_name,
				    $expr->{'source'},
				    $expr->{'predicate'},
				    $den
		);

	    $logger->debug("[JS Expr] ", $expr->{'source'}, ":", $expr->{'predicate'}, " -> ", $v);

	    return {'type' => infer_type($v),
		    'val' => $v};
 	};
	/counter/ && do {
	    my $v = eval_counter($req_info, $session, $expr->{'val'});
	    return {'type' => infer_type($v),
		    'val' => $v};
	};

    } 

}




sub eval_js_prim {
    my ($prim, $rule_env, $rule_name, $req_info, $session) = @_;

    my $vals = eval_js_rands($prim->{'args'}, $rule_env, $rule_name, $req_info, $session);
   

    my $val0 = den_to_exp($vals->[0]);
    my $val1 = den_to_exp($vals->[1]);

    # FIXME: Add operators
    # FIXME: Do we need more than binary?
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
    }

    return 0;

    
}

# warning: this returns a ref to an array, not an array!
sub eval_js_rands {
    my ($rands, $rule_env, $rule_name, $req_info, $session) = @_;

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
	$logger->debug("[decl] expr for ", $decl->{'lhs'}, ' -> ', $val );

    } elsif ($decl->{'type'} eq 'here_doc') {

	$val = eval_heredoc($decl->{'rhs'});

	$logger->debug("[decl] here doc for ", $decl->{'lhs'} );
    }

    # JS is generated for all vars in the rule env
#    $logger->debug("Evaling " . $rule_name.":".$decl->{'lhs'});


    return ($decl->{'lhs'}, $val);


}



sub eval_datasource {
    my($req_info,$rule_env,$rule_name,$source, $function, $args) = @_;
  
 #   $args->[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes

    my $val = '';

    my $logger = get_logger();
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
    } elsif ($source eq 'datasource') {
	$val = Kynetx::Datasets::get_datasource($rule_env,$args,$function);
    }

    return $val;

}

sub eval_counter {
    my($req_info, $session, $name) = @_;

#    my $logger = get_logger();
#    $logger->debug("RID: ", $req_info->{'rid'}, "Name: $name");
    
    return session_get($req_info->{'rid'}, $session, $name);

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

    case: for ($expr->{'type'}) {
	/str|num/ && do {
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
	    return map {den_to_exp($_)} @{ $expr->{'val'} };
	};


	
    } 

}

sub exp_to_den {
    my ($expr) = @_;

    my $type = infer_type($expr);
    if(ref $expr eq 'HASH' && ! defined $expr->{'val'} && ! defined $expr->{'type'}) {
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
	return $expr
    }

}

# crude type inference for prims
sub infer_type {
    my ($v) = @_;
    my $t;
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
    if(defined $_[0]) {
	my $str = join(" ",@_);
	$str =~ y/\n\r/  /; # remove newlines
	return "'". escape_js_str($str) . "'";
    } else {
	return "''";
    }
}

sub escape_js_str {
    my ($val) = @_;
    $val =~ s/'/\\'/g;  #' - for syntax highlighting
    return $val;
}

