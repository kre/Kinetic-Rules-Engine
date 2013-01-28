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
use POSIX qw(INT_MAX);

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
use Apache2::Request;
use Sys::Hostname;
use HTML::Template;
use DateTime::Format::RFC3339;

use Kynetx::Memcached qw(:all);
use Kynetx::Configure;
use Kynetx::Persistence::KEN;
use Kynetx::Environments;
use Kynetx::Request;
use Kynetx::Metrics::Datapoint;
use Kynetx::Json;
use Kynetx::Predicates::Time;
use Kynetx::Persistence::Ruleset;

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
use constant MAX_POINTS => 1500;
use constant MIN_POINTS => 10;

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

	$logger->trace($r->path_info());


    if($method eq 'scatter') {
    	scatter_plot($r,$method,$path);
    } elsif ($method eq 'bar') {
    	bar_plot($r,$method,$path);
    } elsif ($method eq 'ctl') {
    	control();
    } elsif ($method eq 'col') {
    	column_plot($r,$method,$path);
    } elsif ($method eq 'any') {
    	any_plot($r,$method,$path);
    }
    
    return Apache2::Const::OK;

}

sub control {
	my @ctrl = ('/web/bin/apachectl', 'graceful');
	system(@ctrl) == 0
		or die "Could not execute $ctrl[0]";
}

sub filter {
	my ($dp,$req) = @_;
	my $logger = get_logger();
	my @params = $req->param;
	foreach my $p (@params) {
		next if ($p eq "limit");
		next if ($p eq "sort_order");
		my $a = $req->param($p);
		my $b = $dp->{$p};
		$logger->trace("Check for $p: $a");
		$logger->trace("            : $b");
		if (defined $b) {
			if ($a ne $b) {
				return 0;
			}
		} else {
			return 0;
		}
		
	}
	return 1;
}

sub _filter {
	my ($dp,$filter) = @_;
	my $logger = get_logger();
	#$logger->debug("Filter: ", sub {Dumper($filter)});
	foreach my $p (keys %{$filter}) {
		next if ($p eq "limit");
		next if ($p eq "sort_order");
		my $a = $filter->{$p};
		my $b = $dp->{$p};
		$logger->trace("Check for $p: $a");
		my $re = qr(^$a$);
		if (defined $b) {
			$b = "$b";
		$logger->trace("            : $b");
			if ($a ne $b) {
				return 0;
			}
		} else {
			return 0;
		}
		
	}
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
		my $key;
		$logger->debug("Series: ", $s);
		if ($sname eq "any") {
			$key = {};
		} else {
			$key =  { "series" => $sname };
		}
		$logger->trace("sname: ", $sname);
		$logger->trace("Xname: ", $xname);
		$logger->trace("Yname: ", $yname);
		$sname = $sname || "";
		$xname = $xname || "timestamp";
		$yname = $yname || "realtime"; 
		my $result = Kynetx::Metrics::Datapoint::get_data($key,$req);
		if (defined $result) {
			$logger->trace("Num points: ", scalar @{$result});
			my @loop = ();
			my $pmax = 1000;
			my $count = 0;
			foreach my $dp (@{$result}) {
				if (filter($dp,$req)) {
					$count++;					
					push(@loop,$dp);
					if ($count >= $pmax) {
						last;
					}
				}			

			}
			$logger->debug("Filtered points: ", scalar @loop);
			$dp_struct->{$sname}->{'data'} = \@loop;
			$dp_struct->{$sname}->{'x'} = $xname;
			$dp_struct->{$sname}->{'y'} = $yname;					
		} else {
			$logger->debug("No data for $sname,$xname,$yname");
		}
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
		$logger->trace("Last: $num");
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
		#$data = prune($data,$req);
		my @cats = ();
		my @yvals = ();
		for (my $i = 0;$i < (scalar @{$data})-1; $i++) {
			my $dp = $data->[$i];
			if (defined $dp) {
				my $x = $dp->{$xname};
				my $y = $dp->{$yname} || $dp->{'count'};
				$logger->trace("DP $i: $xname: $x $yname: $y");
				push(@cats,{'x' => $x});
				push(@yvals,{'y'=> $y});
			}
		}
		my $last = $data->[(scalar @{$data}) -1];
		$test_template->param("CATEGORIES" => \@cats);
		$test_template->param("LASTx" => $last->{$xname});
		$test_template->param("LASTy" => $last->{$yname} || $last->{'count'});
		$test_template->param("YVALUES" => \@yvals);
	}	
	$r->content_type('text/html');
	print $test_template->output;	
}

