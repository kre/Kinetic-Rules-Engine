package Kynetx::Console;
# file: Kynetx/Console.pm
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
use HTML::Template;
use DateTime;
use Data::Dumper;
$Data::Dumper::Indent = 1;



use Kynetx::Session qw(:all);
use Kynetx::Environments qw(:all);
use Kynetx::Request qw(:all);
use Kynetx::Rules qw(:all);
use Kynetx::Modules qw(:all);
use Kynetx::Expressions qw(:all);
use Kynetx::Predicates::Location qw(:all);
use Kynetx::Predicates::Time qw(:all);
use Kynetx::Predicates::Weather qw(:all);
use Kynetx::Predicates::Demographics qw(:all);
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

    $context_template->param(site => $req_info->{'site'});
    $context_template->param(caller => $req_info->{'caller'});

    my @client_info = (       
	{ name => 'Kynetx CS Server',
	  value => $req_info->{'hostname'}},

	{ name => 'Client ID', 
	  value => $req_info->{'site'}},

	{ name => 'Client calling page',
	  value => $req_info->{'caller'}},

	);


    $context_template->param(client_info => \@client_info);

    my $demo_preds = Kynetx::Predicates::Demographics::get_predicates();

    my @user_info = (       

	{ name => 'User IP Address',
	  value => $req_info->{'ip'}},

	{ name => 'City',
	  value => get_geoip($req_info,'city')},
	{ name => 'Region',
	  value => get_geoip($req_info,'region')},
	{ name => 'Zip Code',
	  value => get_geoip($req_info,'postal_code')},
	{ name => 'Country',
	  value => get_geoip($req_info,'country_name')},

	{ name => 'Local time',
	  value => get_local_time($req_info)},
	{ name => 'Local time zone',
	  value => get_local_time($req_info)->time_zone->name},


	{ name => 'Current temperature',
	  value => get_weather($req_info,'curr_temp') . ' F'},
	{ name => 'Current conditions',
	  value => get_weather($req_info,'curr_cond') . ' '},
	{ name => 'Tomorrow high',
	  value => get_weather($req_info,'tomorrow_high') . ' F'},
	{ name => 'Tomorrow low',
	  value => get_weather($req_info,'tomorrow_low') . ' F'},
	{ name => 'Tomorrow forecast',
	  value => get_weather($req_info,'tomorrow_cond') . ' '},


	{ name => 'Median income',
	  value => '$'.get_demographics($req_info, 'median_income')},
	{ name => 'Urban',
	  value => &{$demo_preds->{'urban'}}($req_info) ? 'yes' : 'no'},
	{ name => 'Rural',
	  value => &{$demo_preds->{'rural'}}($req_info) ? 'yes' : 'no'},

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
