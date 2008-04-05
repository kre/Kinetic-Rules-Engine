package Kynetx::Json;
# file: Kynetx/Json.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

use Kynetx::Parser qw/:all/;
use Kynetx::PrettyPrinter qw/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
krlToJson
jsonToKrl
jsonToRuleBody
astToJson
jsonToAst
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub krlToJson {
    my($krl) = @_;

    my $tree = parse_ruleset($krl);
    return encode_json($tree);

}

sub jsonToKrl {
    my($json) = @_;

    my $tree = decode_json($json);
    return pp($tree);


}

sub jsonToRuleBody {
    my($json) = @_;

    my $tree = decode_json($json);
    return pp_rule_body($tree,0);


}


# a renaming of encode_json for Abstract Syntax Trees
sub astToJson {
    my($ast) = @_;

    return encode_json($ast);

}

sub jsonToAst {
    my($json) = @_;

    return decode_json($json);

}



1;
