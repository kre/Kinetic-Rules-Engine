package Kynetx::Util;
# file: Kynetx/Util.pm
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
use Log::Log4perl::Level;
use Log::Log4perl::Appender::ErrorStack;

use Kynetx::Memcached qw(:all);
use URI::Escape ('uri_escape');
use Sys::Hostname;
use Data::Dumper;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

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
merror
mis_error
end_slash
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
    my $layout =
	Log::Log4perl::Layout::PatternLayout->new(
	    "%d %p %F{1} %X{site} %X{rule} %m%n");

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

sub mk_url {
  my ($base_url, $url_options) = @_;

  my $params = join('&', map("$_=".uri_escape($url_options->{$_}), keys %{ $url_options }));

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


1;
