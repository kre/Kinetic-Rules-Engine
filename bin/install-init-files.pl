#!/usr/bin/perl -w

use strict;


use lib qw(
/web/lib/perl
/web/etc
);


use Getopt::Std;
use HTML::Template;
use JavaScript::Minifier qw(minify);
use Compress::Zlib;
use DateTime;
use Data::Dumper;


use constant DEFAULT_JS_ROOT => '/web/lib/perl/etc/js';
use constant DEFAULT_JS_VERSION => '0.9';



my $base_var = 'KOBJ_ROOT';
my $base = $ENV{$base_var} || die "$base_var is undefined in the environment";
my $tmpls = $base . "/etc/tmpl";
#my $init_tmpl = $tmpls . "/httpd-perl.conf.tmpl";

my $web_root_var = 'WEB_ROOT';
my $web_root = $ENV{$web_root_var} || 
    die "$web_root_var is undefined in the environment";

my $dt = DateTime->now;
my $dstamp = $dt->ymd('');
my $hstamp = $dt->hms('');

my $kobj_file = "kobj-static-".$dstamp.".js";

my @js_files = qw(
jquery-1.2.6.js
jquery.json-1.2.js
jquery-ui-personalized-1.6rc2.js
kgrowl-1.0.js
krl-runtime.js
);




# global options
use vars qw/ %opt /;
my $opt_string = 'hv:r:a';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};


# open the template
#my $init_template = HTML::Template->new(filename => $init_tmpl);

# fill in the parameters
#$init_template->param(KOBJ_ROOT => $base);

my $js_version = $opt{'v'} || DEFAULT_JS_VERSION;
my $js_root = $opt{'r'} || DEFAULT_JS_ROOT;


my $js = "var kobj_fn = '$kobj_file'; var kobj_ts = '$hstamp';";

# get the static files    
foreach my $file (@js_files) {
    $js .= get_js_file($file,$js_version,$js_root);
}



if($opt{'a'}) {  # save to S3

    require Amazon::S3;
    Amazon::S3->import;
#    use vars qw/$OWNER_ID $OWNER_DISPLAYNAME/;

# load the Amazon credentials
# these are not in the code repository on purpose
    require amazon_credentials; 


    # compress the JS program
    my $cjs = Compress::Zlib::memGzip($js);

    # create expires timestamp
    $dt = $dt->add(days => 364);
    my $expires = $dt->strftime("%a %d %b %Y %T %Z");


    # FIXME: there ought to be a way to override credentials on CL

    my $s3 = Amazon::S3->new(
	{   aws_access_key_id     => amazon_credentials->get_key_id(),
	    aws_secret_access_key => amazon_credentials->get_access_key()
	}
	);



    my $bucket = $s3->bucket('init-files') or die $s3->err . ": " . $s3->errstr;;



    print "Writing JS to $kobj_file on S3 with expiration of $expires\n";
    $bucket->add_key( 
	$kobj_file, # file name
	$cjs,        # 
	{ 'Content-type' => 'text/javascript', 
	  'Content-encoding' => 'gzip',
	  'Expires' => $expires,
	  'x-amz-acl' => 'public-read'
	},
	) or die $s3->err . ": " . $s3->errstr;

}

# print the file
my $filename = join('/',($js_root,$js_version,$kobj_file));
print "Writing $filename...\n";

# save file locally
open(FH,">$filename");
print FH $js;
close(FH);

my $pofn = join('/',($js_root,$js_version,"kobj-static.js"));
unlink $pofn;
link($filename,$pofn);



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

   -a       : store to S3
   -r DIR   : use DIR as the root directory for JS files
   -v V     : use V as the verion number


EOF

exit;


}