sub column_plot {
	my ($r, $method,$path) = @_;
    my $logger = get_logger();
    my $req_info = Kynetx::Request::build_request_env($r, $method, "TENX");
	my $req = Apache2::Request->new($r);
	my $template = DEFAULT_TEMPLATE_DIR . "/col_metrics.tmpl";
	my $test_template = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	my $dp_struct = get_datapoints($r,$path);
	my @series_loop = ();
	foreach my $s (keys %{$dp_struct}) {
		my @loop = ();
		my $xname = $dp_struct->{$s}->{'x'} || "timestamp";
		my $yname = $dp_struct->{$s}->{'y'} || "count";
		my $sname = $s;		
		my $data = $dp_struct->{$s}->{'data'};
		#$data = prune($data,$req);
		my @cats = ();
		my @yvals = ();
		my $points;
		for (my $i = 0;$i < (scalar @{$data})-1; $i++) {
			my $dp = $data->[$i];
			if (defined $dp) {
				my $x = $dp->{$xname};
				my $y = $dp->{$yname} || $dp->{'count'};
				my $id = $dp->{"id"};
				$logger->trace("DP $i: $xname: $x $yname: $y");
				my $ystr = "{y: $y, id: \'$id\' }";
				my $xstr = "\'$x\'";
				push(@cats,$xstr);
				push(@yvals,$ystr);
				$points->{$id} = pretty_point($dp);
			}
		}
		my $catstr = '[' . join(",",@cats) . "]";
		my $ystr	= '['. join(",",@yvals). "]";
		my $pstr;
		eval {
			$pstr = Kynetx::Json::astToJson($points)
		};
		if ($@ && not defined $pstr) {
			$pstr = "n/a";
		}
		$test_template->param("CATEGORIES" => $catstr);
		$test_template->param("yname" => $yname); 
		$test_template->param("yval" => $ystr); 
		$test_template->param("point" => $pstr); 
		$test_template->param("sname" => $s);
	}	
	$r->content_type('text/html');
	print $test_template->output;		
}

sub _get_datapoints {
	my ($key,$limits,$filter) = @_;
	my $logger = get_logger();
	my ($count,$matrix);
	my $ulimit = 100000;
	$limits->{'limit'} = $limits->{'limit'} || 1500;
	$logger->trace("filter gd: ", sub {Dumper($filter)});
	do {
		$logger->trace("Limit: ", sub {Dumper($limits)});
		my $result = Kynetx::Metrics::Datapoint::get_data($key,$limits);
		if (defined $result) {
			$count = 0;
			$matrix = {};
			foreach my $dp (@{$result}) {
				#last unless ($count < MAX_POINTS);
				last unless ($count < $limits);
				my $series = $dp->{'series'};
				$matrix->{$series}->{'data'} = () unless (defined $matrix->{$series}->{'data'});
				push(@{$matrix->{$series}->{'data'}},$dp);
				$count++;
			}
		}
		$limits->{'limit'}	*= 2;	
		$logger->trace("New limit: ", sub {Dumper($limits)});
	} while ($count == 0 && $limits->{'limit'} < $ulimit);
	return $matrix;
}


