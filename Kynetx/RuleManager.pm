package Kynetx::RuleManager;
# file: Kynetx/RuleManager.pm
#
# Copyright 2007-2009, Kynetx Inc.  All rights reserved.
# 
# This Software is an unpublished, proprietary work of Kynetx Inc.
# Your access to it does not grant you any rights, including, but not
# limited to, the right to install, execute, copy, transcribe, reverse
# engineer, or transmit it by any means.  Use of this Software is
# governed by the terms of a Software License Agreement transmitted
# separately.
# 
# Any reproduction, redistribution, or reverse engineering of the
# Software not in accordance with the License Agreement is expressly
# prohibited by law, and may result in severe civil and criminal
# penalties. Violators will be prosecuted to the maximum extent
# possible.
# 
# Without limiting the foregoing, copying or reproduction of the
# Software to any other server or location for further reproduction or
# redistribution is expressly prohibited, unless such reproduction or
# redistribution is expressly permitted by the License Agreement
# accompanying this Software.
# 
# The Software is warranted, if at all, only according to the terms of
# the License Agreement. Except as warranted in the License Agreement,
# Kynetx Inc. hereby disclaims all warranties and conditions
# with regard to the software, including all warranties and conditions
# of merchantability, whether express, implied or statutory, fitness
# for a particular purpose, title and non-infringement.
# 
use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);


use Data::Dumper;
$Data::Dumper::Indent = 1;

use HTML::Template;
use JSON::XS;

use Kynetx::Parser qw(:all);
use Kynetx::PrettyPrinter qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Json qw/:all/;
use Kynetx::Util qw(:all);;
use Kynetx::Version qw/:all/;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Apache2::Const qw(FORBIDDEN OK);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    config_logging($r);

    my $logger = get_logger();
    my ($method,$rid) = $r->path_info =~ m!/([a-z]+)/([A-Za-z0-9_]*)!;
    $logger->debug("Performing $method method on ruleset $rid");

    Log::Log4perl::MDC->put('site', $method);
    Log::Log4perl::MDC->put('rule', $rid);  # no rule for now...

    # for later logging
    $r->subprocess_env(RIDS => $rid);
    $r->subprocess_env(METHOD => $method);


    my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);
    Kynetx::Request::log_request_env($logger, $req_info);

    my ($result, $type);
    # at some point we need a better dispatch function
    if($method eq "validate") {
	($result,$type) = validate_rule($req_info, $method, $rid);
    } elsif($method eq "jsontokrl") {
	($result,$type) = pp_json($req_info, $method, $rid);
    } elsif($method eq "version") {
	show_build_num($r);
	return Apache2::Const::OK; 
    } elsif($method eq "parse") {
	$logger->debug("Parsing $method, $rid");
	$result = parse_api($req_info, $method, $rid);
	$type = 'text/plain';
    } elsif($method eq "unparse") {
	$result = unparse_api($req_info, $method, $rid);
	$type = 'text/plain';
    }

    $logger->debug("__FLUSH__");

    $r->content_type($type);
    print $result;

    return Apache2::Const::OK; 
}

1;

sub validate_rule {
    my ($req_info, $method, $rid) = @_;

    my $logger = get_logger();

    my $template = Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR') . "/validate_rule.tmpl";
    my $test_template = HTML::Template->new(filename => $template);

    # fill in the parameters
    $test_template->param(ACTION_URL => $req_info->{'uri'});

    my $result = "";
    my $type = "";

    my $rule = $req_info->{'rule'} || '';
    my $flavor = $req_info->{'flavor'} || '';
    my ($json,$tree);
    if($rule) {

	$logger->debug("[validate] validating rule");

	$test_template->param(RULE => $rule);

	$tree = parse_ruleset($rule);

	$logger->debug("Global start: ", $tree->{'global_start_line'});

	if(defined $tree->{'error'}) {
	    warn $tree->{'error'};
	    $test_template->param(ERROR => $tree->{'error'});
	} else {
	    $json = krlToJson($rule);
	    $test_template->param(JSON => $json);
	} 

    } 
    
    if($flavor eq 'json') {
	$type = 'text/plain';
	$result = $json || $tree->{'error'};
    } else {
	# print the page
	$type = 'text/html';
	$result = $test_template->output;
    }

    return($result, $type);

}

