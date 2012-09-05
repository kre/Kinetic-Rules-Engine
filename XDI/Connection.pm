package XDI::Connection;

use lib qw(..);

use warnings;
use strict;

use Carp qw(
	carp
	croak
	cluck
);
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Storable qw(dclone);
use Scalar::Util;
use HTTP::Request;
use LWP::UserAgent;

use XDI qw(s_debug);
use XDI::Message;

require Exporter;
use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 0.01;

@ISA         = qw(Exporter);
@EXPORT      = qw(
	iname_lookup
	inumber_lookup
	lookup
);
%EXPORT_TAGS = ( );   

@EXPORT_OK   = qw($Var1 %Hashit &func3);

use vars qw($Var1 %Hashit);
# non-exported package globals go here
use vars      qw();

# file-private lexicals go here
my %fields = (
	target => undef,
	secret => undef,
	resolve => 1,
	server => undef,
	context => 0
);

our $AUTOLOAD;
our $USE_LOCAL_MESSAGE = 1;
our $XRI_AUTHORITY = "http://xri2xdi.net";

sub new {
	my $class  = shift;
	my $xdi = shift;
	my $self = {%fields,};
	bless($self,$class);
	if (ref $xdi ne 'XDI') {		
		my ($p,$s) = XDI->s_debug();
		carp "$p requires object 'XDI' in $s";
		return undef;
	} else {
		$self->{'__xdi__'} = $xdi;
	}
	my ($var_hash) = @_;
	if (defined $var_hash  ) {
		if (ref $var_hash eq "HASH"){
			foreach my $varkey (keys %{$var_hash}) {
				if (exists $self->{$varkey}) {
					$self->{$varkey} = $var_hash->{$varkey};
				}
			}
		} else {
		croak "Initialization failed: parameters not passed as hash reference or iname string";
		}
	} 
	$self->{'server'} = lookup($self->target)->[2] unless (defined $self->{'server'});
	
	return $self;	
}

sub message {
	my $self = shift;
	my $msg = XDI::Message->new();
	$msg->from_graph($self->__xdi__->from_graph);
	$msg->from($self->__xdi__->from);
	$msg->target($self->target);
	$msg->secret($self->secret) if (defined $self->secret);
	
	return $msg;
}


sub post {
	my $self = shift;
	my $logger = get_logger();
	my ($msg,$test) = @_;
	my $body;
	if (ref $msg eq 'XDI::Message') {
		$body = $msg->to_string();
	} elsif(ref $msg eq '') {
		$body = $msg;
	} else {
		return undef;
	}
	my $resp =  _post($self->server,$body,$self->context);
	if (defined $resp) {
		return _xdi_response($resp);
	} else {
		return undef;
	}
}

sub _post {
	my ($server, $body, $context) = @_;
	my $logger = get_logger();
	my $request = HTTP::Request->new( 'POST', $server);
	my $ua = new LWP::UserAgent;
	my $cheader = 'application/xdi+json';
	if ($context) {
		$cheader .= ';contexts=1';
	}
	$request->header('accept' => $cheader);
	$request->content($body);
	my $response = $ua->request($request);
	my $code = $response->code;
	if ($response->is_success()) {
		return $response->content;
	} else {
		carp "Post: ", $response->status_line;
		return undef;
	}
		
}

sub _xdi_response {
	my ($json) = @_;
	my $struct = XDI::_decode($json);
	if (defined $struct) {
		my $tuple = XDI::pick_xdi_tuple($struct,['$false$string','!']);
		if (defined $tuple) {
			carp "XDI server returned \$false: ",$tuple->[2];
			return undef;
		} else {
			return $struct;
		}
	}
	return undef;
	
}

sub lookup {
	my $obj = shift;
	my $xdi;
	if (ref $obj eq "XDI::Connection") {
		$xdi = shift;
	} else {
		$xdi = $obj;
	}
	if (XDI::is_inumber($xdi)) {
		return inumber_lookup($xdi);
	} else {
		return iname_lookup($xdi);
	}
}

