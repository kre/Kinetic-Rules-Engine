#!/usr/bin/perl -w

use strict;

use Getopt::Std;
use Cwd;

# config
my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";

my $web_root_var = 'WEB_ROOT';
my $web_root = $ENV{$web_root_var} || 
    die "$web_root_var is undefined in the environment";

my $APACHECTL = "sudo /etc/init.d/httpd";

# global options
use vars qw/ %opt /;
my $opt_string = 'h?ajlk';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'} || $opt{'?'};

my $init_gender = $opt{'j'} || 0;
my $action_gender = $opt{'a'} || 0;
my $log_gender = $opt{'l'} || 0;
my $krl_gender = $opt{'k'} || 0;
my $frag_gender = $opt{'f'} || 0;

# set the working directory
chdir $base;

print "Updating source...\n";
system "svn up";

chdir "$base/etc/kynetx-private-bundle"; 

my $cd = getcwd();

print "Updating perl modules (with sudo in $cd)...\n";
system "sudo perl -MCPAN -e 'install Bundle::kobj_modules'";

chdir $base;


print "Updating httpd.conf and other machine specific items...\n";
# set up the machine
if ($init_gender) { # for init.kobj.net

    system "$base/bin/install-httpd-conf.pl  -jm";
    # install the right init files
    system "$base/bin/install-init-files.pl";

} elsif ($action_gender) { # for csXX.kobj.net

    system "$base/bin/install-httpd-conf.pl -am";

} elsif ($log_gender) { # for logger.kobj.net

    system "$base/bin/install-httpd-conf.pl -lm";

} elsif ($krl_gender) { # for krl.kobj.net

    system "$base/bin/install-httpd-conf.pl -k";
} elsif ($frag_gender) { # for frag.kobj.net

    system "$base/bin/install-httpd-conf.pl -fm";
}

print "Restart Apache...\n";
system "$APACHECTL restart";


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

Examples:

  For cs.kobj.net

   update.pl -a -m 192.168.122.151,192.168.122.152


EOF

exit;


}

