package Kynetx::KOBJ;
# file: Kynetx/KOBJ.pm

use strict;
use warnings;

use File::Find::Rule;
use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

use constant DEFAULT_SERVER_ROOT => 'kobj.net';
use constant DEFAULT_ACTION_PREFIX => 'kobj-cs';
use constant DEFAULT_LOG_PREFIX => 'kobj-log';
use constant DEFAULT_ACTION_HOST => '127.0.0.1';
use constant DEFAULT_LOG_HOST => '127.0.0.1';
use constant DEFAULT_JS_ROOT => '/web/lib/perl/etc/js';
use constant DEFAULT_JS_VERSION => '0.9';

use Kynetx::Util qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Repository qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Datasets qw(:all);

use Data::Dumper;

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);

    $r->content_type('text/javascript');

#    return Apache2::Const::DECLINED 
#	unless $r->content_type() eq 'text/javascript';

    my $logger = get_logger();

    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my ($method,$rids) = $r->uri =~ m#/js/([^/]+)/([^/]*(\.js)?)/?#;

    Log::Log4perl::MDC->put('site', $method);
    Log::Log4perl::MDC->put('rule', '[initialization]');  # no rule for now...

    $logger->debug("RIDs -> $rids");

    my $js_version = $r->dir_config('kobj_js_version') || DEFAULT_JS_VERSION;
    my $js_root = $r->dir_config('kobj_js_root') || DEFAULT_JS_ROOT;


    my $js = "";
    if ($rids eq 'kobj.js') {

	$logger->info("Generating client initialization file ", $rids);

	my $req_info = Kynetx::Request::build_request_env($r, 'initialize', $method);

	Kynetx::Request::log_request_env($logger, $req_info);

	my($prefix, $middle, $root) = $r->hostname =~ m/^([^.]+)\.?(.*)\.([^.]+\.[^.]+)$/;

	$logger->debug("Hostname: ", $prefix, " and ", $root);

	my $action_host;
	my $log_host;
	# track virtual hosts
	if($root eq DEFAULT_SERVER_ROOT ||
	   $r->hostname =~ m/\d+\.\d+\.\d+\.\d+/) {
	    $action_host = $r->dir_config('action_host') || DEFAULT_ACTION_HOST;
	    $log_host = $r->dir_config('log_host') || DEFAULT_LOG_HOST;
	} else {
	    $middle .= "." if $middle;
	    my $ending = "." . $middle  . $root;
	    $action_host = DEFAULT_ACTION_PREFIX . $ending;
	    $log_host = DEFAULT_LOG_PREFIX . $ending;
	}

	$logger->info("Generating KOBJ file ", $rids, ' with action host ' , $action_host);


	$js = get_kobj($r,
		       'http://', 
		       $action_host, 
		       $log_host, 
		       $method, 
		       $js_version, 
		       $req_info);


    } elsif($method eq 'static' || 
	    $method eq 'shared' || 
	    $method eq '996337974') { # Backcountry
	if($r->dir_config('UseCloudFront')) { # redirect to CloudFront
	    my $version = $r->dir_config('CloudFrontFile');
	    if (! $version) {
		 $version = 'kobj-static-1.js';
		 $logger->error("CloudFrontFile config directive missing from Apache httpd.conf.  Using $version");
	    } 
	    my $cf_url = "http://static.kobj.net/". $version;
	    $logger->info("Redirecting to Cloudfront ", $cf_url);
	    $r->headers_out->set(Location => $cf_url);
	    
	    return Apache2::Const::REDIRECT;
	    
	} else {  # send the file from here
	    $logger->info("Generating KOBJ static file ", $rids);
	    $js = get_js_file($rids, $js_version,$js_root);
	}
	
    } elsif($method eq 'dispatch') {
	my $req_info = Kynetx::Request::build_request_env($r, 'initialize', $method);

	Kynetx::Request::log_request_env($logger, $req_info);

	$js = dispatch($req_info, $rids, $r->dir_config('svn_conn'));

	$r->content_type('text/plain');


    } elsif($method eq 'datasets') {
	my $req_info = Kynetx::Request::build_request_env($r, 'initialize', $method);

	Kynetx::Request::log_request_env($logger, $req_info);

	$js = datasets($req_info, $rids, $r->dir_config('svn_conn'));

	$r->content_type('text/javascript');


    } elsif($method eq 'version') {
	show_build_num($r);
    } 

    print $js;

    return Apache2::Const::OK; 

}


