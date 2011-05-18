package Kynetx::Errors;
# file: Kynetx/Errors.pm
# file: Kynetx/Predicates/Referers.pm
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


use Kynetx::Parser;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

  # put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
			    qw(
			     ) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


sub raise_error {
  my ($req_info, $level, $errormsg, 
      $options
     ) = @_;
  my $logger = get_logger();

  
  $errormsg ||= "An unspecified error occured";
  $level ||= "debug";

  my $genus = $options->{'genus'} || 'general';
  my $species = $options->{'species'} || 'general';

  my $rule_name = $options->{'rule_name'} || 'system';

  if ($level eq 'error') {
    $logger->error($errormsg);
  } elsif ($level eq 'warn') {
    $logger->warn($errormsg);
  } else {
    $logger->debug($errormsg);
  }


  # make modifiers in right form for raise expr
  my $ms = [];
  push( @{$ms}, 
	{'name' => 'genus',
	 'value' => mk_den_str($genus),
	}
      );
  push( @{$ms}, 
	{'name' => 'species',
	 'value' => mk_den_str($species),
	}
      );
  push( @{$ms}, 
	{'name' => 'msg',
	 'value' => mk_den_str($errormsg),
	}
      );

  push( @{$ms}, 
	{'name' => 'level',
	 'value' => mk_den_str($level),
	}
      );

  push( @{$ms}, 
	{'name' => 'rid',
	 'value' => mk_den_str($req_info->{'rid'}),
	}
      );

  push( @{$ms}, 
	{'name' => 'rule_name',
	 'value' => mk_den_str($rule_name),
	}
      );

  my $rid;
  if (defined $req_info->{'errorsto'}) {
    $rid = $req_info->{'errorsto'}->{'rid'};
    if (defined $req_info->{'errorsto'}->{'version'}) {
      $rid .= "." . $req_info->{'errorsto'}->{'version'};
    }
  } else {
     $rid = $req_info->{'rid'};
  }

  # create an expression to pass to eval_raise_statement
  my $expr = {'type' => 'raise',
	      'domain' => 'system',
	      'rid' => $rid,
	      'event' => Kynetx::Parser::mk_expr_node('str','error'),
	      'modifiers' => $ms
	     };

  my $rule_env = Kynetx::Environments::empty_rule_env();
  my $session = {"_session_id" => "31831839173918379131"};

  my $js .= Kynetx::Postlude::eval_raise_statement($expr,
						   $session,
						   $req_info,
						   $rule_env,
						   $rule_name);

  # special handling follows
  if ($errormsg =~ m/mongodb/i) {
    Kynetx::MongoDB::init();
    $logger->error("Caught MongoDB error, reset connection");
  }
}

sub merror {
    my ($e, $v, $private) = @_;
    my $msg='';
    my $tag;
    if ($private) {
        $tag = 'TRACE';
    } else {
        $tag = 'DEBUG';
    }
    if (ref $e eq 'HASH') {
        # Existing error hash
        $msg =  $v;
    } else {
        $msg = $e;
        $e = {'_error_' => 1};
        if ($v) {
            $tag = 'TRACE';
        } else {
            $tag = 'DEBUG';
        }

    }
    $e->{$tag} =  $msg . "\n" . ($e->{$tag} || '');

    return $e;
}


sub mis_error {
    my ($v) = @_;
    if (ref $v eq 'HASH' and $v->{'_error_'}) {
        return 1;
    } else {
        return 0;
    }
}


sub mk_den_str {
    my ($v) = @_;

    return {'type' => 'str',
	    'val' => $v}
}


1;
