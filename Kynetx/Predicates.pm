package Kynetx::Predicates;
# file: Kynetx/Predicates.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);

use Data::Dumper;
$Data::Dumper::Indent = 1;


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
    my($request_info, $rule_env, $session, $cond, $rule_name) = @_;

    my $logger = get_logger();

#    $logger->debug(Dumper($cond));
#    $logger->debug("Rule name: $rule_name");

    my $v = 0;
    case: for ($cond->{'type'}) {
	/bool/ && do {
	    return den_to_exp($cond);
	};
	/^pred$/ && do {
	    $v = eval_pred($request_info, $rule_env, $session, 
			   $cond, $rule_name);
	    return $v ||= 0;
	};
	/ineq/ && do {
	    $v = eval_ineq($request_info, $rule_env, $session, 
			   $cond, $rule_name);
	    return $v ||= 0;
	};
	/simple/ && do {
	    my $pred = $cond->{'predicate'};

	    my $predf = $predicates{$pred};
	    if($predf eq "") {
		$logger->warn("Predicate $pred not found for ", $rule_name);
	    } else {

		my $args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

		# FIXME: this leaves string args as '...' which means that the predicates have to remember to remove them.  That causes errors.  

		$v = &$predf($request_info, 
			     $rule_env, 
			     $args
		    );
		$v ||= 0;

		$logger->debug('[predicate] ',
			       "$pred executing with args (" , 
			       sub { join(', ', @{ $args } )}, 
			       ')',
			       ' -> ',
			       $v);
	    }
	    return $v;
	};
	/^counter_pred$/ && do {
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
	       defined $cond->{'within'} &&
	       exists $session->{mk_created_session_name($name)}) {


		my $desired = 
		    DateTime->from_epoch( epoch => 
					  $session->{mk_created_session_name($name)});

		$logger->debug("[counter:$name] created ", $desired->ymd);

		$desired->add( $cond->{'timeframe'} => $cond->{'within'} );

		$logger->debug("[counter:$name] ",
			       $cond->{'timeframe'}, " -> ", $cond->{'within'},
			       ' desired ', $desired->ymd
		     );

		$v = $v && after_now($desired);

	    }
	    return $v;
	};
    }

    # returns default value if nothing returned above
    return $v;

}

sub eval_pred {
    my($request_info, $rule_env, $session, $pred, $rule_name) = @_;

    my $logger = get_logger();

    my @results = 
	map {eval_predicates(
		 $request_info, $rule_env, $session, 
		 $_, $rule_name) } @{ $pred->{'args'} };


#    warn Dumper(@results);

    $logger->debug("Complex predicate: ", $pred->{'op'});

    if($pred->{'op'} eq '&&') {
	my $val = shift @results;
	for (@results) {
	    $val = $val && $_;
	}
	return $val;

    } elsif($pred->{'op'} eq '||') {
	my $val = shift @results;
	for (@results) {
	    $val = $val || $_;
	}
	return $val;
    } elsif($pred->{'op'} eq 'negation') {
	return 
	    not $results[0];
    } else {
	$logger->warn("Invalid predicate");
    }
    return 0;

}

sub eval_ineq {
    my($request_info, $rule_env, $session, $pred, $rule_name) = @_;

    my $logger = get_logger();

    my @results;
    for (@{ $pred->{'args'} }) {
	my $den = eval_js_expr($_, $rule_env, $rule_name, $request_info, $session);
#	$logger->debug("Denoted -> ", sub { Dumper($den) });
	push @results, den_to_exp($den);
    }
	
    case: for ($pred->{'op'}) {
	/<=/ && do {
	    return $results[0] <= $results[1]
	};
	/>=/ && do {
	    return $results[0] >= $results[1]
	};
	/</ && do {
	    return $results[0] < $results[1]
	};
	/>/ && do {
	    return $results[0] > $results[1]
	};
	/==/ && do {
	    return $results[0] == $results[1]
	};

	/!=/ && do {
	    return $results[0] != $results[1]
	};

	/neq/ && do {
	    return ! ($results[0] eq $results[1]);
	};
	/eq/ && do {
	    return $results[0] eq $results[1]
	};
	/like/ && do {
	    my $re = qr!$results[1]!;
	    return $results[0] =~ $re;
	};

#	    $logger->debug($results[0], " neq? ", $results[1]);

    }
}



1;
