package Kynetx::Modules;
# file: Kynetx/Modules.pm
#
# Copyright 2007-2010, Kynetx Inc.  All rights reserved.
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
use Kynetx::Expressions qw(:all);
use Kynetx::Environments qw(:all);
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
eval_module
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



# to add a new module to the engine, add it's name here
my @modules = qw(
Demographics
Location
Weather
Time
Markets
Referers
Mobile
MediaMarkets
Useragent
Twitter
Page
Math
);

# eval necessary with computed module names (not bare words)
foreach my $module (@modules) {
    eval "use Kynetx::Predicates::${module} (':all')";
}


# the above code does this:
# use Kynetx::Predicates::Location qw(:all);
# use Kynetx::Predicates::Weather qw(:all);
# use Kynetx::Predicates::Time qw(:all);
# use Kynetx::Predicates::Markets qw(:all);
# use Kynetx::Predicates::Referers qw(:all);



sub eval_module {
    my($req_info, $rule_env, $session, $rule_name, $source, $function, $args) = @_;


    my $logger = get_logger();
  
 #   $args->[0] =~ s/'([^']*)'/$1/;  # cheating here to remove JS quotes
      # get the values
    
#    $logger->debug("Datasource args ", sub {Dumper $args});

    my $val = '';
    my $preds = {};

    # 
    # the following code is ugly for historical reasons.  Ultimately,
    # we need to clean it up so that all modules have a common
    # function name and predicates are linked into that one function
    # and this big if-then-else can go away.  Data driven FTW!
    #

    if ($source eq 'datasource') { # do first since most common
      #$val = Kynetx::Datasets::get_datasource($rule_env,$args,$function);
      my $rs = Kynetx::Environments::lookup_rule_env('datasource:'.$function,$rule_env);
      my $new_ds = Kynetx::Datasets->new($rs);
      $new_ds->load($req_info,$args);
      $new_ds->unmarshal();
      if (defined $new_ds->json) {
        $val = $new_ds->json;
      } else {
        $val = $new_ds->sourcedata;
      }
    } elsif ($source eq 'twitter') {
	$preds = Kynetx::Predicates::Twitter::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Twitter::eval_twitter($req_info,$rule_env,$session,$rule_name,$function,$args);
	}
    } elsif ($source eq 'page') {
	$preds = Kynetx::Predicates::Page::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Page::get_pageinfo($req_info,$function,$args);
	}
    } elsif($source eq 'weather') {
	$preds = Kynetx::Predicates::Weather::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Weather::get_weather($req_info,$function);
	}
    } elsif($source eq 'demographics') {
	$preds = Kynetx::Predicates::Demographics::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Demographics::get_demographics($req_info,$function);
	}
    } elsif ($source eq 'geoip' || $source eq 'location') {
	$preds = Kynetx::Predicates::Location::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Location::get_geoip($req_info,$function);
	}
    } elsif ($source eq 'stocks' || $ source eq 'markets') {
	$preds = Kynetx::Predicates::Markets::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Markets::get_stocks($req_info,$args->[0],$function);
	}
    } elsif ($source eq 'referer') {
	$preds = Kynetx::Predicates::Referers::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Referers::get_referer($req_info,$function);
	}
    } elsif ($source eq 'mediamarket') {
	$preds = Kynetx::Predicates::MediaMarkets::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::MediaMarkets::get_mediamarket($req_info,$function);
	}
    } elsif ($source eq 'useragent') {
	$preds = Kynetx::Predicates::Useragent::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Useragent::get_useragent($req_info,$function);
	}
    } elsif ($source eq 'math') {
	$preds = Kynetx::Predicates::Math::get_predicates();
	if (defined $preds->{$function}) {
	  $val = $preds->{$function}->($req_info,$rule_env,$args);
	  $val ||= 0;
	} else {
	  $val = Kynetx::Predicates::Math::do_math($req_info,$function,$args);
	}
    } else {
      $logger->warn("Datasource for $source not found");
    }

    $logger->debug("Datasource $source:$function -> $val");

    return $val;

}


# # start with some global predicates
# my %predicates = (
#     'truth' => sub  { 1; },
#     );


# #warn (Dumper Kynetx::Predicates::Twitter::eval_twitter()) ;
  

# # load the predicates from the predicate modules
# #  eval necessary with computed module names
# foreach my $module (@Predicate_modules) {
#     %predicates = (%predicates,
# 		   %{ eval "Kynetx::Predicates::${module}::get_predicates()"  });
# }

# # this code does this:
# # %predicates = (%predicates, 
# # 	       %{ Kynetx::Predicates::Location::get_predicates() },
# # 	       %{ Kynetx::Predicates::Weather::get_predicates() },
# # 	       %{ Kynetx::Predicates::Time::get_predicates() },
# # 	       %{ Kynetx::Predicates::Markets::get_predicates() },
# # 	       %{ Kynetx::Predicates::Referers::get_predicates() },
# #     );

# my get_predicates {
#   return \%predicates;
# }


# sub eval_predicates {
#     my($req_info, $rule_env, $session, $cond, $rule_name) = @_;

