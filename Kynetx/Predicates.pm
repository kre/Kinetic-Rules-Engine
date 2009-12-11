package Kynetx::Predicates;
# file: Kynetx/Predicates.pm
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

use Log::Log4perl qw(get_logger :levels);
use Kynetx::Util qw(:all);
use Kynetx::JavaScript qw(:all);
use Kynetx::Session qw(:all);

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
Useragent
Page
Math
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
    my($req_info, $rule_env, $session, $cond, $rule_name) = @_;

    my $logger = get_logger();

#    $logger->debug("Rule name: $rule_name");

    my $v = 0;
    if ($cond->{'type'} eq 'bool') {
	return Kynetx::JavaScript::den_to_exp($cond);
    } elsif($cond->{'type'} eq 'pred') {
	$v = eval_pred($req_info, $rule_env, $session, 
		       $cond, $rule_name);
	return $v ||= 0;
    } elsif($cond->{'type'} eq 'ineq') {
	$v = eval_ineq($req_info, $rule_env, $session, 
		       $cond, $rule_name);
	return $v ||= 0;
    } elsif($cond->{'type'} eq 'simple') {

	my $pred = $cond->{'predicate'};

	my $predf = $predicates{$pred};
	if($predf eq "") {
	    $logger->warn("Predicate $pred not found for ", $rule_name);
	} else {

	    my $args = Kynetx::JavaScript::gen_js_rands($cond->{'args'});

	# FIXME: this leaves string args as '...' which means that the predicates have to remember to remove them.  That causes errors.  

	    $v = &$predf($req_info, 
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
    } elsif($cond->{'type'} eq 'persistent_ineq') {
	my $name = $cond->{'var'};

	# check count
	my $count = 0;
	if($cond->{'domain'} eq 'ent') {
	    $count = session_get($req_info->{'rid'}, $session, $name);
	}

	$logger->debug('[persistent_ineq] ', "$name -> $count");

	$v = ineq_test($cond->{'ineq'}, 
		       $count, 
		       Kynetx::JavaScript::den_to_exp(
			   Kynetx::JavaScript::eval_js_expr($cond->{'expr'}, 
					$rule_env, 
					$rule_name, 
					$req_info, 
					$session))
	    );


	# check date, if needed
	if($v && 
	   defined $cond->{'within'} &&
	   session_defined($req_info->{'rid'}, $session, $name)) {

	    my $tv = 1;
	    if($cond->{'domain'} eq 'ent') {
		$tv = session_within($req_info->{'rid'}, 
				     $session, 
				     $name, 
				     Kynetx::JavaScript::den_to_exp(
					 Kynetx::JavaScript::eval_js_expr($cond->{'within'},
						      $rule_env, 
						      $rule_name, 
						      $req_info, 
						      $session)),
				     $cond->{'timeframe'}
		    )
	    }

	    $v = $v && $tv;
	}
    } elsif($cond->{'type'} eq 'seen_timeframe') {
	my $name = $cond->{'var'};

	$logger->debug('[seen_timeframe] ', "$name");

	# check date, if needed
	if(defined $cond->{'within'} &&
	   session_defined($req_info->{'rid'}, $session, $name)) {

	    if($cond->{'domain'} eq 'ent') {
		$v = session_seen_within($req_info->{'rid'}, 
					 $session, 
					 $name, 
					 $cond->{'regexp'},
					 Kynetx::JavaScript::den_to_exp(
					  Kynetx::JavaScript::eval_js_expr($cond->{'within'},
						       $rule_env, 
						       $rule_name, 
						       $req_info, 
						       $session)),
					  $cond->{'timeframe'}
		    )
	    }
	} elsif(session_defined($req_info->{'rid'}, $session, $name)) {
	    if($cond->{'domain'} eq 'ent') {
		# session_seen returns index (which can be 0)
		$v = defined session_seen($req_info->{'rid'}, 
				  $session, 
				  $name, 
				  $cond->{'regexp'}
		    ) ? 1 : 0;
	    }
	}
    } elsif($cond->{'type'} eq 'seen_compare') {
	my $name = $cond->{'var'};
	if($cond->{'domain'} eq 'ent') {
	    my($r1,$r2) =
		$cond->{'op'} eq 'after' ? ($cond->{'regexp_1'},
					    $cond->{'regexp_2'})
                                         : ($cond->{'regexp_2'},
					    $cond->{'regexp_1'});
	    $v = session_seen_compare($req_info->{'rid'}, 
				      $session, 
				      $name, 
				      $r1,
				      $r2
		) ? 1 : 0; # ensure 0 returned for testing
	}
    } elsif($cond->{'type'} eq 'persistent') {
	my $name = $cond->{'name'};
	if($cond->{'domain'} eq 'ent') {
	    $v = session_defined($req_info->{'rid'}, $session, $name) &&
		session_get($req_info->{'rid'}, $session, $name);
	    
	}
    }


    # returns default value if nothing returned above
    return $v;

}

sub eval_pred {
    my($req_info, $rule_env, $session, $pred, $rule_name) = @_;

    my $logger = get_logger();

    my @results = 
	map {eval_predicates(
		 $req_info, $rule_env, $session, 
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
    my($req_info, $rule_env, $session, $pred, $rule_name) = @_;

    my $logger = get_logger();

    my @results;
    for (@{ $pred->{'args'} }) {
	my $den = Kynetx::JavaScript::eval_js_expr($_, $rule_env, $rule_name, $req_info, $session);
#	$logger->debug("Denoted -> ", sub { Dumper($den) });
	push @results, Kynetx::JavaScript::den_to_exp($den);
    }

    return ineq_test($pred->{'op'}, $results[0], $results[1]);
	
}


sub ineq_test {
    my($op, $rand0, $rand1) = @_;

#    my $logger = get_logger();
#    $logger->debug("[ineq_test] $rand0 $op $rand1");

    if ($op eq '<=') {
	return $rand0 <= $rand1;
    } elsif($op eq '>=') {
	return $rand0 >= $rand1;
    } elsif($op eq '<') {
	return $rand0 < $rand1;
    } elsif($op eq '>') {
	return $rand0 > $rand1;
    } elsif($op eq '==') {
	return $rand0 == $rand1;
    } elsif($op eq '!=') {
	return $rand0 != $rand1;
    } elsif($op eq 'neq') {
	    return ! ($rand0 eq $rand1);
    } elsif($op eq 'eq') {
	return $rand0 eq $rand1;
    } elsif($op eq 'like') {
	my $re = qr!$rand1!;
	return $rand0 =~ $re;
    }
}

1;
