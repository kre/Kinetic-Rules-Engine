package Kynetx::Parser;
# file: Kynetx/Parser.pm

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
parse_ruleset
remove_comments
mk_expr_node
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Log::Log4perl qw(get_logger :levels);

use Parse::RecDescent;
use Data::Dumper;

use vars qw(%VARIABLE);

# Enable warnings within the Parse::RecDescent module.

$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
#$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
#$::RD_HINT   = 1; # Give out hints to help fix problems.

#$::RD_AUTOSTUB = 1;
#$::RD_TRACE = 1;

my $grammar = <<'_EOGRAMMAR_';
{my $errors = "";
} # startup action

# Terminals (macros that can't expand further)
#
HTML: /<<.*?>>/s  {$return=Kynetx::Parser::html($item[1]) }
STRING: /"[^"]*"|'[^']'/ {$return=Kynetx::Parser::string($item[1]) }
VAR:   /[_A-Za-z]\w*/ 
NUM:   /\d*\.\d+|\d+/          
COMMA: /,/ 
INCR: /\+=/ 
DECR: /-=/ 
DOT: /\./ 
OP:   m([+-/*])          
LBRACKET: /\[/ 
RBRACKET: /\]/ 
LPAREN: /\(/ 
RPAREN: /\)/ 
EQUALS: /=/ 
INEQUALITY: /[<>]/ 
COLON: /:/ 
SEMICOLON: /;/ 
LOGICAL_AND: /&&/ 
BOOL: 'true' | 'false' 

eofile: /^\Z/

ruleset: 'ruleset' ruleset_name  '{' 
           meta_block(0..1)
           dispatch_block(0..1)
           global_decls(0..1)
           rule(s?)   #??
         '}' eofile
             {$return = {
		 'ruleset_name' => $item{ruleset_name},
		 'meta' => $item[4][0] || {},
		 'dispatch' => $item[5][0] || [],
		 'global' => $item[6][0] || [],
		 'rules' => $item[7]
	         }
	     }
       | { foreach (@{$thisparser->{errors}}) {
              $errors .= "Line $_->[1]:$_->[0]\n";
           }
          $thisparser->{errors} = undef;
          $return = {'error' => $errors}
          }

ruleset_name: VAR  # {return $item[1]}
            | NUM  # {return $item[1]}
            | <error>

meta_block_top: meta_block
   | { foreach (@{$thisparser->{errors}}) {
              $errors .= "Line $_->[1]:$_->[0]\n";
	      print "$_->[1]\n";
           }
       $thisparser->{errors} = undef;
       $return = {'error' => $errors}
     }



meta_block: 'meta' '{' 
       pragma(s?)
      '}' 
    { my $r = {};
      foreach my $a ( @{ $item[3] } ) {
        foreach my $k (keys %{ $a } ) {
           $r->{$k} = $a->{$k};
        }
      }

      $return = $r;
    }
 | <error>

pragma: desc_block 
    {$return = {
        'description' => $item[1]
        }
    }
 | logging_pragma
    {$return = {
        'logging' => $item[1]
        }
    }
 | <error>

desc_block: 'description' (HTML | STRING)
   {$return = $item[2];}
 | <error>


logging_pragma: 'logging' ('on' | 'off')
   {$return = $item[2];}
 | <error>


dispatch_block_top: dispatch_block
   | { $errors = "";
       foreach (@{$thisparser->{errors}}) {
              $errors .= "Line $_->[1]:$_->[0]\n";
	      print "$_->[1]\n";
           }
       $thisparser->{errors} = undef;
       $return = {'error' => $errors}
     }


dispatch_block: 'dispatch' '{' dispatch(s?) '}' #?
     {$return = $item[3]}
   | <error>

dispatch: 'domain' STRING dispatch_target(?)
     {$return = {
	 'domain' => $item[2],
	 'ruleset_id' => $item[3][0] 
         }
     }
   | <error>

dispatch_target: '->' STRING
     {$return = $item[2]
     }
   | <error>
                   

dataset: 'dataset' VAR '<-' STRING cachable(?)
     {$return = {
	 'name' => $item[2],
	 'source' => $item[4],
	 'cachable' => $item[5][0] || 0
         }
     }
    | <error>

cachable: 'cachable' cachetime(?)
     {$return = $item[2][0] || 1
     }
   | <error>

cachetime: 'for' NUM period
     {$return = {
	 'value' => $item[2],
	 'period' => $item[3]
      }
     }
   | <error>

global_decls_top: global_decls
   | { $errors = "";
       foreach (@{$thisparser->{errors}}) {
              $errors .= "Line $_->[1]:$_->[0]\n";
	      print "$_->[1]\n";
           }
       $thisparser->{'errors'} = undef;
       $return = {'error' =>  $errors}
     }


global_decls: 'global' '{' globals(s? /;/)  SEMICOLON(?) '}' #?
     {$return = $item[3]}
    | <error>

globals: emit_block
          {$return = {'emit' => $item[1]
                     }
          }
       | dataset
          {$return = $item[1]
          }
       | <error>


rule_top: rule
   | { $errors = "";
       foreach (@{$thisparser->{errors}}) {
              $errors .= "Line $_->[1]:$_->[0]\n";
	      print "$_->[1]\n";
           }
       $thisparser->{errors} = undef;
       $return = {'error' => $errors}
     }



rule: 'rule' VAR 'is' rule_state '{'
        select
        pre_block
        emit_block(0..1)
        action SEMICOLON(?)
        callbacks(0..1)
        post_block(0..1)
       '}'
  {$return = {'name' => $item{VAR},
	      'state' => $item{rule_state},
	      'pagetype' => $item{select},
  	      'pre' => $item{pre_block},
	      'emit' => $item[8][0],
  	      'actions' => $item{action}->{'actions'},
	      'blocktype' => $item{action}->{'blocktype'} || 'every',
	      'cond' => $item{action}->{'cond'} || 
		        Kynetx::Parser::mk_expr_node('bool','true'),
	      'callbacks' => $item[11][0],
	      'post' => $item[12][0]
           } }
  | <error>


rule_state: 'active'
          | 'inactive'
          | 'test'
          | <error>


select:  'select' 'using' STRING 
            'setting' '(' VAR(s? /,/) ')' SEMICOLON(?) #?
	  {$return =
	   { 'pattern' => $item[3],
	     'vars' => $item[6]
	   } 
	  }
      | <error>


pre_block: 'pre' '{' decl(s? /;/) SEMICOLON(?) '}' #?
           {$return=$item[3]}
         | <error>


decl: VAR '=' VAR ':' VAR '(' expr(s? /,/) ')'
      {$return =
       {'lhs' => $item[1],
        'type' => 'data_source',
        'source' => $item[3],
        'function' => $item[5],
        'args' => $item[7]
       }
      }
    | VAR '=' 'counter' '.' VAR
      {$return =
       {'lhs' => $item[1],
        'type' => $item[3],
        'name' => $item[5]
       }
      }
    | VAR '=' HTML
      {$return =
       {'lhs' => $item[1],
        'type' => 'here_doc',
        'value' => $item[3]
       }
      }
    | <error: Invalid decl: $text>

emit_block: 'emit' (HTML | STRING)
   {$return = $item[2];}


action: conditional_action 
        {$return = $item{conditional_action}}
      | unconditional_action 
        {$return = $item{unconditional_action}}
      | <error>

conditional_action: 'if' predexpr 'then' unconditional_action
        {$return=
         {'cond' => $item{predexpr},
          'blocktype' => $item{unconditional_action}->{'blocktype'} || 'every',
          'actions' => $item{unconditional_action}->{'actions'},
         }
        }

unconditional_action: primrule 
        {$return =
         {'blocktype' => 'every',
          'actions' => [$item{primrule}],
         }
        }
   | actionblock
        {$return = $item{actionblock}}

primrule: rule_label(?) action_name '(' expr(s? /,/) ')' modifier_clause(?)
        {$return =
         {'label' => $item[1][0],
          'action' => 
             {'args' => $item[4],
              'modifiers' => $item[6][0],  # returned as array of array
              'name' => $item{action_name}
             }
         }
        }
     | rule_label(?) emit_block
        {$return = 
	 {'label' => $item[1][0],
          'emit' => $item[2],
         }
	}
     | <error>

rule_label: VAR ':'
        {$return = $item[1]}

modifier_clause: 'with' modifier(s /and/)
        {$return = $item[2]}

modifier: VAR '=' expr
        {$return=
         {'name' => $item{VAR},
          'value' => $item{expr}
         }
        }

action_name: 'alert'
           | 'annotate_search_results'
           | 'float_html'
           | 'float'
           | 'move_after'
           | 'move_to_top'
           | 'notify'
           | 'noop'
           | 'popup'
           | 'redirect'
           | 'replace_html'
           | 'replace_image_src'
           | 'replace'
           | <error>

actionblock: blocktype(?) '{' primrule(s /;/) SEMICOLON(?) '}'
      {$return =
       {'blocktype' => $item[1][0] || 'every',
	'actions' => $item[3]
       }
      }

blocktype: 'choose'
         | 'every'


#
# Predicate expressions
#
predexpr: conjunction '||' predexpr
      {$return=
       {'type' => 'pred',
        'op' => '||',
        'args' => [$item[1], $item[3]]
       }
      }
    | conjunction


conjunction: pred '&&' conjunction
      {$return=
       {'type' => 'pred',
        'op' => '&&',
        'args' => [$item[1], $item[3]]
       }
      }
    | pred


# FIXME: move all pred terms into expression?  
pred: 'not' pred
      {$return =
       {'type' => 'pred',
        'op' => 'negation',
        'args' => [$item[2]]
       }
      }
    | '(' predexpr ')'
      {$return = $item[2]}
    | expr predop expr
      {$return =
       {'type' => 'ineq',
	'op' => $item[2],
	'args' => [$item[1], $item[3]]
       }
      }
    | expr
    | <error>

predop: '<=' | '>=' | '<' | '>' | '==' | '!=' | 'eq' | 'neq' | 'like'




#
# Callbacks
#
callbacks: 'callbacks' '{' success(?) failure(?) '}'
     {$return=
      {'success' => $item[3][0],
       'failure' => $item[4][0]
      }
     }

success: 'success' '{' click(s /;/) '}'
     {$return= $item[3] }
   
failure: 'failure' '{' click(s /;/) '}'
     {$return= $item[3] }
   
click: 'click' VAR '=' STRING
     {$return=
      {'type' => $item[1],
       'attribute' => $item{VAR},
       'value' => $item{STRING},
      }
     }
     | <error>

post_block: post '{' counter_expr SEMICOLON(?) '}' post_alternate(?)
     {$return=
      {'type' => $item[1],
       'cons' => $item[3],
       'alt' => $item[6][0],
      }
     }
  
post: 'fired'
    | 'always'


post_alternate: 'else' '{' counter_expr SEMICOLON(?) '}'
      {$return=$item[3]}

counter_expr: counter_clear
	    | counter_iterate

counter_clear: 'clear' 'counter' '.' VAR 
     {$return=
      {'type' => 'clear',
       'counter' => $item[2],
       'name' => $item[4],
      }
     }

counter_iterate: 'counter' '.' VAR counter_op NUM counter_start(?)
     {$return=
      {'type' => 'iterator',
       'counter' => $item[1],
       'name' => $item[3],
       'op' => $item[4],
       'value' => $item[5],
       'from' => defined $item[6][0] ? $item[6][0] : 1 ,
      }
     }
    

counter_op: '+='
          | '-='
          | <error>

counter_start: 'from' NUM

expr: term term_op expr
      {$return=
       {'type' => 'prim',
        'op' => $item[2],
        'args' => [$item[1], $item[3]]
       }
      }
    | term

term_op: '+'|'-'

term: factor factor_op term
      {$return=
       {'type' => 'prim',
        'op' => $item[2],
        'args' => [$item[1], $item[3]]
       }
      }
    | factor

factor_op: '*'|'/'

factor: NUM
        {$return=Kynetx::Parser::mk_expr_node('num',$item[1])}
      | '-' NUM
        {$return=Kynetx::Parser::mk_expr_node('num',$item[2] * -1)}
      | STRING
        {$return=Kynetx::Parser::mk_expr_node('str',$item[1])}
      | 'true'
        {$return=Kynetx::Parser::mk_expr_node('bool',$item[1])}
      | 'false'
        {$return=Kynetx::Parser::mk_expr_node('bool',$item[1])}
      | simple_pred 
      | qualified_pred
      | counter_pred
      | VAR   # if this isn't after 'true' and 'false' they'll be vars
        {$return=Kynetx::Parser::mk_expr_node('var',$item[1])}
      | '[' expr(s? /,/) ']'
        {$return=Kynetx::Parser::mk_expr_node('array',$item[2])}
      | '(' expr ')'
        {$return=$item[2]}

simple_pred: VAR '(' expr(s? /,/) ')' 
      {$return=
       {'type' => 'simple',
        'predicate' => $item{VAR},
        'args' => $item[3]
       }
      }

qualified_pred: VAR ':' VAR '(' expr(s? /,/) ')'
      {$return=
       {'type' => 'qualified',
        'source' => $item[1],
        'predicate' => $item[3],
        'args' => $item[5]
       }
      }

counter_pred: 'counter' '.' VAR INEQUALITY NUM timeframe(?)
      {$return=
       {'type' => 'counter',
        'name' => $item[3],
        'ineq' => $item[4],
        'value' => $item[5],
        'within' => (ref $item[6][0] eq 'HASH') ? $item[6][0]->{'within'} : undef,
        'timeframe' => (ref $item[6][0] eq 'HASH') ? $item[6][0]->{'period'} : undef,
       }
      }

timeframe: 'within' NUM period
      {$return=
       {'within' => $item[2],
        'period' => $item[3]
       }
      }

period: 'years'
      | 'months'
      | 'weeks'
      | 'days'
      | 'hours'
      | 'minutes'
      | 'seconds'
      | <error>



_EOGRAMMAR_

sub html {
    my ($value) = @_;
    $value =~ s/^<<\s*//;
    $value =~ s/>>\s*$//;
    $value =~ s/[\n\r]/  /sg;
    return $value;
}  

sub string {
    my ($value) = @_;
    $value =~ s/^["']//;
    $value =~ s/["']$//;
    return $value;
}  


my $parser = Parse::RecDescent->new($grammar);

# this removes KRL-style comments taking into account quotes
my $comment_re = qr%
       /\*         ##  Start of /* ... */ comment
       [^*]*\*+    ##  Non-* followed by 1-or-more *'s
       (
         [^/*][^*]*\*+
       )*          ##  0-or-more things which don't start with /
                   ##    but do end with '*'
       /           ##  End of /* ... */ comment
     |
        //[^\n]*    ## slash style comments
     |         ##     OR  various things which aren't comments:

       (
         "           ##  Start of " ... " string
         (
           \\.           ##  Escaped char
         |               ##    OR
           [^"\\]        ##  Non "\
         )*
         "           ##  End of " ... " string

     |         ##     OR
        .           ##  Anything other char
         [^/"'\\]*   ##  Chars which doesn't start a comment, string or escape
       )
     %xs;

sub remove_comments {

    my($ruleset) = @_;

    $ruleset =~ s%$comment_re%defined $2 ? $2 : ""%gxse;
    return $ruleset;

}

sub parse_ruleset {
    my ($ruleset) = @_;
    
    my $logger = get_logger();

    $ruleset = remove_comments($ruleset);


#    print $ruleset; exit;

    # remove newlines
#    $ruleset =~ s%\n%%g;


    my $result = ($parser->ruleset($ruleset));
    if (defined $result->{'error'}) {
	$logger->error("Can't parse ruleset: $result->{'error'}");
    } else {
	$logger->debug("Parsed rules");
    }

    return $result;

#    print Dumper($result);


}

# Helper function used in testing  
sub parse_expr {
    my ($expr) = @_;
    
    my $logger = get_logger();

    $expr = remove_comments($expr);

    # remove newlines
    $expr =~ s%\n%%g;


    my $result = ($parser->expr($expr));
    if (defined $result->{'error'}) {
	$logger->error("Can't parse expression: $result->{'error'}");
    } else {
	$logger->debug("Parsed expression");
    }

    return $result;

#    print Dumper($result);


}

# Helper function used in testing  
sub parse_decl {
    my ($expr) = @_;
    
    my $logger = get_logger();

    $expr = remove_comments($expr);

    # remove newlines
    $expr =~ s%\n%%g;

    my $result = ($parser->decl($expr));
    if (defined $result->{'error'}) {
	$logger->error("Can't parse expression: $result->{'error'}");
    } else {
	$logger->debug("Parsed expression");
    }

    return $result;

#    print Dumper($result);


}

# Helper function used in testing  
sub parse_predexpr {
    my ($expr) = @_;
    
    my $logger = get_logger();

    $expr = remove_comments($expr);

    # remove newlines
    $expr =~ s%\n%%g;

    my $result = ($parser->predexpr($expr));
    if (defined $result->{'error'}) {
	$logger->error("Can't parse expression: $result->{'error'}");
    } else {
	$logger->debug("Parsed expression");
    }

    return $result;

#    print Dumper($result);


}


sub parse_rule {
    my ($rule) = @_;
    
    my $logger = get_logger();

    $rule = remove_comments($rule);


#    print $rule; exit;

    # remove newlines
    $rule =~ s%\n%%g;


    my $result = ($parser->rule_top($rule));

    if (ref $result eq 'HASH' && $result->{'error'}) {
	$logger->debug("Can't parse rule: $result->{'error'}");
    } else {
	$logger->debug("Parsed rules");
    }

    return $result;

#    print Dumper($result);


}


sub parse_action {
    my $rule = shift;
    
    my $logger = get_logger();

    $rule = remove_comments($rule);

    # remove newlines
    $rule =~ s%\n%%g;

    my $result = $parser->action($rule);
    if (defined $result->{'error'}) {
	$logger->error("Can't parse actions: $result->{'error'}");
    } else {
	$logger->debug("Parsed rules");
    }

    return $result;

}

sub parse_global_decls {
    my $element = shift;
    
    my $logger = get_logger();

    $element = remove_comments($element);

    my $result = $parser->global_decls_top($element);

#    $logger->debug(Dumper($result));
    if (ref $result eq 'HASH' && $result->{'error'}) {
	$logger->debug("Can't parse global declarations: $result->{'error'}");
    } else {
	$logger->debug("Parsed global decls");#, 
    }
    

    return $result;

}

sub parse_dispatch {
    my $element = shift;
    
    my $logger = get_logger();

    $element = remove_comments($element);

    my $result = $parser->dispatch_block_top($element);

    if (ref $result eq 'HASH' && $result->{'error'}) {
	$logger->debug("Can't parse dispatch declaration: $result->{'error'}");
    } else {
	$logger->debug("Parsed dispatch declaration");
    }

    return $result;

}


sub parse_meta {
    my $element = shift;
    
    my $logger = get_logger();

    $element = remove_comments($element);

    my $result = $parser->meta_block_top($element);
    
    if (ref $result eq 'HASH' && $result->{'error'}) {
	$logger->debug("Can't parse meta information: $result->{'error'}");
    } else {
	$logger->debug("Parsed meta information");
    }


    return $result;

}


sub mk_expr_node {
    my($type, $val) = @_;
    return {'type' => $type,
	    'val' => $val};
}


1;