sub get_series {
	my ($path,$queryp) = @_;
    my $logger = get_logger();
    $logger->trace("get series");
    my ($limits,$filter);
    my $defx = 'ts';
    my $defy = 'realtime';
    my $graph = {};
	my ($restpart,$querypart) = split(/\?/,$path);
	foreach my $key (keys (%{$queryp})) {
		my $value=$queryp->{$key};
    	$logger->trace("KV: ",$key,"/",$value);
		if (defined $key && defined $value) {
			if ($key eq 'limit') {
				$limits->{$key} = $value;
			} else {
				$filter->{$key} = $value;
			}
		}
	}
	
	my @series = split(/\//,$restpart);
	my $key = {};
	my $labels;
	if (scalar @series > 1) {
		my @slist;
		foreach my $s (@series) {
			my ($sname,$xname,$yname) = split(/;/,$s);
			my $element = {
				'series' => $sname
			};
			push(@slist,$element);
			$labels->{$sname}->{'xname'} = $xname || $defx;
			$labels->{$sname}->{'yname'} = $yname || $defy;
		}
		$key = {'$or' => \@slist};
	} elsif (scalar @series == 1) {
		my ($sname,$xname,$yname) = split(/;/,$series[0]);
		$key = {
			'series' => $sname
		} unless ($sname eq 'any');
		$labels->{$sname}->{'xname'} = $xname || $defx;
		$labels->{$sname}->{'yname'} = $yname || $defy;
	}
	foreach my $f (keys %{$filter}) {
	  $key->{$f} = $filter->{$f};
	}
	$graph = _get_datapoints($key,$limits,$filter);
	$logger->trace("Labels: ", sub {Dumper($labels)});
	foreach my $label (keys %{$labels}){
		$logger->trace("$label: ", sub {Dumper($labels->{$label})});
		$graph->{$label}->{'xname'} = $labels->{$label}->{'xname'};
		$graph->{$label}->{'yname'} = $labels->{$label}->{'yname'};
		
	}
	return $graph;
	
}

sub any_plot {
	my ($r, $method,$path) = @_;
  my $logger = get_logger();
  my $req_info = Kynetx::Request::build_request_env($r, $method, "TENX");
	my $template = DEFAULT_TEMPLATE_DIR . "/any_metrics.tmpl";
	my $req = Apache2::Request->new($r);
	my @params = $req->param;
	my $filter;
	foreach my $p (@params) {
		$filter->{$p} = $req->param($p);
	}
	my $test_template = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	my $graph = get_series($path,$filter);
	my @series_data = ();
	my $points;
	my @series = keys %{$graph};
	my $population;
	my $minX = INT_MAX;
	my $maxX = 0;
	foreach my $s (@series) {
    my @temp;
		my $struct;		
		$struct->{'name'} = $s;
		$struct->{'type'} = 'scatter';
		my $xname = $graph->{$s}->{'xname'} || $graph->{'any'}->{'xname'};
		my $yname = $graph->{$s}->{'yname'} || $graph->{'any'}->{'yname'};
		$logger->trace("$s: ", sub {Dumper($graph->{$s})});
		my @data = ();
		foreach my $point (@{$graph->{$s}->{'data'}}) {
			$logger->trace("$xname, $yname, p: ", sub {Dumper($point)});
			my $x = $point->{$xname};
			my $y = $point->{$yname};
			my $id = $point->{'id'};
			$y = int($y * 1000);
			if (defined $x) {
			  $minX = $x if ($x < $minX);
			  $maxX = $x if ($x > $maxX);
			}
			push(@data,{
				'id' => $id,
				'y' => $y,
				'x' => $x * 1
			});
			$points->{$id} = pretty_point($point);
			if ($s ne "any") {
			  push(@temp,$y);
			}
			
		}
		$struct->{'data'} = \@data;
		if (scalar(@data) > 0) {
			push(@series_data,$struct);		
		}
		if (scalar(@temp)> MIN_POINTS) {
		  $population->{$s} = \@temp;
		}
		
	}
	my $empty_set = "[{
	  'name' : 'No Data',
	  'xname' : '$graph->{'any'}->{'xname'}',
	  'yname' : '$graph->{'any'}->{'yname'}',
	  'data' : []
	}]";
	
	my $data;
	my $pstr;
	if (! @series_data) {
	  $logger->debug("No data");
	  $data = $empty_set; #Kynetx::Json::encode_json(@empty_set);
	  $pstr = '[]';
	  $logger->trace("Encoded");
	} else {
	  if (scalar keys %{$population} < 2) {
  	  foreach my $series (keys %{$population}) {
  	    my $data = $population->{$series};
  	    $logger->debug("Size: ", scalar @{$data});
  	    my $mean = mean_series($data,$minX,$maxX);
  	    if (defined $mean) {
  	      $mean->{'name'} = $series . "-mean";
  	      $mean->{'type'} = 'line';
  	      push(@series_data,$mean);
  	    }
  	    my $median = median_series($data,$minX,$maxX);
  	    if (defined $median) {
  	      $median->{'name'} = $series . "-median";
  	      $median->{'type'} = 'line';
  	      push(@series_data,$median);
  	    }
  	    
  	    
  	  }
	    
	  }
	  $data = encode_json(\@series_data);
	  $pstr = encode_json($points);
	}
	my $num_points = scalar (keys %{$points});
	
	
	$test_template->param("numpoints" => $num_points);
	$test_template->param("BANDS" => plotBands($population));

	$test_template->param("DATA" => $data);
	$test_template->param("point" => $pstr);
	$r->content_type('text/html');
	
	print $test_template->output;
	
}

