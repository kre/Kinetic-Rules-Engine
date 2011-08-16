package Kynetx::Parser;
# file: Kynetx/Parser.pm
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
use utf8;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use lib qw(/web/lib/perl);

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
use Data::Dumper;
use Kynetx::JParser;
use Kynetx::Json;
use Encode qw(from_to);

use vars qw(%VARIABLE);

# Enable warnings within the Parse::RecDescent module.


sub html {
    my ($value) = @_;
    $value =~ s/^<<\s*//;
    $value =~ s/>>\s*$//;
#    $value = remove_comments($value);
#    $value =~ s/[\n\r]/  /sg;
    return $value;
}

sub javascript {
    my ($value) = @_;
    $value =~ s/^<\|[ \t]*//;
    $value =~ s/\|>\s*$//;
#    $value = remove_comments($value);
#    $value =~ s/[\n\r]/  /sg;
    return $value;
}

sub string {
    my ($value) = @_;
    $value =~ s/^["']//;
    $value =~ s/["']$//;
    return $value;
}


# assumes an array of at least length three and with odd number of members
sub build_expr_tree {
  my ($exprs, $type) = @_;

  return unless (int(@{ $exprs}) >= 3);
  my $firstarg = shift @{ $exprs };
  my $op = shift @{ $exprs };
  my $secondarg;

  if (defined $exprs->[1]) {
    $secondarg = build_expr_tree($exprs, $type);
  } else {
    $secondarg = $exprs->[0];
  }

  return {'type' => $type,
	  'op' => $op,
	  'args' => [$firstarg, $secondarg]
         };

}

sub structure_operators {
  my($obj, $operators) = @_;
  if (int(@{$operators}) == 0) {
    return $obj;
  } else {
    my $last = pop(@{$operators});
    return {'type' => 'operator',
	    'name' => $last->[0],
	    'args' => $last->[1],
	    'obj' => structure_operators($obj, $operators)
	   }

  }

}

my $parser = Kynetx::JParser::get_antlr_parser();

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
       //[^\n]*    ## slash style comments that don't have \ in front (quote)
     |         ##     OR  various things which aren't comments:

       (
         "           ##  Start of " ... " string
         (
           \\.           ##  Escaped char
         |               ##    OR
           [^"\\]        ##  Non "\
         )*
         "           ##  End of " ... " string
        |
         \#           ##  Start of # ... # regexp
         (
           \\.           ##  Escaped char
         |               ##    OR
           [^#\\]        ##  Non "\
         )*
         \#          ##  End
        |         ##     OR  various things which aren't comments:
          <<           ##  Start of << ... >> string
          .*?
          >>           ##  End of " ... " string
       |
         \\//  # backslashes before double slashes
       |         ##     OR
        .           ##  Anything other char
         [^/"#'<\\]*   ##  Chars which doesn't start a comment, string or escape
       )
     %xms;

sub remove_comments {

    my($ruleset) = @_;

    $ruleset =~ s%$comment_re%defined $2 ? $2 : ""%gxmse;
    return $ruleset;

}
sub utf8_parse_ruleset {
	my ($u_ruleset) = @_;
	my $enc = Kynetx::Util::str_in($u_ruleset);
	return parse_ruleset($enc);
}

sub parse_ruleset {
    my ($ruleset) = @_;

    my $logger = get_logger();
    $logger->trace("[parser::parse_ruleset] passed: ", sub {Dumper($ruleset)});

    #$ruleset = remove_comments($ruleset);

    $logger->trace("[parser::parse_ruleset] after comments: ", sub {Dumper($ruleset)});
    my $json = $parser->ruleset($ruleset);
    #$logger->debug("Result: ",$json);
    my $result;
    eval {
        $result = Kynetx::Json::jsonToAst($json);
    };



    if ($@) {
        my @jsonerr = ("Invalid JSON Format!");
        $logger->warn("JSON error: ", $@);
        my $string = $@;
        push (@jsonerr,$string);
        push (@jsonerr,$result);
        $result->{'error'} = @jsonerr;
    }
    if (defined $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
	   $logger->error("Can't parse ruleset: $estring");
    } else {
	   $logger->trace("Parsed rules");
    }
    return $result;
}

# Helper function used in testing
sub parse_expr {
    my ($expr) = @_;

    my $logger = get_logger();

    $expr = remove_comments($expr);

    # remove newlines
#    $expr =~ s%\n%%g;


    my $json = $parser->expr($expr);
    my $result = Kynetx::Json::jsonToAst_w($json);
    if (defined $result->{'error'}) {
       my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse expression: $estring");
       return $result;
    } else {
    $logger->debug("Parsed expression: ",sub {Dumper($expr)});
    }

    return $result->{'result'};

}

# Helper function used in testing
sub parse_decl {
    my ($expr) = @_;

    my $logger = get_logger();

    $expr = remove_comments($expr);

    # remove newlines
#    $expr =~ s%\n%%g;
    my $json = $parser->decl($expr);
    my $result = Kynetx::Json::jsonToAst_w($json);
    if (defined $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse declaration: $estring");
       return $result;
    } else {
    $logger->trace("Parsed declaration: ",sub {Dumper($expr)});
    }

    return $result->{'result'};

#    print Dumper($result);


}

# Helper function used in testing
sub parse_pre {
    my ($expr) = @_;

    my $logger = get_logger();

    $expr = remove_comments($expr);

    # remove newlines
#    $expr =~ s%\n%%g;

    my $json = $parser->pre_block($expr);
    my $result = Kynetx::Json::jsonToAst_w($json);
    if (defined $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse pre: $estring");
       return $result;
    } else {
        $logger->debug("Parsed pre");
    }

    return $result->{'result'};

#    print Dumper($result);


}



sub parse_rule {
    my ($rule) = @_;

    my $logger = get_logger();

    $rule = remove_comments($rule);

    my $json = ($parser->rule($rule));
    my $result = Kynetx::Json::jsonToAst_w($json);

    if (ref $result eq 'HASH' && $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse rule: $estring");
       return $result;
    } else {
	$logger->debug("Parsed rules");
    }

 #   $logger->debug("Rule parsed:", sub {Dumper($result)});

    return $result->{"result"};



}


sub parse_action {
    my $rule = shift;

    my $logger = get_logger();

    $rule = remove_comments($rule);

    my $json = ($parser->action($rule));
    $logger->trace("Action resp: ", $json);

    my $result = Kynetx::Json::jsonToAst_w($json);
    if (defined $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse action: $estring");
       return $result;
    } else {
	$logger->trace("Parsed rules");
    }

    return $result;

}

sub parse_callbacks {
    my $rule = shift;

    my $logger = get_logger();

    $rule = remove_comments($rule);

    # remove newlines
 #   $rule =~ s%\n%%g;

    my $json =  $parser->callbacks($rule);
    my $result = Kynetx::Json::jsonToAst_w($json);
    if (defined $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse callback: $estring");
       return $result;
    } else {
	$logger->debug("Parsed rules");
    }

    return $result->{"result"};

}

sub parse_post {
    my $rule = shift;

    my $logger = get_logger();

    $rule = remove_comments($rule);

    # remove newlines
#    $rule =~ s%\n%%g;

    my $json =  $parser->post_block($rule);
    my $result = Kynetx::Json::jsonToAst_w($json);
    if (defined $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse post: $estring");
       return $result;
    } else {
	$logger->debug("Parsed post");
    }

    return $result->{'result'};

}

sub parse_global_decls {
    my $element = shift;

    my $logger = get_logger();

    $element = remove_comments($element);

    #my $encap = $element;#_encapsulate($element);

    my $json = $parser->global($element);
    $logger->trace(Dumper($json));
    my $result = Kynetx::Json::jsonToAst_w($json);

#    $logger->debug(Dumper($result));
    if (ref $result eq 'HASH' && $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse global: $estring");
       return $result;
    } else {
	   #$logger->debug("[Parser] Parsed global decls");#,
    }


    return $result->{"result"};

}

sub parse_dispatch {
    my $element = shift;

    my $logger = get_logger();

    $element = remove_comments($element);

    my $json =  $parser->dispatch_block($element);
    my $result = Kynetx::Json::jsonToAst_w($json);

    if (ref $result eq 'HASH' && $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse dispatch: $estring");
       return $result;
    } else {
	$logger->debug("Parsed dispatch declaration");
    }

    return $result->{'result'};

}


sub parse_meta {
    my $element = shift;

    my $logger = get_logger();

    $element = remove_comments($element);

    my $json = $parser->meta_block($element);
    my $result = Kynetx::Json::jsonToAst_w($json);

    if (ref $result eq 'HASH' && $result->{'error'}) {
        my $estring = join("\n",@{$result->{'error'}});
       $logger->error("Can't parse meta block: $estring");
       return $result;
    } else {
	$logger->debug("Parsed meta information");
    }


    return $result->{'result'};

}


sub mk_expr_node {
    my($type, $val) = @_;
    return {'type' => $type,
	    'val' => $val};
}




1;
