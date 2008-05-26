package Apache2::xForwardedFor;
use strict;
use warnings;

use constant DEBUG=> $ENV{'xForwardedFor_DEBUG'} || 1;
use constant TEST=> $ENV{'xForwardedFor_TEST'} || 0; # note that there are 2 testing levels TEST>1 will set the required additional header


BEGIN {
	use vars qw ($VERSION);
    $VERSION= '0.04';
}

use Apache2::Const qw(:common);

sub handler {
    my 	( $r )= shift;
    return DECLINED if $r->uri eq '/favicon.ico';
    DEBUG && print STDERR "\n============================ Apache2::xForwardedFor";

    my 	$x_forwarded_for__header_name= $r->dir_config->get('xForwardedForAlternateHeaderName') || 'X-Forwarded-For' ;
    my 	$require_header= $r->dir_config->get('xForwardedForRequire') || undef;
	
	# for testing purposes, toss in a local header value
	TEST && $r->headers_in->set( $x_forwarded_for__header_name=> '10.0.1.140' );
	my 	$x_forwarded_for__header_value= $r->headers_in->{ $x_forwarded_for__header_name };

	# if we are requiring a header to be sent, and its not there, fail immediately
	if ( $require_header ) {
		DEBUG && print STDERR "\nRequire: true";
		if ( !$x_forwarded_for__header_value ) {
			DEBUG && print STDERR "\n \theader missing";
			return FORBIDDEN;
		}
	}

	# if we are requiring an additional header to be sent, and its not there or doesn't match, fail immediately
	if 	( my $require_header_other_name= $r->dir_config->get('xForwardedForRequireHeaderName') ) {
		if ( TEST ) {
			my 	@allowable_names= $r->dir_config->get('xForwardedForRequireHeaderValue');
			$r->headers_in->set( $require_header_other_name=> $allowable_names[0] );
		}
		DEBUG && print STDERR "\nRequire Additional Header: true";
		my 	$require_header_other_value= $r->headers_in->{ $require_header_other_name };
		if 	( !$require_header_other_value ) {
			DEBUG && print STDERR "\n \tadditional required header missing";
			return FORBIDDEN;		
		}
		my 	%values_accept= map { $_=> 1 } $r->dir_config->get('xForwardedForRequireHeaderValue');
		if ( !$values_accept{ $require_header_other_value } ) {
			DEBUG && print STDERR "\n \tadditional required header invalid";
			return FORBIDDEN;		
		}
	};
	

    # Block based on Remove / Add AcceptForwarder values
    
	my 	$_accept= 0;
    my 	$remote_ip= $r->connection->remote_ip ;
	TEST && ( $remote_ip= '192.168.1.2');
	DEBUG && print STDERR "\n remote_ip__proxy: ". $remote_ip;
		my %ips_accept= map { $_=> 1 } $r->dir_config->get('xForwardedForAccept');
		if ( exists $ips_accept{$remote_ip} ) {
			$_accept= 1;
		}
		my %ips_deny= map { $_=> 1 } $r->dir_config->get('xForwardedForDeny');
		if ( exists $ips_deny{$remote_ip} ) {
			$_accept= -1;
		}

	if 	( $_accept < 0 ) {
		DEBUG && print STDERR "\n ip in blocked list";
		return FORBIDDEN;
	}
	elsif ( !$_accept && $require_header) {
		DEBUG && print STDERR "\n ip not passed, and header required";
		return FORBIDDEN;
	}
	elsif ( !$_accept && !$require_header) {
		DEBUG && print STDERR "\n ip not passed, but header not required";
	}


    DEBUG && print STDERR "\n x_forwarded_for__header_value: ".$x_forwarded_for__header_value;

    if ($x_forwarded_for__header_value) {
	my @ips = split(/,/,$x_forwarded_for__header_value);

	# we want the last value (presumably the originator)
	my $ip = pop @ips;
    
	DEBUG && print STDERR "\n using... $ip";
#    my $ip = $x_forwarded_for__header_value=~ /^([\d\.]+)/ 
	# Extract the desired IP address
	if ($ip) {
	    DEBUG && print STDERR "\n original remote_ip: ". $remote_ip;
	    $r->connection->remote_ip($ip);
	    DEBUG && print STDERR "\n new remote_ip: ".$r->connection->remote_ip;
	} else {
	    # do nothing if no ip is in forwarded-for header
	    # should we toss an error if this is because we couldn't parse an ip, but the header was there?
	    DEBUG && print STDERR "\n no ip change";
	}
    }

    # stacked handlers should still run off this
    return OK;
};

