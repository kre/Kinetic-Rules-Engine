#!/usr/bin/perl -w

use strict;

use Getopt::Std;

# config
my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";

my $web_root_var = 'WEB_ROOT';
my $web_root = $ENV{$web_root_var} || 
    die "$web_root_var is undefined in the environment";

# global options
use vars qw/ %opt /;
my $opt_string = 'hajlkm:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};

my $init_gender = $opt{'j'} || 0;
my $action_gender = $opt{'a'} || 0;
my $log_gender = $opt{'l'} || 0;
my $krl_gender = $opt{'k'} || 0;
my $memcache_ips = $opt{'m'};

# set the working directory
chdir $base;

system "svn up";

chdir "$base/lib/perl/etc/kynetx-private-bundle"; 

system "sudo perl -MCPAN -e 'install Bundle::kobj_modules'"

chdir $base;


# set up the machine
if ($init_gender) { # for init.kobj.net

    system "$base/bin/install-httpd-conf.pl  -j -m $memcache_ips";
    # install the right init files
    system "$base/bin/install-init-files.pl"

} elsif ($action_gender) { # for csXX.kobj.net

    system "$base/bin/install-httpd-conf.pl -a -m $memcache_ips";

} elsif ($log_gender) { # for logger.kobj.net

    system "$base/bin/install-httpd-conf.pl -l -m $memcache_ips";

} elsif ($krl_gender) { # for krl.kobj.net

    system "$base/bin/install-httpd-conf.pl -k";
}


1;

sub usage {
    print STDERR <<EOF;

usage:  

   update.pl [-haljk]

Do everything necessary on the local server to refresh the code base.  

Options are:

  -h    : show this file
  -a	: Gender is action server
  -l	: Gender is log server
  -j	: Gender is Javascript server (init)
  -k	: Gender is KRL server
  -m ML : use memcached, ML is a comma seperated list of host IP numbers



EOF

exit;


}