sub get_js_file {
    my ($file, $js_version, $js_root) = @_;

    my $logger = get_logger();
    my $filename = join('/',($js_root,$js_version,$file));

    $logger->debug("Outputting JS file ", $file, " from ", $filename);

    open(JS, "< $filename") || 
	$logger->error("Can't open file $filename: $!\n");
    local $/ = undef;
    my $js = <JS>;

    close JS;
    
    return $js;


}

# turn the datasets from a ruleset into JS 
sub get_datasets {
    my ($svn_conn, $req_info) = @_;
    my $rid = $req_info->{'rid'};

    my $logger = get_logger();
    $logger->debug("Getting ruleset for $rid");

    my $js = "";

    my $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $svn_conn, $req_info);

    if( $ruleset->{'global'} ) {
	$logger->debug("Processing decls for $rid");
	foreach my $g (@{ $ruleset->{'global'} }) {

	    if(defined $g->{'name'} && Kynetx::Datasets::global_dataset($g)) { # more than 24 hours
		$logger->debug("Creating JS for decl " . $g->{'name'});
		$js .= mk_dataset_js($g, $req_info, {}); # empty rule env
	    }
	}
    } 
    $logger->debug("Returning JS for global decls");
    return $js;

}


sub datasets {
    my($req_info, $rids, $svn_conn) = @_;

    my $logger = get_logger();
    $logger->debug("Returning datasets for $rids");


    my $js = "KOBJ['data'] = KOBJ['data'] || {};\n";

    my @rids = split(/;/,$rids);
    

    foreach my $rid (@rids) {
	$req_info->{'rid'} = $rid;
	$js .= get_datasets($svn_conn, $req_info) ;
    }
    

    return $js;

}


sub dispatch {
    my($req_info, $rids, $svn_conn) = @_;

    my $logger = get_logger();
    $logger->debug("Returning dispatch sites for $rids");

    my $r = {};

    my @rids = split(/;/,$rids);
    

    foreach my $rid (@rids) {

	my $ruleset = Kynetx::Repository::get_rules_from_repository($rid, $svn_conn, $req_info);

	if( $ruleset->{'dispatch'} ) {
	    $logger->debug("Processing dispatch block for $rid");
#	    $logger->debug(sub() {Dumper($ruleset->{'dispatch'})});
	    $r->{$rid} = [];
	    foreach my $d (@{ $ruleset->{'dispatch'} }) {
		push(@{ $r->{$rid} }, $d->{'domain'});
	    }
	}    
    }
    
    $r = encode_json($r);
    $logger->debug($r);

    return $r;

}

sub get_kobj {


    my ($r, $proto, $host, $cb_host, $rids, $js_version, $req_info) = @_;

    my $logger = get_logger();

    my @rids = split(/;/,$rids);

    my $js = <<EOF;
var KOBJ= KOBJ || {  };
EOF

    foreach my $rid (@rids) {

	my $data_root = "/web/data/client/$rid";

	# add in datasets  The datasets param is a filter
	my @ds;

	my $datasets = $req_info->{'datasets'};
    
	if($datasets) {
	    @ds = split(/,/, $datasets);
	} else {
	    @ds = File::Find::Rule->file()
		->name( '*.pm' )
		->in( $data_root );
	}

	foreach my $dataset (@ds) {
	    my $fn = "$data_root/$dataset.json";
	    if(-e $fn) {
		open(JSON, $fn ) || 
		    $logger->error("Can't open file $data_root/$dataset.json: $!\n");
		local $/ = undef;
		$js .= "KOBJ.$dataset = ";
		$js .= <JSON>;
		$js .= ";\n";
		close JS;
	    }
	}

	$req_info->{'rid'} = $rid;
#	$js .= get_datasets($r->dir_config('svn_conn'), $req_info);
    }


    # create param string for tacking on to CS request
    my $param_names = $req_info->{'param_names'};
    my $params = {'rids' => \@rids};
    foreach my $n (@{ $param_names }) {
#	$logger->debug("Adding $n to parameters...");
	$params->{$n} = $req_info->{$n};
    }

    my $param_json = encode_json($params);

    

    $js .= <<EOF;
function startKJQuery() {
    if(typeof(KOBJ.init) !== "undefined"){
	\$K.isReady = true;
    } else {
	setTimeout("startKJQuery()", 20);
    }
 };
startKJQuery;
KOBJ.init({"callback_host" : "$cb_host",
	   "eval_host" : "$host"
	  });
KOBJ.eval($param_json);
EOF

    return $js;

}




1;


