package Kynetx;
# file: Kynetx.pm

use strict;
use warnings;


use XML::XPath;
use LWP::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);
use Cache::Memcached;

use Kynetx::Rules qw(:all);;
use Kynetx::Util qw(:all);;
use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);


my $logger;
$logger = get_logger();

# Make this global so we can use memcache all over
our $memd;

if($logger->is_debug()) {

    use Data::Dumper;
}


my $s = Apache2::ServerUtil->server;

sub handler {
    my $r = shift;

    $r->content_type('text/javascript');
    
    my @host_array = $r->dir_config->get('memcached_hosts');

    if($r->dir_config('memcached_hosts')) {
	Kynetx::Memcached->init(\@host_array);
    }

    # at some point we need a better dispatch function
    if($r->path_info =~ m!/flush/! ) {
	flush_ruleset_cache($r);
    } else {
	process_rules($r);
    }

    return Apache2::Const::OK; 
}

1;






sub flush_ruleset_cache {
    my ($r) = @_;

    # nothing to do if no memcache hosts
    return unless $r->dir_config('memcached_hosts');

    my ($site) = $r->path_info =~ m#/(\d+)#;

    Log::Log4perl::MDC->put('site', $site);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...


    $logger->debug("[flush] flushing rules for $site");
    my $memd = get_memd();
    $memd->delete("ruleset:$site");

    $r->content_type('text/html');
    print "<h1>Rules flushed for site $site</h1>";

}



