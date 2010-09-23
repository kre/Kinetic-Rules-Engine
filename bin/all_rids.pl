#!/usr/bin/perl -w

use strict;
use lib qw(/web/lib/perl);
use warnings;

use strict;

use LWP::Simple;
use LWP::UserAgent;
use HTTP::Request;
use Parallel::ForkManager;
use Getopt::Std;

use Kynetx::Configure;
Kynetx::Configure::configure();

my $host = Kynetx::Configure::get_config('KRL_HOST') || '127.0.0.1';
my $port = Kynetx::Configure::get_config('OAUTH_CALLBACK_PORT') || '8082';

# global options
use vars qw/ %opt /;
my $opt_string = 'hf:';
getopts( "$opt_string", \%opt );    # or &usage();
&usage() if $opt{'h'};

my $filename = "";
$filename = $opt{'f'};

print "Got $filename\n";

my @rids = getrids($filename);

foreach my $rid (@rids) {
    my $url = 'http://' . "$host:$port" . '/manage/perf/'.$rid;
    #print "Requesting: $url\n";
    print "$rid,production,";
    print request($url,'prod') . ",$url\n";
    print "$rid,development,";
    print request($url,'dev') . ",$url\n";

}

sub request {
    my ($url,$version) = @_;
    $url .= "/$version";
    my $href = HTTP::Request->new(GET => $url);
    my $ua = LWP::UserAgent->new;
    my $resp = $ua->simple_request($href);
    if ($resp->is_success) {
        return $resp->content;
    } else {
        return "Request failed: $url";
    }

}

sub getrids {
    my $filename = shift;
    open( KRL, "< $filename" ) || die "Can't open file $filename: $!\n";
    my @ridlist = ();
    while (<KRL>) {
        my $rid = $_;
        chomp $rid;
        #print "$rid\n";
        push(@ridlist,$rid);
    }
    return @ridlist;

}

sub usage {

    print STDERR <<EOF;

usage:

   all_rids.pl -f filename

all_rids.pl reads a list of RIDs from a file and performs a lookup and parse on each one


EOF

    exit;

}
