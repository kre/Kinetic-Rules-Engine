package Kynetx::Util;
# file: Kynetx/Util.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use Log::Log4perl::Level;

use Kynetx::Memcached qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
reduce
before_now
after_now
mk_created_session_name
config_logging
turn_on_logging
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

    if($r->dir_config('run_mode') eq 'development' || 
       $r->dir_config('debug') eq 'on') {
	$logger->level($DEBUG);
    } elsif($r->dir_config('run_mode') eq 'production') {
	$logger->level($WARN);
    }

}

sub turn_on_logging {

    my $logger = get_logger('Kynetx');

    my $appender = Log::Log4perl::Appender->new(
         "Log::Dispatch::Screen",
         stderr => 0,
         name => "ConsoleLogger"
	);
     
    $logger->add_appender($appender);

    # don't write detailed logs unless we're already in debug mode
    $logger->remove_appender('FileLogger') unless $logger->is_debug();
    $logger->level($DEBUG);
    
    # Layouts
    my $layout = 
	Log::Log4perl::Layout::PatternLayout->new(
	    "// %d %p %F{1} %X{site} %X{rule} %m%n");
    $appender->layout($layout);

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


sub before_now {
    my $desired = shift;

    my $now = DateTime->now;

    # print("Comparing ", $now . " with " . $desired . "\n");

    # 1 if first greater than second
    return DateTime->compare($now,$desired) == 1;

}


sub after_now {
    my $desired = shift;

    return not before_now($desired);

}


