#!/usr/bin/perl -w

use strict;

use Getopt::Std;
use Sys::Hostname;
use HTML::Template;
use File::Spec;


use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use lib qw(/web/lib/perl);
use Kynetx::Configure qw/:all/;


# configure KNS
Kynetx::Configure::configure();


# determine our base directory and get the web root from that
my $base=File::Spec->rel2abs($0);
$base =~ s#/bin/install-httpd-conf.pl##;
my $web_root = $base;
$web_root =~ s#(^/[^/]+).*#$1#;

# config
#my $base_var = 'KOBJ_ROOT';
#my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";
#my $web_root_var = 'WEB_ROOT';
#my $web_root = $ENV{$web_root_var} || 
#    die "$web_root_var is undefined in the environment";


my $tmpls = $base . "/etc/tmpl";
my $config_tmpl = $tmpls . "/httpd-perl.conf.tmpl";


my $conf_dir = join('/',($web_root,'conf'));
my $conf_file = 'httpd.conf';


# global options
use vars qw/ %opt /;
my $opt_string = 'h?ajlkfdrs';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $include_svn = $opt{'s'} || 0;
my $init_api = $opt{'j'} || 0;
my $eval_api = $opt{'a'} || 0;
my $log_api = $opt{'l'} || 0;
my $krl_api = $opt{'k'} || 0;
my $frag_api = $opt{'f'} || 0;

# my $init_host = 'init.kobj.net';
# my $log_host = 'logger.kobj.net';
# my $eval_host = 'cs.kobj.net';
# my $krl_host = 'krl.kobj.net';
# my $frag_host = 'frag.kobj.net';
# #my $db_host = 'db2.kobj.net';
# #my $db_username = 'logger';
# #my $db_passwd = '$kynetx123$';
# if ($opt{'d'}) { # development
#     $init_host = '127.0.0.1';
#     $log_host = '127.0.0.1';
#     $eval_host = '127.0.0.1';
#     $frag_host = '127.0.0.1';
# #    $db_host = 'localhost';
# #    $db_username = 'root';
# #    $db_passwd = 'foobar';
# }

# my $svn;
# if ($opt{'r'}) { 
#     $svn = 'svn://127.0.0.1/rules/client/|web|foobar';

# } else {
#     $svn = 'http://krl.kobj.net/rules/client/|cs|fizzbazz';
# }


die "Must specify at least one option.  See $0 -h for more info."
    unless ($init_api || $eval_api || 
	    $log_api || $krl_api ||
	    $frag_api
    );


# open the html template
my $conf_template = HTML::Template->new(filename => $config_tmpl,
					die_on_bad_params => 0
    );

my $datenow = localtime();
$conf_template->param(GEN_DATE => $datenow);


$conf_template->param(INCLUDE_SVN => 1) if $include_svn;
$conf_template->param(HOSTNAME => hostname);

# fill in the parameters
# $conf_template->param(KOBJ_ROOT => $base);
# $conf_template->param(JS_VERSION => '0.9');
# $conf_template->param(INIT_HOST => $init_host);
# $conf_template->param(CB_HOST => $log_host);
# $conf_template->param(FRAG_HOST => $frag_host);
# $conf_template->param(EVAL_HOST => $eval_host);
# $conf_template->param(KRL_HOST => $krl_host);
# $conf_template->param(KOBJ_ROOT => $base);


$conf_template->param(API_EVAL => 1) if $eval_api;
$conf_template->param(API_CALLBACK => 1) if $log_api;
$conf_template->param(API_INIT => 1) if $init_api;
$conf_template->param(API_KRL => 1) if $krl_api;
$conf_template->param(API_FRAG => 1) if $frag_api;



# # database
# #$conf_template->param(DB_HOST => $db_host);
# #$conf_template->param(DB_USERNAME => $db_username);
# #$conf_template->param(DB_PASSWD => $db_passwd);

# # rule repository
# $conf_template->param(RULE_REPOSITORY => $svn);

# # logging (these are for cronolog)
# $conf_template->param(LOG_PERIOD => '1hour');
# # $conf_template->param(LOG_PERIOD => '5min');

# # we can use the 'debug' config parameter to force detailed logging
# if ($opt{'d'}) { # development
#     $conf_template->param(RUN_MODE => 'development');
#     $conf_template->param(DEBUG => 'on');
# } else {
#     $conf_template->param(RUN_MODE => 'production');
#     $conf_template->param(DEBUG => 'off');
# }


# do this last to override anything from above
for my $key (@{ Kynetx::Configure::config_keys() }) {
    $conf_template->param($key => Kynetx::Configure::get_config($key));
}



#if the dir doesn't exist, make it
if(! -e $conf_dir) {
    mkdir $conf_dir;
    warn "Created $conf_dir; ensure httpd.conf file is looking there for $conf_file."
}
    


# print the file
print "Writing $conf_dir/$conf_file\n";
open(FH,">$conf_dir/$conf_file");
print FH $conf_template->output;
close(FH);



1;

sub usage {
    print STDERR <<EOF;

usage:  

   install-httpd-conf.pl [-aljkfdrm]

Create an httpd.conf file in $web_root/conf
that configures the server in accordence with it's api

Options are:

  -a	: include API for eval server
  -l	: include API for log server
  -j	: include API for Javascript server (init)
  -k	: include API for KRL server
  -f	: include API for FRAG server

At least one must be given and they may be given in any combination.  

Examples:

For local running all on one machine with local repository

   install-httpd-conf.pl -aljkfs

For local running all on one machine with remote repository

   install-httpd-conf.pl -aljkf 

For cs.kobj.net

   install-httpd-conf.pl -a

For logger.kobj.net

   install-httpd-conf.pl -l

For init.kobj.net

   install-httpd-conf.pl -j

For krl.kobj.net

   install-httpd-conf.pl -k

For frag.kobj.net

   install-httpd-conf.pl -f
EOF

exit;


}

