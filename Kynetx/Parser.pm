package Kynetx::Parser;
# file: Kynetx/Parser.pm

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ qw(parse_ruleset dump_lex) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use HOP::Stream qw/:all/;
use HOP::Lexer 'make_lexer';
use HOP::Parser qw/:all/;

use Log::Log4perl qw(get_logger :levels);


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
    'float_html',
    'replace',
    'replace_html',
    'redirect',
    'alert',
    'popup',
    'with',
    'and',
    'not',
    'fired',
    'callbacks',
    'success',
    'failure',
    'else',
    'always',
    'counter',
    'clear',
    'from',
    'within',
    'days',
    'log',
    'click',
    'choose',
    'every',
    );

# only on word boundaries
my $kw = join '|', map {"\\b".$_."\\b"} @keywords;

my @input_tokens = (
     [ 'HTML', qr/<<.*?>>/s, \&html  ],
     [ 'STRING', qr/"[^"]*"/, \&string],
     [ 'COMMENT', qr%//.*%, sub { () } ],
     [ 'KEYWORD', qr/(?i:$kw)/ ],
     [ 'BOOL', qr/true|false/ ],
     [ 'VAR',   qr/[_A-Za-z]\w*/    ],
     [ 'NUM',   qr/\d+/             ],
     [ 'COMMA', qr/,/ ],
     [ 'INCR', qr/\+=/ ],
     [ 'DECR', qr/-=/ ],
     [ 'DOT', qr/\./ ],
     [ 'OP',    qr{[+-/*]}            ],
     [ 'SPACE', qr/\s*/, sub { () } ],
     [ 'LBRACE', qr/{/ ],
     [ 'RBRACE', qr/}/ ],
     [ 'LBRACKET', qr/\[/ ],
     [ 'RBRACKET', qr/\]/ ],
     [ 'LPAREN', qr/\(/ ],
     [ 'RPAREN', qr/\)/ ],
     [ 'EQUALS', qr/=/ ],
     [ 'INEQUALITY', qr/[<>]/ ],
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

# FIXME: should we be removing newlines or quoting them?  
sub html {
    my ($label, $value) = @_;
    $value =~ s/^<<\s*//;
    $value =~ s/>>\s*$//;
    $value =~ s/[\n\r]/  /sg;
    return [$label, $value ];
}  

# now to parse it

my ($ruleset, $rule, $select, $vars, $pre_block, 
    $decls, $decl, $args, $actions, $actionblock,
    $cond, $preds, $pred, $primrule, $modifiers, $modifier, 
    $action, $expr, $term, $factor, $entire_input,
    $simple_pred, $counter_pred, $post_block, $clear, $iterator,
    $counter_expr, $callbacks, $click, $succeed, $fail
);



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
my $Simple_pred = parser { $simple_pred->(@_) };
my $Counter_pred = parser { $counter_pred->(@_) };
my $Primrule = parser { $primrule->(@_) };
my $Modifiers = parser { $modifiers->(@_) };
my $Modifier = parser { $modifier->(@_) };
my $Action = parser { $action->(@_) };
my $Actions = parser { $actions->(@_) };
my $Actionblock = parser { $actionblock->(@_) };
my $Counter_expr = parser { $counter_expr->(@_) };
my $Expr = parser { $expr->(@_) };
my $Term = parser { $term->(@_) };
my $Factor = parser { $factor->(@_) };
my $Post_block = parser { $post_block->(@_) };
my $Clear = parser { $clear->(@_) };
my $Iterator = parser { $iterator->(@_) };
my $Callbacks = parser { $callbacks->(@_) };
my $Click = parser { $click->(@_) };
my $Succeed = parser { $succeed->(@_) };
my $Fail = parser { $fail->(@_) };




# <ruleset> ::= ruleset { <var> | <num> } LBRACE { <rule> }* RBRACE EOI

$entire_input = concatenate($Ruleset, 
				  \&End_of_Input);
			    
$ruleset = 
	T(
	    error(
		concatenate(lookfor(['KEYWORD', 'ruleset']), 
			    alternate(lookfor('VAR'),
				      lookfor('NUM')),
			    lookfor('LBRACE'),
			    star($Rule),
			    lookfor('RBRACE'))),
	     sub { my %m;
		   $m{ $_[1]  } = $_[3]; 
	           return \%m;
	     }
    );

# <rule> ::= rule <var> is <var> LBRACE 
#            <select> <pre_block> {html_block}* { <cond> | <actions> } 
#            { <succeed> }[0/1]
#            { <fail> }[0/1]
#            { <post_block> }[0/1]
#            RBRACE

$rule = T(concatenate(absorb(lookfor(['KEYWORD', 'rule'])),
		       lookfor('VAR'),
		       absorb(lookfor(['KEYWORD', 'is'])),
		       lookfor('VAR'),
		       absorb(lookfor('LBRACE')),
		       error($Select),
		       error($Pre_block),
		       alternate($Cond,
				 $Actions),
		       optionalx($Callbacks),
		       optionalx($Post_block),
		       lookfor('RBRACE')),
	  sub { 
	      my($name,$state,$pagetype,$pre,$prim,$callback,$post) = @_; 
	      my $x =  { 'name' => $name,
			 'state' => $state,
			 'pagetype' => $pagetype,
			 'pre' => $pre->[0],
	      };

	      $x->{'actions'} = $prim->{'actions'} ||  [$prim];
	      $x->{'blocktype'} =  $prim->{'blocktype'} || 'every';
	      $x->{'cond'} =  $prim->{'cond'};

		
#	      foreach my $k (keys %{ $prim } ) {
#		  $x->{$k} = $prim->{$k};
#	      }
	      # optionals
	      if(ref $callback eq 'HASH') {
		  $x->{'callbacks'} = $callback;
	      }
	      if(ref $post eq 'HASH') {
		  $x->{'post'} = $post;
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
	    sub { { 'pattern' => $_[1],
		    'vars' => defined $_[4][0] ? $_[4][0] : []} } 
    );

# <vars> ::= <var> 
#          | { <var> , <vars> }
$vars = star(list_values_of( lookfor('VAR'),
			     match('COMMA')));


# <pre_block> ::= pre LBRACE { <decl> }* RRBRACE
$pre_block = T(concatenate(lookfor(['KEYWORD','pre']),
			   lookfor('LBRACE'),
			   star(list_values_of($Decl, match('SEMICOLON'))),
			   optional(absorb(match('SEMICOLON'))),
			   lookfor('RBRACE')),
	       sub {  $_[2] });


# <decl> ::= <var> = <var> : <var> LPAREN <args> RPAREN SEMICOLON
#          | <var> = counter DOT <var> SEMICOLON
#          | <var> = HTML
$decl = alternate(
         T(concatenate(lookfor('VAR'),
		      lookfor('EQUALS'),
		      lookfor('VAR'),
		      lookfor('COLON'),
		      lookfor('VAR'),
		      lookfor('LPAREN'),
		      $Args,
		      lookfor('RPAREN')),
	  sub { {'lhs' => $_[0],
		 'type' => 'data_source',
	         'source' => $_[2],
		 'function' => $_[4],
		 'args' => defined $_[6][0] ? $_[6][0] : [] }
	      }),
          T(concatenate(lookfor('VAR'),
		      absorb(lookfor('EQUALS')),
		      lookfor('KEYWORD'),
		      absorb(lookfor('DOT')),
		      lookfor('VAR')),
	    sub {my ($lhs, $type, $name) = @_;
		 {'lhs' => $lhs,
		  'type' => $type,
		  'name' => $name } }),
          T(concatenate(lookfor('VAR'),
		      absorb(lookfor('EQUALS')),
		      lookfor('HTML')),
	    sub {
		my ($lhs, $value) = @_;
		{'type' => 'here_doc',
		 'lhs' => $lhs,
		 'value' => $value } })
    );


# <args> ::= <expr> 
#          | { <expr> , <args> }
$args = star(list_values_of($Expr, match('COMMA')));
	

# <actions> ::= <primrule>
#             | <actionblock>
$actions = alternate($Primrule, $Actionblock);


# <actionblock> ::= (choose | every)* LBRACE {<primrule>}*; RBRACE
$actionblock = 
    T(concatenate(optional(alternate(lookfor(['KEYWORD', 'choose']),
			             lookfor(['KEYWORD', 'every']))),
	          absorb(lookfor('LBRACE')),
		  star(list_values_of($Primrule,match('SEMICOLON'))),
		  absorb(optional(match('SEMICOLON'))),
		  absorb(lookfor('RBRACE'))),
      sub { my($blocktype, $actions) = @_;
	    { 'blocktype' => $blocktype->[0],
	      'actions' =>  singleton($actions)
	    }
      }
    );

# take a list of singletons and remove the nesting
sub singleton {
    my $arr = shift;
    my @a;
    foreach my $s (@{$arr}) {
	push @a, $s->[0];
    }
    return \@a;
}


# <cond> ::= if <preds> then <primrule> | <actionblock>
$cond = T(concatenate(absorb(lookfor(['KEYWORD', 'if'])),
		      $Preds,
		      absorb(lookfor(['KEYWORD', 'then'])),
		      $Actions),
	  sub { my($preds, $ab) = @_;
	      my $x = {'cond' => defined $preds->[0] ? $preds->[0] : []};
		# always return an array of actions
		$x->{'actions'} = $ab->{'actions'} ||  [$ab];
		$x->{'blocktype'} =  $ab->{'blocktype'} || 'every';
		return $x}
    );


#		foreach my $k (keys %{$_[1][0][0]} ) {
#		    $x->{$k} = $_[1][0][0]->{$k};
#		}


		      

# <preds> ::= <pred> 
#           | { <pred> && <preds> }
$preds = star( list_values_of( $Pred, match('LOGICAL_AND')));

# <pred> ::= <simple_pred> | <counter_pred>
$pred = alternate($Simple_pred, $Counter_pred);


# <simple_pred> ::= <var> LPAREN <args> RPAREN
$simple_pred = T(concatenate(lookfor('VAR'),
			     lookfor('LPAREN'),
			     $Args,
			     lookfor('RPAREN')),
		 sub { {'predicate' => $_[0],
			'type' => 'simple',
			'args' => empty_not_undef($_[2])} } 
    );

# <counter_pred> ::= counter DOT <var> INEQUALITY <num>
#                       { within <num> <timeframe> } 
# <timeframe> ::= days
$counter_pred = T(concatenate(
		      lookfor(['KEYWORD','counter']),
		      lookfor('DOT'),
		      lookfor('VAR'),
		      lookfor('INEQUALITY'),
		      lookfor('NUM'),
		      optionalx(concatenate(
				     lookfor(['KEYWORD','within']),
				     lookfor('NUM'),
				     lookfor(['KEYWORD','days'])))

		  ),
		  sub { {'name' => $_[2],
			 'type' => $_[0],
			 'ineq' => $_[3],
			 'value' => $_[4],
			 'within' => $_[5][1],
			 'timeframe' => $_[5][2] } });



# <primrule> ::= <action> LPAREN <args> RPAREN with <modifiers>
$primrule = T(concatenate(optional(concatenate(lookfor('VAR'),
					       absorb(match('COLON')))),
		          $Action,
			  absorb(lookfor('LPAREN')),
			  $Args,
			  absorb(lookfor('RPAREN')),
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
				     })),
			  absorb(optional(match('SEMICOLON')))
	      ),
	      sub {my($label,$name,$args,$modifiers) = @_;
		   return {'label'=> $label->[0] || undef,
			   'action' => 
			      {'args' => empty_not_undef($args),
			       'modifiers' => empty_not_undef($modifiers),
			       'name' => $name
			      }}
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
		    lookfor(['KEYWORD','float_html']),
		    lookfor(['KEYWORD','replace']),
		    lookfor(['KEYWORD','replace_html']),
		    lookfor(['KEYWORD','popup']),
		    lookfor(['KEYWORD','alert']),
		    lookfor(['KEYWORD','redirect']),
    );
		    

# <callbacks> ::= callbacks LBRACE { <succeed> }[0/1] { <fail> }[0/1] RBRACE
$callbacks = T(concatenate(
		 lookfor(['KEYWORD','callbacks']),
		 absorb(lookfor('LBRACE')),
		 optionalx($Succeed),
		 optionalx($Fail),
		 absorb(lookfor('RBRACE'))),
	       sub { { 'success' => $_[1],
		       'failure' => $_[2]
		     } }
    );



# <succeed> ::= succeeds LBRACE {<click>}+ RBRACE
$succeed = T(concatenate(
		 lookfor(['KEYWORD','success']),
		 absorb(lookfor('LBRACE')),
		 list_values_of( $Click, match('SEMICOLON')),
		 absorb(lookfor('RBRACE'))
	     ),
	     sub {  $_[1] } 
         );
		 
# <fail> ::= fails LBRACE {<click>}+ RBRACE
$fail = T(concatenate(
		 lookfor(['KEYWORD','failure']),
		 absorb(lookfor('LBRACE')),
		 list_values_of( $Click, match('SEMICOLON')),
		 absorb(lookfor('RBRACE'))
	     ),
	     sub {  $_[1] } 
         );
	 


# <post-block> ::= {fired|always} LBRACE <counter_expr> RBRACE
#                    { else LBRACE <counter_expr> RBRACE }
$post_block = T(
		concatenate(
		    alternate(lookfor(['KEYWORD','fired']),
			      lookfor(['KEYWORD','always'])),
		    absorb(lookfor('LBRACE')),
		    error($Counter_expr),
		    absorb(lookfor('RBRACE')),
		    optionalx(concatenate(
				  absorb(lookfor(['KEYWORD','else'])),
				  absorb(lookfor('LBRACE')),
				  error($Counter_expr),
				  absorb(lookfor('RBRACE'))))
			 ),
		sub{ { 'type' => $_[0],
		       'cons' => $_[1],
		       'alt' => $_[2][0]
		    } });





# <counter_expr> ::= <clear> 
#                  | <iterator>
$counter_expr = alternate($Clear, $Iterator);

# <clear> ::= clear counter DOT <var> SEMICOLON
$clear = T(concatenate(lookfor(['KEYWORD','clear']),
		       lookfor(['KEYWORD','counter']),
		       absorb(lookfor('DOT')),
		       lookfor('VAR'),
		       lookfor('SEMICOLON')),
	   sub { {'type' => $_[0],
		  'counter' => $_[1],
		  'name' => $_[2] } });

# <iterator> ::= counter DOT <var> { INCR | DECR } <num> {from <num>} SEMICOLON
$iterator = T(concatenate(lookfor(['KEYWORD','counter']),
			  absorb(lookfor('DOT')),
			  lookfor('VAR'),
			  alternate(lookfor('INCR'),
				    lookfor('DECR')),
			  lookfor('NUM'),
			  optionalx(concatenate(
					absorb(lookfor(['KEYWORD','from'])),
					lookfor('NUM'))),
			  lookfor('SEMICOLON')),
	      sub{ { 'type' => 'iterator',
		     'counter' => $_[0],
		     'name' => $_[1],
		     'op' => $_[2],
		     'value' => $_[3],
		     'from' => $_[4][0] } });


# <click> ::= click <var> = <var> 
$click = T(concatenate(
	       lookfor(['KEYWORD','click']),
	       lookfor('VAR'),
	       absorb(lookfor('EQUALS')),
	       lookfor('STRING')
	   ),
	   sub { { 'type' => $_[0],
		   'attribute' => $_[1],
		   'value' => $_[2] }
	   });


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
			  absorb(lookfor('LBRACKET')),
			  list_values_of( $Expr, match('COMMA')),
			  absorb(lookfor('RBRACKET'))),
		      sub { {'array' => $_[0] } } ),
		    T(concatenate(
			  lookfor('LPAREN'),
			  $Expr,
			  lookfor('RPAREN')),
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

    my $logger = get_logger();


    my ($result) = eval {$entire_input->($lexer)};
    if ($@) {
	my $msg = $@;
	$logger->error("Can't parse rules: $msg");
	return {'error' => $msg};
    } else {
	$logger->debug("Parsed rules");
	return $result->[0];
    }

}



sub dump_lex {
    my @input = @_;
    my $input = sub {shift @input};
    
    my $lexer = iterator_to_stream(
	make_lexer($input,@input_tokens));

    while(my $t = drop($lexer)) {
	print "$t->[0], $t->[1]\n";
    }

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
