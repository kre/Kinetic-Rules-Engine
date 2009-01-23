package Kynetx::Version;
# file: Kynetx/Version.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use JSON::XS;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
get_build_num
show_build_num
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub get_build_num {
    my ($kobj_root) = @_;
    my $build_num = `cd $kobj_root;/usr/bin/svnversion -n`;
    return $build_num || 'failed';
}

sub show_build_num {
    my ($r) = @_;

    my $kobj_root = $r->dir_config('kobj_root');

    my $build_num = get_build_num($kobj_root);

    my $logger = get_logger();

    my ($site) = $r->path_info =~ m#/version/(.+)#;

    my $req = Apache2::Request->new($r);
    my $flavor = $req->param('flavor') || 'html';

    Log::Log4perl::MDC->put('site', $site);
    Log::Log4perl::MDC->put('rule', '[version]');  # no rule for now...


    if($flavor eq 'json') {
	my $json = new JSON::XS;

	$r->content_type('text/plain');
	print $json->encode({'build_num' => $build_num}) ;
    } else {
	$r->content_type('text/html');
	my $msg = "KNS build number $build_num";
	print "<title>KNS Version</title><h1>$msg</h1>";
    }

}


1;
