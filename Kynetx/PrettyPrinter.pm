package Kynetx::PrettyPrinter;
# file: Kynetx/PrettyPrinter.pm
#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc. 
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
use strict;
#use warnings;

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

    $o .= pp_authz($mb->{'authz'}, $indent+$g_indent) if ($mb->{'authz'}) ;

    $o .= pp_logging($mb->{'logging'}, $indent+$g_indent) if ($mb->{'logging'}) ;

    $o .= pp_sharing($mb->{'sharing'}, $indent+$g_indent) if ($mb->{'sharing'}) ;

    $o .= pp_keys($mb->{'keys'}, $indent+$g_indent) if ($mb->{'keys'}) ;

    $o .= pp_errorsto($mb->{'errors'}, $indent+$g_indent) if ($mb->{'errors'}) ;

    $o .= pp_use($mb->{'use'}, $indent+$g_indent) if ($mb->{'use'}) ;

    $o .= pp_configure($mb->{'configure'}, $indent+$g_indent) if ($mb->{'configure'}) ;
    $o .= pp_provide($mb->{'provide'}, $indent+$g_indent) if ($mb->{'provide'}) ;
    $o .= pp_provides_keys($mb->{'module_keys'},$indent+$g_indent) if ($mb->{'module_keys'}) ;

    $o .= $beg . "\n$beg}\n";

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
	$o .= "\n>>\n";
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

sub pp_sharing {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= "sharing ";
    $o .= $node;
  
    return $o;
}

