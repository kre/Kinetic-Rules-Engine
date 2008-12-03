#!/usr/bin/perl -w

use strict;


use lib qw(/web/lib/perl);


use Getopt::Std;
use HTML::Template;
use JavaScript::Minifier qw(minify);

use constant DEFAULT_JS_ROOT => '/web/lib/perl/etc/js';
use constant DEFAULT_JS_VERSION => '0.9';


my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";
my $tmpls = $base . "/etc/tmpl";
#my $init_tmpl = $tmpls . "/httpd-perl.conf.tmpl";

my $web_root_var = 'WEB_ROOT';
my $web_root = $ENV{$web_root_var} || 
    die "$web_root_var is undefined in the environment";

my $kobj_file = 'kobj-static.js';

my @js_files = qw(
jquery-1.2.6.js
jquery.json-1.2.js
jquery-ui-personalized-1.6rc2.js
jquery.livequery.js
kobj-extras.js
);




# global options
use vars qw/ %opt /;
my $opt_string = 'hv:r:';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};


# open the template
#my $init_template = HTML::Template->new(filename => $init_tmpl);

# fill in the parameters
#$init_template->param(KOBJ_ROOT => $base);

my $js_version = $opt{'v'} || DEFAULT_JS_VERSION;
my $js_root = $opt{'r'} || DEFAULT_JS_ROOT;


my $js;

# get the static files    
foreach my $file (@js_files) {
    $js .= get_js_file($file,$js_version,$js_root);
}


# print the file
my $filename = join('/',($js_root,$js_version,$kobj_file));
print "Writing $filename...\n";
open(FH,">$filename");
print FH $js;
close(FH);



1;


sub get_js_file {
    my ($file, $js_version, $js_root) = @_;

    my $filename = join('/',($js_root,$js_version,$file));

    open(JS, "< $filename") ||  
	die("Can't open file $filename: $!\n");


    my $js = minify(input=> *JS);

    # reduce conflict by renaming some Prototype functions
#    $js =~ s#\$\$\(#K\$\$\(#gs;
#    $js =~ s#([^\$])\$\(#$1K\$\(#gs; # don't replace $$

    close JS;
    
    return $js;

}



sub usage {
    print STDERR <<EOF;

usage:  

   install-init-files.pl [-rv]

Create Kynetx initialization js files

Options:

   -r DIR   : use DIR as the root directory for JS files
   -v V     : use V as the verion number


EOF

exit;


}

