package HOP::Parser;

use warnings;
use strict;

use base 'Exporter';
use HOP::Stream qw/drop tail head/;

my $verbose = 0;

our %N;

our @EXPORT_OK = qw(
  absorb
  action
  alternate
  concatenate
  debug
  fetch_error
  End_of_Input
  error
  list_of
  list_values_of
  lookfor
  match
  nothing
  null_list
  operator
  optional
  optionalx 
  parser
  rlist_of
  rlist_values_of
  star
  T
  test
);

our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

sub parser (&);    # Forward declaration - see below

=head1 NAME

HOP::Parser - "Higher Order Perl" Parser

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use HOP::Parser qw/:all/;
  
  # assemble a bunch of parsers according to a grammar

=head1 DESCRIPTION

This package is based on the Parser.pm code from the book "Higher Order Perl",
by Mark Jason Dominus.

This module implements recursive-descent parsers by allowing programmers to
build a bunch of smaller parsers to represent grammar elements and assemble
them into a full parser. Pages 376 to 415 of the first edition of HOP should
be enough to get you up to speed :)

Please note that this module should be considered B<ALPHA> code.  While
everything works fairly well, the documentation is incomplete and some of the
functions could stand to be better named (C<rlist_of>, for example).

=head1 EXPORT

=over 4

=item * absorb

=item * action

=item * alternate

=item * concatenate

=item * debug

=item * fetch_error

=item * End_of_Input

=item * error

=item * list_of

=item * list_values_of

=item * lookfor

=item * match

=item * nothing

=item * null_list

=item * operator

=item * optional

=item * parser

=item * rlist_of

=item * rlist_values_of

=item * star

=item * T

=item * test

=back

=head1 FUNCTIONS

=head2 nothing

  my ($parsed, $remainder) = nothing($stream);

C<nothing> is a special purpose parser which is used internally.  It always
succeeds and returns I<undef> for C<$parsed> and the C<$remainder> is the
unaltered input C<$stream>.

=cut

sub nothing {
    my $input = shift;
    return ( undef, $input );
}

##############################################################################

=head2 End_of_Input

  if (End_of_Input($stream)) {
    ...
  }

C<End_of_Input> is another special purpose parser which only succeeds if there
is no input left in the stream.  It's generally used in the I<start symbol> of
the grammar.

  # entire_input ::= statements 'End_Of_Input'

  my $entire_input = concatenate(
    $statements,
    \&End_of_Input
  );


=cut

sub End_of_Input {
    my $input = shift;

    print "Found end of input\n" if $verbose;

    return ( undef, undef ) unless defined($input);
    die [ "End of input", $input ];
}

##############################################################################

=head2 lookfor

  my $parser = lookfor($label, [\&get_value], [$param]); # or
  my $parser = lookfor(\@label_and_optional_values, [\&get_value], [$param]);
  my ($parsed, $remaining_stream) = $parser->($stream);

The following details the arguments to C<lookfor>.

=over 4

=item * C<$label> or C<@label_and_optional_values>

The first argument is either a scalar with the token label or an array
reference. The first element in the array reference should be the token label
and subsequent elements can be anything you need. Usually the second element
is the token value, but if you need more than this, that's OK.

=item * C<\&get_value>

If an optional C<get_value> subroutine is supplied, that C<get_value> will be
applied to the parsed value prior to it being returned. This is useful if
non-standard tokens are being passed in or if we wish to preprocess the
returned values.

=item * C<$param>

