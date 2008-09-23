#!/usr/bin/perl -w

use strict;

use Cwd;


my $base = $ARGV[0];

chdir "$base/etc/kynetx-private-bundle"; 

my $cd = getcwd();

print "Updating perl modules (with sudo in $cd)...\n";


system "/usr/bin/perl -MCPAN -e 'install Bundle::kobj_modules'";
