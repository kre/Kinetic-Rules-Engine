#!/usr/bin/perl -w

#
# This file is part of the Kinetic Rules Engine (KRE)
# Copyright (C) 2007-2011 Kynetx, Inc. 
#
# KRE is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
# MA 02111-1307 USA
#
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
my $opt_string = 'h?ajlkf';
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


chdir "$base/t";

print "\nRunning built-in tests...\n";
system "./smoke" || die "failed tests";

chdir $base;



print "Updating httpd.conf and other machine specific items...\n";
# set up the machine
if ($init_gender) { # for init.kobj.net

    system "$base/bin/install-httpd-conf.pl  -j";
    # install the right init files
    system "$base/bin/install-init-files.pl";

} elsif ($action_gender) { # for csXX.kobj.net

    system "$base/bin/install-httpd-conf.pl -a";

} elsif ($log_gender) { # for logger.kobj.net

    system "$base/bin/install-httpd-conf.pl -l";

} elsif ($krl_gender) { # for krl.kobj.net

    system "$base/bin/install-httpd-conf.pl -k";
} elsif ($frag_gender) { # for frag.kobj.net

    system "$base/bin/install-httpd-conf.pl -f";
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
  -a	: Gender is action server (cs)
  -l	: Gender is log server
  -j	: Gender is Javascript server (init)
  -k	: Gender is KRL server
  -f	: Gender is fragment server

Examples:

  For cs.kobj.net

   update.pl -a


EOF

exit;


}

