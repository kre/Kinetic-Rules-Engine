package Kynetx::JavaScript;
# file: Kynetx/JavaScript.pm

use strict;
use warnings;

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
	    return '\'' . $val . '\'';
	};
	/num/ && do {
	    return  $val ;
	};
	/var/ && do {
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






#	    pre => {
#		decls => [{name => 'tc',
#			   source => {weather => 'tomorrow_cond'}}],
#	    },

sub gen_js_pre {
    my ($req_info, $rule_env, $pre) = @_;

    return join(' ', gen_js_decls($req_info, $rule_env, $pre->{'decls'}));

}

sub gen_js_decls {
    my ($req_info, $rule_env, $decls) = @_;

    map {gen_js_decl($req_info, $rule_env, $_)} @{ $decls };
}

sub gen_js_decl {
    my ($req_info, $rule_env, $decl) = @_;

    my $source = $decl->{'source'};

    my @nodes = keys %{ $source };  # these are singleton hashes
    my $type =  $nodes[0];

    Apache2::ServerUtil->server->warn("Decl source: ". $type);

    my $val = '0';
    if($type eq 'weather') {
	$val = Kynetx::Rules::get_weather($req_info,$source->{$type});
    } elsif ($type eq 'geoip') {
	$val = Kynetx::Rules::get_geoip($req_info,$source->{$type});
    }
    
    return 'var ' . $decl->{'name'} . ' = \'' . $val . '\';'
}
