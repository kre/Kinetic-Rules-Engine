package Kynetx::Predicates::Mobile;
# file: Kynetx/Predicates/Mobile.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Mobile::UserAgent;




use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my %predicates = (

    'mobile' => sub {
	my ($req_info, $rule_env, $args) = @_;
	
	my $uaobj = new Mobile::UserAgent($req_info->{'ua'});

	my $logger = get_logger();
	$logger->debug("UserAgent: ", $req_info->{'ua'});

	return $uaobj->success() ||
	       $req_info->{'ua'} =~ m/iPhone|IEMobile|HTCP|Opera Mini|Nokia|Palm/;
	
    },
    

    );


sub get_predicates {
    return \%predicates;
}

# condition subfunctions
# first argument is a record of data about the request



1;
