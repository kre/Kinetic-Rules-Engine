package Kynetx::RuleManager;

# file: Kynetx/RuleManager.pm
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
#use warnings;
use lib qw(/web/lib/perl);
use utf8;

use Log::Log4perl qw(get_logger :levels);

use Data::Dumper;
$Data::Dumper::Indent = 1;

use HTML::Template;
use JSON::XS;
use Cache::Memcached;
use DateTime::Format::ISO8601;
use Benchmark ':hireswallclock';
use Encode;

use Kynetx::OParser;
use Kynetx::Parser qw(:all);
use Kynetx::PrettyPrinter qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Json qw/:all/;
use Kynetx::Util qw(:all);
use Kynetx::Version qw/:all/;
use Kynetx::Memcached qw(:all);
use Kynetx::Repository;
use Kynetx::Configure qw(get_config);
use Kynetx::Directives qw(
  set_options
);
use Kynetx::Predicates::Amazon::SNS qw(:all);
use Encode qw(from_to);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

use Apache2::Const qw(FORBIDDEN OK);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

my $skrl = <<_KRL_;
ruleset 10 {
    rule test0 is active {
        select using "/test/" setting()
        pre {
        current_price = stocks:last("^DJI");
        current_price = stocks:last("^DJI","foo");
    }
        replace("test","test");
    }
}
_KRL_

sub handler {
    my $r = shift;
    #my $p = Kynetx::JParser::get_antlr_parser();

    # configure logging for production, development, etc.
    Kynetx::Util::config_logging($r);

    my $logger = get_logger();
    my ( $method, $rid, $version ) = $r->path_info =~ m!/([a-z]+)/([A-Za-z0-9_]*)/?([A-Za-z0-9_]*)!;
    $logger->debug("Performing $method method on ruleset $rid");

    Log::Log4perl::MDC->put( 'site', $method );
    Log::Log4perl::MDC->put( 'rule', $rid );      # no rule for now...

    Kynetx::Memcached->init();

    # for later logging
    $r->subprocess_env( RIDS   => $rid );
    $r->subprocess_env( METHOD => $method );

    my $req_info = Kynetx::Request::build_request_env( $r, $method, $rid );
    # Did not insert lock here since these functions don't seem to be
    # consumers of persistent variables

    $req_info->{'kynetx_app_version'} = $version || 'prod';
    Kynetx::Request::log_request_env( $logger, $req_info );

    my ( $result, $type );

    # at some point we need a better dispatch function
    if ( $method eq "validate" ) {
        ( $result, $type ) = validate_rule( $req_info, $method, $rid );
    } elsif ( $method eq "jsontokrl" ) {
        ( $result, $type ) = pp_json( $req_info, $method, $rid );
    } elsif ( $method eq "version" ) {
        show_build_num($r);
        return Apache2::Const::OK;
    } elsif ( $method eq "parse" ) {
        $logger->debug("Parsing $method, $rid");
        $result = parse_api( $req_info, $method, $rid );
        $type = 'text/plain';
    } elsif ( $method eq "unparse" ) {
        $result = unparse_api( $req_info, $method, $rid );
        $type = 'text/plain';
    } elsif ( $method eq "flushdata" ) {
        $result = flush_data( $req_info, $method, $rid );
        $type = 'text/html';
    } elsif ( $method eq "perf" ) {
        $logger->debug("Performance testing $method, $rid");
        $result = parse_performance( $req_info, $method, $rid );
        $type = 'text/plain';
    }

    $logger->debug("__FLUSH__");

    $r->content_type($type);
    print $result;

    return Apache2::Const::OK;
}

