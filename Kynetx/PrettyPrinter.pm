package Kynetx::PrettyPrinter;
# file: Kynetx/PrettyPrinter.pm

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
pp
pp_rule_body
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Log::Log4perl qw(get_logger :levels);

my $g_indent = 4;


sub pp {
    my ($rules) = @_;

    foreach my $k (keys %{$rules}) {
	return "ruleset $k {\n" . pp_rules($rules->{$k},$g_indent) . "\n}\n";
    }


}

sub pp_rules {
    my ($rules, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = "";
    foreach my $r ( @{$rules}) {
	$o .= $beg . "rule " . $r->{'name'} . " is " . $r->{'state'} . " {\n";

	$o .= pp_rule_body($r, $indent);

	$o .= $beg . "}\n";
    }

    return $o;
}

sub pp_rule_body {
    my ($r, $indent) = @_;

    my $o .= pp_select($r->{'pagetype'},$indent+$g_indent);

    $o .= pp_pre($r->{'pre'},$indent+$g_indent);

    if(defined $r->{'cond'}) {
	$o.= pp_cond($r,$indent+$g_indent);
    } else { # just primrule
	$o.= pp_primrule($r->{'action'},$indent+$g_indent);
    }

    if(defined $r->{'callbacks'}) {
	$o .= pp_callbacks($r->{'callbacks'},$indent+$g_indent);
    }


    if(defined $r->{'post'}) {
	$o .= pp_post($r->{'post'},$indent+$g_indent);
    }

    return $o;

}

sub pp_select {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= 'select using "' . $node->{'pattern'} . '" setting (';
    $o .= join ", ", @{$node->{'vars'}};
    $o .= ")\n";

    return $o;

}

sub pp_pre {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= "pre {\n";
    foreach my $d (@{$node}) {
	$o .= pp_decl($d,$indent+$g_indent);
    }
    $o .= $beg . "}\n";
  
    return $o;
}

sub pp_decl {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    if($node->{'type'} eq 'counter') {
	$o .= $node->{'lhs'} . " = " . $node->{'type'} . "." .  
  	      $node->{'name'} . ";\n";
    } else { # datasource

	$o .= $node->{'lhs'} . " = ";
	$o .= $node->{'source'} . ":" . $node->{'function'} . "(";
	$o .= join ", ", pp_rands($node->{'args'});
	$o .= ");\n";
    }
  
    return $o;

}

sub pp_cond {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    $o .= "if ";
    $o .= join " && ", map {pp_pred($_, 0)} @{ $node->{'cond'} };
    $o .= "\n" . $beg . "then {\n";
    $o .= pp_primrule($node->{'action'},$indent+$g_indent);
    $o .= $beg . "}\n";

    return $o;

}

sub pp_pred{
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
    if($node->{'type'} eq 'simple') {
	$o .= $node->{'predicate'} . "(";
	$o .= join ", ", pp_rands($node->{'args'});
	$o .= ")";
    } else { #counter
	$o .= $node->{'type'} . "." . $node->{'name'};
	$o .= " " . $node->{'ineq'} . " ";
	$o .= $node->{'value'};
	if(defined $node->{'within'}) {
	    $o .= " within " . $node->{'within'} . " " . $node->{'timeframe'};
	}
    }

    return $o;
}


sub pp_primrule{
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
    
    $o .= $node->{'name'} . "(";
    $o .= join ", ", pp_rands($node->{'args'});
    $o .= ")";
    if(@{ $node->{'modifiers'} } > 0) {
	$o .= "\n". $beg . "with\n";
	$o .= join " and\n", 
	        map {pp_modifier($_, $indent+$g_indent)} 
	            @{ $node->{'modifiers'} };
    }
	
    $o .= ";\n";
    

    return $o;
}

sub pp_modifier{
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
    
    $o .= $node->{'name'} . " = ";
    $o .= pp_expr($node->{'value'});


    return $o;
}


sub pp_callbacks {
    my ($node, $indent, $sense) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    $o .= "callbacks {\n";
    foreach my $sense ('success','failure') {
	if(@{ $node->{$sense} } > 0) {
	    $o .= pp_callback_types($node->{$sense},
				    $indent+$g_indent,
				    $sense);
	}
    }
    $o .= $beg . "}\n";
    return $o;
}


sub pp_callback_types {
    my ($node_list, $indent, $sense) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    $o .= $sense . " {\n";

    $o .= join ";\n", map {pp_callback($_,$indent+$g_indent)} @{ $node_list};

    $o .= "\n" . $beg . "}\n";

    return $o;
}

sub pp_callback {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    $o .= $node->{'type'} . " " . $node->{'attribute'} . "=";
    $o .= '"' . $node->{'value'} . '"';

    return $o;
}


sub pp_post {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
    $o .= $node->{'type'} . " {\n";

    $o .= pp_counter_expr($node->{'cons'}, $indent+$g_indent);

    if(defined $node->{'alt'}) {
	$o .= $beg . "} else {\n";
	
	$o .= pp_counter_expr($node->{'alt'}, $indent+$g_indent);

    }

    $o .= $beg . "}\n";
    return $o;
}


sub pp_counter_expr {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    my $counter =  "counter" . "." . $node->{'name'};

    if($node->{'type'} eq 'iterator') {
	$o .= $counter . " " . $node->{'op'} . " " . $node->{'value'};
	if(defined $node->{'from'}) {
	    $o .= " from " . $node->{'from'};
	}
	$o .= ";\n";
	
    } else { # clear

	$o .= "clear " . $counter . ";\n";
    }

    return $o;
}

# expressions below
sub pp_expr {
    my $expr = shift;

    my @nodes = keys %{ $expr };  # these are singleton hashes
    my $val =  $expr->{$nodes[0]};

    case: for ($nodes[0]) {
	/str/ && do {
#	    $val =~ s/'/\\'/g;  #' - for syntax highlighting
	    return '"' . $val . '"';
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
	    return pp_prim($val);
	};
	
    } 

}

sub pp_prim {
    my $prim = shift;

    join(' ' . $prim->{'op'} . ' ', pp_rands($prim->{'args'}));

    
}

sub pp_rands {
    my $rands = shift;

    map {pp_expr($_)} @{ $rands };

}




1;
