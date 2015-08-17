package Kynetx::Console;
# file: Kynetx/Console.pm
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

use Log::Log4perl qw(get_logger :levels);
use HTML::Template;
use DateTime;
use Data::Dumper;
$Data::Dumper::Indent = 1;



use Kynetx::Session qw(:all);
use Kynetx::Environments qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Rules qw(:all);
use Kynetx::Rids qw(:all);
use Kynetx::Modules qw(:all);
use Kynetx::Expressions qw(:all);
use Kynetx::Predicates::Time qw(:all);
use Kynetx::Configure qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
show_context test_harness
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

sub error_page {
	my ($r, $method, $rid,$oauth) = @_;
	my $logger = get_logger();
	my $session = process_session($r);

    my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);
    my $template = Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR') . "/error.tmpl";
    my $context_template = HTML::Template->new(filename => $template,
                           die_on_bad_params => 0);

    $context_template->param("RULESET_ID" => $rid);
    $context_template->param("SESSION_ID" => Kynetx::Session::session_id($session) );
    $context_template->param("COOKIE" => $r->headers_in->{'Cookie'});

    my $req = Apache2::Request->new($r);
}


sub test_harness {
    my ($r, $method, $rid,$eid) = @_;
    
    my $logger = get_logger();

    my $session = process_session($r);

    my $req_info = Kynetx::Request::build_request_env($r,$method,$rid);

    $r->content_type('text/plain');
    print "Request env: " . Dumper($req_info);
    print "Config test: " . Kynetx::Configure::to_string();
}

sub show_context {
    my ($r, $method, $rid) = @_;

    my $logger = get_logger();


    if(Kynetx::Configure::get_config('RUN_MODE') eq 'development') {
	# WARNING: THIS CHANGES THE USER'S IP NUMBER FOR TESTING!!
	my $test_ip = Kynetx::Configure::get_config('TEST_IP');
	$r->connection->remote_ip($test_ip); 
    }


    # get a session hash 
    my $session = process_session($r);

    my $req_info = Kynetx::Request::build_request_env($r, $method, $rid);


    $logger->info("Displaying context data for site " . $req_info->{'site'});

    # side effects environment with precondition pattern values
    $req_info->{'rid'} = mk_rid_info($req_info,$rid);
    my $ruleset = 
	get_rule_set($req_info);

    my $rule_env = empty_rule_env();
    # this loops through the rules ONCE applying all that fire

    # FIXME: too much code duplicated between here and Rules.pm.  Abstract


    my %fired;
    $req_info->{'rule_count'} = 0;
    $req_info->{'selected_rules'} = [];
    foreach my $rule ( @{ $ruleset->{'rules'} } ) {
      $rule->{'state'} ||= 'active';
      if($rule->{'state'} eq 'active' || 
	 ($rule->{'state'} eq 'test' && 
	  $req_info->{'mode'} && 
	  $req_info->{'mode'} eq 'test' )) {  # optimize??

	$req_info->{'rule_count'}++;
      


	# test and capture here
	my($selected, $captured_vals) = 
	  Kynetx::Rules::select_rule($req_info->{'caller'}, $rule);

	if ($selected) {
	  my $pred_value = 
	    den_to_exp(
		       eval_expr ($rule->{'cond'}, $rule_env, $rule->{'name'},$req_info, $session));


	  push @{ $req_info->{'selected_rules'} }, $rule->{'name'};

	  if ($pred_value) {
	    $fired{$rule->{'name'}} = 'will fire';
	  } else {
	    $fired{$rule->{'name'}} = 'will not fire';
	  }
	}
      }

    }

    Kynetx::Request::log_request_env($logger, $req_info);

#     if($logger->is_debug()) {
# 	foreach my $entry (keys %{ $req_info}) {
# 	    $logger->debug($entry . ": " . $req_info->{$entry});
# 	}
#     }


    # print template
    $logger->debug("printing template");

    my $template = Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR') . "/show_context.tmpl";
    my $context_template = HTML::Template->new(filename => $template,
					       die_on_bad_params => 0);

    $context_template->param(site => Kynetx::Rids::print_rids($req_info->{'site'}));
    $context_template->param(caller => $req_info->{'caller'});

    my @client_info = (       
	{ name => 'Kynetx CS Server',
	  value => $req_info->{'hostname'}},

	{ name => 'Client ID', 
	  value => Kynetx::Rids::print_rids($req_info->{'site'})},

	{ name => 'Client calling page',
	  value => $req_info->{'caller'}},

	);


    $context_template->param(client_info => \@client_info);

    my @user_info = (       

	);

    $context_template->param(user_info => \@user_info);

    my @rule_info =  (
	{ name => 'Rule Version', 
	  value => $req_info->{'rule_version'}},

	{ name => 'Active rules', 
	  value => $req_info->{'rule_count'}},

	);


    $context_template->param(rule_info => \@rule_info);

    my $c = 0;
    my @rules = ();
    foreach my $rule_name (@{ $req_info->{'selected_rules'} }) {
	push @rules, 
   	     { number => $c,
	       name => $rule_name,
	       fired => $fired{$rule_name},
	     };
	$c++;
    }


    $context_template->param(rules => \@rules);


    $r->content_type('text/html');
    print $context_template->output;


    $logger->info("finished");


}


1;