sub scatter_plot {
  	my ($r, $method,$path) = @_;
  my $logger = get_logger();
  my $req_info = Kynetx::Request::build_request_env($r, $method, "TENX");
	my $template = DEFAULT_TEMPLATE_DIR . "/scatter_metrics.tmpl";
	my $req = Apache2::Request->new($r);
	my @params = $req->param;
	my $filter;
	foreach my $p (@params) {
		$filter->{$p} = $req->param($p);
	}
	my $test_template = HTML::Template->new(filename => $template,die_on_bad_params => 0);
	my $graph = get_series($path,$filter);
	my @series_data = ();
	my $points;
	my @series = keys %{$graph};
	my $population;
	my $minX = INT_MAX;
	my $maxX = 0;
	foreach my $s (@series) {
    my @temp;
		my $struct;		
		$struct->{'name'} = $s;
		$struct->{'type'} = 'scatter';
		my $xname = $graph->{$s}->{'xname'} || $graph->{'any'}->{'xname'};
		my $yname = $graph->{$s}->{'yname'} || $graph->{'any'}->{'yname'};
		$test_template->param("XAXIS" => $xname);
		$test_template->param("YAXIS" => $yname);
		$logger->trace("$s: ", sub {Dumper($graph->{$s})});
		my @data = ();
		foreach my $point (@{$graph->{$s}->{'data'}}) {
			$logger->trace("$xname, $yname, p: ", sub {Dumper($point)});
			my $x = $point->{$xname};
			my $y = $point->{$yname};
			my $id = $point->{'id'};
			$y = int($y * 1000);
			if (defined $x) {
			  $minX = $x if ($x < $minX);
			  $maxX = $x if ($x > $maxX);
			}
			push(@data,{
				'id' => $id,
				'y' => $y,
				'x' => $x * 1
			});
			$points->{$id} = pretty_point($point);
			if ($s ne "any") {
			  push(@temp,{
  				'y' => $y,
  				'x' => $x * 1
			  });
			}
			
		}
		$struct->{'data'} = \@data;
		if (scalar(@data) > 0) {
			push(@series_data,$struct);		
		}
		if (scalar(@temp)> MIN_POINTS) {
		  $population->{$s} = \@temp;
		}
		
	}
	my $empty_set = "[{
	  'name' : 'No Data',
	  'xname' : '$graph->{'any'}->{'xname'}',
	  'yname' : '$graph->{'any'}->{'yname'}',
	  'data' : []
	}]";
	
	my $data;
	my $pstr;
	if (! @series_data) {
	  $logger->debug("No data");
	  $data = $empty_set; #Kynetx::Json::encode_json(@empty_set);
	  $pstr = '[]';
	  $logger->trace("Encoded");
	} else {
	  if (scalar keys %{$population} < 2) {
  	  foreach my $series (keys %{$population}) {
  	    my $data = $population->{$series};
  	    $logger->debug("Size: ", scalar @{$data});
  	    my $regression = regression_series($data);
  	    if (defined $regression) {
  	      $regression->{'name'} = $series . "-regression ". $regression->{'name'};
  	      $regression->{'type'} = 'line';
  	      push(@series_data,$regression);
  	    }  	      	    
  	  }
	    
	  }
	  $data = encode_json(\@series_data);
	  $pstr = encode_json($points);
	}
	my $num_points = scalar (keys %{$points});
	
	
	$test_template->param("numpoints" => $num_points);
	$test_template->param("DATA" => $data);
	$test_template->param("point" => $pstr);
	$r->content_type('text/html');
	
	print $test_template->output;
  
}