#     my $logger = get_logger();

# #    $logger->debug("Rule name: $rule_name");

#     my $v = 0;
#     if ($cond->{'type'} eq 'bool') {
#       return Kynetx::Expressions::den_to_exp($cond);
# #     } elsif($cond->{'type'} eq 'pred') {
# #       $v = eval_pred($req_info, $rule_env, $session, 
# # 		     $cond, $rule_name);
# #       return $v ||= 0;
# #     } elsif($cond->{'type'} eq 'ineq') {
# #       $v = eval_ineq($req_info, $rule_env, $session, 
# # 		     $cond, $rule_name);
# #       return $v ||= 0;
#     } elsif($cond->{'type'} eq 'simple') {

#       my $pred = $cond->{'predicate'};

#       my $predf = $predicates{$pred};
#       if($predf eq "") {
# 	$logger->warn("Predicate $pred not found for ", $rule_name);
#       } else {

# 	my $args = Kynetx::Expressions::eval_rands($cond->{'args'}, 
# 						     $rule_env, 
# 						     $rule_name,
# 						     $req_info, 
# 						     $session
# 						    );
# 	for (@{ $args }) {
# 	  $_ = den_to_exp($_);
# 	}


# #	$logger->debug("Pred args ", Dumper $args);
	
# 	$v = &$predf($req_info, 
# 		     $rule_env, 
# 		     $args
# 		    );

# 	$v ||= 0;

# 	$logger->debug('[predicate] ',
# 		       "$pred executing with args (" , 
# 		       sub { join(', ', @{ $args } )}, 
# 		       ')',
# 		       ' -> ',
# 		       $v);
#       }
# #     } elsif ($cond->{'type'} eq 'qualified') {

# #       my $den = Kynetx::Expressions::eval_rands($cond->{'args'}, $rule_env, $rule_name,$req_info, $session);

# #     # FIXME: datasources don't expect denoted values.  
    
# #       for (@{ $den }) {
# # 	$_ = den_to_exp($_);
# #       }

# #       $v = Kynetx::JavaScript::eval_datasource($req_info,
# # 						  $rule_env,
# # 						  $session,
# # 						  $rule_name,
# # 						  $cond->{'source'},
# # 						  $cond->{'predicate'},
# # 						  $den
# # 						 );
	
# #       $logger->debug("[predicate] ", $cond->{'source'}, ":", $cond->{'predicate'}, " -> ", $v);

# #       $v ||= 0;

# #     } elsif($cond->{'type'} eq 'persistent_ineq') {
# # 	my $name = $cond->{'var'};

# # 	# check count
# # 	my $count = 0;
# # 	if($cond->{'domain'} eq 'ent') {
# # 	    $count = session_get($req_info->{'rid'}, $session, $name);
# # 	}

# # 	$logger->debug('[persistent_ineq] ', "$name -> $count");

# # 	$v = ineq_test($cond->{'ineq'}, 
# # 		       $count, 
# # 		       Kynetx::Expressions::den_to_exp(
# # 			   Kynetx::Expressions::eval_expr($cond->{'expr'}, 
# # 					$rule_env, 
# # 					$rule_name, 
# # 					$req_info, 
# # 					$session))
# # 	    );


# # 	# check date, if needed
# # 	if($v && 
# # 	   defined $cond->{'within'} &&
# # 	   session_defined($req_info->{'rid'}, $session, $name)) {

# # 	    my $tv = 1;
# # 	    if($cond->{'domain'} eq 'ent') {
# # 		$tv = session_within($req_info->{'rid'}, 
# # 				     $session, 
# # 				     $name, 
# # 				     Kynetx::Expressions::den_to_exp(
# # 					 Kynetx::Expressions::eval_expr($cond->{'within'},
# # 						      $rule_env, 
# # 						      $rule_name, 
# # 						      $req_info, 
# # 						      $session)),
# # 				     $cond->{'timeframe'}
# # 		    )
# # 	    }

# # 	    $v = $v && $tv;
# # 	}
# #     } elsif($cond->{'type'} eq 'seen_timeframe') {
# # 	my $name = $cond->{'var'};

# # 	$logger->debug('[seen_timeframe] ', "$name");

# # 	# check date, if needed
# # 	if(defined $cond->{'within'} &&
# # 	   session_defined($req_info->{'rid'}, $session, $name)) {

