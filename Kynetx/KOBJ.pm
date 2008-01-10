package Kynetx::KOBJ;
# file: Kynetx/KOBJ.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

Log::Log4perl->init_and_watch("/web/lib/perl/log4perl.conf", 60);

sub handler {
    my $r = shift;

    $r->content_type('text/javascript');


    my ($site) = $r->path_info =~ m#/(\d+)/.*\.js#;

    Log::Log4perl::MDC->put('site', $site);
    Log::Log4perl::MDC->put('rule', '[global]');  # no rule for now...

    my $logger = get_logger();
    $logger->info("Outputting KOBJ file");

    print_kobj('http://','127.0.0.1',$site);

    return Apache2::Const::OK; 
}


1;




sub print_kobj {

    my ($proto, $host, $site_id) = @_;

    print <<EOF;

KOBJ.d = (new Date).getTime();
KOBJ.proto = \'$proto\'; 
KOBJ.host_with_port = \'$host\'; 
KOBJ.site_id = $site_id;
KOBJ.url = KOBJ.proto+KOBJ.host_with_port+"/site/" + KOBJ.site_id;


r=document.createElement("script");
r.src=KOBJ.url + "/" + KOBJ.d + ".js";
r.src=r.src+"?";
r.src=r.src+"referer="+encodeURI(document.referrer) + "&";
r.src=r.src+"title="+encodeURI(document.title);
body=document.getElementsByTagName("body")[0];
body.appendChild(r);

EOF

}

