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

# global options
use vars qw/ %opt /;
my $opt_string = 'hv:r:au';
getopts( "$opt_string", \%opt ); # or &usage();
&usage() if $opt{'h'};


use Kynetx::Configure qw/:all/;

# FIXME: don't hardcode this...
use constant DEFAULT_JS_ROOT => '/web/lib/perl/etc/js';
use constant DEFAULT_JS_VERSION => '0.9';


# configure KNS
Kynetx::Configure::configure();

# use production mode to generate the file if sending to Amazon
Kynetx::Configure::set_run_mode('production') if $opt{'a'};


my $dt = DateTime->now;
my $dstamp = $dt->ymd('');
my $hstamp = $dt->hms('');

my $kobj_file = "kobj-static-".$dstamp.$hstamp.".js";

my @js_files = qw(
jquery-1.4.2.js
jquery.json-1.2.js
jquery-ui-1.8.custom.js
kgrowl-1.0.js
snowfall.jquery.js
krl-setup.js
krl-domwatch.js
krl-annotate.js
krl-percolation.js
krl-sidetab.js
krl-runtime.js.tmpl
);

my $foo = <<_krl_;





_krl_

#jquery-ui-personalized-1.6rc2.js





my $js_version = $opt{'v'} || DEFAULT_JS_VERSION;
my $js_root = $opt{'r'} || DEFAULT_JS_ROOT;
my $minify = !$opt{'u'};


my $js = "var kobj_fn = '$kobj_file'; var kobj_ts = '$dstamp$hstamp';";

# get the static files    
foreach my $file (@js_files) {
    $js .= get_js_file($file,$js_version,$js_root,$minify);
}

# At the vary vary bottom of our new js put back jquery.
$js .= "jQuery.noConflict();";




if($opt{'a'}) {  # save to S3

  require Amazon::S3;
  Amazon::S3->import;
#    use vars qw/$OWNER_ID $OWNER_DISPLAYNAME/;

# load the Amazon credentials
  # these are not in the code repository on purpose
  require amazon_credentials; 

  warn "\nWARNING!!!!! 127.0.0.1 appear in the KRL runetime file on S3\n" if 
      Kynetx::Configure::get_config('INIT_HOST') eq '127.0.0.1' ||
      Kynetx::Configure::get_config('CB_HOST') eq '127.0.0.1' ||
      Kynetx::Configure::get_config('KRL_HOST') eq '127.0.0.1' ||
      Kynetx::Configure::get_config('EVAL_HOST') eq '127.0.0.1';

  # create expires timestamp
  $dt = $dt->add(days => 364);
  my $expires = $dt->strftime("%a %d %b %Y %T %Z");

  # compress the JS program
	my $cjs = "";
	my $jsheaders = { 'Content-type' => 'text/javascript',
	  'Expires' => $expires,
	  'x-amz-acl' => 'public-read'
	};
	if($minify){
		$cjs = Compress::Zlib::memGzip($js);
		$jsheaders->{'Content-encoding'} = 'gzip';
	} else {
		$cjs = $js;
	}
  




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
	$jsheaders,
	) or die $s3->err . ": " . $s3->errstr;

  print "See http://static.kobj.net/$kobj_file for results\n";

} else {

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

    
}



1;


sub get_js_file {
    my ($file, $js_version, $js_root, $minify) = @_;

    my $filename = join('/',($js_root,$js_version,$file));
    my $js = '';

    if ($filename =~ m/\.tmpl$/) {
        # open the template
	my $init_template = HTML::Template->new(filename => $filename,
						die_on_bad_params => 0);

        # do this last to override anything from above
	for my $key (@{ Kynetx::Configure::config_keys() }) {
	    $init_template->param($key => Kynetx::Configure::get_config($key));
	}
		if($minify){
			$js = minify(input => $init_template->output);
		} else {
			$js = $init_template->output;
		}
    } else {
		open(JS, "< $filename") || die("Can't open file $filename: $!\n");
		if($minify){	
			$js = minify(input=> *JS);
		} else {
			undef $/;
			$js = <JS>;
		}

    }


    close JS;
    
    return $js;

}



sub usage {
    print STDERR <<EOF;

usage:  

   install-init-files.pl [-rv]

Create Kynetx initialization js files

Options:

   -a       : store to S3 only in production mode
   -u       : don't minify the file during publish
   -r DIR   : use DIR as the root directory for JS files
   -v V     : use V as the verion number


EOF

exit;


}

