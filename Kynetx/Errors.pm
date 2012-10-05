package Kynetx::Errors;
# file: Kynetx/Errors.pm
# file: Kynetx/Predicates/Referers.pm
#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc. 
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
use strict;
#use warnings;

use Log::Log4perl qw(get_logger :levels);


use JSON::XS;
use Storable qw/dclone freeze/;
use Digest::MD5 qw/md5_hex/;
use Clone qw/clone/;

use Kynetx::Parser;
use Kynetx::Rids qw/:all/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# use constant ERROR_CALL_THRESHOLD => 5;

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

  # put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
			    qw(
			     ) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 0;

my $ERROR_RAISE_THRESHOLD = Kynetx::Configure::get_config('ERROR_RAISE_THRESHOLD') || 1;


sub raise_error {
  my ($req_info, $level, $errormsg, 
      $options
     ) = @_;
  my $logger = get_logger();

  my $sig = md5_hex(freeze($options||{}) . $errormsg);

  $req_info->{$sig} = 0
    unless defined $req_info->{$sig};

  $req_info->{$sig}++;

#  $logger->debug("*** $sig has value ", $req_info->{$sig}, " ***");

  $errormsg ||= "An unspecified error occured";
  $level ||= "debug";
  
  if ($errormsg =~ m/send_javascript/) {
  	return;
  }

  if ($req_info->{$sig} > $ERROR_RAISE_THRESHOLD) {
    $logger->error("Error threshold exceeded; not raising error event for $errormsg");
    return;
  }

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
     $rid = get_rid($req_info->{'rid'});
  }
  $logger->debug("Sending errors to $rid");

  # create an expression to pass to eval_raise_statement
  my $expr = {'type' => 'raise',
	      'domain' => 'system',
	      'ruleset' => {'val'=>$rid, 'type' => 'str'},
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
