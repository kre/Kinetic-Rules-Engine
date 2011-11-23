package Kynetx::KOBJ;
# file: Kynetx/KOBJ.pm
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
use warnings;
no warnings qw(uninitialized);

use File::Find::Rule;
use Log::Log4perl qw(get_logger :levels);
use JSON::XS;

# meh: I am taking out references to these defaults because they should be
# loaded from the Configure module
#use constant DEFAULT_SERVER_ROOT => 'kobj.net';
#use constant DEFAULT_ACTION_PREFIX => 'kobj-cs';
#use constant DEFAULT_LOG_PREFIX => 'kobj-log';
#use constant DEFAULT_ACTION_HOST => '127.0.0.1';
#use constant DEFAULT_LOG_HOST => '127.0.0.1';
#use constant DEFAULT_JS_ROOT => '/web/lib/perl/etc/js';
#use constant DEFAULT_JS_VERSION => '0.9';

use Kynetx::Util qw(:all);
use Kynetx::Version qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Repository;
use Kynetx::Memcached qw(:all);
use Kynetx::Datasets qw(:all);
use Kynetx::Environments qw(:all);
use Kynetx::Session;
use Kynetx::Dispatch ;

use Data::Dumper;

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    Kynetx::Util::config_logging($r);

    $r->content_type('text/javascript');

#    return Apache2::Const::DECLINED
#	unless $r->content_type() eq 'text/javascript';

    my $logger = get_logger();

    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    my ($api,$method,$rids) = $r->uri =~ m#/(init|js)/([^/]+)/([^/]*(\.js)?)/?#;

    Log::Log4perl::MDC->put('site', $method);
    Log::Log4perl::MDC->put('rule', '[initialization]');  # no rule for now...

    # for later logging
    $r->subprocess_env(METHOD => $method);

    my $req_info = Kynetx::Request::build_request_env($r, 'initialize', $method);
    
    Kynetx::Request::log_request_env($logger, $req_info);

    # get a session, if _sid param is defined it will override cookie
    my $session = Kynetx::Session::process_session($r, $req_info->{'kntx_token'});

	my $sid = Kynetx::Session::session_id($session);
	$r->subprocess_env(SID => $sid);

    $logger->debug("RIDs -> $rids");

    my $js_version = Kynetx::Configure::get_config('JS_VERSION');
    my $js_root = Kynetx::Configure::get_config('DEFAULT_JS_ROOT');

    my $not_secure = ! (($r->headers_in->{'X-Secure'} || '') eq 'Yes');
    $logger->debug("This is a secure connection") unless $not_secure;


    my $js = "";
    if ($rids eq 'kobj.js') {

      # FIXME: I don't think this is used anymore
	$logger->info("Generating client initialization file ", $rids);

	my($prefix, $middle, $root) = $r->hostname =~ m/^([^.]+)\.?(.*)\.([^.]+\.[^.]+)$/;

	$logger->debug("Hostname: ", $prefix, " and ", $root);

	my $action_host;
	my $log_host;
	# track virtual hosts
	if($root eq Kynetx::Configure::get_config('DEFAULT_SERVER_ROOT') ||
	   $r->hostname =~ m/\d+\.\d+\.\d+\.\d+/) {
	    $action_host = Kynetx::Configure::get_config('DEFAULT_ACTION_HOST');
	    $log_host = Kynetx::Configure::get_config('DEFAULT_LOG_HOST');
	} else {
	    $middle .= "." if $middle;
	    my $ending = "." . $middle  . $root;
	    $action_host =
		Kynetx::Configure::get_config('DEFAULT_ACTION_PREFIX') . $ending;
	    $log_host =
		Kynetx::Configure::get_config('DEFAULT_LOG_PREFIX') . $ending;
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
	if(Kynetx::Configure::get_config('USE_CLOUDFRONT') && $not_secure) {
            # redirect to CloudFront
	    my $version = Kynetx::Configure::get_config('RUNTIME_LIB_NAME');
	    if (! $version) {
		 $version = 'http://static.kobj.net/kobj-static-1.js';
		 $logger->error("RUNTIME_LIB_NAME is undefined in configuration!" .  " Using $version");
	    }
	    $logger->info("Redirecting to Cloudfront ", $version);
	    $r->headers_out->set(Location => $version);

	    return Apache2::Const::REDIRECT;

	} else {  # send the file from here
	    # $rids will be the final file name of the URL called...
	    $logger->info("Generating KOBJ static file ", $rids);
	    $js = get_js_file($rids, $js_version,$js_root);
	}

    } elsif($method eq 'dispatch') {

	if ($api eq 'js') {
	  $js = Kynetx::Dispatch::simple_dispatch($req_info, $rids);

	} elsif ($api eq 'init') {
	  $js = Kynetx::Dispatch::extended_dispatch($req_info);
	}

	$r->content_type('text/plain');


    } elsif($method eq 'datasets') {

	$js = datasets($req_info, $rids);

	$r->content_type('text/javascript');


    } elsif($method eq 'version') {
	show_build_num($r);
    }

    $logger->debug("__FLUSH__");

    print Kynetx::Util::str_out($js);

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
    my ($req_info) = @_;
    my $rid_info = $req_info->{'rid'};
    my $rid = get_rid($rid_info);

    my $logger = get_logger();
    $logger->debug("Getting ruleset for $rid");

    my $js = '';


    my $ruleset = Kynetx::Repository::get_rules_from_repository($rid_info, $req_info);

    if( $ruleset->{'global'} ) {
	$logger->debug("Processing decls for $rid");
	foreach my $g (@{ $ruleset->{'global'} }) {
	    my $this_js = '';
	    my $var = '';
	    my $val = 0;
	    if(defined $g->{'name'} &&
	       $g->{'type'} eq 'dataset' &&
	       Kynetx::Datasets::global_dataset($g)) { # more than 24 hours
		$logger->debug("Creating JS for decl " . $g->{'name'});
		($this_js, $var, $val) = mk_dataset_js($g, $req_info, empty_rule_env()); # empty rule env
	    }
	    $js .= $this_js;
	}
    }
    $logger->debug("Returning JS for global decls");
    return $js;

}


sub datasets {
    my($req_info, $rids) = @_;

    my $logger = get_logger();
    $logger->debug("Returning datasets for $rids");


    my $js = "KOBJ['data'] = KOBJ['data'] || {};\n";

    my @rids = split(/;/,$rids);


    foreach my $rid (@rids) {
      $req_info->{'rid'} = mk_rid_info($req_info,$rid);
      $js .= get_datasets($req_info) ;
      $js .= <<EOF
KOBJ.registerDataSet('$rid', []);
EOF
    }

    return $js;

}



sub get_kobj {


    my ($r, $proto, $host, $cb_host, $rids, $js_version, $req_info) = @_;

    my $logger = get_logger();

    my @rids = split(/;/,$rids);

    my $js = <<EOF;
var KOBJ= KOBJ || {  };
EOF

    foreach my $rid (@rids) {

        # we don't store client datasets anymore. Historical...

        # FIXME: hard coded path
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
		close JSON;
	    }
	}

	$req_info->{'rid'} = $rid;
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


