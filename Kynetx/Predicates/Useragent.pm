package Kynetx::Predicates::Useragent;
# file: Kynetx/Predicates/Useragent.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use HTML::ParseBrowser;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_useragent
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my %predicates = (

    'using_ie' => sub {
	my ($req_info, $rule_env, $args) = @_;
	
	return get_useragent($req_info,'browser_name') eq 'MSIE'
	
    },
    
    'using_firefox' => sub {
	my ($req_info, $rule_env, $args) = @_;
	
	return get_useragent($req_info,'browser_name') eq 'Firefox'
	
    },
    

    );


sub get_predicates {
    return \%predicates;
}

# condition subfunctions
# first argument is a record of data about the request

sub get_useragent {
    my ($req_info, $field) = @_;
    # for US locations only right now (with Yahoo!)
    
    my @field_names = qw(
         language
         language_code
         browser_name
         browser_version
         browser_version_major
         browser_version_minor
         os
         os_type
         os_version
         );
    
    my $logger = get_logger();

    if(not defined $req_info->{'useragent'}->{$field}) {

	my $ua_string = $req_info->{'ua'};

	$logger->debug("UserAgent: ", $ua_string);
	my $ua = HTML::ParseBrowser->new($ua_string);


	$req_info->{'useragent'}->{'language'} = $ua->language();
	$req_info->{'useragent'}->{'language_code'} = $ua->lang();
	$req_info->{'useragent'}->{'browser_name'} = $ua->name();
	$req_info->{'useragent'}->{'browser_version'} = $ua->v();
	$req_info->{'useragent'}->{'browser_version_major'} = $ua->major();
	$req_info->{'useragent'}->{'browser_version_minor'} = $ua->minor();
	$req_info->{'useragent'}->{'os'} = $ua->os();
	$req_info->{'useragent'}->{'os_type'} = $ua->ostype();
	$req_info->{'useragent'}->{'os_version'} = $ua->osvers();

    }

    $logger->debug("User-Agent information: " ,
		   $req_info->{'useragent'}->{$field});


    return $req_info->{'useragent'}->{$field};

}



1;
