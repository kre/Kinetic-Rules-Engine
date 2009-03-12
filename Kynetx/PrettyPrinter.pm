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


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $g_indent = 4;


sub pp {
    my ($ruleset) = @_;

    print Dumper($ruleset);

    my $name = $ruleset->{'ruleset_name'};
    my $rules = $ruleset->{'rules'};

    my $o = "";

    $o .= "ruleset $name {\n";


    if( $ruleset->{'meta'} && %{ $ruleset->{'meta'}} ) {
	$o .= pp_meta_block($ruleset->{'meta'}, $g_indent);
    }    

    if( $ruleset->{'dispatch'} && @{ $ruleset->{'dispatch'} }) {
	$o .= pp_dispatch_block($ruleset->{'dispatch'}, $g_indent);
    }    

    if( $ruleset->{'datasets'} && @{ $ruleset->{'datasets'} }) {
	$o .= pp_datasets_block($ruleset->{'datasets'}, $g_indent);
    }    

    if( $ruleset->{'global'} && @{ $ruleset->{'global'} }) {
	$o .= pp_global_block($ruleset->{'global'}, $g_indent);
    }    

    $o .= pp_rules($rules,$g_indent);
    $o .= "\n}\n";
    
    return $o;
}

sub pp_meta_block {
    my ($mb, $indent) = @_;

    my $beg = " "x$indent;


    my $o .= $beg . "meta {\n";
    
    $o .= pp_desc($mb->{'description'}, $indent+$g_indent) if ($mb->{'description'}) ;
    $o .= pp_logging($mb->{'logging'}, $indent+$g_indent) if ($mb->{'logging'}) ;

    $o .= $beg . "}\n";

    return $o;

}

sub pp_desc {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= "description <<\n";
    $o .= $node;
    $o .= $beg . ">>\n";
  
    return $o;
}

sub pp_logging {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= "logging ";
    $o .= $node;
  
    return $o;
}



