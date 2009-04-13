package Kynetx::JSONPath;
# file: Kynetx/JSONPath.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use JSON::XS;
use Data::Dumper;


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
new
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

$Data::Dumper::Indent = 1;


# This module is a heavily modified version of JSONPath 0.8.1 - XPath for JSON
# The following notice came with that version and applies only to portions of this
# file that are unmodified.
#	
#	A port of the JavaScript and PHP versions 
#	of JSONPath which is 
#	Copyright (c) 2007 Stefan Goessner (goessner.net)
#	Licensed under the MIT licence: 
#	
#	Permission is hereby granted, free of charge, to any person
#	obtaining a copy of this software and associated documentation
#	files (the "Software"), to deal in the Software without
#	restriction, including without limitation the rights to use,
#	copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the
#	Software is furnished to do so, subject to the following
#	conditions:
#	
#	The above copyright notice and this permission notice shall be
#	included in all copies or substantial portions of the Software.
#	


sub new(){
	my $class = shift;
	my $self = bless {
		obj => undef,
		result_type => 'VALUE',
		result => [],
		subx => [],
		reserved_locs => {
			'*' => undef,
			'..' => undef,
		}
	}, $class;
	return $self;

}

sub run(){
	my $self = shift;
	$self->{'result'} = (); #reset it
	$self->{'obj'} = undef;
	my ($obj, $expr, $arg) = @_;
	#my $self->{'obj'} = $obj;
	#$self->logit( "arg: $arg");
	$self->{'result_type'} = 'VALUE';
	if ($arg && $arg->{'result_type'}){
		my $result_type = $arg->{'result_type'};
		if ($result_type eq 'PATH' | $result_type eq 'VALUE'){
			$self->{'result_type'} = $arg->{'result_type'};
		}
	}
	if ($expr and $obj && 
	    ($self->{'result_type'} eq 'VALUE' || 
	     $self->{'result_type'} eq 'PATH')) {
		my $cleaned_expr = $self->normalize($expr);
		$cleaned_expr =~ s/^\$;//;
		$self->trace($cleaned_expr, $obj, '$');
		my $result = $self->{'result'};
		
		if (defined $result){
			#print STDERR " will return result\n";
			return $result;
		} 
		#print STDERR "will return zero\n";
		return 0;
	}
}



=nd 
normalize the path expression;

