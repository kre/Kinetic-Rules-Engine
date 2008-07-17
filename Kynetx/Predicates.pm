package Kynetx::Predicates;
# file: Kynetx/Predicates.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Kynetx::Util qw(:all);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
eval_predicates
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


# to add a new module to the engine, add it's name here
my @Predicate_modules = qw(
Demographics
Location
Weather
Time
Markets
Referers
Mobile
MediaMarkets
);

# eval necessary with computed module names (not bare words)
foreach my $module (@Predicate_modules) {
    eval "use Kynetx::Predicates::${module} (':all')";
}
# the above code does this:
# use Kynetx::Predicates::Location qw(:all);
# use Kynetx::Predicates::Weather qw(:all);
# use Kynetx::Predicates::Time qw(:all);
# use Kynetx::Predicates::Markets qw(:all);
# use Kynetx::Predicates::Referers qw(:all);



# start with some global predicates
my %predicates = (
    'truth' => sub  { 1; },
    );



# load the predicates from the predicate modules
#  eval necessary with computed module names
foreach my $module (@Predicate_modules) {
    %predicates = (%predicates,
		   %{ eval "Kynetx::Predicates::${module}::get_predicates()"  });
}

# this code does this:
# %predicates = (%predicates, 
# 	       %{ Kynetx::Predicates::Location::get_predicates() },
# 	       %{ Kynetx::Predicates::Weather::get_predicates() },
# 	       %{ Kynetx::Predicates::Time::get_predicates() },
# 	       %{ Kynetx::Predicates::Markets::get_predicates() },
# 	       %{ Kynetx::Predicates::Referers::get_predicates() },
#     );



sub eval_predicates {
    my($request_info, $rule_env, $session, $rule) = @_;

    my $logger = get_logger();

    my $conds = $rule->{'cond'};
    my $pred_value = 1;
    foreach my $cond ( @$conds ) {
	my $v = 0;
	if ($cond->{'type'} eq 'simple') {
	    my $pred = $cond->{'predicate'};

	    my $predf = $predicates{$pred};
	    if($predf eq "") {
		$logger->warn("Predicate $pred not found for ", $rule->{'name'});
	    } else {

		my $args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

		# FIXME: this leaves string args as '...' which means that the predicates have to remember to remove them.  That causes errors.  

		$v = &$predf($request_info, 
			     $rule_env, 
			     $args
		    );

		$logger->debug('[predicate] ',
			       "$pred executing with args (" , 
			       join(', ', @{ $args } ), 
			       ')',
			       ' -> ',
			       $v);
	    }

	} elsif ($cond->{'type'} eq 'counter') {

	    my $name = $cond->{'name'};

	    # check count
	    my $count = $session->{$name} || 0;

	    $logger->debug('[counter] ', "$name -> $count");


	    if($cond->{'ineq'} eq '>') {
		$v =  $count > $cond->{'value'};
	    } elsif($cond->{'ineq'} eq '<') {
		$v = $count < $cond->{'value'};
	    } 

	    # check date, if needed
	    if($v &&
	       exists $cond->{'within'} &&
	       exists $session->{mk_created_session_name($name)}) {

		my $desired = 
		    DateTime->from_epoch( epoch => 
					  $session->{mk_created_session_name($name)});
		$desired->add( $cond->{'timeframe'} => $cond->{'within'} );

		$v = $v && after_now($desired);
	    }


	}

	$pred_value = $pred_value && $v;
    }
    return $pred_value;
}



1;
