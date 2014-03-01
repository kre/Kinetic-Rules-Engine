package Kynetx::Modules::This2That;
# file: Kynetx/Modules/This2That.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Kynetx::Util qw(ll);
use Kynetx::KTime;

use XML::XML2JSON;
use MIME::Base64 qw(
	encode_base64url
	decode_base64url
);
use Data::Diver qw( Dive DiveRef DiveError );

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
	get_predicates
	get_resources
	get_actions
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $predicates = {
};

my $default_actions = {
};



sub get_resources {
    return {};
}
sub get_actions {
    return $default_actions;
}
sub get_predicates {
    return $predicates;
}

my $funcs = {};



sub run_function {
    my($req_info, $function, $args) = @_;

    my $logger = get_logger();
    $logger->trace("Function:", sub {Dumper($function)});
    my $resp = undef;
    my $f = $funcs->{$function};
    if (defined $f) {
    	eval {
    		$resp = $f->( $req_info, $function, $args );
    	};
    	if ($@) {
    		$logger->warn("This2That error: $@");
    		return undef;
    	} else {
    		return $resp;
    	}
    } else {
    	$logger->debug("Function ($function) undefined in module This2That");
    }

    return $resp;
}

sub _xml2json {
	my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $xmlstring = $args->[0];
    my %init_mods;
    $init_mods{'module'} = "JSON::XS";
    if (defined $args->[1] && ref $args->[1] eq "HASH") {
    	my $opts = $args->[1];
    	if ($opts->{'pretty'}) {
    		$init_mods{'pretty'} = 1;
    	}
     	if ($opts->{'force_array'}) {
    		$init_mods{'force_array'} = 1;
    	}
    	if ($opts->{'attribute_prefix'}) {
    		$init_mods{'attribute_prefix'} = $opts->{'attribute_prefix'};
    	}
    	if ($opts->{'content_key'}) {
    		$init_mods{'content_key'} = $opts->{'content_key'};
    	}
    	if ($opts->{'private_elements'} && ref $opts->{'private_elements'} eq "ARRAY") {
    		$init_mods{'private_elements'} = $opts->{'private_elements'};
    	}
     	if ($opts->{'empty_elements'} && ref $opts->{'empty_elements'} eq "ARRAY") {
    		$init_mods{'empty_elements'} = $opts->{'empty_elements'};
    	}
     	if ($opts->{'private_attributes'} && ref $opts->{'private_attributes'} eq "ARRAY") {
    		$init_mods{'private_attributes'} = $opts->{'private_attributes'};
    	}
    	
    }
    my $t2t = XML::XML2JSON->new(%init_mods);
    if (defined $xmlstring && $xmlstring ne "") {
    	my $json = $t2t->convert($xmlstring);
    	if ($args->[1]->{'decode'}) {
    		my $obj = Kynetx::Json::jsonToAst_w($json);
    		return $obj;
    	}
    	return $json;
    }
    
    return undef;
}
$funcs->{'xml2json'} = \&_xml2json;

sub _string2base64 {
    my ($req_info, $function, $args) = @_;
    my $string = $args->[0];
    my $eol;
    if (defined $args->[1]) {
    	$eol = $args->[1];
    } else {
    	$eol = "";
    }
    return MIME::Base64::encode_base64($string,$eol);
}
$funcs->{'string2base64'} = \&_string2base64;
$funcs->{'encodeBase64'} = \&_string2base64;

sub _chr {
  my ($req_info, $function, $args) = @_;
  my $number = $args->[0];
  if ($number =~ m/^\d+$/) {
    return chr($number)        
  }
  return undef
}
$funcs->{'chr'} = \&_chr;

sub _ord {
  my ($req_info, $function, $args) = @_;
  my $string = $args->[0];
  if ($string) {
    return ord($string)        
  }
  return undef
}
$funcs->{'ord'} = \&_ord;

sub _pack {
  my ($req_info, $function, $args) = @_;
  my $charArray = $args->[0];
  return pack("C*",@{$charArray});
}
$funcs->{'pack'} = \&_pack;

sub _unpack {
  my ($req_info, $function, $args) = @_;
  my $string = $args->[0];
  my @array_of_ord =  unpack("C*",$string);
  return \@array_of_ord;
}
$funcs->{'unpack'} = \&_unpack;

sub _url2base64 {
    my ($req_info, $function, $args) = @_;
    my $string = $args->[0];
    my $eol;
    if (defined $args->[1]) {
    	$eol = $args->[1];
    } else {
    	$eol = "";
    }
    return MIME::Base64::encode_base64url($string,$eol);
}
$funcs->{'url2base64'} = \&_url2base64;