# # 	    if($cond->{'domain'} eq 'ent') {
# # 		$v = session_seen_within($req_info->{'rid'}, 
# # 					 $session, 
# # 					 $name, 
# # 					 $cond->{'regexp'},
# # 					 Kynetx::Expressions::den_to_exp(
# # 					  Kynetx::Expressions::eval_expr($cond->{'within'},
# # 						       $rule_env, 
# # 						       $rule_name, 
# # 						       $req_info, 
# # 						       $session)),
# # 					  $cond->{'timeframe'}
# # 		    )
# # 	    }
# # 	} elsif(session_defined($req_info->{'rid'}, $session, $name)) {
# # 	    if($cond->{'domain'} eq 'ent') {
# # 		# session_seen returns index (which can be 0)
# # 		$v = defined session_seen($req_info->{'rid'}, 
# # 				  $session, 
# # 				  $name, 
# # 				  $cond->{'regexp'}
# # 		    ) ? 1 : 0;
# # 	    }
# # 	}
# #     } elsif($cond->{'type'} eq 'seen_compare') {
# # 	my $name = $cond->{'var'};
# # 	if($cond->{'domain'} eq 'ent') {
# # 	    my($r1,$r2) =
# # 		$cond->{'op'} eq 'after' ? ($cond->{'regexp_1'},
# # 					    $cond->{'regexp_2'})
# #                                          : ($cond->{'regexp_2'},
# # 					    $cond->{'regexp_1'});
# # 	    $v = session_seen_compare($req_info->{'rid'}, 
# # 				      $session, 
# # 				      $name, 
# # 				      $r1,
# # 				      $r2
# # 		) ? 1 : 0; # ensure 0 returned for testing
# # 	}
# #     } elsif($cond->{'type'} eq 'persistent') {
# # 	my $name = $cond->{'name'};
# # 	if($cond->{'domain'} eq 'ent') {
# # 	    $v = session_defined($req_info->{'rid'}, $session, $name) &&
# # 		session_get($req_info->{'rid'}, $session, $name);
	    
# # 	}
# #       }



#     # returns default value if nothing returned above

#     }
#     return $v;
#   }

# # sub eval_pred {
# #     my($req_info, $rule_env, $session, $pred, $rule_name) = @_;

# #     my $logger = get_logger();

# # #    $logger->debug("[eval_pred] ", Dumper $pred);

# #     my @results = 
# # 	map {eval_predicates(
# # 		 $req_info, $rule_env, $session, 
# # 		 $_, $rule_name) } @{ $pred->{'args'} };

    

# # #    $logger->debug("[eval_pred] Rand values: ", Dumper @results);

# #     $logger->debug("Complex predicate: ", $pred->{'op'});

# #     if($pred->{'op'} eq '&&') {
# # 	my $val = shift @results;
# # 	for (@results) {
# # 	    $val = $val && $_;
# # 	}
# # 	return $val;

# #     } elsif($pred->{'op'} eq '||') {
# # 	my $val = shift @results;
# # 	for (@results) {
# # 	    $val = $val || $_;
# # 	}
# # 	return $val;
# #     } elsif($pred->{'op'} eq 'negation') {
# # 	return 
# # 	    not $results[0];
# #     } else {
# # 	$logger->warn("Invalid predicate");
# #     }
# #     return 0;

# # }

# # sub eval_ineq {
# #     my($req_info, $rule_env, $session, $pred, $rule_name) = @_;

# #     my $logger = get_logger();

# #     my @results;
# #     for (@{ $pred->{'args'} }) {
# # 	my $den = Kynetx::Expressions::eval_expr($_, $rule_env, $rule_name, $req_info, $session);
# # #	$logger->debug("Denoted -> ", sub { Dumper($den) });
# # 	push @results, Kynetx::Expressions::den_to_exp($den);
# #     }

# #     return ineq_test($pred->{'op'}, $results[0], $results[1]);
	
# # }


# # sub ineq_test {
# #     my($op, $rand0, $rand1) = @_;

# #     my $logger = get_logger();
# # #    $logger->debug("[ineq_test] $rand0 $op $rand1");

# #     if ($op eq '<=') {
# # 	return $rand0 <= $rand1;
# #     } elsif($op eq '>=') {
# # 	return $rand0 >= $rand1;
# #     } elsif($op eq '<') {
# # 	return $rand0 < $rand1;
# #     } elsif($op eq '>') {
# # 	return $rand0 > $rand1;
# #     } elsif($op eq '==') {
# # 	return $rand0 == $rand1;
# #     } elsif($op eq '!=') {
# # 	return $rand0 != $rand1;
# #     } elsif($op eq 'neq') {
# # 	    return ! ($rand0 eq $rand1);
# #     } elsif($op eq 'eq') {
# # 	return $rand0 eq $rand1;
# #     } elsif($op eq 'like') {

# #       # Note: this relies on the fact that a regular expression looks like a string inside 
# #       # the KRL AST.

# #       # for backward compatibility, make strings look like KRL regexp
# #       $rand1 = "/$rand1/" unless $rand1 =~ m#^/[^/]+/#;

# #       # FIXME: This is code that should be shared with replace in Operators.pm


# #       my $pattern = '';
# #       my $modifiers;
# #       ($pattern, $modifiers) = $rand1 =~ m#/(.+)/(i|g){0,2}#; 

# #       $modifiers = $modifiers || '';

# #       my $embedable_modifiers = $modifiers;
# #       $embedable_modifiers =~ s/g//;

# #       my $re = qr/(?$embedable_modifiers)$pattern/;
# # #	my $re = qr!$rand1!;

# #       $logger->debug("Matching string $rand0 with $pattern & modifiers $modifiers: $re");

# #       # g modifier does nothing here...
# #       return $rand0 =~ /$re/;

# #     }
# # }

1;
