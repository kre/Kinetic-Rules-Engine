package Kynetx::Pick;
# file: Kynetx/Pick.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;

use Kynetx::JavaScript q/eval_js_expr/;
use Kynetx::JSONPath ;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
eval_pick
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub eval_pick {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();

    my $obj = Kynetx::JavaScript::eval_js_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);
#    $logger->debug("obj: ", sub { Dumper($obj) });
    
    
    my $jp = Kynetx::JSONPath->new();
    my $v = $jp->run($obj->{'val'}, $expr->{'pattern'});

    $v = $v->[0] if(scalar @{ $v } == 1);

    return  { 'type' => Kynetx::JavaScript::infer_type($v),
	      'val' => $v
    };
}

1;