sub _cmp {
  my ($a, $b, $path,$constraint) = @_;
  my $logger = get_logger();
  $constraint ||= "";
  my $aVal = Dive($a,@{$path});
  my $bVal = Dive($b,@{$path});
  $logger->trace("A: $aVal B: $bVal");
  if (ref $constraint eq "HASH" && defined $constraint->{'compare'}  ) {
    if ($constraint->{'compare'} eq "numeric") {           # allow dev to force numeric sort
      $logger->trace("Numeric");
      return $aVal <=> $bVal
    } elsif ($constraint->{'compare'} eq "datetime") {
      $logger->trace("datetime");
      my $dtA;
      my $dtB;
      if (defined $constraint->{'date_format'}) {
        my $df = $constraint->{'date_format'};
        eval {
          $dtA = Kynetx::KTime->parse_datetime($aVal,$df);
          $dtB = Kynetx::KTime->parse_datetime($bVal,$df);
        };
        
      } else {
        eval {
          $dtA = Kynetx::KTime->parse_datetime($aVal);
          $dtB = Kynetx::KTime->parse_datetime($bVal);
        };
        
      }
      if ($@) {
        $logger->debug("Error. Using string comparison instead of datetime",$@);
        return $aVal cmp $bVal
      } else {
        return $dtA->epoch() <=> $dtB->epoch()
      }
    } elsif ($constraint->{'compare'} eq "string") {
      $logger->trace("string");
      return $aVal cmp $bVal
    } else {
      $logger->trace("default");
      return $aVal <=> $bVal ||          # NaN != NaN
             $aVal cmp $bVal
      
    }    
  } else {
      $logger->trace("default");
      return $aVal <=> $bVal ||          # NaN != NaN
             $aVal cmp $bVal
      
    }

  
}
sub _hash_transform {
  my ($req_info, $function, $args) = @_;
  my $logger = get_logger();
  my @sorted;
  my @index;
  my @values;
  my $obj = $args->[0];
  my $sort_ops = $args->[1]; 
  my $global_ops = $args->[2];
  
  if (ref $sort_ops eq "HASH") {
    # single sort param enclose in hash
    push(@index,$sort_ops);
  } elsif(ref $sort_ops eq "ARRAY") {
    @index = @{$sort_ops};
  }
  return undef unless (scalar @index >= 1);
  
  if (ref $obj eq "HASH") {
    @sorted = _hsort($obj,\@index);
  } elsif (ref $obj eq "ARRAY") {
    @sorted = _asort($obj,\
    @index);
  } else {
    return undef;
  }
  
  if (defined $global_ops->{'index'} || defined $global_ops->{'limit'}) {
    my @temp = @sorted;
    my $size = scalar @temp - 1;
    my $limit = $size;
    my $i = 0;
    
    if (defined $global_ops->{'limit'}) {
      $limit = $global_ops->{'limit'} -1;
    }
    
    if (defined $global_ops->{'index'}) {
      $i = $global_ops->{'index'}
    }
    
    my $j = $i + $limit;
    if ($j > $size) {
      $j = $size;
    }
    $logger->trace("indices:  $i .. $j");
    @sorted = @temp[$i .. $j];
  }
  $logger->trace("sort: ", sub {Dumper(@sorted)});
  return \@sorted;
}
$funcs->{'hash_transform'} = \&_hash_transform;
$funcs->{'transform'} = \&_hash_transform;

sub _recursive_sort {
  my ($a,$b,$opts) = @_;
  my $logger = get_logger();
  my @optsArray = @{$opts};
  
  my $c_opts = shift @optsArray;
  $logger->trace("Received options: ", sub {Dumper(@optsArray)});
  $logger->trace("Current options: ", sub {Dumper($c_opts)});
  my $path = $c_opts->{'path'};
  my $sort_direction = $c_opts->{'reverse'} ? -1 : 1;
  my $compare = _cmp($a,$b,$path,$c_opts);
  $compare *= $sort_direction;
  if ($compare == 0 && scalar @optsArray > 0) {
    return _recursive_sort($a,$b,\@optsArray)
  } else {
    return $compare;
  }
}

sub _asort {
  my ($obj,$opts) = @_;
  my $logger = get_logger();
  $logger->debug("array sort");
  return sort {                            
      _recursive_sort($a,$b,$opts);
    } @{$obj};
}

sub _hsort {
  my ($obj,$opts) = @_;
  my $logger = get_logger();
  $logger->debug("hash sort");

  # Schwartzian Transform
  my @sorted = map {
    $_->[1]                           # return the key only from [cmp_val, key]
  } sort {                            # sort based on cmp_val
    _recursive_sort($a->[0],$b->[0],$opts);      
  } map {
    [$obj->{$_},$_]                   # Construct a temp array of [cmp_val, key]
  } keys %{$obj};
  
  return @sorted;
}



sub _base642string {
    my ($req_info, $function, $args) = @_;
    my $string = $args->[0];
	return MIME::Base64::decode_base64($string);	
}
$funcs->{'base642string'} = \&_base642string;
$funcs->{'decodeBase64'} = \&_base642string;

sub _base642url {
    my ($req_info, $function, $args) = @_;
    my $string = $args->[0];
	return MIME::Base64::decode_base64url($string);	
}
$funcs->{'base642url'} = \&_base642url;


1;