=head1 NAME

Apache2::xForwardedFor - Re-set remote_ip to incoming client's ip when running mod_perl behind a reverse proxy server. 
In other words, copy the first IP from B<X-Forwarded-For> header, which was set by your reverse proxy server, 
to the B<remote_ip> connection property.

=head1 SYNOPSIS

  in httpd.conf

    PerlModule Apache2::xForwardedFor
	PerlSetVar  xForwardedForRequire 1
	PerlSetVar  xForwardedForAccept 192.168.1.1
	PerlAddVar  xForwardedForAccept 192.168.1.2
	PerlPostReadRequestHandler Apache2::xForwardedFor
	
  also note:
  	PerlSetVar  xForwardedForRequireHeaderName X-Internal-Password
	PerlSetVar  xForwardedForRequireHeaderValue shibby

  or:
    PerlSetVar  xForwardedForRequireHeaderName X-Forwarded-Server
	PerlSetVar  xForwardedForRequireHeaderValue lanServer1
	PerlAddVar  xForwardedForRequireHeaderValue lanServer2


=head1 USAGE

At this time you simply need to load the module and add it to the PerlPostReadRequestHandler phase of your mod_perl-enabled httpd, and set a few variables.

Apache2::xForwardedFor is really flexible and does some very odd ( but neat! ) things 

Set some variables in httpd.conf, and that's it

=head1 DESCRIPTION

Apache2::xForwardedFor will let you do all this neat stuff

  migrate X-Forwarded-For headers into $c->remote_ip for proxied requests
  specify which reverse proxy servers your mod_perl app serves to using:
     a list of IPs you allow
     a list of IPs you prohibit
     a secondary header of your choice, with a set value , inserted by the reverse proxy

This allows you to limit which hosts Apache serves content to ( in a rather flexible manner ), with just a few simple settings.

=head2 Variables

=head3 xForwardedForAlternateHeaderName

should you want to receive the X-Forwarded-For info from the proxy server on another ip, the name of it would be the value of this variable.

=head3 xForwardedForRequire

require the X-Forwarded-For header (or alternate name).  return FORBIDDEN otherwise

Why would you do this?  So that by default you can use either access apache through the proxy or directly.  This is FALSE by default, if someone wants to patch to be TRUE by default, send it my way. 

=head3 xForwardedForRequireHeaderName

should you require an additional header, this is the name of it.

Why would you do this?  Maybe you don't trust your gateway/proxy admin to be filtering headers correctly.  So you want to put a hash or an internal lan marking on internal requests.

=head3 xForwardedForRequireHeaderValue

should you require an additional header (xForwardedForRequireHeaderName), this is the value.  this will be ignored if xForwardedForRequireHeaderName is not set.  if xForwardedForRequireHeader and this is UNDEF, the header value does not match, or the header is not sent, this will return FORBIDDEN

=head3 xForwardedForAccept 

single item or list of IP addresses to accept

=head3 xForwardedForDeny

single item or list of IP addresses to deny

=head1 BUGS/TODO

This doesn't support AT ALL: 

	IPV6

	X-Forwarded-Host

This doesn't fully support :

	X-Forwarded-Server

If you patch it to support those , let me know.

As illustrated in the example above, you can feign some support for X-Forwarded-Server by using the alternate header name 

=head1 DEBUG INFO

As this module is designed for use under mod_perl , it takes advantage of how mod_perl 'optimizes away' debug statements tied to false constants at compile time.

In order to Debug for testing, you must set some envelope variables-- either on the commandline, or just in HTTPD.conf before this module is included .

  xForwardedFor_DEBUG
    0 (default) , 1 (print debug info)
  
  xForwardedFor_TEST
    0 (default) , 1 ( require alternate header ) , 2 ( require alternate header and set it if not provided )

=head1 AUTHOR

 Jonathan Vanasco - cpan@2xlp.com
 http://2xlp.com 

=head1 COPYRIGHT

Copyright (c) 2006 Jonathan Vanasco. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself. 

=head1 ACKNOWLEDGEMENTS

Based on the module Apache::ForwardedFor by Jay J. Lawrence ( jlawrenc@cpan.org )

This has a lot of tweaks/additions that you might find useless

=cut

1; 