sub iname_lookup {
	my $obj = shift;
	my $iname;
	if (ref $obj eq "XDI::Connection") {
		$iname = shift;
	} else {
		$iname = $obj;
	}
	my $struct = xdi_lookup($iname);
	my $temp = XDI::pick_xdi_tuple($struct,[$iname,'$is']);
	my $inumber = $temp->[2];
	my $subject = '('. $inumber . ')$!($uri)';
	$temp = XDI::pick_xdi_tuple($struct,[$subject,'!']);
	my $url = $temp->[2];
	return [$iname,$inumber,$url];
	
}

sub inumber_lookup {
	my $obj = shift;
	my $inumber;
	if (ref $obj eq "XDI::Connection") {
		$inumber = shift;
	} else {
		$inumber = $obj;
	}
	my $iname = undef;
	my $struct = xdi_lookup($inumber);
	print Dumper($struct);
	my $subject = '('. $inumber . ')$!($uri)';
	my $temp = XDI::pick_xdi_tuple($struct,[$subject,'!']);
	my $url = $temp->[2];
	return [$iname,$inumber,$url];
	
}


sub xdi_lookup {
	my $obj = shift;
	my $iname;
	if (ref $obj eq "XDI::Connection") {
		$iname = shift;
	} else {
		$iname = $obj;
	}
	my $authority = $XRI_AUTHORITY;
	# Populate the msg with dummy XDI data
	my $rstruct = {
		"from_graph" => '=1111',
		"from" => '=1111',
		"target" => $iname,
		"link_contract" => '()',				
	};
	my $msg = XDI::Message->new($rstruct);
	$msg->get($iname);
	print $msg->to_string, "\n";
	my $resp = _post($authority,$msg->to_string);
	return XDI::_decode($resp);
}



sub AUTOLOAD {
	my $self   = shift;
	my $type   = ref($self)
	  or croak "($AUTOLOAD): $self is not an object";
	my $name = $AUTOLOAD;
	$name =~ s/.*://;
	unless ( exists $self->{$name} ) {
		carp "$name not permitted in class $type";
		return;
	}

	if (@_) {
		my $obj = shift;
		if ( ref $obj ne "" ) {
			return $self->{$name} = dclone $obj;
		}
		else {
			return $self->{$name} = $obj;
		}

	}
	else {
		return $self->{$name};
	}
}

sub DESTROY { }

END { }       # module clean-up code here (global destructor)

1;

=head1 NAME

XDI::Connection - XDI Connection and iname resolution object

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS
	
	use XDI;
	
	my $xdi = new XDI;
	my $c = $xdi->connect();
	
	..
	
	my $xdi_hash = {
		'from' => '=my_graph',
		'from_graph' => '@xdiserver'
	};
	
	my $xdi = XDI->new($hash);
	my $c = $xdi->connect({	target => '=other_graph', secret => "foosh"});
	
=head1 EXPORTS

	iname_lookup
	inumber_lookup
	lookup

=head1 XDI::Connection

Set the target graph and shared secret for the object.  Default behavior is to do
a lookup on I<target> to get the inumber and server URI that is hosting the graph. You can
provide either an iname or an inumber as the I<target> value, but the current services
do not allow an inumber to be resolved back to an iname.

=head1 DESCRIPTION

The XDI perl module provides iname resolution and provides an http post method to send
messages

=head2 Notation and Conventions

	$xdi	Root object defining identity of querier
	$c	Connection object defining graph target and permissions
	$msg	Message object for XDI messages
	$hash	Reference to a hash of key/attribute values
	$target	iname or inumber of the graph which is queried
	$secret	Shared secret for access to the I<target> graph

=head2 Usage Outline

The primary method for creating a Connection object is via the C<connect()> method of the XDI object

	$c = $xdi->connect();
	