sub parse_performance {
    my ( $req_info, $method, $rid ) = @_;
    my ($t_repository,$t_newparser,$t_parseruleset,$t_oparse);
    my ($s_parser,$s_oparser,$s_overall,$e_newparser);
    my $logger = get_logger();
    my $runs = 1;
    my $start = new Benchmark;
    my $rid_info = mk_rid_info($req_info, $rid);
    my $ruleset = Kynetx::Repository::get_rules_from_repository($rid_info, $req_info,undef,1,1);
    if ($ruleset) {
        my $r_repos = new Benchmark;
        my $repo_diff = timediff($r_repos,$start);
        $t_repository = $repo_diff->[0];
        my $p= Kynetx::JParser::get_antlr_parser();
        my $r_parser = new Benchmark;
        my $rp_diff = timediff($r_parser,$r_repos);
        $t_newparser = $rp_diff->[0];
        my $p_str = $p->ruleset($ruleset);
    $logger->debug("Ruleset: **", $p_str,"**");
        my $parsed = new Benchmark;
        my $pd_diff = timediff($parsed,$r_parser);
        $t_parseruleset = $pd_diff->[0];
        my $status = is_parsed($p_str);
        if ($status eq 'OK') {
            $s_parser = $status;
            $s_overall = $status;
            $e_newparser = '';
        } else {
            $s_parser = 'FAIL';
            $e_newparser = $status;
        }
        return "$t_repository,$t_newparser,$t_parseruleset,$s_parser,$e_newparser";
    } else {
        return parse_api($req_info, $method,'ruleset');
    }
}

sub old_parser {
    my ($ruleset) = @_;
    my $result = Kynetx::OParser::parse_ruleset($ruleset);
    if (defined ($result->{'error'})) {
        return "FAIL";
    } else {
        return "OK";
    }
}

sub is_parsed {
    my ($p_str) = @_;
    my $json = encode("UTF-8",$p_str);
    #my $json = $p_str;
    my $logger = get_logger();

    my $ast;
    eval {
        $ast = Kynetx::Json::jsonToAst($json);
    };

    $logger->debug("Result: ",sub {Dumper($ast)});
    if (ref $ast eq "HASH") {
        if ($ast->{'error'}) {
            my $rstr = join('|', @{$ast->{'error'}});
            return $rstr;
        } else {
            return 'OK';
        }
    } else {
        return "Invalid JSON format: " . sub {Dumper($ast)};
    }
}

sub validate_rule {
    my ( $req_info, $method, $rid ) = @_;

    my $logger = get_logger();

    my $template = Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR')
      . "/validate_rule.tmpl";
    my $test_template = HTML::Template->new( filename => $template );

    # fill in the parameters
    $test_template->param( ACTION_URL => $req_info->{'uri'} );

    my $result = "";
    my $type   = "";

    my $rule   = $req_info->{'rule'}   || '';
    my $flavor = $req_info->{'flavor'} || '';
    my ( $json, $tree );
    if ($rule) {

        $logger->debug("[validate] validating rule ", sub { Dumper($rule)});

        $test_template->param( RULE => $rule );

        $tree = Kynetx::Parser::parse_ruleset($rule);

        if ( defined $tree->{'error'} ) {
            warn $tree->{'error'};
            $test_template->param( ERROR => $tree->{'error'} );
        } else {
            $json = krlToJson($rule);
            $test_template->param( JSON => $json );
        }

    }

    if ( $flavor eq 'json' ) {
        $type = 'text/plain';
        $result = $json || $tree->{'error'};
    } else {

        # print the page
        $type   = 'text/html';
        $result = $test_template->output;
    }

    return ( $result, $type );

}

sub pp_json {
    my ( $req_info, $method, $rid ) = @_;

    my $logger = get_logger();

    my $template =
      Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR') . "/jsonToKrl.tmpl";
    my $test_template = HTML::Template->new( filename => $template );

    # fill in the parameters
    $test_template->param( ACTION_URL => $req_info->{'uri'} );

    my $json = $req_info->{'json'};
    my $type = $req_info->{'type'};
    my ($krl);
    if ($json) {

        $logger->debug( "[jsontokrl] converting json [" . $type . "]" );

        $test_template->param( JSON => $json );

        if ( $type eq 'bodyonly' ) {
            $krl = jsonToRuleBody($json);
        } else {
            $krl = jsonToKrl($json);
        }
        $test_template->param( KRL => $krl );

    }

    return ( $test_template->output, 'text/html' );

}