sub pp_json {
    my ($req_info, $method, $rid) = @_;

    my $logger = get_logger();

    my $template =  Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR') . "/jsonToKrl.tmpl";
    my $test_template = HTML::Template->new(filename => $template);

    # fill in the parameters
    $test_template->param(ACTION_URL => $req_info->{'uri'});

    my $json = $req_info->{'json'};
    my $type = $req_info->{'type'};
    my ($krl);
    if($json) {

	$logger->debug("[jsontokrl] converting json [" . $type . "]");

	$test_template->param(JSON => $json);


	if($type eq 'bodyonly') {
	    $krl = jsonToRuleBody($json);
	} else {
	    $krl = jsonToKrl($json);
	}
	$test_template->param(KRL => $krl);


    } 

    return($test_template->output, 'text/html');

}


sub parse_api {
    my ($req_info, $method, $submethod) = @_;
    


    my $logger = get_logger();


    my $krl = $req_info->{'krl'};

#    $logger->debug("KRL: ", $krl);

    my $json = "";
    if($krl) {

	$logger->debug("[parse_api] parsing krl as $submethod");

	my $tree;
	my $errors;
	if($submethod eq 'ruleset') {
	    $tree = Kynetx::Parser::parse_ruleset($krl);
	    $errors .= lint_ruleset($tree);
	} elsif($submethod eq 'rule') {
	    $tree = Kynetx::Parser::parse_rule($krl);
	    $errors .= lint_rule($tree);
	} elsif($submethod eq 'global') {
	    $tree = Kynetx::Parser::parse_global_decls($krl);
	} elsif($submethod eq 'dispatch') {
	    $tree = Kynetx::Parser::parse_dispatch($krl);
	} elsif($submethod eq 'meta') {
	    $tree = Kynetx::Parser::parse_meta($krl);
	} 

	$tree->{'errors'} = $errors if($errors);

#	$logger->debug(sub {Dumper($tree)});

	if(ref $tree eq "HASH" && defined $tree->{'error'}) {
	    $logger->debug("Parse failed for $krl as $submethod");
	    $json = astToJson({"error" => $tree->{'error'} });
	} else {
	    $json = astToJson($tree);
	}

    }
   
    $logger->debug("Returning JSON");

    return $json;

}

sub unparse_api {
    my ($req_info, $method, $submethod) = @_;


    my $logger = get_logger();


    my $json = $req_info->{'ast'};

    $logger->debug("KRL: ", $json);

    my $krl = "";
    if($json) {

	$logger->debug("[parse_api] unparsing json as $submethod");

	my $tree = jsonToAst($json);

	my $errors;
	if($submethod eq 'ruleset') {
	    $errors .= lint_ruleset($tree);
	    $krl = Kynetx::PrettyPrinter::pp($tree,0);
	} elsif($submethod eq 'rule') {
	    $errors .= lint_rule($tree);
	    $krl = Kynetx::PrettyPrinter::pp_rule_body($tree,0);
	} elsif($submethod eq 'global') {
	    $krl = Kynetx::PrettyPrinter::pp_global_block($tree,0);
	} elsif($submethod eq 'dispatch') {
	    $krl = Kynetx::PrettyPrinter::pp_dispatch_block($tree,0);
	} elsif($submethod eq 'meta') {
	    $krl = Kynetx::PrettyPrinter::pp_meta_block($tree,0);
	} 

#	$logger->debug(Dumper($tree));

	# if(ref $tree eq "HASH" && defined $tree->{'error'}) {
	#     $logger->debug("Parse failed for $krl as $submethod");
	#     $json = '{"error": "' . $tree->{'error'} .'"}';
	# } else {


	# }


    }
   
    $logger->debug("Returning KRL");

    return $krl;

}

sub lint_ruleset {
    my ($tree) = @_;
    my $errors = '';
    return '' if (! ref $tree eq 'HASH' && defined $tree->{'error'});
    foreach my $rule ( @{ $tree->{'rules'} } ) {
	$errors .= lint_rule($rule);
    }
    return $errors;
}

sub lint_rule {
    my ($rule) = @_;
    my $errors = '';
    my $pattern = $rule->{'pagetype'}->{'pattern'} || $rule->{'pagetype'}->{'event_expr'}->{'pattern'} || "/.*/";
    eval { qr!$pattern!; };
    if ($@) {
	$errors .= $@;
    }
    return $errors;
}
