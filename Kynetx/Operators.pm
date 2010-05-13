package Kynetx::Operators;
# file: Kynetx/Operators.pm
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
use Data::Dumper;
use Storable qw(dclone);

use Kynetx::Expressions;
use Kynetx::JSONPath ;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
eval_pick
eval_length
eval_operator
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my $funcs = {};

sub eval_pick {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();

    $logger->trace("expr: ", sub { Dumper($expr)});
    $logger->trace("[pick] rule_env: ", sub { Dumper($rule_env) });

    my $int = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);
    # if you don't clone this, it modified the rule env 

    my $obj = Kynetx::Expressions::den_to_exp(dclone($int));
   $logger->trace("[pick] obj: ", sub { Dumper($obj) });
    
    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);

    my $pattern = '';
    if($rands->[0]->{'type'} eq 'str') {
	$pattern = $rands->[0]->{'val'}
    } else {
	$logger->warn("WARNING: pattern argument to pick not a string");
    }
    $logger->trace("pattern: ", $pattern);


    my $jp = Kynetx::JSONPath->new();
    my $v = $jp->run($obj, $pattern);

#    $logger->debug("[pick] obj after processing pick: ", sub { Dumper($obj) });

#    $logger->debug("[pick] Rule env after: ", sub { Dumper($rule_env) });


    $v = $v->[0] if(defined $v && ref $v eq 'ARRAY' && int(@{ $v }) == 1);

    $logger->debug("pick using $pattern"); # returning ", Dumper($v));

    return Kynetx::Expressions::typed_value($v);
}
$funcs->{'pick'} = \&eval_pick;

#-----------------------------------------------------------------------------------
# array operators
#-----------------------------------------------------------------------------------

sub eval_length {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#    $logger->debug("obj: ", sub { Dumper($obj) });

    my $v = 0;
    if ($obj->{'type'} eq 'array') {
	$v = @{ $obj->{'val'} } + 0;
    } else {
      $logger->debug("length used in non-array context");
    }

    return Kynetx::Expressions::typed_value($v);
}
$funcs->{'length'} = \&eval_length;

sub eval_head {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#    $logger->debug("obj: ", sub { Dumper($obj) });

    my $v = 0;
    if ($obj->{'type'} eq 'array') {
	$v =$obj->{'val'}->[0];
    } else {
      $logger->debug("head used in non-array context");
    }

    return Kynetx::Expressions::typed_value($v);
}
$funcs->{'head'} = \&eval_head;

sub eval_tail {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#    $logger->debug("obj: ", sub { Dumper($obj) });

    my $v = 0;
    if ($obj->{'type'} eq 'array') {
      my @a = @{$obj->{'val'}};
      shift @a;
      $v = \@a;
    } else {
      $logger->debug("tail used in non-array context");
    }

    return Kynetx::Expressions::typed_value($v);
}
$funcs->{'tail'} = \&eval_tail;


sub eval_sort {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    
    my $obj = 
      Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#    $logger->debug("obj: ", sub { Dumper($obj) });

    my $v = 0;
    if ($obj->{'type'} eq 'array') {
      

      my $eval = Kynetx::Expressions::den_to_exp($obj);

      my $dval = Kynetx::Expressions::eval_expr($expr->{'args'}->[0], $rule_env, $rule_name,$req_info, $session) if (int(@{$expr->{'args'}}) > 0);
      
      if (defined $dval && Kynetx::Expressions::den_to_exp($dval) eq 'reverse') {
	my @a = sort {$b cmp $a} @{$eval};
	$v = \@a;
      } elsif (defined $dval && Kynetx::Expressions::type_of($dval) eq 'closure') {


	my @a = sort {
	  my $app = {'type' => 'app',
		     'function_expr' => $expr->{'args'}->[0],
		     'args' => [Kynetx::Expressions::typed_value($a),
				Kynetx::Expressions::typed_value($b)]};
	 
	  my $r = Kynetx::Expressions::den_to_exp(
	    Kynetx::Expressions::eval_application($app,
						  $rule_env,
						  $rule_name,
						  $req_info,
						  $session));

#	  $logger->debug("Sort function returned ",Dumper $r);

	  return $r;


	} @{$eval};
	
	$v = \@a;
	
#	$logger->debug("Array after sort ",Dumper $v);

						    

      } else {
	my @a = sort {$a cmp $b} @{$eval};
#        $logger->debug("Array after sorting ",Dumper @a);
	$v = \@a;
      }
	
    } else {
      $logger->debug("sort used in non-array context");
    }
      
    return Kynetx::Expressions::typed_value($v);

}
$funcs->{'sort'} = \&eval_sort;

