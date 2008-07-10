package Kynetx::JavaScript;
# file: Kynetx/JavaScript.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);


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
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

# this is NOT a JavaScript evaluater.  Rather, it creates JS strings
# from Perly parse trees.  So, more like a pretty-printer.  


sub gen_js_expr {
    my $expr = shift;

    my @nodes = keys %{ $expr };  # these are singleton hashes
    my $val =  $expr->{$nodes[0]};

    case: for ($nodes[0]) {
	/str/ && do {
	    $val =~ s/'/\\'/g;  #' - for syntax highlighting
	    return '\'' . $val . '\'';
	};
	/num/ && do {
	    return  $val ;
	};
	/var/ && do {
	    return  $val ;
	};
	/bool/ && do {
	    return  $val ;
	};
	/array/ && do {
	    return  "[" . join(', ', @{ gen_js_rands($val) }) . "]" ;
	};
	/prim/ && do {
	    return gen_js_prim($val);
	};
	
    } 

}

sub gen_js_prim {
    my $prim = shift;

    return join(' ' . $prim->{'op'} . ' ', @{ gen_js_rands($prim->{'args'}) });

    
}

sub gen_js_rands {
    my ($rands) = @_;

    my @rands = map {gen_js_expr($_)} @{ $rands } ;

#    my $logger = get_logger();
#    $logger->debug("Args: ", join(", ", @rands));

    return \@rands;

}




sub gen_js_pre {
    my ($req_info, $rule_env, $rule_name, $session, $pre) = @_;

#    my $logger = get_logger();
#    $logger->debug("[pre] Got ", $#{ $pre }, " items.");
    
    return map {gen_js_decl($req_info, $rule_env, $rule_name, $session, $_)} @{ $pre };
}

# modifies rule_env by inserting value with LHS
sub gen_js_decl {
    my ($req_info, $rule_env, $rule_name, $session, $decl) = @_;

    my $val = '0';

    
    my $logger = get_logger();

    $logger->debug(
	"[decl] Type: " . $decl->{'type'}
	);

    if($decl->{'type'} eq 'data_source') {
	my $source = $decl->{'source'};

	my $function = $decl->{'function'};


	if($source eq 'weather') {
	    $val = Kynetx::Predicates::Weather::get_weather($req_info,$function);
	} elsif ($source eq 'geoip' || $source eq 'location') {
	    $val = Kynetx::Predicates::Location::get_geoip($req_info,$function);
	} elsif ($source eq 'stocks' || $ source eq 'markets') {

	    my $arg = gen_js_rands($decl->{'args'});
	    $arg->[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes
	    $val = Kynetx::Predicates::Markets::get_stocks($req_info,$arg->[0],$function);
	} elsif ($source eq 'referer') {
	    $val = Kynetx::Predicates::Referers::get_referer($req_info,$function);
	} 

	$logger->debug("[decl] Source: $source:$function = $val" );


    } elsif ($decl->{'type'} eq 'counter') {

	$logger->debug("Counter name: " . $decl->{'name'});

	$val = $session->{$decl->{'name'}};

    } elsif ($decl->{'type'} eq 'here_doc') {

	$logger->debug("Here doc for ", $decl->{'lhs'} );

	$val = $decl->{'value'};
	$val =~ s/'/\\'/g;  #' - for syntax highlighting
	$val =~ s/#{([^}]*)}/'+$1+'/g;
    }

    $rule_env->{$rule_name.":".$decl->{'lhs'}} = $val;

    return $val;

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
    my ($expr, $rule_env, $rule_name) = @_;

    my @nodes = keys %{ $expr };  # these are singleton hashes
    my $val =  $expr->{$nodes[0]};

    my $logger = get_logger();
    $logger->debug("Evaling ", $nodes[0], " -> ", $val);
    

    case: for ($nodes[0]) {
	/str/ && do {
	    return $expr;
	};
	/num/ && do {
	    return  $expr ;
	};
	# FIXME: assuming all vars are  strings
	/var/ && do {
	    return  {'str' => $rule_env->{$rule_name.':'.$val} };
	};
	/bool/ && do {
	    return  $expr ;
	};
	/array/ && do {
	    return  { 'array' => join(' ', @{ eval_js_rands($val, $rule_env, $rule_name) }) } ;
	};
	/prim/ && do {
	    return eval_js_prim($val, $rule_env, $rule_name);
	};
	
    } 

}

sub eval_js_prim {
    my ($prim, $rule_env, $rule_name) = @_;

    my $val_hashes = eval_js_rands($prim->{'args'}, $rule_env, $rule_name);

    my(@types, @vals);
    foreach my $val (@{ $val_hashes }) {
	my @type = keys %{ $val }; #singleton hash
	push(@types, $type[0]);
	push(@vals, $val->{$type[0]});
	
    }

    # FIXME: Add operators
    # FIXME: Do we need mroe than binary?
    case: for ($prim->{'op'}) {
	/\+/ && do {

	    if($types[0] eq 'str') {
		return {'str' => $vals[0] . $vals[1]};
	    } else {
		return {'num' => $vals[0] + $vals[1]};
	    }

	};
    }

    return 0;

    
}

sub eval_js_rands {
    my ($rands, $rule_env, $rule_name) = @_;

    my @rands = map {eval_js_expr($_, $rule_env, $rule_name)} @{ $rands } ;

    return \@rands;

}






#
# utility functions
#
sub mk_js_str {
    return "'". join(" ",@_) . "'";
}

