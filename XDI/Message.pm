package XDI::Message;

use strict;
use warnings;

use Carp;
use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;
use Storable qw(dclone);
use Scalar::Util;
use Data::UUID;
use DateTime::Format::RFC3339;

require Exporter;
use vars       qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION     = 0.01;

@ISA         = qw(Exporter);
@EXPORT      = qw();
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions
@EXPORT_OK   = qw();


my %fields = (
	id => undef,
	timestamp => undef,
	from_graph => undef,
	from => undef,
	target => undef,
	link_contract => undef,
	secret => undef,
	operations => undef,
	type => undef
);


our $AUTOLOAD;
our $USE_LOCAL_MESSAGE = 1;

sub new {
	my $class  = shift;
	my $self = {%fields,};
	bless($self,$class);
	my $ug = new Data::UUID;
	$self->{'id'} = $ug->create_str() ;
#	$self->{'id'} = int(rand 10);
	$self->{'timestamp'} = &_timestamp;
	$self->{'operations'} = [];
	my ($var_hash) = @_;
	if (defined $var_hash  ) {
		if (ref $var_hash eq "HASH"){
			foreach my $varkey (keys %{$var_hash}) {
				if (exists $self->{$varkey}) {
					$self->{$varkey} = $var_hash->{$varkey};
				}
			}
		} else {
		croak "Initialization failed: parameters not passed as hash reference";
		}
	} 
	return $self;
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

sub get {
	my $self = shift;
	my $statement = shift;
	my $op = '$get';
	return $self->_add_op($op,$statement);
}

sub add {
	my $self = shift;
	my $statement = shift;
	my $op = '$add';
	return $self->_add_op($op,$statement);
}

sub mod {
	my $self = shift;
	my $statement = shift;
	my $op = '$mod';
	return $self->_add_op($op,$statement);
}

sub del {
	my $self = shift;
	my $statement = shift;
	my $op = '$del';
	return $self->_add_op($op,$statement);
}

sub to_string {
	my $self = shift;
	my @statements;
	push(@statements,$self->_local_requestor);
	push(@statements,$self->_destination);
	push(@statements,$self->_timestamp_statement);
	push(@statements,$self->_link_contract);
	if (defined $self->secret) {
		push(@statements, $self->_auth_statement)
	}
	foreach my $op (@{$self->operations}) {
		push(@statements,$self->_operation($self->type,$op));
	}
	return (join("\n",@statements));	
}

sub _id {
	my $self = shift;
	my $id = '$(!' . $self->id . ')';
	return $id;
}

sub _timestamp {
	my $now = DateTime->now;
	my $f = DateTime::Format::RFC3339->new();
	my $ts = $f->format_datetime($now);
	return $ts;
}

sub _local_requestor {
	my $self = shift;
	my $string = "(" . $self->from_graph . ')/$add/' . $self->from . '$($msg)'. $self->_id;
	return $string;
}

sub _destination {
	my $self = shift;
	my $string = $self->from . '$($msg)' . $self->_id . '/$is()/(' . $self->target . ')';
	return $string;
}

sub _timestamp_statement {
	my $self = shift;
	my $string = $self->from . '$($msg)' . $self->_id . '$d/!/(data:,' . $self->timestamp . ')';
	return $string;
}

sub _link_contract {
	my $self = shift;
	my $string = $self->from . '$($msg)' . $self->_id . '/$do/' . $self->link_contract . '$do';
	return $string;
}

sub _operation {
	my $self = shift;
	my ($op,$statement) = @_;
	my $string =  $self->from . '$($msg)' . $self->_id . '$do/' . $op . '/' . $statement;
	return $string;
}

sub _auth_statement {
	my $self = shift;
	my $string = $self->from . '$($msg)' . $self->_id .'$secret$!($token)/!/(data:,' . $self->secret . ')';
	return $string;
}

sub _add_op {
	my $self = shift;
	my ($op,$statement) = @_;
	if (! defined $self->type) {
		$self->type($op);
	} elsif ($self->type ne $op) {
		carp "XDI message may only carry one type of operations: $op($self->{'type'})";
		return 0;
	} 
	push(@{$self->operations}, $statement);	
	return 1;
}


sub DESTROY { }


END { }       # module clean-up code here (global destructor)

1;

=head1 NAME

XDI::Message - Message object for XDI client

=head1 VERSION

Version 0.01

=cut

=head1 SYNOPSIS
	
	use XDI;
	
	my $xdi = XDI->new('=tester');
	my $c = $xdi->connect({	target => '=markus', secret => "foosh"});
	$msg = $c->message({link_contract => '=!91F2.8153.F600.AE24'});
	$msg->add('(=markus/+friend/=tester)');
	$c->post($msg);
	
=head1 EXPORTS


=head1 XDI::Message

XDI::Message automatically contructs the XDI message 'envelope' and let's the user
enter queries in the XDI statement format.  Queries or operations available to the user are
the common CRUD methods ($get,$mod,$add,$del in XDI syntax).  Multiple statements can 
be included in a message, but they must all be of the same operation type; ie: no mixing
$get and $mod in the same message.

XDI statements in a message do not have an order of execution and currently a single failed 
statement will roll back the entire message transaction.

The progression from XDI to XDI::Connection to XDI::Message is designed to help construct the 
message in short, logical steps--not throwing too many configuration options in one blow; however,
XDI::Message can stand alone to build the complete XDI message.  

Since the message transport is a simple http post, XDI::message can be converted to plain text
string and included in a post as the body content.

=head1 DESCRIPTION

The XDI::Message module provides an object for constructing XDI messages L<https://wiki.oasis-open.org/xdi/XdiMessagePatterns>

=head2 Notation and Conventions

	$xdi	Root object defining identity of querier
	$c	Connection object defining graph target and permissions
	$msg	Message object for XDI messages
	$hash	Reference to a hash of key/attribute values
	$target	iname or inumber of the graph which is queried
	$secret	Shared secret for access to the I<target> graph
	$graph  From graph
	$from	XDI entity making the query
	$lc 	link contract
	
=head2 Usage Outline

=head3 Using XDI::Message to construct a self-contained XDI message

XDI messaging syntax is defined at L<https://wiki.oasis-open.org/xdi/XdiMessagePatterns>

	use XDI::Message;
	
	my $msg = new XDI::Message;
	
Set the ID of the user making the query

	$msg->from("=tester");
	
Set the ID of the graph that is making the request.  If this is being implemented in a 
peer to peer manner, this will be the same ID as the requestor.  In a mediated model where
a third party is making the requests on behalf of the requestor (perhaps a link contract management
provider that has permissions to create link contracts on the requestor's behalf) this will
be a different ID;

	$msg->from_graph('@kynetx');
	
The target graph is the authoritative graph for the XDI entity that will be queried.  When
set in the XDI::Message context, it is up to the user to guarantee that the C<target> is
a valid XDI target

	$msg->target('@example');
	
Link contracts are still being developed.  Some XDI servers may not yet enforce link contracts,
but those servers should ignore the link contract statement so it is always better to include
it.  In the beginning phases of link contracts, try the target's graph root; ie: '@example' or '=tester'

	$msg->link_contract('@example');
	
Every graph owner can set the authorization method for their graph, but a shared secret is the 
default method at this early time of implementation

	$msg->secret('kltpzyxM');
	
With the configuration done, the client can now configure the operations (CRUD) the user would
like to perform on the target graph
	

=head1 SUBROUTINES/METHODS

XDI and it's members support the common PERL OO-style syntax via AUTOLOAD

The first operation method called (get,add,mod,del) will set the XDI::Message object type
and all further operations must be of the same type else the method will fail with an error.

=head2 Constructor

	$msg = new XDI::Message;
	
	$msg = XDI::Message({from => '=tester', secret => 'kltpzyxM'})

=head2 get - Return an XDI graph

Get the whole graph for a user

	$msg->get('=!1111');
	
Get a portion of the graph

	$msg->get('@example$(+passport)$!(+country)');
	$msg->get('@example+tel$!1');
	
	$msg->get('@example+passport');

=head2 add - Add a new element to an XDI graph

Add a literal node

	$msg->add('(@example+work+fax$!(+tel)/!/(data:,+1.801.555.1212))');
	
Add a new context node

	$msg->add('(@example/()/$*(+tel))');

=head2 mod - Modify an existing element of an XDI graph

	$msg->mod('(@example$(+address)$!1$!(+state)/!/(data:,UT))');

=head2 del - Delete a portion of an XDI graph

	$msg->del('@example+birthdate');

=head2 to_string - Convert the XDI::Message object to a string

	$content = $msg->to_string();

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