sub eval_filter {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    
    my $obj = 
      Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#    $logger->debug("obj: ", sub { Dumper($obj) });

    my $v = 0;
    if ($obj->{'type'} eq 'array' && int(@{$expr->{'args'}}) > 0) {

      my $eval = Kynetx::Expressions::den_to_exp($obj);

      my $dval = Kynetx::Expressions::eval_expr($expr->{'args'}->[0], $rule_env, $rule_name,$req_info, $session);
      
      if (Kynetx::Expressions::type_of($dval) eq 'closure') {


	my $a = [];
	foreach my $av (@{$eval}) {

	  my $app = {'type' => 'app',
		     'function_expr' => $expr->{'args'}->[0],
		     'args' => [Kynetx::Expressions::typed_value($av)]};
	 
	  my $r = Kynetx::Expressions::den_to_exp(
	    Kynetx::Expressions::eval_application($app,
						  $rule_env,
						  $rule_name,
						  $req_info,
						  $session));

	  push(@{$a}, $av) if $r;

	}
	
	$v = $a;
	
#	$logger->debug("Array after sort ",Dumper $v);
					    

      } else {
	$logger->debug("filter used with non-function argument");
      }
    } else {
      $logger->debug("filter used in non-array context or without argument");
    }
      
    return Kynetx::Expressions::typed_value($v);

}
$funcs->{'filter'} = \&eval_filter;

sub eval_map {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    
    my $obj = 
      Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#    $logger->debug("obj: ", sub { Dumper($obj) });

    my $v = 0;
    if ($obj->{'type'} eq 'array' && int(@{$expr->{'args'}}) > 0) {

      my $eval = Kynetx::Expressions::den_to_exp($obj);

      my $dval = Kynetx::Expressions::eval_expr($expr->{'args'}->[0], $rule_env, $rule_name,$req_info, $session);
      
      if (Kynetx::Expressions::type_of($dval) eq 'closure') {


	my $a = [];
	foreach my $av (@{$eval}) {

	  my $app = {'type' => 'app',
		     'function_expr' => $expr->{'args'}->[0],
		     'args' => [Kynetx::Expressions::typed_value($av)]};
	 
	  my $r = Kynetx::Expressions::den_to_exp(
	    Kynetx::Expressions::eval_application($app,
						  $rule_env,
						  $rule_name,
						  $req_info,
						  $session));

	  push(@{$a}, $r);

	}
	
	$v = $a;
	
#	$logger->debug("Array after sort ",Dumper $v);
					    

      } else {
	$logger->debug("map used with non-function argument");
      }
    } else {
      $logger->debug("map used in non-array context or without argument");
    }
      
    return Kynetx::Expressions::typed_value($v);

}
$funcs->{'map'} = \&eval_map;

#-----------------------------------------------------------------------------------
# string operators
#-----------------------------------------------------------------------------------