sub pp_dispatch_block {
    my ($db, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . "dispatch {\n";
    foreach my $d ( @{$db}) {

	$o .= pp_dispatch($d, $indent+$g_indent) . ";";
    }
    $o .= $beg . "}\n";

    return $o;

}


sub pp_dispatch {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . "domain " ;
    $o .= '"'.$d->{'domain'}.'"';  
    $o .= " -> ";
    $o .= '"'.$d->{'ruleset_name'}.'"';
    $o .= "\n";

    return $o;

}


# sub pp_datasets_block {
#     my ($db, $indent) = @_;

#     my $beg = " "x$indent;

#     my $o .= $beg . "datasets {\n";
#     foreach my $d ( @{$db}) {

# 	$o .= pp_dataset($d, $indent+$g_indent) . ";";
#     }
#     $o .= $beg . "}\n";

#     return $o;

# }


sub pp_dataset {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . 'dataset ' . $d->{'name'} . ' <- "'. $d->{'source'} . '"' ;
    if($d->{'cachable'}) {
	$o .= " cachable";
	if (ref $d->{'cachable'} eq 'HASH') {
	    $o .= " for " . $d->{'cachable'}->{'value'} . " " .  $d->{'cachable'}->{'period'};
	}
    }
    $o .= "\n";

    return $o;

}



sub pp_global_block {
    my ($db, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . "global {\n";
    foreach my $d ( @{$db}) {

	if (defined $d->{'name'}) { # this is a data set

	    $o .= pp_dataset($d, $indent+$g_indent) . ";";
	} else {

	    $o .= pp_global_emit($d, $indent+$g_indent) . ";";
	}
    }
    $o .= $beg . "}\n";

    return $o;

}

sub pp_global_emit {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $o;
    if($d->{'emit'}) {
	$o .= $beg . "emit << " ;
	$o .= $d->{'emit'};
	$o .= ">>\n";
    }
    
    

    return $o;

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

    my $o;

    if(defined $r->{'pagetype'}) {
	$o .= pp_select($r->{'pagetype'},$indent+$g_indent);
    }

    $o .= pp_pre($r->{'pre'},$indent+$g_indent);

    if(defined $r->{'emit'}) {
	$o .= pp_emit($r->{'emit'},$indent+$g_indent);
    }

    if(defined $r->{'cond'}) {
	$o.= pp_cond($r,$indent+$g_indent);
    } else { # just actions
	$o.= pp_actions($r->{'actions'},$r->{'blocktype'},$indent+$g_indent);
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
	$o .= ";\n"
    }
    $o .= $beg . "}\n";
  
    return $o;
}

sub pp_decl {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;


    my $logger = get_logger();

    $logger->debug("Seeing ", $node->{'type'});

    if($node->{'type'} eq 'counter') {
	$o .= $node->{'lhs'} . " = " . $node->{'type'} . "." .  
	    $node->{'name'} ;
    } elsif($node->{'type'} eq 'data_source') { # datasource

	$o .= $node->{'lhs'} . " = ";
	$o .= $node->{'source'} . ":" . $node->{'function'} . "(";
	$o .= join ", ", pp_rands($node->{'args'});
	$o .= ")";
    } elsif($node->{'type'} eq 'here_doc') { 

	$o .= $node->{'lhs'} . " = << \n";
	$o .= $node->{'value'};
	$o .= "\n >>";
    }
  
    return $o;

}


sub pp_emit {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= "emit <<\n";
    $o .= $node;
    $o .= $beg . ">>\n";
  
    return $o;
}


sub pp_cond {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    my $pred = pp_predexpr($node->{'cond'});
    my $actions = pp_actions($node->{'actions'},$node->{'blocktype'},$indent);

    if($pred eq 'true') {
	$o .= $actions;
    } else {
	$o .= "if ";
	$o .= $pred;
	    $o .= "\n" . $beg . "then\n";
	$o .= $actions;
	$o .= $beg . "\n";
    } 

    return $o;

}


# expressions below
sub pp_predexpr {
    my $expr = shift;

    case: for ($expr->{'type'}) {
	/ineq/ && do {
	    return join(' ' . $expr->{'op'} . ' ', 
			pp_rands($expr->{'args'}))  ;
        };
	/pred/ && do {
	    return pp_pred($expr);
	};
	/.*/ && do {
	    return pp_expr($expr);
	};
	
    } 

}


sub pp_pred {
    my $pred = shift;
    
    if($pred->{'op'} eq 'negation') {
	return 'not' . pp_predexpr($pred->{'args'}->[0]) ;
    } else {
	return 
	    '(' . 
	    join(' ' . $pred->{'op'} . ' ', pp_predrands($pred->{'args'})) .
	    ')';
    }

    
}

sub pp_predrands {
    my $rands = shift;

    map {pp_predexpr($_)} @{ $rands };

}


# sub pp_pred{
#     my ($node, $indent) = @_;
#     my $beg = " "x$indent;
#     my $o = $beg;
#     if($node->{'type'} eq 'simple') {
# 	$o .= $node->{'predicate'} . "(";
# 	$o .= join ", ", pp_rands($node->{'args'});
# 	$o .= ")";
#     } elsif($node->{'type'} eq 'qualified') {
# 	$o .= $node->{'source'} . ':';
# 	$o .= $node->{'predicate'} . "(";
# 	$o .= join ", ", pp_rands($node->{'args'});
# 	$o .= ")";
#     } else { #counter
# 	$o .= $node->{'type'} . "." . $node->{'name'};
# 	$o .= " " . $node->{'ineq'} . " ";
# 	$o .= $node->{'value'};
# 	if(defined $node->{'within'}) {
# 	    $o .= " within " . $node->{'within'} . " " . $node->{'timeframe'};
# 	}
#     }

#     return $o;
# }


sub pp_actions {
    my ($node, $blocktype, $indent) = @_;
    my $beg = " "x$indent;
    my $o = "";



    if(defined $node && @{$node} > 1) { #actionblock
	$o .= pp_actionblock($node, $blocktype, $indent);
    } else { # primrule
	# singleton block; deal with it
	$o .= pp_primrule($node->[0], $indent+$g_indent);
    }
   
    return $o;
}


sub pp_actionblock {
    my ($node, $blocktype, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
    
    $o .= $blocktype . " {\n";
    foreach my $pr (@{ $node }) {
	$o .= pp_primrule($pr,$indent+$g_indent);
    }
    $o .= $beg . "}\n";

    return $o;
}


sub pp_primrule{
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;

    if(defined $node->{'emit'}) {

	if($node->{'label'}) {
	    $o .= $node->{'label'} . ":\n";
	    $beg .= " "x$g_indent;
	    $o .= $beg;
	}

	$o .= pp_emit($node->{'emit'},$indent+$g_indent) ;
    } else {


	if($node->{'label'}) {
	    $o .= $node->{'label'} . ":\n";
	    $beg .= " "x$g_indent;
	    $o .= $beg;
	}
	
	

	$o .= $node->{'action'}->{'name'} . "(";
	$o .= join ", ", pp_rands($node->{'action'}->{'args'});
	$o .= ")";
	if(defined $node->{'action'}->{'modifiers'} && 
	   @{ $node->{'action'}->{'modifiers'} } > 0) {
	    $o .= "\n". $beg . "with\n";
	    $o .= join " and\n", 
	    map {pp_modifier($_, $indent+$g_indent+$g_indent)} 
	    @{ $node->{'action'}->{'modifiers'} };
	}
	
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
	if(defined $node->{$sense} && 
	   @{ $node->{$sense} } > 0) {
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


    case: for ($expr->{'type'}) {
	/str/ && do {
#	    $expr->{'val'} =~ s/'/\\'/g;  #' - for syntax highlighting
	    return '"' . $expr->{'val'} . '"';
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
	    return  "[" . join(', ', pp_rands($expr->{'val'})) . "]" ;
	};
	/prim/ && do {
	    return pp_prim($expr);
	};
	/simple/ && do {
	    my $o = '';
	    $o .= $expr->{'predicate'} . "(";
	    $o .= join ", ", pp_rands($expr->{'args'});
	    $o .= ")";
	    return $o;
	};
	/qualified/ && do {
	    my $o = '';
	    $o .= $expr->{'source'} . ':';
	    $o .= $expr->{'predicate'} . "(";
	    $o .= join ", ", pp_rands($expr->{'args'});
	    $o .= ")";
	    return  $o ;
	};
	/counter/ && do {
	    my $o = '';
	    $o .= $expr->{'type'} . "." . $expr->{'name'};
	    $o .= " " . $expr->{'ineq'} . " ";
	    $o .= $expr->{'value'};
	    if(defined $expr->{'within'}) {
		$o .= " within " . $expr->{'within'} . " " . $expr->{'timeframe'};
	    }
	    return  $o ;
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
