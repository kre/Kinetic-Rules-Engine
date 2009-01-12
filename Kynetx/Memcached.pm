package Kynetx::Memcached;
# file: Kynetx/Memcached.pm

use strict;
use warnings;

# for memcache config values
use lib qw(
/web/etc
);

use Log::Log4perl qw(get_logger :levels);
use memcache_ips;


use constant DEFAULT_MEMCACHED_PORT => '11211';

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
init
get_memd
get_memcached_servers
get_remote_data
get_cached_file
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

our $MEMD = 0;
our $MEMSERVERS = '127.0.0.1:' . DEFAULT_MEMCACHED_PORT;

sub init {
    my($class) = @_;

    my $logger = get_logger();

    my $hosts_array = memcache_ips::get_mcd_hosts();

    $logger->debug("Hosts: ", join " ", @{ $hosts_array });

    my @memd_hosts = map {$_ . ":" . memcache_ips::get_mcd_port() } @{ $hosts_array };

    $MEMSERVERS = join(" ", @memd_hosts);

    $logger->debug("Initializing memcached: ", $MEMSERVERS);

    $MEMD = new Cache::Memcached {
	'servers' => \@memd_hosts,
	'debug' => 0,
	'compress_threshold' => 10000,
    };
}


sub get_memd {
    return $MEMD;
}

sub get_memcached_servers {
    return $MEMSERVERS;
}


sub get_remote_data {
    my($url,$expire) = @_;

    $expire = 20 * 60 if (! $expire); # twenty minutes

    my $logger = get_logger();
    my $memd = get_memd();

    my $key = $url;

    my $content;
    if ($memd) {
        $content = $memd->get($key) ;
	if ($content) {
	    $logger->debug("Using cached data for $url");
	    return $content;
	}
    }

    $content = LWP::Simple::get($url);

    if($memd) {
	$logger->debug("Caching data for $url");
	$memd->set($key,$content,$expire);
    }

    return $content;

}

# FIXME: probably ought to refactor this and previous function to use a common core
sub get_cached_file {
    my($filepath,$expire) = @_;

    $expire = 20 * 60 if (! $expire); # twenty minutes

    my $logger = get_logger();
    my $memd = get_memd();

    my $key = $filepath;

    my $content;
    if ($memd) {
        $content = $memd->get($key) ;
	if ($content) {
	    $logger->debug("Using cached data for $filepath");
	    return $content;
	}
    }

    $content = read_file_contents($filepath);

    if($memd) {
	$logger->debug("Caching data for $filepath");
	$memd->set($key,$content,$expire);
    }

    return $content;

}

sub read_file_contents {

    my ($filepath) = @_;

    open(FOO, "< $filepath") ;
# || die "Can't open file $filepath: $!\n";

    # read it all at once
    local $/ = undef;
    my $contents = <FOO>;

    close FOO;
    return $contents;

}


1;

