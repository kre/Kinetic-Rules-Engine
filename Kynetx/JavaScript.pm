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
mk_js_str
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
	/prim/ && do {
	    return gen_js_prim($val);
	};
	
    } 

}

sub gen_js_prim {
    my $prim = shift;

    join(' ' . $prim->{'op'} . ' ', gen_js_rands($prim->{'args'}));

    
}

sub gen_js_rands {
    my $rands = shift;

    map {gen_js_expr($_)} @{ $rands };

}




sub gen_js_pre {
    my ($req_info, $rule_env, $session, $pre) = @_;

    join "", map {gen_js_decl($req_info, $rule_env, $session, $_)} @{ $pre };
}

sub gen_js_decl {
    my ($req_info, $rule_env, $session, $decl) = @_;

    my $val = '0';

    
    my $logger = get_logger();
    $logger->debug(
	"[decl] Type: " . $decl->{'type'}
	);

    if($decl->{'type'} eq 'data_source') {
	my $source = $decl->{'source'};

	my $function = $decl->{'function'};

	$logger->debug("[decl] Source: ". "$source:$function");

	if($source eq 'weather') {
	    $val = Kynetx::Rules::get_weather($req_info,$function);
	} elsif ($source eq 'geoip') {
	    $val = Kynetx::Rules::get_geoip($req_info,$function);
	}elsif ($source eq 'stocks') {
	    my @arg = gen_js_rands($decl->{'args'});
	    $arg[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes
	    $val = Kynetx::Rules::get_stocks($req_info,$arg[0],$function);
	}

    } elsif ($decl->{'type'} eq 'counter') {

	$logger->debug("Counter name: " . $decl->{'name'});

	$val = $session->{$decl->{'name'}};
    }

    return 'var ' . $decl->{'lhs'} . ' = \'' . $val . "\';\n"

}


sub gen_js_callbacks {
    my ($callbacks,$type,$rule_name) = @_;

    join("", map {gen_js_callback($_,$type,$rule_name)} @{ $callbacks });

}

sub gen_js_callback {
    my ($cb,$type,$rule_name) = @_;

    my $logger = get_logger();
    
    # if it's not click don't do anything!
    if($cb->{'type'} eq 'click') {
	$logger->debug('[callbacks]',$cb->{'attribute'}." -> ".$cb->{'value'}.",");

	return 
	    "KOBJ.obs(".
	     mk_js_str($cb->{'attribute'}).",".
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
# utility functions
#
sub mk_js_str {
    return "'". join(" ",@_) . "'";
}