sub eval_replace {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

    $logger->debug("obj: ", sub { Dumper($obj) });

    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
#    $logger->debug("obj: ", sub { Dumper($rands) });

    my $v = $obj->{'val'};

    if($obj->{'type'} eq 'str' && 
       $rands->[0]->{'type'} eq 'regexp' && 
       $rands->[1]->{'type'} eq 'str') {
    
	my $pattern = '';
	my $modifiers;
	($pattern, $modifiers) = $rands->[0]->{'val'} =~ m%[#/](.+)[#/](i|g){0,2}%; 

	$modifiers = $modifiers || '';

	my $embedable_modifiers = $modifiers;
	$embedable_modifiers =~ s/g//;

	my $re = qr/(?$embedable_modifiers)$pattern/;

	$logger->debug("Replacing string with $pattern & modifiers $modifiers: $re");

	# get capture vars first
	my @items = ( $v =~ $pattern ); 

	if($modifiers =~ m#g#) {
	  $v =~ s/$re/$rands->[1]->{'val'}/g;
 	} else {
	  $v =~ s/$re/$rands->[1]->{'val'}/;
 	}

	# now put capture vars in (this avoids evaling the replacement)
	for( reverse 0 .. $#items ){ 
	    my $n = $_ + 1; 
	    #  Many More Rules can go here, ie: \g matchers  and \{ } 
	    $v =~ s/\\$n/${items[$_]}/g ;
	    $v =~ s/\$$n/${items[$_]}/g ;
	}
      } else {
	$logger->warn("Not a regular expression: ", $rands->[0]->{'val'})
	  unless $rands->[0]->{'type'} eq 'regexp';
      }


    return { 'type' => Kynetx::Expressions::infer_type($v),
	      'val' => $v
    }
}
$funcs->{'replace'} = \&eval_replace;

sub eval_match {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#   $logger->debug("obj: ", sub { Dumper($obj) });

    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
#    $logger->debug("obj: ", sub { Dumper($rands) });

    my $v = $obj->{'val'};

    if($obj->{'type'} eq 'str' && 
       $rands->[0]->{'type'} eq 'regexp') {
    
	my $pattern = '';
	my $modifiers;
	($pattern, $modifiers) = $rands->[0]->{'val'} =~ m%[/#](.+)[/#](i|g){0,2}%; 

	$modifiers = $modifiers || '';

	my $embedable_modifiers = $modifiers;
	$embedable_modifiers =~ s/g//;

	my $re = qr/(?$embedable_modifiers)$pattern/;

	$logger->debug("Matching string with $pattern & modifiers $modifiers: $re");

	# get capture vars first
	my @items = ( $v =~ $pattern ); 

	if($modifiers =~ m#g#) {
	  $v = ($v =~ m/$re/g);
 	} else {
	  $v = ($v =~ m/$re/);
 	}
#	$logger->debug("Match at ", pos($v));

      } else {
	$logger->warn("Not a regular expression: ", $rands->[0]->{'val'})
	  unless $rands->[0]->{'type'} eq 'regexp';
      }


    if ($v) {
      return Kynetx::Expressions::mk_expr_node('bool','true');
    } else {
      return Kynetx::Expressions::mk_expr_node('bool','false');
    }
}
$funcs->{'match'} = \&eval_match;


sub eval_uc {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

    $logger->trace("obj: ", sub { Dumper($obj) });

    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
    $logger->trace("obj: ", sub { Dumper($rands) });

    if($obj->{'type'} eq 'str') {
        my $v = $obj->{'val'};
        $v = uc($v);
        $logger->debug("toUpper: ", $v);
        return Kynetx::Expressions::typed_value($v);
    } else {
        $logger->warn("Not a string");
    }
}
$funcs->{'uc'} = \&eval_uc;

sub eval_lc {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

    $logger->trace("obj: ", sub { Dumper($obj) });

    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);
    $logger->trace("obj: ", sub { Dumper($rands) });

    if($obj->{'type'} eq 'str') {
        my $v = $obj->{'val'};
        $v = lc($v);
        $logger->debug("toLower: ", $v);
        return Kynetx::Expressions::typed_value($v);
    } else {
        $logger->warn("Not a string");
    }
}
$funcs->{'lc'} = \&eval_lc;

#-----------------------------------------------------------------------------------
# casting
#-----------------------------------------------------------------------------------

sub eval_as {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

    my $rands = Kynetx::Expressions::eval_rands($expr->{'args'}, $rule_env, $rule_name,$req_info, $session);

    $logger->trace("obj: ", sub { Dumper($obj) }, " as ", $rands->[0]->{'val'} );

    my $v = 0;
    if ($obj->{'type'} eq 'str') {
      if ($rands->[0]->{'val'} eq 'num' || 
	  $rands->[0]->{'val'} eq 'regexp' ) {
	$obj->{'type'} = $rands->[0]->{'val'};
      }
    } elsif ($obj->{'type'} eq 'num') {
      if ($rands->[0]->{'val'} eq 'str' ) {
	$obj->{'type'} = $rands->[0]->{'val'};
      }
    } elsif ($obj->{'type'} eq 'regexp') {
      if ($rands->[0]->{'val'} eq 'str') {
	$obj->{'type'} = $rands->[0]->{'val'};
      }
    }


    return $obj;
}
$funcs->{'as'} = \&eval_as;


sub eval_toRegexp {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    my $obj = Kynetx::Expressions::eval_expr($expr->{'obj'}, $rule_env, $rule_name,$req_info, $session);

#    $logger->debug("obj: ", sub { Dumper($obj) });

    my $v = 0;
    if ($obj->{'type'} eq 'str') {
      $obj->{'type'} = 'regexp';
    }

    return $obj;
}
$funcs->{'toRegexp'} = \&eval_toRegexp;


#-----------------------------------------------------------------------------------
# make it all happen
#-----------------------------------------------------------------------------------

sub eval_operator {
    my ($expr, $rule_env, $rule_name, $req_info, $session) = @_;
    my $logger = get_logger();
    $logger->debug("eval_operator evaluation with op -> ", $expr->{'name'});
    my $f = $funcs->{$expr->{'name'}};
    return &$f($expr, $rule_env, $rule_name, $req_info, $session);
}

1;
