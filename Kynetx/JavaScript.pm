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
	"Decl type: " . $decl->{'type'}
	);

    if($decl->{'type'} eq 'data_source') {
	my $source = $decl->{'source'};

	my $function = $decl->{'function'};

	my $logger = get_logger();
	$logger->debug("Decl source: ". "$source:$function");

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

	my $logger = get_logger();
	$logger->debug("Counter name: " . $decl->{'name'});

	$val = $session->{$decl->{'name'}};
    }

    return 'var ' . $decl->{'lhs'} . ' = \'' . $val . "\';\n"

}