You can pass any XDI::Connection initialization parameters to C<connect()>

	$hash = {
		target => E<lt>iname|inumberE<gt>,  # eg: =my_personal_cloud
		secret => $secret
	};
	
	$c = $xdi->connect($hash);
	
Given an I<iname>, the default behavior for XDI is to attempt to resolve the iname to it's 
corresponding inumber using the iname resolution service at xri2xdi.net. This service
also returns the URI to the graph that is authoritative for said I<iname>, during testing and
development that often proves inconvenient so you can override this behavior

	$c->resolve(0);
	
Of course, if you do that, you will have to specify the URI of the graph to which you are
sending a query

	$c->server("http://example/=my_personal_cloud");
	
You may have noticed that we haven't actually I<connected> to anything yet.  I reserve the right
to make checking the target graph for a valid link contract part of the connection process

=head3 secret

=over 2

XDI security policy is currently under discussion by the XDI Technical Committee so the placeholder for a more robust policy is to use a shared secret. Please note that the policy allows for arbitrarily complex expressions and Javascript is proposed for the expression syntax.  L<https://wiki.oasis-open.org/xdi/XdiPolicyExpression> As the policy matures, I expect to need to update the client

=back

	$graph = $c->post($msg);
	
The result is a JSON encoded representation of the nodes requested in the $get operation.  Other
operations will return an empty hash {} upon success.  Default behavior is to automatically convert
the JSON to a perl hash object

=head1 SUBROUTINES/METHODS

XDI and it's members support the common PERL OO-style syntax via AUTOLOAD

=head2 Constructor

Generally, the constructor for the XDI::Connection object is not called directly.
 
=head2 Instance variables

Instance variables are only accessible through the respective getter/setter methods.  Allowed
variables are:

=over 4

=item C<target>	#iname/inumber (string)

=item C<secret>	#target graph's shared secret (string)

=item C<resolve>	#perform automatic lookup on I<target> (boolean)

=item C<server>	#url (string)

=item C<context>	#include contexts nodes in results (boolean)

=back

=head2 message

	$msg = $c->message();
	
As usual, you can pass valid message constructor parameters to XDI::Connection::message

	$msg = $c->message({ link_contract => '=!1111'});
	
=head2 post

	$result = $c->post($msg);
	$result = $c->post($xdi_string);
	
I<post> accepts either a XDI::Message object or a perl string as a parameter and returns a perl
hash object. Currently $add operations return an empty hash {}.  In case of an HTTP or XDI error,
undef is returned.  The error message can be accessed by encapsulating the post in an eval block

	eval {
		$result = $c->post($msg);
	};
	
	if ($@) {
		# error handler
	}
	
=head2 iname_lookup

	$tuple = iname_lookup('=tester');
	
=head2 inumber_lookup

	$tuple = inumber_lookup('=!3436.F6A6.3644.4D74');
	
=head2 lookup

	$tuple = lookup(<iname | inumber>);
	
C<$tuple> is [iname,inumber,url] # for inumber_lookup, C<iname> will be undef

lookup, iname_lookup, and inumber_lookup are convenience functions to call the XDI resolution service
built into XDI::Connection. C<lookup> uses a simple method to determine whether the parameter
is an inumber or iname and then performs the appropriate I<x_lookup>

Technically, these are both XDI messages to the xri2xdi.net server
but I<x_lookup> encapsulates the whole process into an anonymous XDI message.  xri2xdi.net also allows direct 
http calls to a url, but the results are in serialized XDI JSON format.  Respectively:

=over 4

=item http://xri2xdi.net/=tester
=item http://xri2xdi.net/=!3436.F6A6.3644.4D74

=back

	BTW: currently, neither of these are valid XDI entities


=head1 AUTHOR

	Mark Horstmeier <solargroovey@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007-2012 Kynetx, Inc. 

The perl XDI client is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public
License along with this program; if not, write to the Free
Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
MA 02111-1307 USA

