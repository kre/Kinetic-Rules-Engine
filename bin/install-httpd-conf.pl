#!/usr/bin/perl -w

use strict;

use Getopt::Std;
use HTML::Template;

# config
my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";
my $tmpls = $base . "/etc/tmpl";
my $config_tmpl = $tmpls . "/httpd-perl.conf.tmpl";

my $web_root_var = 'WEB_ROOT';
my $web_root = $ENV{$web_root_var} || 
    die "$web_root_var is undefined in the environment";

my $conf_dir = join('/',($web_root,'conf','extra'));
my $conf_file = 'http-perl.conf';


# global options
use vars qw/ %opt /;
my $opt_string = 'hajld';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};

my $init_gender = $opt{'j'} || 0;
my $action_gender = $opt{'a'} || 0;
my $log_gender = $opt{'l'} || 0;

my $init_host = 'init.kobj.net';
my $log_host = 'logger.kobj.net';
my $action_host = 'cs.kobj.net';
if ($opt{'d'}) { # development
    $init_host = '127.0.0.1';
    $log_host = '127.0.0.1';
    $action_host = '127.0.0.1';
}

die "Must specify at least one option.  See $0 -h for more info."
    unless ($init_gender || $action_gender || $log_gender);

# assumes that we're running in a /web configuration
#cp $KOBJ_ROOT/httpd-perl.conf.example /web/conf/extra/httpd-perl.conf

# open the html template
my $conf_template = HTML::Template->new(filename => $config_tmpl);

my $datenow = localtime();

# fill in the parameters
$conf_template->param(KOBJ_ROOT => $base);
$conf_template->param(GEN_DATE => $datenow);
$conf_template->param(JS_VERSION => '0.8');
$conf_template->param(INIT_HOST => $init_host);
$conf_template->param(LOG_HOST => $log_host);
$conf_template->param(ACTION_HOST => $action_host);
$conf_template->param(GENDER_ACTION => 1) if $action_gender;
$conf_template->param(GENDER_LOG => 1) if $log_gender;
$conf_template->param(GENDER_INIT => 1) if $init_gender;

#if the dir doesn't exist, make it
if(! -e $conf_dir) {
    mkdir $conf_dir;
    warn "Created $conf_dir; ensure httpd.conf file is looking there for $conf_file."
}
    


# print the file
open(FH,">$conf_dir/$conf_file");
print FH $conf_template->output;
close(FH);



1;

sub usage {
    print STDERR <<EOF;

usage:  

   install-httpd-conf.pl [-alj]

Create an httpd-perl.conf file in $web_root/conf/extra 
that configures the server's gender.

Options are:

  -a	: Gender is action server
  -l	: Gender is log server
  -j	: Gender is Javascript server
  -d    : use 127.0.0.1 as the host

At least one must be given and they may be given in any combination.  

EOF

exit;


}

