package Kynetx::Metrics::TENX;
# file: Kynetx::Metrics/TENX.pm
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
no warnings qw(uninitialized);
use utf8;
use lib qw(/web/lib/perl);

use XML::XPath;
use LWP::Simple;
use DateTime;
use Log::Log4perl qw(get_logger :levels);
use Cache::Memcached;
use JSON::XS;
use Data::Dumper;
use URI::Escape ('uri_escape_utf8');
use Apache2::Const qw(OK);
use Apache2::ServerUtil;
use Sys::Hostname;
use HTML::Template;

use Kynetx::Memcached qw(:all);
use Kynetx::Configure;
use Kynetx::Persistence::KEN;
use Kynetx::Environments;
use Kynetx::Request;
use Kynetx::Metrics::Datapoint;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;
use constant DEFAULT_TEMPLATE_DIR => Kynetx::Configure::get_config('DEFAULT_TEMPLATE_DIR');

#my $s = Apache2::ServerUtil->server;

my %benchmark_vars;
%benchmark_vars = map {$benchmark_vars{$_} => 1} qw(systime cpu usertime csystime cusertime realtime);

sub handler {
    my $r = shift;

    # configure logging for production, development, etc.
    Kynetx::Util::config_logging($r);

    my $logger = get_logger();    	

    $logger->debug("\n\n>>>>---------------- Metric display-------------<<<<");
    $logger->debug("Initializing memcached");
    Kynetx::Memcached->init();

    #my ($method,$rid,$eid) = $r->path_info =~ m!/([a-z+_]+)/([A-Za-z0-9_;]*)/?(\d+)?!;
    my ($method,$path) = $r->path_info() =~ m!/([a-z+_]+)/(.*)!;

	$logger->debug($r->path_info());


    if($method eq 'scatter') {
    	scatter_plot($r,$method,$path);
    } elsif ($method eq 'bar') {
    	bar_plot($r,$method,$path);
    }
    
    return Apache2::Const::OK;

}

sub filter {
	my ($dp,$req) = @_;
	return 1;
}