#sub scatter_plot {
#	my ($r, $method,$path) = @_;
#    my $logger = get_logger();
#    my $req_info = Kynetx::Request::build_request_env($r, $method, "TENX");
#	my $template = DEFAULT_TEMPLATE_DIR . "/altmetrics.tmpl";
#	my $test_template = HTML::Template->new(filename => $template,die_on_bad_params => 0);
#	my $dp_struct = get_datapoints($r,$path);
#	my @series_loop = ();
#	foreach my $s (keys %{$dp_struct}) {
#		my $sumX=	0;
#		my $sumY=	0;
#		my $sumX2 = 0;
#		my $sumXY = 0;
#		my $maxX = 0;
#		my $loop_struct = {
#			'SERIES_NAME' => $s
#		};
#		my @loop = ();
#		my $xname = $dp_struct->{$s}->{'x'} || "var_size";
#		my $yname = $dp_struct->{$s}->{'y'} || "realtime";
#		my $sname = $s;
#		my $data = $dp_struct->{$s}->{'data'};
#		for (my $i = 0;$i < scalar @{$data}; $i++){
#			my $dp = $data->[$i];
#			if (defined $dp) {
#				my $x = $dp->get_metric($xname)|| 0;
#				my $y = int($dp->get_metric($yname) * 1000 || 0);
#				my $id = $dp->id;
#				my $proc = $dp->mproc;
#				my $hostname = $dp->mhostname;
#				my $ts = $dp->timestamp;
#				my $struct = {
#					'x' => $x,
#					'y' => $y,
#					'id' => $id,
#					'proc' => $proc,
#					'hostname' => $hostname,
#					'timestamp' => $ts,
#				};
##				foreach my $key (@{$dp->vars}) {
##					$logger->debug("BM: ", sub {Dumper(%benchmark_vars)});					
##					my $m = $dp->get_metric($key);
##					$struct->{'metric'}->{$key} = $m unless ($benchmark_vars{$key} && $dp->get_metric($key) == 0) 
##				}
#				$logger->trace("dp $i: ", sub {Dumper($struct)});
#				push(@loop,$struct);
#				$sumX += $x;
#				$sumY += $y;
#				$sumX2 += ($x * $x);
#				$sumXY += ($x * $y);	
#				if ($x > $maxX) {
#					$maxX=$x;
#				}			
#			}
#		}
#		my $n = scalar(@{$data});
#		my $b;# = ($sumXY -($sumX * $sumY)/$n)/($sumX2 - ($sumX * $sumX)/$n);
#		#my $b = ($sumXY -($sumX * $sumY)/$n)/($sumX2 - ($sumX * $sumX)/$n);
#		my $a = undef;
#		while (! defined $a && $n > 0) {
#			my $rPoint = rand($n);
#			my $dp1 = $data->[$rPoint];
#			if (defined $dp1) {
#				my $x = $dp1->get_metric($xname)|| 0;
#				my $y = int($dp1->get_metric($yname) * 1000 || 0);
#				$a = $y - $b*$x;
#			} 
#		}
#		$logger->trace("S: $sname a: ", $a , " b: ", $b);		
#		$loop_struct->{'SERIES_DATA'} = \@loop;
#		my $last = $data->[scalar @$data -1];
#		$loop_struct->{'LASTx'} = $last->get_metric($xname)        || 0;
#		$loop_struct->{'LASTy'} = $last->get_metric($yname) * 1000 || 0;
#		$loop_struct->{'LASTid'} = $last->id;
#		CORE::push(@series_loop,$loop_struct);		
#	}
#	$test_template->param("SERIES_LOOP" => \@series_loop);
#	$r->content_type('text/html');
#	print $test_template->output;
#}

sub pretty_point {
	my $point = shift;
	my $pretty;
	foreach my $key (keys %{$point}) {
		#next if ($key eq "id");
		next unless ($point->{$key});
		if ($key eq "ts") {
			my $dt =  DateTime->from_epoch( 'epoch' => $point->{$key});			
        	if (defined $dt) {
        		$dt->set_time_zone('America/Denver');
        		my $f = DateTime::Format::RFC3339->new();
            	$pretty->{'ts'} =  $dt->strftime("%FT%TZ");
        	}
		} else {
			$pretty->{$key} = $point->{$key};
		}
	}
	return $pretty;
}

sub plotBands {
  my $population = shift;
  my $logger = get_logger();
  my @series = keys %{$population};
  $logger->debug("Plot bands");
  if (scalar @series == 1) {
    my $stats = population_stats($population->{$series[0]});
    if (defined $stats) {
      return $stats;    
    }
  } else {
    $logger->debug("No bands: ", scalar @series);
  }
  return "[]";
  
}

