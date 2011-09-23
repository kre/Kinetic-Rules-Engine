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

$conf_template->param(API_EVAL => 1) if $eval_api;
$conf_template->param(API_CALLBACK => 1) if $log_api;
$conf_template->param(API_INIT => 1) if $init_api;
$conf_template->param(API_KRL => 1) if $krl_api;
$conf_template->param(API_FRAG => 1) if $frag_api;

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

