package Kynetx::Util;
# file: Kynetx/Util.pm
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
use utf8;
use lib qw(/web/lib/perl);

use Log::Log4perl qw(get_logger :levels);
use Log::Log4perl::Level;
use Log::Log4perl::Appender::ErrorStack;

use Kynetx::Memcached qw(:all);
use URI::Escape ('uri_escape_utf8');
use Sys::Hostname;
use Data::Dumper;
use Data::Diver qw(
	DiveVal
	DiveRef
);
use Math::Combinatorics qw(combine);
use Storable qw(dclone);
use Encode qw(
	encode
	decode
);
use Kynetx::Configure;

use Kynetx::Persistence::KEN;

# FIXME: hard coded path
if (-e "/web/etc/amazon_credentials.pm") {
  require Kynetx::Predicates::Amazon::SNS;
  Kynetx::Predicates::Amazon::SNS->import;
  require Kynetx::Predicates::Amazon::RequestSignatureHelper;
  Kynetx::Predicates::Amazon::RequestSignatureHelper->import qw(
							     kAWSAccessKeyId
							     kAWSSecretKey
							  );
  require amazon_credentials;
  amazon_credentials->import qw(
			     get_key_id
			     get_access_key
			  );
}

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use constant BLOVIATE => 'arn:aws:sns:us-east-1:791773988531:SAM';

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [
qw(
reduce
cdr
before_now
after_now
mk_created_session_name
config_logging
turn_on_logging
turn_off_logging
mk_url
end_slash
bloviate
sns_publish
str_in
str_out
body_to_hash
bin_reg
any_matrix
union
has
intersection
to_seconds
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;




# set up logging
sub config_logging {
    my ($r) = @_;
    # we can use the 'debug' config parameter to force detailed logging

    my $appender = Log::Log4perl::Appender->new(
	"Log::Dispatch::File",
	filename => "/web/logs/detail_log",
	mode     => "append",
        name     => "FileLogger"
	);

    my $logger = get_logger("Kynetx");

    $logger->add_appender($appender);

    # Layouts
#    my $layout =
#	Log::Log4perl::Layout::PatternLayout->new(
#	    "%d %p %F{1} %X{site} %X{rule} %m%n");
    my $layout =
    Log::Log4perl::Layout::PatternLayout->new(
        "%r %p %F{1} %X{site} %X{rule} %m%n");

    $appender->layout($layout);


    my $stack_key = Kynetx::Configure::get_config('ERRORSTACK_KEY');

    if (defined $stack_key) {
    # Layouts

      my $stack_level = Kynetx::Configure::get_config('ERRORSTACK_LEVEL') || 'WARN';
      my $trigger = sub {
                      my ($self, $params) = @_;
		      return $params->{'message'} =~ /__FLUSH__/;
		    };

      my $hostname = Sys::Hostname::hostname();
      my $es_layout =
	Log::Log4perl::Layout::PatternLayout->new(
	    "<b>$hostname</b> %d %p %F{1} %X{site} <em>%X{rule}</em> <code>%m%n</code>");
      my $es_appender = Log::Log4perl::Appender->new(
						     "Log::Log4perl::Appender::ErrorStack",
						     name => 'ErrorStack',
						     key => $stack_key,
						     level => $stack_level,
						     trigger => $trigger
						    );
      $es_appender->layout($es_layout);
      $logger->add_appender($es_appender);
    }


    my $mode = Kynetx::Configure::get_config('RUN_MODE');
    my $debug = Kynetx::Configure::get_config('DEBUG');
    if($mode eq 'development' || $debug eq 'on') {
      $logger->level($DEBUG);
    } elsif($mode eq 'production') {
      $logger->level($WARN);
    }

}


sub turn_on_logging {

    my $logger = get_logger('Kynetx');

    # match any newline not at the end of the string
    my $re = qr%\n(?!$)%;
    my $appender = Log::Log4perl::Appender->new(
	"Log::Dispatch::Screen",
	stderr => 0,
	name => "ConsoleLogger",
	callbacks => sub{my (%h) = @_;
			 $h{'message'} =~ s%$re%\n//%gs;
			 return $h{'message'};
	}
	);


    $logger->add_appender($appender);

    # don't write detailed logs unless we're already in debug mode
    $logger->remove_appender('FileLogger') unless $logger->is_debug();
    $logger->level($DEBUG);

    # Layouts
    my $layout =
	Log::Log4perl::Layout::PatternLayout->new(
	    "// %d %p %F{1} %X{site} %X{rule} %m%n"
	);
    $appender->layout($layout);

}

sub turn_off_logging {
    my $logger = get_logger('Kynetx');
    # this is cheating.  Removing an appender that doesn't exist
    # causes an error.  This traps it
    eval {
      $logger->remove_appender('ConsoleLogger');
    }
}



# takes a counter name and makes a uniform session var name from it
sub mk_created_session_name {
    my $name = shift;
    return $name.'_created';
}

# From HOP
# reduce(sub { $a + $b }, @VALUES)
sub reduce (&@) {
    my $code = shift;
    my $val = shift;
    for (@_) {
	local($a, $b) = ($val, $_);
	$val = $code->($val, $_);
    }
    return $val;
}


sub cdr { shift; @_ }

sub before_now {
    my $desired = shift;

    my $now = DateTime->now;

    my $ans = DateTime->compare($now,$desired);

#    my $logger = get_logger();
#    $logger->debug("[before_now] is $now  after $desired: $ans" );

    # 1 if first greater than second
    return $ans == 1;

}


sub after_now {
    my $desired = shift;

    # ensure consistently get 0 or 1 for testing
    return before_now($desired) ? 0 : 1;

}

sub from_pairs {
	my ($pairs) = @_;
	my $logger = get_logger();
	my $parm = {};
	if (ref $pairs ne "ARRAY") {
		$logger->warn("Expecting array of k/v pairs");
	}
	foreach my $kv_pair (@$pairs) {
		my ($k,$v) = split(/=/,$kv_pair);
		if (defined $k && defined $v) {
			$v =~ s/(^"|"$)//g;
			$parm->{$k} = $v;
		}
	}
	return $parm;
}

sub mk_url {
  my ($base_url, $url_options) = @_;

  my $params = join('&', map("$_=".uri_escape_utf8($url_options->{$_}), keys %{ $url_options }));
  if (! defined $params) {
  	return $base_url;
  }
  if ($base_url =~ m/\?$/) {
    return $base_url . $params;
  } elsif ($base_url =~ m/\?/) {
    return $base_url . '&' . $params;
  } else {
    return $base_url . '?' . $params;
  }


#  $base_url .= join('&', map("$_=".uri_escape($url_options->{$_}), keys %{ $url_options }));


  return $base_url;
}

sub end_slash {
    my ($url_str)= @_;
    my $logger = get_logger();
    $url_str =~ /.+(\/)$/g;
    if (not defined $1 or $1 eq 'web') {
        $url_str = $url_str . '/';
    }
    return $url_str;
}

sub page_dump {
    my $r = shift;
    my $req_info = shift;
    my $session = shift;
    my @remainder = @_;
    $r->content_type('text/plain');
    print "r: ";
    print "\nr.args: ", $r->args();
    print "\nr.unparsed_uri: ", $r->unparsed_uri;
    print "\nr.uri: ", $r->uri;
    print "\nr.user: ", $r->user;
    print "\nr.status: ", $r->status;
    print "\nr.the_request: ", $r->the_request();
    print "\nr.notes: ", sub {Dumper($r->pnotes)};
    print "\nreq_info: ", Dumper($req_info);
    print "\nsession: ", Dumper($session);
    foreach my $element (@remainder) {
        print "----->", Dumper($element);
    }

}

sub request_dump {
    my $r = shift;
    my $data;
    my $howmuch = $r->bytes_sent() || 2000;
    my $req = Apache2::Request->new($r);
    #my $req_info = Kynetx::Request::build_request_env($r, "none","rugby");
    $r->read($data,$howmuch);
    my $logger = get_logger();
    $logger->debug("R: ", sub {Dumper($r)});
    $logger->debug("R.main: ", sub {Dumper($r->main())});
    $logger->debug("R.ct: ", sub {Dumper($r->content_type())});
    $logger->debug("R.filename: ", sub {Dumper($r->filename())});
    $logger->debug("R.headers_in: ", sub {Dumper($r->headers_in())});
    $logger->debug( "request: ");
    $logger->debug( "r.method: ",$req->method);
    $logger->debug( "r.path_info: ",$req->path_info);
    $logger->debug( "r.args: ", $req->args());
    $logger->debug( "r.unparsed_uri: ", $req->unparsed_uri);
    $logger->debug( "r.uri: ", $req->uri);
    $logger->debug( "r.user: ", $req->user);
    $logger->debug( "r.status: ", $req->status);
    $logger->debug( "r.the_request: ", $req->the_request());
    $logger->debug( "r.notes: ", sub {Dumper($req->pnotes)});
    $logger->debug( "r.subprocess_env: ", sub {Dumper($req->subprocess_env)});
    $logger->debug("param: ", sub {Dumper($req->param())});
    $logger->debug("R.status: ", sub {Dumper($req->body_status())});
    $logger->debug("body: ", sub {Dumper($req->body())});
    $logger->debug("body-token: ", sub {Dumper($req->body("Token"))});
    $logger->debug("Data: ", $data);

}

sub validate_array {
    my ( $val, $arry ) = @_;
    my $logger = get_logger();
    my %found;
    map { $found{$_} = 1 } @$arry;
    if ( $found{$val} ) {
        return $val;
    } else {
        return undef;
    }
}

sub validate_qstring {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( defined $arg ) {
        return uri_escape($arg);
    } else {
        return undef;
    }
}

sub validate_nospace {
    my ($arg,$replace) = @_;
    my $logger = get_logger();
    if ( defined $arg ) {
        $arg =~ s/\s/$replace/g;
        return uri_escape($arg);
    } else {
        return undef;
    }

}

sub validate_boolean {
    my ($arg) = @_;
    if ( defined $arg ) {
        if ( lc($arg) eq 'true' ) {
            return 'true';
        } else {
            return 'false';
        }
    } else {
        return undef;
    }
}

sub validate_timestamp {
    my ($arg)  = @_;
    my $logger = get_logger();
    my $f      = DateTime::Format::RFC3339->new();
    my $dt     = DateTime::Format::ISO8601->parse_datetime($arg);
    if ( defined $arg ) {
        my $ts = $f->format_datetime($dt);
        $logger->debug("Validate: ", $ts);
        return $ts;
    } else {
        return undef;
    }
}

sub validate_int {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( $arg =~ m/^\d+/ ) {
        return $arg;
    } else {
        return undef;
    }

}

sub validate_ord {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( defined validate_int($arg) && $arg >= 1 ) {
        return $arg;
    } else {
        return undef;
    }
}

sub validate_card {
    my ($arg) = @_;
    my $logger = get_logger();
    if ( defined validate_int($arg) && $arg >= 0 ) {
        return $arg;
    } else {
        return undef;
    }
}

sub get_arg_hash {
    my ($args) = @_;
    if ( ref $args eq 'ARRAY' ) {
        foreach my $element (@$args) {
            if ( ref $element eq 'HASH' ) {
                return $element;
            }
        }
    }
}

# Decode an input string
sub str_in {
	my ($istr) = @_;
	my $dstr;
	my $logger = get_logger();	
	my $struct = ref $istr;
	if ($struct ne "") {
		$logger->debug("Attempt to UTF-8 encode non-string ($struct)")
	}
	eval {
		$dstr = Encode::decode("UTF-8",$istr);
	};
	if ($@) {
		$logger->debug("Source string not UTF-8 encoded");
		$dstr = $istr;
	}
	return $dstr;
	
}

# Ensure UTF-8 encodings for outbound communications
sub str_out {
	my ($ostr) = @_;
	return Encode::encode("UTF-8",$ostr);
}

sub get_params {
    my ( $args, $params, $defaults ) = @_;
    my $logger        = get_logger();
    my $passed_params = get_arg_hash($args);
    $logger->trace( "default params: ", sub { Dumper($defaults) } );
    $logger->trace( "passed params: ",  sub { Dumper($passed_params) } );
    foreach my $key ( keys %$defaults ) {
        if ( defined $passed_params->{$key} ) {
            my $val = undef;
            if ( ref $defaults->{$key} eq 'ARRAY' ) {
                 $val =
                  validate_array( $passed_params->{$key}, $defaults->{$key} );
            } elsif ( $defaults->{$key} =~ m/<(\w+)>/ ) {
                my $match = $1 || "";
              case: for ($match) {
                    /qstring/ && do {
                        $val = validate_qstring( $passed_params->{$key} );
                    };
                    /_string/ && do {
                        $val = validate_nospace( $passed_params->{$key} );
                    };
                    /timestamp/ && do {
                        $val = validate_timestamp( $passed_params->{$key} );
                    };
                    /bool/ && do {
                        $val = validate_boolean( $passed_params->{$key} );
                    };
                    /int/ && do {
                        $val = validate_int( $passed_params->{$key} );
                    };
                    /ord/ && do {
                        $val = validate_ord( $passed_params->{$key} );
                    };
                    /card/ && do {
                        $val = validate_card( $passed_params->{$key} );
                    };

                }
            }
            $logger->trace( "returned: ", $val );
            if ( defined $val ) {
                $params->{$key} = $val;
            }
        } else {
            my $dvalue = default_value($key);
            if ($dvalue) {
                $params->{$key} = $dvalue;
            }
        }
    }
    return $params;

}

sub default_value {
    my ($var,$config,$namespace)    = @_;
    my $logger   = get_logger();
    my $defaults = $config->{'default'};
    my $val      = $defaults->{$var};
    if ($val) {
        $logger->debug( "using default value ($val) for: ", $var );
        return $val;
    } else {
        return undef;
    }

}

sub get_hostname {
   return hostname || "No hostname found";
 }

sub bloviate {
    my ($message) = @_;
    my $logger = get_logger();
    my $directive = Kynetx::Directives->new("log");
    my $host = get_hostname();
    my $timestamp = DateTime->now;
    my $options = {
        'data' => $message,
        'source' => $host
    };
    $directive->set_options($options);
    my $json = Kynetx::Json::astToJson( $directive->to_directive() );
    my $param = {
        'Subject' => "KNS logging request $timestamp",
        'TopicArn' => BLOVIATE,
        'Message' => $json,
    };
    $logger->info("KNS logging request: ", $message);

}

sub sns_publish {
    my ($hash) = @_;
    my $key    = get_key_id();
    my $secret = get_access_key();
    $hash->{kAWSAccessKeyId()} = $key;
    $hash->{kAWSSecretKey()} = $secret;
    my $sns = Kynetx::Predicates::Amazon::SNS->new($hash);
    $sns->publish();
}

sub body_to_hash {
	my ($str) = @_;
	my $ret = {};
	my @parts = split(/&/,$str);
	foreach my $kvpair (@parts) {
		my ($k,$v) = split(/=/,$kvpair);
		$ret->{$k} = $v;
	}
	return $ret;
}

sub hash_to_elements {
	my ($hash, $ancestors) = @_;
	my $logger = get_logger();
	my @elements = ();
	if (ref $hash eq "HASH") {
		foreach my $key (keys %$hash) {
			my $acopy;
			if (defined $ancestors) {
				$acopy = dclone $ancestors;
			} else {
				$acopy = ();
			}
			push(@$acopy,$key);
			my $val = hash_to_elements($hash->{$key},$acopy);
			if (ref $val eq 'HASH') {
				push(@elements,$val);
			} elsif (ref $val eq 'ARRAY') {
				@elements = (@elements,@$val);
			}
			
		}
		return \@elements;
	} else {
		my $struct = {
			'ancestors' => $ancestors,
			'value' => $hash
		};
		return $struct;
	}
}

sub elements_to_hash {
	my ($array_of_elements) = @_;
	my $logger = get_logger();
	my $hash = {};
	foreach my $element (@$array_of_elements) {
		my $value = $element->{'value'};
		my $path = $element->{'ancestors'};
		$logger->trace("Val: ", $value);
#		_set_path($path,$value,$hash);
		DiveVal($hash, @$path) = $value;
	}
	return $hash;
}

sub normalize_path {
	my ($req_info, $rule_env, $rule_name, $session, $path) = @_;
	my $logger = get_logger();
	my @normalized = ();
	return undef unless (defined $path);
	if ($path->{'type'} eq "array") {
		foreach my $element (@{$path->{'val'}}) {
			my $norm_key = Kynetx::Expressions::den_to_exp(
			   	Kynetx::Expressions::eval_expr($element,
					$rule_env,
				    $rule_name,
				    $req_info,
				    $session) );
			push(@normalized,$norm_key);
		}
	} else {
		my $norm_key = Kynetx::Expressions::den_to_exp(
			Kynetx::Expressions::eval_expr($path,
				$rule_env,
				$rule_name,
				$req_info,
				$session) );
		push(@normalized,$norm_key);
	} 	
	return \@normalized;
	
	
}

# converts a string to a perl regexp which
# is valid in /$reg/ constructs
sub bin_reg {
	my ($reg_string) = @_;
	my $logger = get_logger();
	my $re = undef;
    if ($reg_string =~ m/^#.+#$/ ) {
    	my $composed = "qr$reg_string";
    	$re = eval $composed;
    	if ($@) {
    		$logger->warn("Unable to compile $reg_string as regexp");
    		return undef;
    	}    	
    } else {
    	$re = qr/$reg_string/;
    }
	return $re;
	
}

sub any_matrix {
	my ($n, $k) = @_;
	my $logger = get_logger();
	# check memcached for 
	my @n = ();
	for (my $i = 0; $i < $n; $i++) {
		push(@n,$i);
	}
	if ($k < $n) {
		my $hash = {};
		my @combos = Math::Combinatorics::combine($k, @n);
		#$logger->debug("Combos: ", sub {Dumper(@combos)});
		foreach my $element (@combos) {
			#$logger->debug(" combo: ", sub {Dumper($element)});
			my @permutes = Math::Combinatorics::permute(@{$element});
			foreach my $path (@permutes) {
				#$logger->debug("  p: ", sub {Dumper($path)});
				my $pstr = join(",",@$path);
				$hash->{$pstr} = $path;
			}			
		}
		#$logger->debug("Final: ", sub {Dumper($hash)});
		return values %{$hash};
	} elsif ($k == $n) {
		return Math::Combinatorics::permute(@n);
	} else {
		$logger->warn("Invalid permutation requested $k:$n");
	}
	
}

#----------------------------------------
# raw set operations
#----------------------------------------

sub union {
	my ($a, $b) = @_;
	my %hash;
    foreach (@{$a}) {
        $hash{$_}++;
    }
    foreach (@{$b}) {
        $hash{$_}++;
    }
    my @set = sort keys %hash;
	return @set;	
}

sub intersection {
	my ($a, $b) = @_;
	my %hash;
    foreach (@{$a}) {
        $hash{$_}++;
    }
    foreach (@{$b}) {
        $hash{$_}++;
    }
    my @set = grep {$hash{$_}>1} keys %hash;
    return @set;	
}

sub has {
	my ($a, $b) = @_;
    my $sub_set = scalar @{$b};
    my @x_set = intersection($a,$b);
    my $intr = scalar @x_set;
    return ($sub_set == $intr);	
}

sub to_seconds {
	my ($num,$period) = @_;
	my $seconds = 0;
	if ( $period eq 'years' ) {
		$seconds = $num * 60 * 60 * 24 * 365;
	} elsif ( $period eq 'months' ) {
		$seconds = $num * 60 * 60 * 24 * 30;
	} elsif ( $period eq 'weeks' ) {
		$seconds = $num * 60 * 60 * 24 * 7;
	} elsif ( $period eq 'days' ) {
		$seconds = $num * 60 * 60 * 24;
	} elsif ( $period eq 'hours' ) {
		$seconds = $num * 60 * 60;
	} elsif ( $period eq 'minutes' ) {
		$seconds = $num * 60;
	} elsif ( $period eq 'seconds' ) {
		$seconds = $num;
	}
	return $seconds;
}

1;