sub population_stats {
  my $points = shift;
  my $logger = get_logger();
  $logger->debug("Stats");
  my $sum=0;
  my $maxP = 0;
  my @squares = ();
  my @bands = ();
  my $count = scalar @{$points};
  foreach my $p (@{$points}) {
    $sum += $p;
    $maxP = $p unless ($maxP > $p);
  }
  my $mean = $sum / $count;
  $logger->debug("Mean: ", $mean);
  foreach my $p (@{$points}) {
    my $mean_diff = $p - $mean;
    push(@squares,$mean_diff*$mean_diff);
  }
  $sum = 0;
  foreach my $md (@squares) {
    $sum += $md;
  }
  my $psd = sqrt($sum/$count);
  $logger->debug("stnd dev: ", $psd);
  
  my $color_bands = {
    'odd' => "rgba(68,170,213,0.1)",
    'even'=> "rgba(0,0,0,0)"
  };
  
  #positive bands
  $mean = int($mean);
  $psd = int($psd);
  my $nth = 0;
  for (my $y = $mean;$y <= $maxP;$y += $psd) {
    my $from = $y;
    my $to = $y + $psd;
    my $color = ($nth % 2 == 0) ?  'odd' : 'even';
    
    my $label;
    if ($nth == 0) {
      $label = '+mean';
      $nth++;
    } else {
      $label = $nth++ . "th deviation";
    } 
    my $band = {
      'from' => $from,
      'to' => $to,
      'color' => $color_bands->{$color},
      'label' => {
          'text' => $label,
          'style' => {
            'color' => '#606060'
          }
      }
    };
    push(@bands,$band);
  }

  #negative bands
  $nth = 0;
  for (my $y = $mean;$y > 0;$y -= $psd) {
    my $from = $y;
    my $to = $y - $psd;
    if ($to < 0) {
      $to = 0;
    }
    my $color = ($nth % 2 == 0) ? 'odd' : 'even';
    my $label;
    if ($nth ==0) {
      $label = "-mean";
      $nth++;
    } else {
      $label = $nth++ . "th deviation";
    } 
    my $band = {
      'from' => $from,
      'to' => $to,
      'color' => $color_bands->{$color},
      'label' => {
          'text' => $label,
          'style' => {
            'color' => '#606060'
          }
      }
    };
    push(@bands,$band);
  }
    
  my $str = encode_json(\@bands);
  return $str;
  
}

sub mean_series {
  my ($points,$min,$max) = @_;
  my $count = scalar @{$points};
  my $sum = 0;
  for my $point (@{$points}) {
    $sum += $point;
  }
  my $mean = 0;
  if (defined $count && $count != 0) {
    $mean =  $sum / $count;
  } 
  return undef if ($mean == 0);
  my $series = {
    'data' => [[$min,$mean*1],[$max,$mean*1]],
    'marker' => {
      'enabled' => 0,
      'states' => {
        'hover' => {
          'enabled' => 0
        }
      }
    }
  };
  return $series;
}

sub median_series {
  my ($points,$min,$max) = @_;
  my $median;
  my @sorted = sort @{$points};
  my $length = scalar @sorted;
  my $mid_point = $length / 2;
  if ($mid_point == (int $mid_point)) {
    $median = ($sorted[$mid_point] + $sorted[$mid_point + 1])/2;  
  } else {
    $median = $sorted[int $mid_point + 1];
  }
  my $series = {
    'data' => [[$min,$median*1],[$max,$median*1]],
    'marker' => {
      'enabled' => 0
    }
  };
  return $series;
}

sub regression_series {
  my ($points) = @_;
  my $logger = get_logger();
	my $sumX=	0;
	my $sumY=	0;
	my $sumX2 = 0;
	my $sumY2 = 0;
	my $sumXY = 0;
	my $maxX = 0;
	my $minX = $points->[0]->{'x'};
	for my $p (@{$points}) {
	  my $x = $p->{'x'};
	  my $y = $p->{'y'};
		$sumX += $x;
		$sumY += $y;
		if ($x > $maxX) {
		  $maxX = $x;
		}
		if ($x < $minX) {
		  $minX = $x;
		}
	}
	my $n = scalar(@{$points});
	my $xmean = $sumX / $n;
	my $ymean = $sumY / $n;
	for my $p (@{$points}) {
	  my $x = $p->{'x'};
	  my $y = $p->{'y'};
	  my $xd = $x - $xmean;
	  my $yd = $y - $ymean;
	  $sumX2 += ($xd * $xd);
	  $sumXY += ($xd * $yd);
	  $sumY2 += ($yd * $yd);	  
	}
	my $b1 = $sumXY / $sumX2;
	my $b0 = $ymean -($b1 * $xmean);
	my $r2 = ($sumXY * $sumXY) / ($sumX2 * $sumY2);
	my $r2p = int ($r2 * 100);
	my $y0 = $b0 + ($b1*$minX);
	my $yn = $b0 + ($b1*$maxX);
  my $series = {
    'data' => [[$minX,$y0],[$maxX,$yn]],
    'name' => "(R2 = \%$r2p)",
    'marker' => {
      'enabled' => 0,
      'states' => {
        'hover' => {
          'enabled' => 0
        }
      }
    }
  };
  return $series;
	

  
}

1;
