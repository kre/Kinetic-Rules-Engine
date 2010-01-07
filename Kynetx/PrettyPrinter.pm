package Kynetx::PrettyPrinter;
# file: Kynetx/PrettyPrinter.pm
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

#    print Dumper($ruleset);

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
    
    $o .= pp_meta_item('name',$mb, $indent+$g_indent);
    $o .= pp_meta_item('author',$mb, $indent+$g_indent);
    $o .= pp_meta_item('description',$mb, $indent+$g_indent);

    $o .= pp_logging($mb->{'logging'}, $indent+$g_indent) if ($mb->{'logging'}) ;

    $o .= pp_keys($mb->{'keys'}, $indent+$g_indent) if ($mb->{'keys'}) ;

    $o .= $beg . "}\n";

    return $o;

}

sub pp_meta_item {
    my ($item, $mb, $indent) = @_;

    return "" unless $mb->{$item};

    my $node = $mb->{$item};


    my $beg = " "x$indent;
    
    
    my $o = $beg;

    if ($item eq 'description') {
	$o .= "description <<\n";
    } else {
	$o .= "$item \"";
    }
    $o .= $node;
    if ($item eq 'description') {
	$o .= $beg . ">>\n";
    } else {
	$o .= "\"\n";
    }
  
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


sub pp_keys {
    my ($node, $indent) = @_;

    return unless ref $node eq 'HASH';

    my $beg = " "x$indent;
    
    my $o = '';
    foreach my $k (sort keys %{ $node }) {
	$o .= $beg ."key ";
	$o .= $k . " ";
	$o .= pp_keyval($node->{$k}, $indent+$g_indent) . "\n";
    }
    return $o;
}


sub pp_keyval {
  my ($node, $indent) = @_;

  my $beg = " "x$indent;

  my $o = '';
  if (ref $node eq 'HASH') {
    $o .= "{\n$beg";
    $o .= join(",\n$beg", map {'"' . $_ . '" : ' . pp_val($node->{$_}) } (sort keys %{ $node}));
    $o .= "\n$beg}";
  } else {
    $o .= '"' . $node . '"';
  }
}

sub pp_val {
  my($node) = @_;
  if ($node =~ /^\d+$/) {
    return $node;
  } else {
    return '"'.$node.'"';
  }
}

sub pp_dispatch_block {
    my ($db, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . "dispatch {\n";
    foreach my $d ( @{$db}) {

	$o .= pp_dispatch($d, $indent+$g_indent) ;
    }
    $o .= $beg . "}\n";

    return $o;

}


sub pp_dispatch {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . "domain " ;
    $o .= '"'.$d->{'domain'}.'"';  
    if(defined $d->{'ruleset_id'}) {
	$o .= " -> ";
	$o .= '"'.$d->{'ruleset_id'}.'"';
    }
    $o .= "\n";

    return $o;

}



sub pp_dataset {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $var = $d->{'name'};

    my $o .= $beg . 'dataset ' . $var . ' <- "'. $d->{'source'} . '"' ;
    $o .= pp_cachable($d) if($d->{'cachable'}) ;
    $o .= "\n";

    return $o;

}


sub pp_datasource {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $var = $d->{'name'};

    my $o .= $beg . 'datasource ' . $var . ' <- "'. $d->{'source'} . '"' ;
    $o .= pp_cachable($d) if($d->{'cachable'}) ;
    $o .= "\n";

    return $o;

}

sub pp_cachable {
    my($d) = @_;

    my $o;
    if($d->{'cachable'}) {
	$o .= " cachable";
	if (ref $d->{'cachable'} eq 'HASH') {
	    $o .= " for " . $d->{'cachable'}->{'value'} . " " .  $d->{'cachable'}->{'period'};
	}
    }
    return $o;
}

sub pp_css {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . 'css  <<' . $d->{'content'}  . '>>';
    $o .= "\n";

    return $o;

}


sub pp_global_block {
    my ($db, $indent) = @_;

    my $beg = " "x$indent;

    my $o .= $beg . "global {\n";
    foreach my $d ( @{$db}) {

	if (defined $d->{'type'} && $d->{'type'} eq 'dataset') { 
	    $o .= pp_dataset($d, $indent+$g_indent) . ";";
	} elsif (defined $d->{'type'} && $d->{'type'} eq 'datasource') { 
	    $o .= pp_datasource($d, $indent+$g_indent) . ";";
	} elsif (defined $d->{'type'} && $d->{'type'} eq 'css') {
	    $o .= pp_css($d, $indent+$g_indent) . ";";
	} elsif (defined $d->{'type'} && $d->{'type'} eq 'expr') {
	    $o .= pp_decl($d, $indent+$g_indent) . ";";
	} elsif (defined $d->{'type'} && $d->{'type'} eq 'here_doc') {
	    $o .= pp_decl($d, $indent+$g_indent) . ";";
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

    $o .= pp_pre($r->{'pre'},$indent+$g_indent) if(defined $r->{'pre'});

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

    $o .= 'select using ' . pp_string($node->{'pattern'});
    $o .= pp_setting($node->{'vars'}) if defined $node->{'vars'};
    $o .= "\n";
    $o .= pp_foreach($node->{'foreach'}, $indent+$g_indent);
    $o .= "\n";

    return $o;

}

sub pp_foreach {
  my($node, $indent) = @_;

  my $o = '';
  foreach my $fe (@{$node}) {
    $o .= " "x$indent;
    $o .= 'foreach ' . pp_expr($fe->{'expr'});
    $o .= pp_setting([$fe->{'var'}]) . "\n" ;
    $indent+=$g_indent;
  }

  return $o;
}

sub pp_setting {
  my ($vars) = @_;
  my $o = ' setting (';
  $o .= join ", ", @{$vars};
  $o .= ")";

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

    # if($node->{'type'} eq 'counter') {
    # 	$o .= $node->{'lhs'} . " = " . $node->{'type'} . "." .  
    # 	    $node->{'name'} ;
    # } elsif($node->{'type'} eq 'data_source') { # datasource

    # 	$o .= $node->{'lhs'} . " = ";
    # 	$o .= $node->{'source'} . ":" . $node->{'function'} . "(";
    # 	$o .= join ", ", pp_rands($node->{'args'});
    # 	$o .= ")";
    if ($node->{'type'} eq 'expr') { 
	$o .= $node->{'lhs'} . " = " . pp_expr($node->{'rhs'},$g_indent+$indent);
    } elsif($node->{'type'} eq 'here_doc') { 
	$o .= $node->{'lhs'} . " = << \n";
	$o .= $node->{'rhs'};
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
	/^ineq$/ && do {
	    return join(' ' . $expr->{'op'} . ' ', 
			pp_rands($expr->{'args'}))  ;
        };
	/seen_timeframe/ && do {
	    return join(' ', 
			('seen',
			 pp_string($expr->{'regexp'}),
			 'in',
			 pp_var_domain($expr->{'domain'}, 
				       $expr->{'var'}),
			 pp_timeframe($expr)
			));
	};
	/seen_compare/ && do {
	    return join(' ', 
			('seen',
			 pp_string($expr->{'regexp_1'}),
			 $expr->{'op'},
			 pp_string($expr->{'regexp_2'}), 
			 'in',
			 pp_var_domain($expr->{'domain'}, $expr->{'var'})
			));
	};
	/persistent_ineq/ && do {
	    if($expr->{'ineq'} eq '==' &&
	       $expr->{'expr'}->{'val'} eq 'true') {
		return join(' ', 
			    (pp_var_domain($expr->{'domain'}, $expr->{'var'}),
			     pp_timeframe($expr)
			    ));
	    } else {
		return join(' ', 
			    (pp_var_domain($expr->{'domain'}, $expr->{'var'}),
			     $expr->{'ineq'},
			     pp_expr($expr->{'expr'}),
			     pp_timeframe($expr)
			    ));
	    }
	};
	/^pred$/ && do {
	    return pp_pred($expr);
	};
	/.*/ && do {
	    return pp_expr($expr);
	};
	
    } 

}

sub pp_string {
    my $str = shift;
    return '"'.$str.'"';
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
	    $o .= $node->{'label'} . " =>\n";
	    $beg .= " "x$g_indent;
	    $o .= $beg;
	}

	$o .= pp_emit($node->{'emit'},$indent+$g_indent) ;
    } else {


	if($node->{'label'}) {
	    $o .= $node->{'label'} . " =>\n";
	    $beg .= " "x$g_indent;
	    $o .= $beg;
	}

	if ($node->{'action'}->{'source'}) {
	    $o .= $node->{'action'}->{'source'} . ":";
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

    $o .= join(' ',
	       ($node->{'type'},
		$node->{'attribute'},
		"=",
		pp_string($node->{'value'}),
		pp_callback_trigger($node),
		)
	);

    return $o;
}

sub pp_callback_trigger {
    my($node) = @_;
    my $o = '';
    if(defined $node->{'trigger'}) {
	$o .= 'triggers '. pp_persistent_expr($node->{'trigger'});
    }
    return $o;
	
}


sub pp_post {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
    $o .= $node->{'type'} . " {\n";

    $o .= join ";\n", 
          map {pp_post_expr($_, $indent+$g_indent)} @{$node->{'cons'}};

    if(defined $node->{'alt'} && $node->{'alt'}) {
	$o .= $beg . "} else {\n";
	$o .= join ";\n", 
	       map {pp_post_expr($_, $indent+$g_indent)} @{$node->{'alt'}};
    }

    $o .= $beg . "}\n";
    return $o;
}

sub pp_post_expr {
    my ($node, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
    if($node->{'type'} eq 'persistent') {
	$o.= pp_persistent_expr($node);
    } elsif($node->{'type'} eq 'log') {
	$o.= pp_log_statement($node);
    } elsif($node->{'type'} eq 'control') {
	$o.= pp_control_statement($node);
    }

    if (defined $node->{'test'}) {
      $o .= ' if ' . pp_predexpr($node->{'test'}) 
    }


    return $o . ";\n";
}


sub pp_persistent_expr {
    my ($node) = @_;
    
    my $o = '';

    if($node->{'action'} eq 'set') {
	$o .= 'set ' . pp_var_domain($node->{'domain'}, $node->{'name'});
    } elsif($node->{'action'} eq 'clear') {
	$o .= 'clear ' . pp_var_domain($node->{'domain'}, $node->{'name'});
    } elsif($node->{'action'} eq 'iterator') {
	$o .= join(' ',
		   (pp_var_domain($node->{'domain'}, $node->{'name'}),
		    $node->{'op'},
		    pp_expr($node->{'value'}),
		    'from',
		    pp_expr($node->{'from'}),
		   ));
    } elsif($node->{'action'} eq 'forget') {
	$o .= join(' ',
		   ('forget',
		    pp_string($node->{'regexp'}),
		    'in',
		    pp_var_domain($node->{'domain'}, $node->{'name'}),
		   ));
    } elsif($node->{'action'} eq 'mark') {
	$o .= join(' ',
		   ('mark',
		    pp_var_domain($node->{'domain'}, $node->{'name'}),
		    pp_mark_with($node),
		   ));
    } 
	

    return $o;
}

sub pp_mark_with {
    my $node = shift;
    if (defined $node->{'with'}) {
	return 'with ' . pp_expr($node->{'with'});
    } else {
	return '';
    }
}

sub pp_log_statement {
    my ($node) = @_;
    
    my $o = '';

    $o = 'log ' . pp_expr($node->{'what'});

    return $o;

  }

sub pp_control_statement {
    my ($node) = @_;
    
    my $o = '';

    $o .= $node->{'statement'};
    return $o;

  }


# expressions below
sub pp_expr {
    my $expr = shift;


    case: for ($expr->{'type'}) {
	/str/ && do {
	    return pp_string($expr->{'val'});
	};
	/num/ && do {
	    return  $expr->{'val'} ;
	};
	/regexp/ && do {
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
	/hashraw/ && do {
	    return  "{" . join(', ', pp_hash_lines($expr->{'val'})) . "}" ;
	};
	/prim/ && do {
	    return pp_prim($expr);
	};
	/^persistent$/ && do {
	    return pp_var_domain($expr->{'domain'}, $expr->{'name'}) ;
	};
	/trail_history/ && do {
	    my $o = '';
	    if($expr->{'offset'}->{'val'} == 0) {
		$o .= 'current ';
	    } else {
		$o .= 'history ' . pp_expr($expr->{'offset'});
	    }
	    return $o . ' ' . pp_var_domain($expr->{'domain'}, $expr->{'name'});
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
	/^pred$/ && do {
	    my $o = pp_pred($expr);
	    return  $o ;
	};
	/^condexpr$/ && do {
	    my $o = '';
	    $o .= pp_predexpr($expr->{'test'}) . ' => ';
	    $o .= pp_expr($expr->{'then'}) . ' | ';
	    $o .= pp_expr($expr->{'else'});
	    return  $o ;
	};
# 	/counter_pred/ && do {
# 	    my $o = '';
# 	    $o .= "counter." . $expr->{'name'};
# 	    $o .= " " . $expr->{'ineq'} . " ";
# 	    $o .= $expr->{'value'};
# 	    if(defined $expr->{'within'}) {
# 		$o .= " within " . $expr->{'within'} . " " . $expr->{'timeframe'};
# 	    }
# 	    return  $o ;
# 	};
	/operator/ && do {
	    my $o = '';
	    $o .= pp_expr($expr->{'obj'}) . '.' . $expr->{'name'} . '(';
	    $o .= join ", ", pp_rands($expr->{'args'});
	    $o .= ')';
	    return  $o ;
	};
	
    } 

}

sub pp_timeframe {
    my $expr = shift;
    my $o = '';
    if(defined $expr->{'within'}) {
	$o .= " within " . pp_expr($expr->{'within'}) . " " . $expr->{'timeframe'};
    }
    return $o;
}

sub pp_var_domain {
    my ($domain, $name) = @_;
    return $domain . ':' . $name;
}


sub pp_prim {
    my $prim = shift;

    return join(' ' . $prim->{'op'} . ' ', pp_rands($prim->{'args'}));

    
}

sub pp_rands {
    my $rands = shift;

    return map {pp_expr($_)} @{ $rands };

}


sub pp_hash_lines {
    my $rands = shift;

    return map {pp_hash_line($_)} @{ $rands };

}

sub pp_hash_line {
    my $hash_line = shift;
    return '"' . $hash_line->{'lhs'} .'" : ' . pp_expr($hash_line->{'rhs'});

}


1;
