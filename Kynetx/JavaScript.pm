package Kynetx::JavaScript;
# file: Kynetx/JavaScript.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
use JSON::XS;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
gen_js_expr
gen_js_prim
gen_js_rands
gen_js_pre
gen_js_callbacks
gen_js_afterload
gen_js_mk_cb_func
get_js_html
mk_js_str
eval_js_expr
den_to_exp
infer_type
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

# this is NOT a JavaScript evaluater.  Rather, it creates JS strings
# from Perly parse trees.  So, more like a pretty-printer.  


sub gen_js_expr {
    my $expr = shift;

    case: for ($expr->{'type'}) {
	/str/ && do {
	    $expr->{'val'} =~ s/'/\\'/g;  #' - for syntax highlighting
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



sub gen_js_pre {
    my ($req_info, $rule_env, $rule_name, $session, $pre) = @_;

#    my $logger = get_logger();
#    $logger->debug("[pre] Got ", $#{ $pre }, " items.");
    
    return map {eval_js_decl($req_info, $rule_env, $rule_name, $session, $_)} @{ $pre };
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
    my ($expr, $rule_env, $rule_name,$req_info) = @_;

    my $logger = get_logger();
#    $logger->debug("Rule env: ", sub { Dumper($rule_env) });

    case: for ($expr->{'type'}) {
	/str/ && do {
	    return $expr;
	};
	/num/ && do {
	    return  $expr ;
	};
	/var/ && do {
	    my $v = $rule_env->{$rule_name.':'.$expr->{'val'}};
	    $logger->debug($rule_name.':'.$expr->{'val'}, " -> ", $v, ' Type -> ', infer_type($v));
	    return  {'type' => infer_type($v),
                     'val' =>  $v};
	};
	/bool/ && do {
	    return  $expr ;
	};
	/array/ && do {
	    return  { 'type' => 'array',
		      'val' => eval_js_rands($expr->{'val'}, $rule_env, $rule_name, $req_info)  } ;
	};
	/prim/ && do {
	    return eval_js_prim($expr, $rule_env, $rule_name, $req_info);
	};

 	/qualified/ && do {

	    my $den = eval_js_rands($expr->{'args'}, $rule_env, $rule_name,$req_info);

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
	
	
    } 

}




sub eval_js_prim {
    my ($prim, $rule_env, $rule_name, $req_info) = @_;

    my $vals = eval_js_rands($prim->{'args'}, $rule_env, $rule_name, $req_info);
   

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
    my ($rands, $rule_env, $rule_name, $req_info) = @_;

    my @rands = map {eval_js_expr($_, $rule_env, $rule_name, $req_info)} @{ $rands } ;

    return \@rands;

}

# modifies rule_env by inserting value with LHS
sub eval_js_decl {
    my ($req_info, $rule_env, $rule_name, $session, $decl) = @_;

    my $val = '0';

    my $logger = get_logger();

    if($decl->{'type'} eq 'data_source') {


	my $den = eval_js_rands($decl->{'args'}, 
				$rule_env, $rule_name,$req_info);

	# get the values
	for (@{ $den }) {
	    $_ = den_to_exp($_);
	}


	$val = eval_datasource(
	    $req_info,
	    $rule_env,
	    $rule_name,
	    $decl->{'source'}, 
	    $decl->{'function'}, 
	    $den);


#	    gen_js_rands($decl->{'args'}));

	$logger->debug("[decl] Source: " .
		       $decl->{'source'} . ":" . 
		       $decl->{'function'} . 
		       " -> $val" );

    } elsif ($decl->{'type'} eq 'counter') {

	$val = eval_counter($session, $decl->{'name'});

	$logger->debug("[decl] Counter: " . $decl->{'name'} . " -> " . $val);

    } elsif ($decl->{'type'} eq 'here_doc') {

	$val = eval_heredoc($decl->{'value'});

	$logger->debug("[decl] here doc for ", $decl->{'lhs'} );
    }

    # JS is generated for all vars in the rule env
    $rule_env->{$rule_name.":".$decl->{'lhs'}} = $val;

    # preserve the order of decl evals
#    push(@{$rule_env->{$rule_name."_rules"}}, 
#	 {'lhs' => $decl->{'lhs'},
#	  'val' => $val});
    push(@{$rule_env->{$rule_name."_vars"}}, $decl->{'lhs'});

    return $val;

}



sub eval_datasource {
    my($req_info,$rule_env,$rule_name,$source, $function, $args) = @_;
  
 #   $args->[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes

    my $val = '';

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
	if($function eq 'var') {
	    my $vals = decode_json($req_info->{'kvars'});
	    $val = $vals->{$args->[0]};
	} elsif ($function eq 'id') {
	    # we're really just generating JS here.
	    $val = "K\$('".$args->[0]."').innerHTML";
	} elsif($function eq 'env') {
	    # rulespaced env parameters
	    if(defined $req_info->{$req_info->{'rid'}.':'.$args->[0]}) {
		$val = $req_info->{$req_info->{'rid'}.':'.$args->[0]};
	    } elsif(defined $req_info->{$args->[0]}) {
		$val = $req_info->{$args->[0]};
	    }
	}
    }

    return $val;

}

sub eval_counter {
    my($session, $name) = @_;

    return $session->{$name};

}

sub eval_heredoc {
    my ($val) = @_;
    $val =~ s/'/\\'/g;  #' - for syntax highlighting
    $val =~ s/#{([^}]*)}/'+$1+'/g;
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


	
    } 

}




# crude type inference for prims
sub infer_type {
    my ($v) = @_;
    my $t;
    if($v =~ m/^(\d*\.\d+|\d+)$/) { # crude type inference for primitives
	$t = 'num' ;
    } elsif($v =~ m/^(true|false)$/) {
	$t = 'bool';
    } elsif($v =~ m/^K\$\(.*\)/) {
	$t = 'JS';
    } else {
	$t = 'str';
    }
    return $t;

}


#
# utility functions
#pnnn
sub mk_js_str {
    if(defined $_[0]) {
	return "'". join(" ",@_) . "'";
    } else {
	return "''";
    }
}

