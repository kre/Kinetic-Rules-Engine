#!/usr/bin/perl -w

use strict;

use Getopt::Std;
use Sys::Hostname;
use HTML::Template;

# where the memcache_ips module is.  
use lib qw(/web/etc);


# config
my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";
my $tmpls = $base . "/etc/tmpl";
my $config_tmpl = $tmpls . "/httpd-perl.conf.tmpl";

my $web_root_var = 'WEB_ROOT';
my $web_root = $ENV{$web_root_var} || 
    die "$web_root_var is undefined in the environment";

my $conf_dir = join('/',($web_root,'conf'));
my $conf_file = 'httpd.conf';

use memcache_ips qw(@mcd_hosts);

# global options
use vars qw/ %opt /;
my $opt_string = 'h?ajlkfdrm';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $init_gender = $opt{'j'} || 0;
my $action_gender = $opt{'a'} || 0;
my $log_gender = $opt{'l'} || 0;
my $krl_gender = $opt{'k'} || 0;
my $frag_gender = $opt{'f'} || 0;

my $init_host = 'init.kobj.net';
my $log_host = 'logger.kobj.net';
my $action_host = 'cs.kobj.net';
my $krl_host = 'krl.kobj.net';
my $frag_host = 'frag.kobj.net';
my $db_host = 'db2.kobj.net';
my $db_username = 'logger';
my $db_passwd = '$kynetx123$';
if ($opt{'d'}) { # development
    $init_host = '127.0.0.1';
    $log_host = '127.0.0.1';
    $action_host = '127.0.0.1';
    $frag_host = '127.0.0.1';
    $db_host = 'localhost';
    $db_username = 'root';
    $db_passwd = 'foobar';
}

my $svn;
if ($opt{'r'}) { 
    $svn = 'svn://127.0.0.1/rules/client/|web|foobar';

} else {
    $svn = 'http://krl.kobj.net/rules/client/|cs|fizzbazz';
}


die "Must specify at least one option.  See $0 -h for more info."
    unless ($init_gender || $action_gender || 
	    $log_gender || $krl_gender ||
	    $frag_gender
    );


# open the html template
my $conf_template = HTML::Template->new(filename => $config_tmpl);

my $datenow = localtime();

# fill in the parameters
$conf_template->param(KOBJ_ROOT => $base);
$conf_template->param(GEN_DATE => $datenow);
$conf_template->param(JS_VERSION => '0.9');
$conf_template->param(INIT_HOST => $init_host);
$conf_template->param(LOG_HOST => $log_host);
$conf_template->param(FRAG_HOST => $log_host);
$conf_template->param(ACTION_HOST => $action_host);
$conf_template->param(KRL_HOST => $krl_host);
$conf_template->param(GENDER_ACTION => 1) if $action_gender;
$conf_template->param(GENDER_LOG => 1) if $log_gender;
$conf_template->param(GENDER_INIT => 1) if $init_gender;
$conf_template->param(GENDER_KRL => 1) if $krl_gender;
$conf_template->param(GENDER_FRAG => 1) if $frag_gender;
$conf_template->param(HOSTNAME => hostname);


# database
$conf_template->param(DB_HOST => $db_host);
$conf_template->param(DB_USERNAME => $db_username);
$conf_template->param(DB_PASSWD => $db_passwd);

# rule repository
$conf_template->param(RULE_REPOSITORY => $svn);

# logging (these are for cronolog)
$conf_template->param(LOG_PERIOD => '1hour');
# $conf_template->param(LOG_PERIOD => '5min');

# we can use the 'debug' config parameter to force detailed logging
if ($opt{'d'}) { # development
    $conf_template->param(RUN_MODE => 'development');
    $conf_template->param(DEBUG => 'on');
} else {
    $conf_template->param(RUN_MODE => 'production');
    $conf_template->param(DEBUG => 'off');
}


if ($opt{'m'}) { # memcached
    $conf_template->param(MEMCACHED => 1);
    $conf_template->param(MEMCACHED_HOST_FIRST => shift @mcd_hosts);
    my @AoH = map { { MEMCACHED_HOST => ($_) }  } @mcd_hosts;
    $conf_template->param(MEMCACHED_HOSTS => \@AoH);

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
that configures the server in accordence with it's gender

Options are:

  -a	: Gender is action server
  -l	: Gender is log server
  -j	: Gender is Javascript server (init)
  -k	: Gender is KRL server
  -f	: Gender is FRAG server
  -d    : use 127.0.0.1 as the host
  -r    : use local rules repository (not krl.kobj.net)
  -m    : use memcached, memcache hosts are in /web/etc/memcache_ips.pm

At least one must be given and they may be given in any combination.  

Examples:

For local running all on one machine with local repository

   install-httpd-conf.pl -aljkfdr

For local running all on one machine with remote repository

   install-httpd-conf.pl -aljkfd 

For cs.kobj.net

   install-httpd-conf.pl -am

For logger.kobj.net

   install-httpd-conf.pl -lm

For init.kobj.net

   install-httpd-conf.pl -jm

For krl.kobj.net

   install-httpd-conf.pl -k

For frag.kobj.net

   install-httpd-conf.pl -fm
EOF

exit;


}