sub pp_authz {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= "authz ";
    $o .= $node->{'type'} . " " . $node->{'level'} ;
  
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

sub pp_errorsto {
    my ($node, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = $beg;

    $o .= "errors to ";
    $o .= $node->{'rid'};

    $o .= " version " . pp_string($node->{'version'}) if $node->{'version'};
  
    return $o;
}

sub pp_provides_keys {
  my ($node, $indent) = @_;
  my $beg = " "x$indent;
  my $o = $beg;
  my $keys = join(', ', @{ $node->{'provides_keys'} });
  my $rids = join(', ', @{ $node->{'provides_rids'} });
  $o .= 'provide keys ' . $keys . ' to ' . $rids;
  return $o;
}

sub pp_provide {
  my ($node, $indent) = @_;

  my $beg = " "x$indent;
    
  my $o = $beg;

  $o .= 'provide ' . join(', ', @{ $node->{'names'} });

  return $o;
  }

sub pp_configure {
  my ($node, $indent) = @_;

  my $beg = " "x$indent;
    
  my $o = $beg;

  $o .= 'configure using ';
  $o .= join " and\n", 
      map {pp_modifier($_, $indent+$g_indent+$g_indent)} 
	@{ $node->{'configuration'} };
  return $o;
  }



sub pp_use {
    my ($node, $indent) = @_;

    return '' unless ref $node eq 'ARRAY';

    my $beg = " "x$indent;
    
    my $o = '';

    foreach my $u ( @{ $node }) {

      if ($u->{'type'} eq 'module') {
	$o .= $beg ."use " . $u->{'type'} . " " . $u->{'name'};
	$o .= " alias " . $u->{'alias'} if $u->{'alias'};
	$o .= pp_modifier_clause($u, $indent);
	$o .= "\n";
      } elsif ($u->{'type'} eq 'resource') {
	$o .= $beg ."use " . $u->{'resource_type'} . " " . $u->{'type'} . " " ;
	if ($u->{'resource'}->{'type'} eq 'url') {
	  $o .= pp_string($u->{'resource'}->{'location'}); 
	} else {
	  $o .= $u->{'resource'}->{'location'}; 
	}

	$o .= "\n";
      }
    }
    return $o;
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

    my $o = '';
    if (defined $d->{'domain'}) {
      $o .= $beg . "domain " ;
      $o .= '"'.$d->{'domain'}.'"';  
      if(defined $d->{'ruleset_id'}) {
	$o .= " -> ";
	$o .= '"'.$d->{'ruleset_id'}.'"';
      }
    } else {
      $o .= $beg . "iframe " ;
      $o .= '"'.$d->{'iframe'}.'"';  
      
    }
    $o .= "\n";

    return $o;

}



sub pp_dataset {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $var = $d->{'name'};

    my $o .= $beg . 'dataset ';

    $o .= ":" . $d->{'datatype'} unless $d->{'datatype'} eq 'JSON';
    $o .= $var . ' <- "'. $d->{'source'} . '"' ;
    $o .= pp_cachable($d) if($d->{'cachable'}) ;
    $o .= "\n";

    return $o;

}


sub pp_datasource {
    my ($d, $indent) = @_;

    my $beg = " "x$indent;

    my $var = $d->{'name'};

    my $o .= $beg . 'datasource ' . $var;
    $o .= ":" . $d->{'datatype'} unless $d->{'datatype'} eq 'JSON';
    $o .= ' <- "'. $d->{'source'} . '"' ;
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
	} elsif (defined $d->{'type'} && $d->{'type'} eq 'JS') {
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

    my $o = pp_emit($d->{'emit'},$indent+$g_indent);

    return $o;

}

sub pp_rules {
    my ($rules, $indent) = @_;

    my $beg = " "x$indent;
    
    my $o = "";
    foreach my $r ( @{$rules}) {
	$o .= $beg . "rule " . $r->{'name'} ;
	$o .= " is " . $r->{'state'} if $r->{'state'};
	$o .= " {\n";

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

    $o .= pp_pre($r->{'pre'},$indent+$g_indent) if(defined $r->{'pre'} && @{$r->{'pre'}});

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

    if (defined $node->{'pattern'}) {
      $o .= 'select using "' . $node->{'pattern'} ;
      $o .= '" setting(' . join(',',@{$node->{'vars'}}) . ")\n" if $node->{'vars'}; 
    } else {
      if (defined $node->{'event_expr'}->{'legacy'}) {
	$o .= 'select using ';
      } else {
	$o .= 'select when ';
      }
      $o .= pp_event_expr($node->{'event_expr'}, $indent+$g_indent);
      $o .= "\n";
    } 

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
    # for old parse trees
    $fe->{'var'} = [$fe->{'var'}] unless (ref $fe->{'var'} eq 'ARRAY');
    $o .= pp_setting([join(',',@{$fe->{'var'}})]) . "\n" ;
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

sub pp_event_expr {
  my($node, $indent) = @_;
  my $o = '';

  if ($node->{'type'} eq 'complex_event') {
    if ($node->{'op'} eq 'between' ||
        $node->{'op'} eq 'notbetween') {
      $o .= pp_event_expr($node->{'mid'},$indent);
      $o .= ' ' . (($node->{'op'} eq 'notbetween') ? 'not ' : '') . "between(";
      $o .= pp_event_expr($node->{'first'},$indent);
      $o .= ', ';
      $o .= pp_event_expr($node->{'last'},$indent);
      $o .= ")\n";

    } else {
      $o .= pp_event_expr($node->{'args'}->[0],$indent);
      $o .= ' ' . $node->{'op'} . "\n" . " "x$indent;
      $o .= pp_event_expr($node->{'args'}->[1],$indent);
    }
  } elsif ($node->{'type'} eq 'prim_event') {

    if (!defined $node->{'domain'} || $node->{'domain'} eq 'web') {
      if ($node->{'op'} eq 'pageview') {
		my $fpat = "";
		my $ftype = "";
		my $op = 'pageview';
#		if (! defined $node->{'legacy'}) {
#		  $o .= $node->{'domain'}  if $node->{'domain'};
#		  $o .= 'pageview '
#		}
		# New AST syntax for common filter
		$o .= $node->{'domain'} . " " if $node->{'domain'};
		if (defined $node->{'filters'}) {
			my $filters = $node->{'filters'};
			foreach my $filter (@$filters) {
				if ($filter->{'type'} ne 'default') {
					$ftype = $filter->{'type'} . " ";
				}
				$fpat = pp_string($filter->{'pattern'}) . " ";
				$o .= $op . " " . $ftype . $fpat;
			}
			$o .= pp_setting($node->{'vars'}) if defined $node->{'vars'};
		} else {
			$o .= pp_string($node->{'pattern'});
			$o .= pp_setting($node->{'vars'}) if defined $node->{'vars'};			
		}
      } elsif ($node->{'op'} eq 'submit' ||
	       $node->{'op'} eq 'change' ||
	       $node->{'op'} eq 'update' ||
	       $node->{'op'} eq 'dblclick' ||
	       $node->{'op'} eq 'click') {
	$o .= $node->{'domain'} if $node->{'domain'};
	$o .= $node->{'op'} . ' ';
	$o .= pp_string($node->{'element'});
	$o .= pp_on_expr($node->{'on'}) if defined $node->{'on'};
	$o .= pp_setting($node->{'vars'}) if defined $node->{'vars'};
      }
    } elsif ($node->{'domain'} eq 'mail') {
      $o .= $node->{'domain'} . " ";
      $o .= $node->{'op'} . ' ';
      foreach my $f (@{ $node->{'filters'} }) {
	$o .= $f->{'type'} . ' ' . pp_string($f->{'pattern'}) . ' ' ;
      }
      $o .= pp_setting($node->{'vars'}) if defined $node->{'vars'};
    } else {
      $o .= $node->{'domain'} . " ";
      $o .= $node->{'op'} . ' ';
      foreach my $f (@{ $node->{'filters'} }) {
	$o .= $f->{'type'} . ' ' . pp_string($f->{'pattern'}) . ' ' ;
      }
      $o .= pp_setting($node->{'vars'}) if defined $node->{'vars'};
     
    }

  }

  return $o;

}

sub pp_on_expr {
  my $node = shift;

  return ' on ' . pp_string($node);
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

#    $logger->debug("Seeing ", $node->{'type'});

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
    } elsif($node->{'type'} eq 'JS') { 
	$o .= $node->{'lhs'} . " = ";
	$o .= pp_JS($node->{'rhs'});
    } elsif($node->{'type'} eq 'xdi') {
    	$o .= $node->{'lhs'} . " = ";
    	$o .= pp_XDI($node->{'rhs'});
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
    my $o;

    my $pred = pp_expr($node->{'cond'});
    my $actions;

    if($pred eq 'true') {
        
	$o .= pp_actions($node->{'actions'},$node->{'blocktype'},$indent);
    } else {

	$o .= $beg . "if ";
	$o .= $pred;
	$o .= "\n" . $beg . "then\n";
	$o .= pp_actions($node->{'actions'},$node->{'blocktype'},$g_indent+$indent);
	$o .= $beg . "\n";
    } 

    return $o;

}



sub pp_string {
    my $str = shift;
    return '"'.$str.'"';
}


sub pp_pred {
    my $pred = shift;
    
    if($pred->{'op'} eq 'negation') {
	return '(not ' . pp_expr($pred->{'args'}->[0]) . ')' ;
    } else {
	return '(' .
	    join(' ' . $pred->{'op'} . ' ', pp_rands($pred->{'args'})) .
          ')';

    }

    
}


sub pp_actions {
    my ($node, $blocktype, $indent) = @_;
    my $beg = " "x$indent;
    my $o = "";



    if(defined $node && @{$node} > 1) { #actionblock
	$o .= pp_actionblock($node, $blocktype, $indent);
    } else { # primrule
	# singleton block; deal with it
	$o .= pp_primrule($node->[0], $indent);
    }
   
    return $o;
}


sub pp_actionblock {
    my ($node, $blocktype, $indent) = @_;
    my $beg = " "x$indent;
    my $o = $beg;
#    my $o;
    
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
#    my $beg;
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
	    $beg .= " "x$indent;
	    $o .= $beg;
	}

	if ($node->{'action'}->{'source'}) {
	    $o .=  $node->{'action'}->{'source'} . ":";
	}
	

	$o .= $node->{'action'}->{'name'} . "(";
	$o .= join ", ", pp_rands($node->{'action'}->{'args'});
	$o .= ")";
	$o .= ' setting(' . join(',',@{$node->{'action'}->{'vars'}}) . ")" if $node->{'action'}->{'vars'}; 
	$o .= pp_modifier_clause($node->{'action'}, $indent);
	
    }	

    $o .= ";\n";

    return $o;
}

sub pp_modifier_clause {
  my($node, $indent) = @_;
  my $beg = " "x$indent;
  my $o = '';
  if(defined $node->{'modifiers'} && 
     @{ $node->{'modifiers'} } > 0) {
    $o .= "\n". $beg . "with\n";
    $o .= join " and\n", 
      map {pp_modifier($_, $indent+$g_indent+$g_indent)} 
	@{ $node->{'modifiers'} };

  }
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
    } elsif($node->{'type'} eq 'log' || $node->{'type'} eq 'error') {
	$o.= pp_log_statement($node);
    } elsif($node->{'type'} eq 'control') {
	$o.= pp_control_statement($node);
    } elsif($node->{'type'} eq 'raise') {
	$o.= pp_raise_statement($node, $indent);
    } elsif($node->{'type'} eq 'schedule') {
	$o.= pp_schedule_statement($node, $indent);
    }
    if (defined $node->{'test'}) {
      if (defined $node->{'test'}->{'type'} && 
	  $node->{'test'}->{'type'} eq 'if') {
	$o .= ' if ' . pp_expr($node->{'test'}->{'expr'}) ;
      } elsif (defined $node->{'test'}->{'type'} && 
	       $node->{'test'}->{'type'} eq 'on' ) {
	$o .= ' on '. $node->{'test'}->{'value'};
      }
    }


    return $o . ";\n";
}


sub pp_persistent_expr {
    my ($node) = @_;
    
    my $o = '';

    if($node->{'action'} eq 'set') {
	$o .= 'set ' . pp_var_domain($node->{'domain'}, $node->{'name'});
    } elsif($node->{'action'} eq 'set_hash') {
    	$o .= 'set ' . pp_var_domain($node->{'domain'}, $node->{'name'});
    	$o .= '{' . pp_expr($node->{'hash_element'}) . '} ';
    	$o .= pp_expr($node->{'value'});
    } elsif($node->{'action'} eq 'set_array') {
    	$o .= 'set ' . pp_var_domain($node->{'domain'}, $node->{'name'});
    	$o .= '[' . pp_expr($node->{'array_index'}) . '] ';
    	$o .= pp_expr($node->{'value'});
    } elsif($node->{'action'} eq 'clear') {
	$o .= 'clear ' . pp_var_domain($node->{'domain'}, $node->{'name'});
    } elsif($node->{'action'} eq 'clear_hash_element') {
		$o .= 'clear ' . pp_var_domain($node->{'domain'}, $node->{'name'});
		$o .= '{'. pp_expr($node->{'hash_element'}) . '}';
    } elsif($node->{'action'} eq 'clear_array_element') {
		$o .= 'clear ' . pp_var_domain($node->{'domain'}, $node->{'name'});
		$o .= '['. pp_expr($node->{'array_index'}) . ']';
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

    $o = $node->{'type'};
    $o .= " " . $node->{'level'} . " " if(defined $node->{'level'});
    $o .= pp_expr($node->{'what'});

    return $o;

  }

sub pp_control_statement {
    my ($node) = @_;
    
    my $o = '';

    $o .= $node->{'statement'};
    return $o;

  }

sub pp_raise_statement {
    my ($node, $indent) = @_;
    
    my $o = '';

    $o .= join(' ',
	       @{['raise',
		  $node->{'domain'},
		  'event',
		  pp_expr($node->{'event'})]
	       });
    if($node->{'ruleset'}) {
      $o .= ' for ' . pp_expr($node->{'ruleset'});
    }
    if (defined $node->{'modifiers'}) {
      $o .= pp_modifier_clause($node, $indent);
    } elsif (defined $node->{'attributes'} ) {
      $o .= ' attributes ' . pp_expr($node->{'attributes'}, $indent);
    }
    return $o;

  }

sub pp_schedule_statement {
    my ($node, $indent) = @_;
    
    my $o = '';

    $o .= join(' ',
	       @{['schedule',
		  $node->{'domain'},
		  'event',
		  pp_expr($node->{'event'})]
	       });
    if($node->{'timespec'}) {
      $o .= pp_timespec($node->{'timespec'});
    }
    if (defined $node->{'modifiers'}) {
      $o .= pp_modifier_clause($node, $indent);
    } elsif (defined $node->{'attributes'} ) {
      $o .= ' attributes ' . pp_expr($node->{'attributes'}, $indent);
    }
    return $o;

  }

sub pp_timespec {
  my ($node) = @_;
  my $o = '';
  if ($node->{'once'}) {
    $o .= ' at ' . pp_expr($node->{'once'});
  } else {
    $o .= ' repeat ' . pp_expr($node->{'repeat'});
  }
  return $o;
}

# expressions below
sub pp_expr {
    my $expr = shift;

    return '' unless defined $expr->{'type'};

    case: for ($expr->{'type'}) {
	/str/ && do {
	    return pp_string($expr->{'val'});
	};
	/num/ && do {
	    return  $expr->{'val'} ;
	};
	/JS/ && do {
	    return  pp_JS($expr->{'val'}) ;
	};
	/XDI/ && do {
		return pp_XDI($expr->{'val'});
	};
	/regexp/ && do {
	    return  're'.$expr->{'val'} ;
	};
	/var/ && do {
	    return  $expr->{'val'} ;
	};
	/bool/ && do {
	    return  $expr->{'val'} ;
	};
	/^array$/ && do {
	    return  "[" . join(', ', pp_rands($expr->{'val'})) . "]" ;
	};
	/^array_ref$/ && do {
	    return  $expr->{'val'}->{'var_expr'} . '['. pp_expr($expr->{'val'}->{'index'}) . ']';
	};
	/^hash_ref$/ && do {
	    return  $expr->{'var_expr'} . '{'. pp_expr($expr->{'hash_key'}) . '}';
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
	    if($expr->{'offset'}->{'type'} eq 'num' &&
	       $expr->{'offset'}->{'val'} == 0) {
		$o .= 'current ';
	    } else {
		$o .= 'history ' . pp_expr($expr->{'offset'});
	    }
	    return $o . ' ' . pp_var_domain($expr->{'domain'}, $expr->{'name'});
	};
	/^app$/ && do {
	    my $o = '';
	    $o .= pp_expr($expr->{'function_expr'}) . "(";
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
	/^function$/ && do {
	    return pp_function($expr);
	};
	/^pred$/ && do {
	    my $o = pp_pred($expr);
	    return  $o ;
	};
	/^condexpr$/ && do {
	    my $o = '';
	    $o .= pp_expr($expr->{'test'}) . ' => ';
	    $o .= pp_expr($expr->{'then'}) . ' | ';
	    $o .= pp_expr($expr->{'else'});
	    return  $o ;
	};
	/operator/ && do {
	    my $o = '';
	    $o .= pp_expr($expr->{'obj'}) . '.' . $expr->{'name'} . '(';
	    $o .= join ", ", pp_rands($expr->{'args'});
	    $o .= ')';
	    return  $o ;
	};
	/^ineq$/ && do {
	    return '('. join(' ' . $expr->{'op'} . ' ', 
			pp_rands($expr->{'args'}))  . ')' ;
        };
	/seen_timeframe/ && do {
	    return join(' ', 
			('seen',
			 pp_expr($expr->{'regexp'}),
			 'in',
			 pp_var_domain($expr->{'domain'}, 
				       $expr->{'var'}),
			 pp_timeframe($expr)
			));
	};
	/seen_compare/ && do {
	    return join(' ', 
			('seen',
			 pp_expr($expr->{'regexp_1'}),
			 $expr->{'op'},
			 pp_expr($expr->{'regexp_2'}), 
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
	
    } 

}

sub pp_function {
  my $expr = shift;
  my $o = '';
  $o .= 'function (';
  $o .= join ", ", @{ $expr->{'vars'} };
  $o .= ") {";
  $o .= join "; ", (map {pp_decl($_, 0)} @{ $expr->{'decls'} });
  $o .= "; " if @{$expr->{'decls'}};
  $o .=  pp_expr($expr->{'expr'});
  $o .= "}";
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

    if ( $prim->{'op'} eq 'NEG') {
      my @rands = pp_rands($prim->{'args'});
      return '-'.$rands[0];
    } else {
      return '('. join(' ' . $prim->{'op'} . ' ', pp_rands($prim->{'args'})) . ')';
    }

    
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
    return  pp_expr($hash_line->{'lhs'}) .' : ' . pp_expr($hash_line->{'rhs'});

}

sub pp_JS {
  my $js = shift;
  return '<|' . $js . '|>';
}

sub pp_XDI {
	my $xdi = shift;
	return '<[' . $xdi .']>';
}


1;
