package Kynetx::Predicates::Time;
# file: Kynetx/Predicates/Time.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Kynetx::Predicates::Weather qw(get_weather);


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
    # time predicates

    'timezone' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];

	my $tz = get_weather($req_info, 'timezone');

	return $tz eq $desired;
    },
   
    'daytime' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $sunrise = get_weather($req_info, 'sunrise');
	$sunrise =~ y/ /:/;
	my @sr = split(/:/, $sunrise);
	$sr[0] += 12 if $sr[2] eq 'pm';

	my $sunset = get_weather($req_info, 'sunset');
	$sunset =~ y/ /:/;
	my @ss = split(/:/, $sunset);
	$ss[0] += 12 if $ss[2] eq 'pm';

	my $tz = get_weather($req_info, 'timezone');

	$tz =~ s#E.T#America/New_York#;
	$tz =~ s#C.T#America/Chicago#;
	$tz =~ s#M.T#America/Denver#;
	$tz =~ s#P.T#America/Los_Angeles#;

	# this code has the potential of breaking badly when the server
        # clock/timzone is not set right...
	my $now = DateTime->now;  
	$now->set_time_zone($tz);


	my $srto = $now->clone;
	$srto->set_hour($sr[0]);
	$srto->set_minute($sr[1]);


	my $ssto = $now->clone;
	$ssto->set_hour($ss[0]);
	$ssto->set_minute($ss[1]);
	

	# returns 1 if a > b
	my $after_sunrise = DateTime->compare($now,$srto);
	my $before_sunset = DateTime->compare($ssto,$now);

	my $logger = get_logger();
	$logger->debug( 
	    "Time for cust: " . $now->hms . "($tz)  " . 
	    "After Sunrise: " . $after_sunrise . " " .
	    "Before Sunset: " . $before_sunset . " " 
	    );
	

	return $after_sunrise eq 1 && $before_sunset eq 1;
   
    
    },

    );


# need predicates already defined for this
$predicates{'nighttime'} = sub {
    return ! $predicates{'daytime'}(@_)

};


sub get_predicates {
    return \%predicates;
}


1;
