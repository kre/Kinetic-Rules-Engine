package Kynetx::Memcached;
# file: Kynetx/Memcached.pm

use strict;
use warnings;

# for memcache config values
use lib qw(
/web/etc
);

use Log::Log4perl qw(get_logger :levels);
#use LWP::Simple qw(get);
use LWP::UserAgent;
use Kynetx::Configure;

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

    $MEMSERVERS = Kynetx::Configure::get_config('MEMCACHE_SERVERS');

    $logger->debug("Initializing memcached: ", join(" ", @{ $MEMSERVERS }));

    # don't set compress threshold.  Compression uses MemGzip which doesn't 
    # handle UTF chars correctly.  
    $MEMD = new Cache::Memcached {
	'servers' => $MEMSERVERS,
	'debug' => 0
    };
    $MEMD->enable_compress(0);

}


sub get_memd {
    return $MEMD;
}

sub get_memcached_servers {
    return join(" ", $MEMSERVERS);
}


sub get_remote_data {
    my($url,$expire) = @_;

    $expire = 10 * 60 if (! $expire); # twenty minutes

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

    my $ua = LWP::UserAgent->new;
    $ua->agent("Kynetx Rule Engine/1.0");

    my $req = HTTP::Request->new(GET => $url);
    my $res = $ua->request($req);

    if($res->is_success) {
	$content = $res->decoded_content;
    } else {
	$content = '';
	$logger->debug("Error retrieving $url: " . $res->status_line . "\n");
    }

    if($memd && $res->is_success) {
	$logger->debug("Caching data for $url for $expire seconds");
	$memd->set($key,$content,$expire);
    }

    return $content;

}

# FIXME: probably ought to refactor this and previous function to use a common core
sub get_cached_file {
    my($filepath,$expire) = @_;

    $expire = 60 * 60 if (! $expire); #   one hour

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