sub parse_api {
    my ( $req_info, $method, $submethod ) = @_;

    my $logger = get_logger();

    my $krl = $req_info->{'krl'};

    $logger->debug( "KRL: ", $krl );

    my $json = "";
    if ($krl) {

        $logger->debug("[parse_api] parsing krl as $submethod");

        my $tree   = "";
        my $errors = "";
        if ( $submethod eq 'ruleset' ) {
            $tree = Kynetx::Parser::parse_ruleset($krl);
            #$errors .= lint_ruleset($tree);
        } elsif ( $submethod eq 'rule' ) {
            $tree = Kynetx::Parser::parse_rule($krl);
            #$errors .= lint_rule($tree);
        } elsif ( $submethod eq 'global' ) {
            $tree = Kynetx::Parser::parse_global_decls($krl);
        } elsif ( $submethod eq 'dispatch' ) {
            $tree = Kynetx::Parser::parse_dispatch($krl);
        } elsif ( $submethod eq 'meta' ) {
            $tree = Kynetx::Parser::parse_meta($krl);
        }

        #$tree->{'errors'} = $errors if($errors);

        #$logger->debug( "Tree: ", sub { Dumper($tree) } );

        #$logger->debug("Errors: ", sub {Dumper($errors)});

        if ( ref $tree eq "HASH" && defined $tree->{'error'} ) {
            $logger->debug("Parse failed for $krl as $submethod");
            $json = astToJson( { "error" => $tree->{'error'} } );
        } else {
            $json = astToJson($tree);
        }

    }

    $logger->debug("Returning JSON");

    return $json;

}

sub unparse_api {
    my ( $req_info, $method, $submethod ) = @_;

    my $logger = get_logger();

    my $json = $req_info->{'ast'};

    #$logger->debug( "KRL: ", $json );

    my $krl = "";
    if ($json) {

        $logger->debug("[parse_api] unparsing json as $submethod");

        my $tree = jsonToAst($json);

        my $errors;
        if ( $submethod eq 'ruleset' ) {
            $errors .= lint_ruleset($tree);
            $krl = Kynetx::PrettyPrinter::pp( $tree, 0 );
        } elsif ( $submethod eq 'rule' ) {
            $errors .= lint_rule($tree);
            $krl = Kynetx::PrettyPrinter::pp_rule_body( $tree, 0 );
        } elsif ( $submethod eq 'global' ) {
            $krl = Kynetx::PrettyPrinter::pp_global_block( $tree, 0 );
        } elsif ( $submethod eq 'dispatch' ) {
            $krl = Kynetx::PrettyPrinter::pp_dispatch_block( $tree, 0 );
        } elsif ( $submethod eq 'meta' ) {
            $krl = Kynetx::PrettyPrinter::pp_meta_block( $tree, 0 );
        }

    }

    $logger->debug("Returning KRL");

    return $krl;

}

sub lint_ruleset {
    my ($tree) = @_;
    my $logger = get_logger();

    #$logger->debug("lint ruleset: ", sub {Dumper($tree)});
    my $errors = '';
    return '' unless ( $tree->{'error'} );
    $errors = join( "\n", @{ $tree->{'error'} } );
    return $errors;
}

sub lint_rule {
    my ($rule) = @_;
    my $errors = '';
    my $pattern =
         $rule->{'pagetype'}->{'pattern'}
      || $rule->{'pagetype'}->{'event_expr'}->{'pattern'}
      || "/.*/";
    eval { qr!$pattern!; };
    if ($@) {
        $errors .= $@;
    }
    return $errors;
}

sub flush_data {
    my ( $req_info, $method, $keys ) = @_;
    my $logger = get_logger();
    my $topic = get_config("sns");
    my $flush = $topic->{"FLUSH"};
    my $action = 'flush';
    my $options = {'action' => $action };
    my $response = "<title>KNS Data Flush</title>";

    foreach my $key ( split( /;/, $keys ) ) {
        my $directive = Kynetx::Directives->new("kns");
        my $timestamp = DateTime->now;
        $options->{'rid'} = $key;
        $directive->set_options($options);
        my $json = Kynetx::Json::astToJson( $directive->to_directive() );
        my $hash = {
            'Subject' => "Flush cache request for $key ($timestamp)" ,
            'TopicArn' => $flush,
            'Message' => $json,
        };
        my $tn = Kynetx::Util::sns_publish($hash);
        my $msg_id = $tn->{'PublishResponse'}->{'PublishResult'}->{'MessageId'};
        my $req_id = $tn->{'PublishResponse'}->{'ResponseMetadata'}->{'RequestId'};
        my $str = Dumper($tn);
        $response .= "<span id=\"$key\"><h1>KNS ruleset flush request for $key</h1>";
        $response .= "<span id=\"requestid\">$msg_id</span>";
        $response .= "<span id=\"responseid\">$req_id</span>";
        $response .= "</span>";
    }

    return $response;


}

1;