If needed, additional arguments besides the current matched token can be
passed to C<&get_value>. Supply them as the third argument (which can be any
data structure you wish, so long as it's a single scalar value).

=back

In practice, the full power of this function is rarely needed and C<match> is
used instead.

=cut

sub lookfor {
    my $wanted = shift;
    my $value  = shift || sub { $_[0][1] };
    my $param  = shift;

    $wanted = [$wanted] unless ref $wanted;

    my $sec = $wanted->[1] || "";




    my $parser = parser {
        my $input = shift;
        unless ( defined $input ) {
            die [ 'TOKEN', $input, $wanted ];
        }


	debug("Looking for $wanted->[0] => $sec");


        my $next = head($input);
        for my $i ( 0 .. $#$wanted ) {
            next unless defined $wanted->[$i];
            no warnings 'uninitialized';
            unless ($wanted->[$i] eq $next->[$i]) {
		debug("But found " . $next->[$i]);
                die [ 'TOKEN', $input, $wanted ];
            }
        }
        my $wanted_value = $value->( $next, $param );

        # the following is unlikely to affect a stream with a promise
        # for a tail as the promise tends to Do The Right Thing.
        #
        # Otherwise, the AoA stream might just return an aref for
        # the tail instead of an AoA.  This breaks things
        my $tail = tail($input);
        if ( 'ARRAY' eq ref $tail && 'ARRAY' ne ref $tail->[0] ) {
            $tail = [$tail];
        }

	debug("Found $wanted_value");

        return ( $wanted_value, $tail );
    };
    $N{$parser} = "[@$wanted]";
    return $parser;
}

##############################################################################

=head2 match

  my $parser = match($label, [$value]);
  my ($parsed, $remainder) = $parser->($stream);

This function takes a label and an optional value and builds a parser which
matches them by dispatching to C<lookfor> with the arguments as an array
reference. See C<lookfor> for more information.

=cut

sub match { @_ = [@_]; goto &lookfor }

##############################################################################

=head2 parser

  my $parser = parser { 'some code' };

Currently, this is merely syntactic sugar that allows us to declare a naked
block as a subroutine (i.e., omit the "sub" keyword).

=cut

sub parser (&) { $_[0] }

##############################################################################

=head2 concatenate

  my $parser = concatenate(@parsers);
  ok ($values, $remainder) = $parser->($stream);

This function takes a list of parsers and returns a new parser. The new parser
succeeds if all parsers passed to C<concatenate> succeed sequentially.

C<concatenate> will discard undefined values.  This allows us to do this and
only return the desired value(s):

  concatenate(absorb($lparen), $value, absorb($rparen))

=cut

sub concatenate {
    shift unless ref $_[0];
    my @parsers = @_;


    return \&nothing   if @parsers == 0;
    return $parsers[0] if @parsers == 1;


    my $parser = parser {

        my $input = shift;
        my ( $v, @values );
        for (@parsers) {
            ( $v, $input ) = $_->($input);

            push @values, $v if defined $v;   # assumes we wish to discard undef
        }
        return ( \@values, $input );
    };
    return $parser;
}

##############################################################################

=head2 alternate

  my $parser = alternate(@parsers);
  my ($parsed, $remainder) = $parser->stream;

This function behaves like C<concatenate> but matches one of any tokens
(rather than all tokens sequentially).

=cut

sub alternate {
    my @parsers = @_;
    return parser { return () }
      if @parsers == 0;
    return $parsers[0] if @parsers == 1;

    my $parser = parser {
        my $input = shift;
        my @failures;

        for (@parsers) {
            my ( $v, $newinput ) = eval { $_->($input) };
            if ($@) {
                die unless ref $@; # not a parser failure
                push @failures, $@;
            } else {
                return ( $v, $newinput );
            }

        }
        die [ 'ALT', $input, \@failures ];
    };
    {
        no warnings 'uninitialized';
        $N{$parser} = "(" . join ( " | ", map $N{$_}, @parsers ) . ")";
    }
    return $parser;
}

##############################################################################

=head2 list_of

  my $parser = list_of( $element, $separator );
  my ($parsed, $remainder) = $parser->($stream);

This function takes two parsers and returns a new parser which matches a
C<$separator> delimited list of C<$element> items.

=cut

sub list_of {
    my ( $element, $separator ) = @_;
    $separator = lookfor('COMMA') unless defined $separator;

    return T(
        concatenate( $element, star( concatenate( $separator, $element ) ) ),
        sub {
            my @matches = shift;
            if ( my $tail = shift ) {
                foreach my $match (@$tail) {
                    push @matches, @$match;
                }
            }
            return \@matches;
        }
    );
}

##############################################################################

=head2 rlist_of

  my $parser = list_of( $element, $separator );
  my ($parsed, $remainder) = $parser->($stream);

This function takes two parsers and returns a new parser which matches a
C<$separator> delimited list of C<$element> items.  Unlike C<list_of>, this
parser expects a leading C<$separator> in what it matches.

=cut

sub rlist_of {
    my ( $element, $separator ) = @_;
    $separator = lookfor('COMMA') unless defined $separator;

    return T( concatenate( $separator, list_of( $element, $separator ) ),
        sub { [ $_[0], @{ $_[1] } ] } );
}

##############################################################################

=head2 list_values_of

  my $parser = list_of( $element, $separator );
  my ($parsed, $remainder) = $parser->($stream);

This parser generator is the same as C<&list_of>, but it only returns the
elements, not the separators.

=cut

sub list_values_of {
    my ( $element, $separator ) = @_;
    $separator = lookfor('COMMA') unless defined $separator;

    return T(
        concatenate(
            $element, star( concatenate( absorb($separator), $element ) )
        ),
        sub {
            my @matches = shift;
            if ( my $tail = shift ) {
                foreach my $match (@$tail) {
                    push @matches, grep defined $_, @$match;
                }
            }
            return \@matches;
        }
    );
}

##############################################################################

=head2 rlist_values_of

  my $parser = list_of( $element, $separator );
  my ($parsed, $remainder) = $parser->($stream);

This parser generator is the same as C<&list_values_of>, but it only returns
the elements, not the separators.

List C<rlist_of>, it expects a separator at the beginning of the list.

=cut

sub rlist_values_of {
    my ( $element, $separator ) = @_;
    $separator = lookfor('COMMA') unless defined $separator;

    return T( concatenate( $separator, list_values_of( $element, $separator ) ),
        sub { $_[1] } );
}

##############################################################################

=head2 absorb

  my $parser = absorb( $parser );
  my ($parsed, $remainder) = $parser->($stream);

This special-purpose parser will allow you to match a given item but not
actually return anything.  This is very useful when matching commas in lists,
statement separators, etc.

=cut

sub absorb {
    my $parser = shift;
    return T( $parser, sub { () } );
}

##############################################################################

=head2 T

  my @result = T( $parser, \&transform );

Given a parser and a transformation sub, this function will apply the
tranformation to the values returned by the parser, if any.

=cut

sub T {
    my ( $parser, $transform ) = @_;


    return parser {
        my $input = shift;


        if ( my ( $value, $newinput ) = $parser->($input) ) {
            local $^W;    # using this to suppress 'uninitialized' warnings
            $value = [$value] if !ref $value;
            $value = $transform->(@$value);

	    # debug("Transforming...$value\n");

            return ( $value, $newinput );
        }
        else {
	    debug("Parser returned no value for transforming...\n");
            return;
        }


    };


}

##############################################################################

=head2 null_list

  my ($parsed, $remainder) = null_list($stream);

This special purpose parser always succeeds and returns an empty array
reference and the stream.

=cut

sub null_list {
    my $input = shift;
    return ( [], $input );
}

##############################################################################

=head2 star

  my $parser = star($another_parser);
  my ($parsed, $remainder) = $parser->($stream);

This parser always succeeds and matches zero or more instances of
C<$another_parser>.  If it matches zero, it returns the same results as
C<null_list>.  Otherwise, it returns and array ref of the matched values and
the remainder of the stream.

=cut

sub star {
    my $p = shift;
    my $p_star;

    $p_star = alternate(
        T(
            concatenate( $p, parser { $p_star->(@_) } ),
            sub {
                my ( $first, $rest ) = @_;
                [ $first, @$rest ];
            }
        ),
        \&null_list
    );
}

##############################################################################

=head2 optional

 my $parser = optional($another_parser);
 my ($parser, $remainder) = $parser->(stream); 

This parser matches 0 or 1 of the given parser item.

=cut

sub optional {
    my $parser = shift;
    return alternate (
        T($parser, sub { [ shift ] }),
        \&null_list,
    );
}

sub optionalx {
    my $parser = shift;
    return alternate (
        $parser,
        \&null_list,
    );
}

## Chapter 8 section 4.4

sub operator {
    my ( $subpart, @ops ) = @_;
    my (@alternatives);
    for my $operator (@ops) {
        my ( $op, $opfunc ) = @$operator;
        push @alternatives, T(
            concatenate( $op, $subpart ),
            sub {
                my $subpart_value = $_[1];
                sub { $opfunc->( $_[0], $subpart_value ) }
            }
        );
    }
    my $result = T(
        concatenate( $subpart, star( alternate(@alternatives) ) ),
        sub {
            my ( $total, $funcs ) = @_;
            for my $f (@$funcs) {
                $total = $f->($total);
            }
            $total;
        }
    );
}

## Chapter 8 section 4.7.1

# orig [pjw]
# sub error {
#     my ($try) = @_;
#     return parser {
#         my $input = shift;
#         my @result = eval { $try->($input) };
#         if ($@) {
#             die ref $@ ? $@ : "Internal error ($@)";
#         }
#         return @result;
#     };
# }

# for better error handling [pjw]
sub error {
  my ($try) = @_;
  my $p;
  $p = parser {
    my $input = shift;
    my @result = eval { $try->($input) };
    if ($@) {
	die ref $@ ? fetch_error($@) : "Internal error ($@)";
    }
    return @result;
  };
}


## Chapter 8 section 6

sub action {
    my $action = shift;
    return parser {
        my $input = shift;
        $action->($input);
        return ( undef, $input );
    };
}

sub test {
    my $action = shift;
    return parser {
        my $input  = shift;
        my $result = $action->($input);
        return $result ? ( undef, $input ) : ();
    };
}

#sub debug { shift; @_ }    # see Parser::Debug::debug
sub debug ($) {
    return unless $verbose;
    my $msg = shift;
    my $i = 0;
    $i++ while caller($i);
    my $I = "|" x ($i-2);
    warn $I, $msg, "\n";
}

my $error;

sub fetch_error {
    my ( $fail, $depth ) = @_;

    # clear the error unless it's a recursive call
    $error = '' if __PACKAGE__ ne caller;
    $depth ||= 0;
    my $I = "  " x $depth;
    return unless 'ARRAY' eq ref $fail; # XXX ?
    my ( $type, $position, $data ) = @$fail;
    my $pos_desc = "";

    while ( length($pos_desc) < 100 ) {
        if ($position) {
            my $h = head($position);
            $pos_desc .= "[@$h] ";
        }
        else {
            $pos_desc .= "End of input ";
            last;
        }
        $position = tail($position);
    }
    chop $pos_desc;
    $pos_desc .= "..." if defined $position;

    if ( $type eq 'TOKEN' ) {
        $error .= "${I}Wanted [@$data] instead of '$pos_desc'\n";
    }
    elsif ( $type eq 'End of input' ) {
        $error .= "${I}Wanted EOI instead of '$pos_desc'\n";
    }
    elsif ( $type eq 'ALT' ) {
        my $any = $depth ? "Or any" : "Any";
        $error .= "${I}$any of the following:\n";
        for (@$data) {
            fetch_error( $_, $depth + 1 );
        }
    }
    return $error;
}


=head1 AUTHOR

Mark Jason Dominus.  Maintained by Curtis "Ovid" Poe, C<< <ovid@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-hop-parser@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HOP-Parser>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

Many thanks to Mark Dominus and Elsevier, Inc. for allowing this work to be
republished.

=head1 COPYRIGHT & LICENSE

Code derived from the book "Higher-Order Perl" by Mark Dominus, published by
Morgan Kaufmann Publishers, Copyright 2005 by Elsevier Inc.

=head1 ABOUT THE SOFTWARE

All Software (code listings) presented in the book can be found on the
companion website for the book (http://perl.plover.com/hop/) and is
subject to the License agreements below.

=head1 ELSEVIER SOFTWARE LICENSE AGREEMENT

Please read the following agreement carefully before using this Software. This
Software is licensed under the terms contained in this Software license
agreement ("agreement"). By using this Software product, you, an individual,
or entity including employees, agents and representatives ("you" or "your"),
acknowledge that you have read this agreement, that you understand it, and
that you agree to be bound by the terms and conditions of this agreement.
Elsevier inc. ("Elsevier") expressly does not agree to license this Software
product to you unless you assent to this agreement. If you do not agree with
any of the following terms, do not use the Software.

=head1 LIMITED WARRANTY AND LIMITATION OF LIABILITY

YOUR USE OF THIS SOFTWARE IS AT YOUR OWN RISK. NEITHER ELSEVIER NOR ITS
LICENSORS REPRESENT OR WARRANT THAT THE SOFTWARE PRODUCT WILL MEET YOUR
REQUIREMENTS OR THAT ITS OPERATION WILL BE UNINTERRUPTED OR ERROR-FREE. WE
EXCLUDE AND EXPRESSLY DISCLAIM ALL EXPRESS AND IMPLIED WARRANTIES NOT STATED
HEREIN, INCLUDING THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE. IN ADDITION, NEITHER ELSEVIER NOR ITS LICENSORS MAKE ANY
REPRESENTATIONS OR WARRANTIES, EITHER EXPRESS OR IMPLIED, REGARDING THE
PERFORMANCE OF YOUR NETWORK OR COMPUTER SYSTEM WHEN USED IN CONJUNCTION WITH
THE SOFTWARE PRODUCT. WE SHALL NOT BE LIABLE FOR ANY DAMAGE OR LOSS OF ANY
KIND ARISING OUT OF OR RESULTING FROM YOUR POSSESSION OR USE OF THE SOFTWARE
PRODUCT CAUSED BY ERRORS OR OMISSIONS, DATA LOSS OR CORRUPTION, ERRORS OR
OMISSIONS IN THE PROPRIETARY MATERIAL, REGARDLESS OF WHETHER SUCH LIABILITY IS
BASED IN TORT, CONTRACT OR OTHERWISE AND INCLUDING, BUT NOT LIMITED TO,
ACTUAL, SPECIAL, INDIRECT, INCIDENTAL OR CONSEQUENTIAL DAMAGES. IF THE
FOREGOING LIMITATION IS HELD TO BE UNENFORCEABLE, OUR MAXIMUM LIABILITY TO YOU
SHALL NOT EXCEED THE AMOUNT OF THE PURCHASE PRICE PAID BY YOU FOR THE SOFTWARE
PRODUCT. THE REMEDIES AVAILABLE TO YOU AGAINST US AND THE LICENSORS OF
MATERIALS INCLUDED IN THE SOFTWARE PRODUCT ARE EXCLUSIVE.

YOU UNDERSTAND THAT ELSEVIER, ITS AFFILIATES, LICENSORS, SUPPLIERS AND AGENTS,
MAKE NO WARRANTIES, EXPRESSED OR IMPLIED, WITH RESPECT TO THE SOFTWARE
PRODUCT, INCLUDING, WITHOUT LIMITATION THE PROPRIETARY MATERIAL, AND
SPECIFICALLY DISCLAIM ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A
PARTICULAR PURPOSE.

IN NO EVENT WILL ELSEVIER, ITS AFFILIATES, LICENSORS, SUPPLIERS OR AGENTS, BE
LIABLE TO YOU FOR ANY DAMAGES, INCLUDING, WITHOUT LIMITATION, ANY LOST
PROFITS, LOST SAVINGS OR OTHER INCIDENTAL OR CONSEQUENTIAL DAMAGES, ARISING
OUT OF YOUR USE OR INABILITY TO USE THE SOFTWARE PRODUCT REGARDLESS OF WHETHER
SUCH DAMAGES ARE FORESEEABLE OR WHETHER SUCH DAMAGES ARE DEEMED TO RESULT FROM
THE FAILURE OR INADEQUACY OF ANY EXCLUSIVE OR OTHER REMEDY.

=head1 SOFTWARE LICENSE AGREEMENT

This Software License Agreement is a legal agreement between the Author and
any person or legal entity using or accepting any Software governed by this
Agreement. The Software is available on the companion website
(http://perl.plover.com/hop/) for the Book, Higher-Order Perl, which is
published by Morgan Kaufmann Publishers. "The Software" is comprised of all
code (fragments and pseudocode) presented in the book.

By installing, copying, or otherwise using the Software, you agree to be bound
by the terms of this Agreement.

The parties agree as follows:

=over 4

=item 1 Grant of License

We grant you a nonexclusive license to use the Software for any purpose,
commercial or non-commercial, as long as the following credit is included
identifying the original source of the Software: "from Higher-Order Perl by
Mark Dominus, published by Morgan Kaufmann Publishers, Copyright 2005 by
Elsevier Inc".

=item 2 Disclaimer of Warranty. 

We make no warranties at all. The Software is transferred to you on an "as is"
basis. You use the Software at your own peril. You assume all risk of loss for
all claims or controversies, now existing or hereafter, arising out of use of
the Software. We shall have no liability based on a claim that your use or
combination of the Software with products or data not supplied by us infringes
any patent, copyright, or proprietary right. All other warranties, expressed
or implied, including, without limitation, any warranty of merchantability or
fitness for a particular purpose are hereby excluded.

=item 3 Limitation of Liability. 

We will have no liability for special, incidental, or consequential damages
even if advised of the possibility of such damages. We will not be liable for
any other damages or loss in any way connected with the Software.

=back

=cut

1; # End of HOP::Parser
