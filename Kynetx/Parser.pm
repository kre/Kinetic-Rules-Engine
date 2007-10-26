package Kynetx::Parser;
# file: Kynetx/Parser.pm

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ qw(parse_ruleset) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use HOP::Stream qw/:all/;
use HOP::Lexer 'make_lexer';
use HOP::Parser qw/:all/;

my @keywords = (
    'ruleset',
    'rule',
    'is',
    'select using',
    'setting',
    'pre',
    'decls',
    'if',
    'then',
    'float',
    'replace',
    'redirect',
    'alert',
    'popup',
    'with',
    'and'
    );
  
my @input_tokens = (
     [ 'STRING', qr/"[^"]*"/, \&string],
     [ 'COMMENT', qr%//.*%, sub { () } ],
     [ 'KEYWORD', qr/(?i:@{[join '|', map {$_} @keywords]})/ ],
     [ 'BOOL', qr/true|false/ ],
     [ 'VAR',   qr/[[:alpha:]][[:alpha:][:digit:]_]+/    ],
     [ 'NUM',   qr/\d+/             ],
     [ 'COMMA', qr/,/ ],
     [ 'OP',    qr{[+-/*]}            ],
     [ 'SPACE', qr/\s*/, sub { () } ],
     [ 'LBRACE', qr/{/ ],
     [ 'RBRACE', qr/}/ ],
     [ 'LPAREN', qr/\(/ ],
     [ 'RPAREN', qr/\)/ ],
     [ 'EQUALS', qr/=/ ],
     [ 'COLON', qr/:/ ],
     [ 'SEMICOLON', qr/;/ ],
     [ 'LOGICAL_AND', qr/&&/ ],
);

sub string {
    my ($label, $value) = @_;
    $value =~ s/^["']//;
    $value =~ s/["']$//;
    return [$label, $value ];
}  

# now to parse it

my ($ruleset, $rule, $select, $vars, $pre_block, $decls, $decl, $args,
    $cond, $preds, $pred, $primrule, $modifiers, $modifier, 
    $action, $expr, $term, $factor, $entire_input);



# eta conversion
my $Ruleset = parser { $ruleset->(@_) };
my $Rule = parser { $rule ->(@_) }; 
my $Select = parser { $select->(@_) };
my $Vars = parser { $vars->(@_) };
my $Pre_block = parser { $pre_block->(@_) };
my $Decls = parser { $decls->(@_) };
my $Decl = parser { $decl->(@_) };
my $Args = parser { $args->(@_) };
my $Cond = parser { $cond->(@_) };
my $Preds = parser { $preds->(@_) };
my $Pred = parser { $pred->(@_) };
my $Primrule = parser { $primrule->(@_) };
my $Modifiers = parser { $modifiers->(@_) };
my $Modifier = parser { $modifier->(@_) };
my $Action = parser { $action->(@_) };
my $Expr = parser { $expr->(@_) };
my $Term = parser { $term->(@_) };
my $Factor = parser { $factor->(@_) };



# <ruleset> ::= ruleset { <var> | <num> } LBRACE { <rule> }* RBRACE EOI

$entire_input = concatenate($Ruleset, 
			    \&End_of_Input);
			    
$ruleset = T(concatenate(lookfor(['KEYWORD', 'ruleset']), 
			 alternate(lookfor('VAR'),
				   lookfor('NUM')),
			 lookfor('LBRACE'),
			 star($Rule),
			 lookfor('RBRACE')),
	     sub { my %m;
		   $m{ $_[1]  } = $_[3]; 
	           return \%m;
	     }
    );

# <rule> ::= rule <var> is <var> LBRACE 
#            <select> <pre_block> { <cond> | <primrule> } 
#            RBRACE

$rule = T(concatenate(lookfor(['KEYWORD', 'rule']),
		       lookfor('VAR'),
		       lookfor(['KEYWORD', 'is']),
		       lookfor('VAR'),
		       lookfor('LBRACE'),
		       $Select,
		       $Pre_block,
		       alternate($Cond,
				 $Primrule),
		       lookfor('RBRACE')),
	  sub { my $x =  { 'name' => $_[1],
			   'state' => $_[3],
			   'pagetype' => $_[5],
			   'pre' => $_[6] };
		foreach my $k (keys %{ $_[7] } ) {
		    $x->{$k} = $_[7]->{$k};
		}
		return $x;

	      });
		       

# <select> ::= select using <string> setting LPAREN <vars> RPAREN ;

$select = T(concatenate(lookfor(['KEYWORD', 'select using']),
			lookfor('STRING'),
			lookfor(['KEYWORD','setting']),
			lookfor('LPAREN'),
			$Vars,
			lookfor('RPAREN')),
	    sub { { 'pattern' => qr!$_[1]!,
		    'vars' => defined $_[4][0] ? $_[4][0] : []} } 
    );

# <vars> ::= <var> 
#          | { <var> , <vars> }
$vars = star(list_values_of( lookfor('VAR'),
			     match('COMMA')));


# <pre_block> ::= pre LBRACE { <decl> }* RRBRACE
$pre_block = T(concatenate(lookfor(['KEYWORD','pre']),
			   lookfor('LBRACE'),
			   star($Decl),
			   lookfor('RBRACE')),
	       sub {  $_[2] });



# <decl> ::= <var> = <var> : <var> LPAREN <args> RPAREN SEMICOLON
$decl = T(concatenate(lookfor('VAR'),
		      lookfor('EQUALS'),
		      lookfor('VAR'),
		      lookfor('COLON'),
		      lookfor('VAR'),
		      lookfor('LPAREN'),
		      $Args,
		      lookfor('RPAREN'),
		      lookfor('SEMICOLON')),
	  sub { {'name' => $_[0],
	         'source' => $_[2],
		 'function' => $_[4],
		 'args' => defined $_[6][0] ? $_[6][0] : [] }
	      });

# <args> ::= <expr> 
#          | { <expr> , <args> }
$args = star(list_values_of($Expr, match('COMMA')));
	


# <cond> ::= if <preds> then <primrule>
$cond = T(concatenate(lookfor(['KEYWORD', 'if']),
		      $Preds,
		      lookfor(['KEYWORD', 'then']),
		      lookfor('LBRACE'),
		      star(list_values_of($Primrule,match('SEMICOLON'))),
		      absorb(optional(match('SEMICOLON'))),
	              lookfor('RBRACE')),
	  sub { my $x = {'cond' => defined $_[1][0] ? $_[1][0] : []};
		foreach my $k (keys %{$_[4][0][0]} ) {
		    $x->{$k} = $_[4][0][0]->{$k};
		}
		return $x}
    );
		      

# <preds> ::= <pred> 
#           | { <pred> && <preds> }
$preds = star( list_values_of( $Pred, match('LOGICAL_AND')));


# <pred> ::= <var> LPAREN <args> RPAREN
$pred = T(concatenate(lookfor('VAR'),
		      lookfor('LPAREN'),
		      $Args,
		      lookfor('RPAREN')),
	  sub { {'predicate' => $_[0],
		 'args' => $_[2]} } 
    );

# <primrule> ::= <action> LPAREN <args> RPAREN with <modifiers>
$primrule = T(concatenate($Action,
			  lookfor('LPAREN'),
			  $Args,
			  lookfor('RPAREN'),
			  optional(T(concatenate(lookfor(['KEYWORD','with']),
						 $Modifiers),
				     sub {
					 my @x;
					 foreach my $m ( @{ $_[1] }) {
					     push @x, 
						 {'name' => $m->[0],
						  'value' => $m->[1]}
					 }
					 [\@x];
				     }))),
	      sub { {'action' => {'name' => $_[0],
				  'args' => empty_not_undef($_[2]),
				  'modifiers' => empty_not_undef($_[4])}}
	      });

# <modifiers> ::= <modifier> 
#               | { <modifier> and <modifiers> }
$modifiers = list_values_of( $Modifier, match('KEYWORD','and'));

# <modifier> ::= <var> = <expr>
$modifier = T(concatenate(lookfor('VAR'),
			  lookfor('EQUALS'),
			  $Expr),
	      sub{[$_[0], $_[2] ] });

# <action> ::= float
#            | replace
#            | popup
#            | alert
#            | redirect
$action = alternate(lookfor(['KEYWORD','float']),
		    lookfor(['KEYWORD','replace']),
		    lookfor(['KEYWORD','popup']),
		    lookfor(['KEYWORD','alert']),
		    lookfor(['KEYWORD','redirect']));
		    

# <expr> ::= <term> {{ + <term> } | { - <term>}}*
$expr = alternate(T(concatenate($Term,
				       lookfor(['OP','+']),
				       $Expr),
			  sub{ {'prim' => {'op' => $_[1],
					   'args' => [$_[0], $_[2]]}}
			       } ),
			$Term);
                        

# <term> ::= <factor> {{ * <factor> } | { / <factor>}}*
$term = alternate(T(concatenate($Factor,
				lookfor(['OP','*']),
				$Term),
			  sub{ {'prim' => {'op' => $_[2],
					   'args' => [$_[0], $_[2]]}}
			       } ),
			$Factor);
				

# <factor> ::= <var>
#            | <num>
#            | <string>
#            | LPAREN <expr> RPAREN
$factor = alternate(T(lookfor('VAR'),
		      sub { {'var' => $_[0] }} ),
		    T(lookfor('NUM'),
		      sub { {'num' => $_[0] }} ),
		    T(lookfor('BOOL'),
		      sub { {'bool' => $_[0] }} ),
		    T(lookfor('STRING'),
		      sub { {'str' => $_[0] }} ),
		    T(concatenate(
			  lookfor('LPAREN'),
			  $Expr,
			  lookfor('LPAREN')),
		      sub { $_[1] } ));
		    

#my $tree = ruleset_to_stream(getkrl());

#$Data::Dumper::Indent = 1;

#if ($tree) {
#    print Dumper($tree), "\n";
#    print "\n\n";
#} else {
#    warn "Parse error.\n";
#}




sub parse_ruleset {
    my @input = @_;
    my $input = sub {shift @input};
    
    my $lexer = iterator_to_stream(
	make_lexer($input,@input_tokens));

#    while(my $t = drop($lexer)) {
#	print "$t->[0], $t->[1]\n";
#    }

    my ($result) = $entire_input->($lexer);

    return $result->[0];
}



sub empty_not_undef {
    my $v = shift;
    if (defined $v->[0]) {
	return $v->[0];
    } else {
	return [];
    }
}



1;