sub get_datapoints {
	my ($r,$path) = @_;
	my $logger = get_logger();
	my $req = Apache2::Request->new($r);
	my $dp_struct;
	my @series = split(/\//,$path);
	foreach my $s (@series) {
		my ($sname,$xname,$yname) = split(/;/,$s);
		$logger->debug("Xname: ", $xname);
		$logger->debug("Series: ", $s);
		$sname = $sname || "";
		$xname = $xname || "timestamp";
		$yname = $yname || "realtime";
		my $result = Kynetx::Metrics::Datapoint::get_data($sname);
		my @loop = ();
		for (my $i =0; $i< scalar(@{$result}) -1;$i++) {
			my $dp = $result->[$i];
			if (filter($dp,$req)) {
				push(@loop,$dp);
			}
		}
		$dp_struct->{$sname}->{'data'} = \@loop;
		$dp_struct->{$sname}->{'x'} = $xname;
		$dp_struct->{$sname}->{'y'} = $yname;		
	}
	return $dp_struct;
}

sub prune {
	my ($dp_array,$req) = @_;
	my $logger = get_logger();
	my $size = scalar (@{$dp_array}) - 1 ;
	if ($req->param('last')) {
		my $num = $req->param('last');
		$num = $size - $num;
		$logger->debug("Last: $num");
		my @temp = @{$dp_array}[$num..$size];
		return \@temp;
	} elsif ($req->param('first')) {
		my $num = $req->param('first');
		my @temp = @{$dp_array}[0..--$num];
		return \@temp;
	}
	return $dp_array;
}

sub bar_plot {
	my ($r, $method,$path) = @_;
    my $logger = get_logger();
    my $req_info = Kynetx::Request::build_request_env($r, $method, "TENX");
	my $req = Apache2::Request->new($r);
	my $template = DEFAULT_TEMPLATE_DIR . "/bar_metrics.tmpl";
	my $test_template = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	my $dp_struct = get_datapoints($r,$path);
	my @series_loop = ();
	foreach my $s (keys %{$dp_struct}) {
		my @loop = ();
		my $xname = $dp_struct->{$s}->{'x'} || "timestamp";
		my $yname = $dp_struct->{$s}->{'y'} || "count";
		my $sname = $s;		
		my $data = $dp_struct->{$s}->{'data'};
		$data = prune($data,$req);
		my @cats = ();
		my @yvals = ();
		for (my $i = 0;$i < (scalar @{$data})-1; $i++) {
			my $dp = $data->[$i];
			$logger->debug("DP $i: ", sub {Dumper($dp)});
			if (defined $dp) {
				my $x = $dp->get_metric($xname) || $dp->$xname;
				my $y = $dp->get_metric($yname) || $dp->count;
				push(@cats,{'x' => $x});
				push(@yvals,{'y'=> $y});
			}
		}
		my $last = $data->[(scalar @{$data}) -1];
		$test_template->param("CATEGORIES" => \@cats);
		$test_template->param("LASTx" => $last->get_metric($xname) || $last->$xname);
		$test_template->param("LASTy" => $last->get_metric($yname) || $last->count);
		$test_template->param("YVALUES" => \@yvals);
	}	
	$r->content_type('text/html');
	print $test_template->output;	
}

sub scatter_plot {
	my ($r, $method,$path) = @_;
    my $logger = get_logger();
    my $req_info = Kynetx::Request::build_request_env($r, $method, "TENX");
	my $template = DEFAULT_TEMPLATE_DIR . "/altmetrics.tmpl";
	my $test_template = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	my $dp_struct = get_datapoints($r,$path);
	my @series_loop = ();
	foreach my $s (keys %{$dp_struct}) {
		my $sumX=	0;
		my $sumY=	0;
		my $sumX2 = 0;
		my $sumXY = 0;
		my $maxX = 0;
		my $loop_struct = {
			'SERIES_NAME' => $s
		};
		my @loop = ();
		my $xname = $dp_struct->{$s}->{'x'} || "var_size";
		my $yname = $dp_struct->{$s}->{'y'} || "realtime";
		my $sname = $s;
		my $data = $dp_struct->{$s}->{'data'};
		for (my $i = 0;$i < scalar @{$data}; $i++){
			my $dp = $data->[$i];
			if (defined $dp) {
				my $x = $dp->get_metric($xname)|| 0;
				my $y = int($dp->get_metric($yname) * 1000 || 0);
				my $id = $dp->id;
				my $proc = $dp->mproc;
				my $hostname = $dp->mhostname;
				my $ts = $dp->timestamp;
				my $struct = {
					'x' => $x,
					'y' => $y,
					'id' => $id,
					'proc' => $proc,
					'hostname' => $hostname,
					'timestamp' => $ts,
				};
#				foreach my $key (@{$dp->vars}) {
#					$logger->debug("BM: ", sub {Dumper(%benchmark_vars)});					
#					my $m = $dp->get_metric($key);
#					$struct->{'metric'}->{$key} = $m unless ($benchmark_vars{$key} && $dp->get_metric($key) == 0) 
#				}
				$logger->debug("dp $i: ", sub {Dumper($struct)});
				push(@loop,$struct);
				$sumX += $x;
				$sumY += $y;
				$sumX2 += ($x * $x);
				$sumXY += ($x * $y);	
				if ($x > $maxX) {
					$maxX=$x;
				}			
			}
		}
		my $n = scalar(@{$data});
		my $b;# = ($sumXY -($sumX * $sumY)/$n)/($sumX2 - ($sumX * $sumX)/$n);
		#my $b = ($sumXY -($sumX * $sumY)/$n)/($sumX2 - ($sumX * $sumX)/$n);
		my $a = undef;
		while (! defined $a && $n > 0) {
			my $rPoint = rand($n);
			my $dp1 = $data->[$rPoint];
			if (defined $dp1) {
				my $x = $dp1->get_metric($xname)|| 0;
				my $y = int($dp1->get_metric($yname) * 1000 || 0);
				$a = $y - $b*$x;
			} 
		}
		$logger->debug("S: $sname a: ", $a , " b: ", $b);		
		$loop_struct->{'SERIES_DATA'} = \@loop;
		my $last = $data->[scalar @$data -1];
		$loop_struct->{'LASTx'} = $last->get_metric($xname)        || 0;
		$loop_struct->{'LASTy'} = $last->get_metric($yname) * 1000 || 0;
		$loop_struct->{'LASTid'} = $last->id;
#		$loop_struct->{'REGRESSION_NAME'} = $s . "regression";
#		$loop_struct->{'X0'} = 0;
#		$loop_struct->{'Y0'} = int($a + .5);
#		$loop_struct->{'Xn'} = int($maxX + .5);
#		$loop_struct->{'Yn'} = int($a + $b * $maxX + .5);
		#$test_template->param(LASTx => $last->get_metric("var_size")|| 0);
		#$test_template->param(LASTy => int($last->get_metric("realtime") * 1000 || 0));
		CORE::push(@series_loop,$loop_struct);		
	}
	$test_template->param("SERIES_LOOP" => \@series_loop);
	$r->content_type('text/html');
	print $test_template->output;
}

1;


1;