=cut
sub normalize (){
	my $self = shift;
	my $x = shift;
#	my $o = $x;
	$x =~ s/"\/[\['](\??\(.*?\))[\]']\/"/&_callback_01($1)/eg;
	$x =~ s/'?(?<!@|\d)\.'?|\['?/;/g; 	#added the negative lookbehind -krhodes
	# added \d in it to compensate when 
	# comparing against decimal numbers
	$x =~ s/;;;|;;/;..;/g;
	$x =~ s/;$|'?\]|'$//g;
	$x =~ s/#([0-9]+)/&_callback_02($1)/eg;
	$self->{'result'} = [];
#	$self->logit("normalized: $o -> $x");
	return $x;
}


sub as_path(){
	my $self = shift;
	my $path = shift;
	
	my @x = split(/;/, $path);
	my $p = '';
	#the JS and PHP versions of this are totally whack
	#foreach my $piece (@x){
	for(my $i =1; $i <= $#x; $i++){
		my $piece = $x[$i];
		if ($piece =~ m/^\d+$/){
			$p .= "[$piece]";
		} else {
			$p .= "[\"$piece\"]";
		}
	}
	return $p;
}

sub store(){
	my $self = shift;
	my $path = shift;
	my $object = shift;
	if ($path){
		if ($self->{'result_type'} eq 'PATH'){
			push @{$self->{'result'}}, $self->as_path($path);
		} else {
			push @{$self->{'result'}}, $object;
		}
	}
	#print STDERR "-Updated Result to: \n";
	foreach my $res (@{$self->{'result'}}){
		#print STDERR "-- $res\n";
	} 
	
	return $path;
}

sub trace(){
	#$self->logit( "raw trace args: @_");
	my $self = shift;
	my ($expr, $obj, $path) = @_;
#	$self->logit( "in trace. $expr /// $obj /// $path");
	if ($expr || $expr =~ m/^\d+$/){
		my @x = split(/;/, $expr);
		my $loc = shift(@x);
		my $x_string = join(';', @x);
#		$self->logit("trace... expr: $expr x_string: $x_string");
		my $ref_type = ref $obj;
		my $reserved_loc = 0;
		if (exists $self->{'reserved_locs'}->{$loc}){
			$reserved_loc = 1;
		}
		
		$self->logit("loc: $loc  // $reserved_loc // $ref_type // $x_string");

		if (! $reserved_loc and  $ref_type eq 'HASH' and ($obj and exists $obj->{$loc}) ){ 
			#$self->logit( "tracing loc($loc) obj (hash)?");
			$self->trace($x_string, $obj->{$loc}, $path . ';' . $loc);
		} elsif (! $reserved_loc &&
			 $ref_type eq 'ARRAY' &&
			 $loc =~ m/^\d+$/ &&
			 $#{$obj} >= $loc) {
		    if ((ref $obj->[$loc] eq 'HASH') ||
			(ref $obj->[$loc] eq 'ARRAY')) {
#			$self->logit( ref $obj->[$loc] );
			$self->logit( "tracing $x_string //" . $obj->[$loc] . "// $loc" );
			$self->trace($x_string, $obj->[$loc], $path . ';' . $loc);
		    } else {
#			$self->logit("Just storing... leaf");
			$self->store($path, $obj);
		    }
		} elsif ($loc eq '*'){
			#$self->logit( "tracing *");
			$self->walk($loc, $x_string, $obj, $path, \&_callback_03);
		} elsif ($loc eq '!'){
			#$self->logit( "tracing !");
			$self->walk($loc, $x_string, $obj, $path, \&_callback_06);
		} elsif ($loc eq '..'){
			#$self->logit( "tracing ..");
			$self->trace($x_string, $obj, $path);
			$self->walk($loc, $x_string, $obj, $path, \&_callback_04);
		} elsif ($loc =~ /,/){
			#$self->logit( "tracing loc w comma");
			foreach my $piece ( split(/'?,'?/, $loc)){
				$self->trace($piece . ';' . $x_string, $obj, $path);
			}
		} elsif ($loc =~ /^\(.*?\)$/){
			#$self->logit( "tracing loc /^\(.*?\)\$/");
			my $path_end = $path;
			$path_end =~ s/.*;(.).*?$/$1/;
			#WTF is eobjuate?!
			$self->trace($self->eobjuate($loc, $obj, $path_end . ';' . $x_string, $obj, $path));
		} elsif ($loc =~ /^\?\(.*?\)$/){
#			$self->logit( "tracing loc /^\?\(.*?\)\$/ -> $loc");
			$self->walk($loc, $x_string, $obj, $path, \&_callback_05);
			#$self->logit( "after walk w/ 05");
		} elsif ($loc =~ /^(-?[0-9]*):(-?[0-9]*):?([0-9]*)$/){
			#$self->logit( "tracing loc ($loc) for slice");
			$self->slice($loc, $x_string, $obj, $path);
		} elsif (! $loc and $ref_type eq 'ARRAY'){
#		    $self->logit("Just storing... no trace expr");
		    $self->store($path, $obj);
		}
	} else {
	#	$self->logit( "trace no expr. will store $obj");
		$self->store($path, $obj);
	}
	#$self->logit( "leaving trace");
}

sub walk (){
	my $self = shift;
	my ($loc, $expr, $obj, $path, $funct) = @_;
#	$self->logit( "in walk. $loc /// $expr /// $obj /// $path ");
	
	if (ref $obj eq 'ARRAY'){
		
		for (my $i = 0; $i <= $#{$obj}; $i++){
			#$self->logit( "before Array func call: w/ $i /// $loc /// $expr /// $obj /// $path");
			$funct->($self, $i, $loc, $expr, $obj, $path); 
			#$self->logit( "after func call");
			
		}
	} elsif (ref $obj eq 'HASH') { # a Hash 
		my @keys = keys %{$obj};
		#print STDERR "$#keys keys in hash to iterate over:\n";
		foreach my $key (@keys){
			#$self->logit( "before Hash func call: w/ $key /// $loc /// $expr /// $obj /// $path");
			$funct->($self, $key, $loc, $expr, $obj, $path); 
			#$self->logit( "after func call");
		}
				
	}
	#$self->logit( " leaving walk");
}

sub slice(){
	my $self = shift;
	my ($loc, $expr, $obj, $path) = @_;
	$loc =~ s/^(-?[0-9]*):(-?[0-9]*):?(-?[0-9]*)$/$1:$2:$3/;
	# $3 would be if you wanted to specify the steps between the start and end.
	
	
	my @s = split (/:|,/,  $loc);
	
	my $len = 0;
	if (ref $obj eq 'HASH'){
		$len = $#{keys %{$obj}};
	} else { #array
		$len = $#{$obj};
	}
	my $start = $s[0] ? $s[0] : 0;
	my $end = undef;
	if ($loc !~ m/^:(\d+):?$/){
		$end = $s[1] ? $s[1] : $len; 
	} else {
		$end = int($s[1]) -1;
	}
	
	my $step = $s[2] ? $s[2] : 1;
	#$start = $start < 0 ? ($start + $len > 0 ? $start + $len : 0) : ($len > $start ? $start : $len);
	if ($start < 0){
		$start =  $len > 0 ? $start + $len +1: 0 ; 
		#the +1 is so that -1 gets us the last entry, -2 gets us the last two, etc...
	}
	$end = $end < 0 ? ($end + $len > 0 ? $end + $len : 0) : ($len > $end ? $end : $len); 
	#$self->logit("start: $start end: $end step: $step");
	for (my $x = $start; $x <= $end; $x += $step){
		$self->trace("$x;$expr", $obj, $path);
	}
}

sub eval_query() {
	my $self = shift;
	my ($loc, $obj) = @_;

	my $logger = get_logger();
#	$logger->debug($loc);

	if ($loc =~ m/^@\.[a-zA-Z0-9_-]*$/){
	    #$self->logit( "existence test ");
	    $loc =~ s/@\.([a-zA-Z0-9_-]*)$/$1/;

	    return $obj && $loc && exists $obj->{$loc};
	} else {
	    my $obj_type = ref($obj);
	    my ($name, $op, $rand) = 
		($loc =~ m/@\.([a-zA-Z0-9_-]*)\s*(><|<|>|<=|>=|==|!=|eq|ne)\s*["|']?([^'"]*)['|"]?/);

	    my $o = $name ? $obj->{$name} : $obj;

#	    $logger->debug("Filtering ", sub {Dumper($o)});
#	    $logger->debug("$name // $op // $rand");
	    my $rand_type = 'STRING';
	    if($rand =~ m/^\d+$/) {
		$rand_type = 'NUMBER';
	    }
	    my $result = 0;

 	    case: for ($op) {
		/^<$/ && do {
		    $result = $o < $rand;
		};
		/^>$/ && do {
		    $result = $o > $rand;
		};
		/^<=$/ && do {
		    $result = $o <= $rand;
		};
		/^>=$/ && do {
		    $result = $o >= $rand;
		};
		/^==$/ && do {
		    $result = $o == $rand;
		};
		/^!=$/ && do {
		    $result = $o != $rand;
		};
		/^eq$/ && do {
		    $result = $o eq $rand;
		};
		/^ne$/ && do {
		    $result = $o ne $rand;
		};
		/^><$/ && do {
		    if(ref $o eq 'HASH') {
			$result = exists ($o->{$rand});
		    } elsif (ref $o eq 'ARRAY') {
			foreach my $mem (@{ $o }) {
#			    $logger->debug("Searching in $name: is $mem eq to $rand?");
			    if ($mem =~ m/^\d+$/ && $rand_type eq 'NUMBER') {
				$result = $mem == $rand;
				last if $result;
			    } else {
				$result = $mem =~ m/$rand/;
				last if $result;
			    }
			}
		    } elsif(defined $o) {
#			$logger->debug("Comparing $o and $rand");
			if ($o =~ m/^\d+$/ && $rand_type eq 'NUMBER') {
			    $result = $o == $rand;
			} elsif ($o) {
			    $result = $o =~ m/$rand/;
			}
		    }
		};
	    }
#	    $logger->debug("Result of $op is ", $result ? "true" : "not true");
	    return $result ;

	}
}


sub _callback_01(){
	my $self = shift;
	#$self->logit( "in 01");
	my $arg = shift;
	push @{$self->{'result'}}, $arg;
	return '[#' . $#{$self->{'result'}} . ']';
}

sub _callback_02 {
	my $self = shift;
	#$self->logit( "in 02");
	my $arg = shift;
	return @{$self->{'result'}}[$arg];
}


sub _callback_03(){
	my $self = shift;
	#$self->logit( " in 03 ");
	my ($key, $loc, $expr, $obj, $path) = @_;
	$self ->trace($key . ';' . $expr , $obj, $path);
}

sub _callback_04(){
	my $self = shift;
	my ($key, $loc, $expr, $obj, $path) = @_;
	#$self->logit( " in 04. expr = $expr");
	if (ref $obj eq 'HASH'){
		if (ref($obj->{$key}) eq 'HASH' ){
			#$self->logit( "Passing this to trace: ..;$expr, " . $obj->{$key} . ", $path;$key\n";
			$self->trace('..;'.$expr, $obj->{$key}, $path . ';' . $key);
		} elsif (ref($obj->{$key})) { #array
			#print STDERR "--- \$obj->{$key} wasn't a hash. it was a " . (ref $obj->{$key}) . "\n";
			$self->trace('..;'.$expr, $obj->{$key}, $path . ';' . $key);
		}
	} else {
		#print STDERR "-- obj wasn't a hash. it was a " . (ref $obj) . "\n";
		if (ref($obj->[$key]) eq 'HASH' ){
			$self->trace('..;'.$expr, $obj->[$key], $path . ';' . $key);
		}
	}

}

sub _callback_05(){
	my $self = shift;
#	$self->logit( "05");
	my ($key, $loc, $expr, $obj, $path) = @_;
#	$self->logit("In 05 with $loc");
	$loc =~ s/^\?\((.*?)\)$/$1/;
	my $eval_result = 0;
	if (ref $obj eq 'HASH'){
#		$self->logit( " in 05 obj: $obj obj->{$key}: ". $obj->{$key});
	    $eval_result = $self->eval_query($loc, $obj->{$key});
	} else {
#		$self->logit( " in 05 obj: $obj obj->[$key]: ". $obj->[$key] );
	    $eval_result = $self->eval_query($loc, $obj->[$key]);
	}
#	$self->logit( "eval_result: $eval_result"); 
	if ($eval_result){
	    my $newloc = "$key;$expr";
#	    $self->logit("IT EVALLED! tracing.. $newloc");
	    $self->trace($newloc, $obj, $path);
	}
#	$self->logit( "leaving 05");
}

sub _callback_06(){
	my $self = shift;
	my ($key, $loc, $expr, $obj, $path) = @_;
	#$self->logit("in 06 $key /// $loc /// $expr /// $obj /// $path" );
	if (ref $obj eq 'HASH'){
		$self->trace($expr, $key, $path);
	}
}

my $log_count = 1;
sub logit(){
	my $self = shift;
	my $message = shift;
	my $logger = get_logger();
	$logger->debug($message);
	$log_count++;
}


1;
