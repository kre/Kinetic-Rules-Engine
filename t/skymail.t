#!/usr/bin/perl -w
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
use lib qw(/web/lib/perl);
use strict;
use warnings;

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use URI::Escape;
use Cache::Memcached;
use Email::MIME;
use MIME::QuotedPrint::Perl;
use MIME::Base64;
use Encode;
use Email::Sender::Simple qw(sendmail);
use Email::MIME::Creator;
use IO::File;
use IO::All;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Actions qw/:all/;
use Kynetx::Modules::Email qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;
use Kynetx::Expressions qw/:all/;
use Kynetx::Parser qw/:all/;


use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();

my $token = 'e277e9a0-3584-012f-dee4-00163e411455';
my $image_file = "/web/lib/perl/t/data/emails/images/jpeg_attach.jpg";
my $b64;
my $buf;
my $fh;
open(FILE, $image_file);
while (read(FILE,$buf,60*57)) {
	$b64 .= MIME::Base64::encode_base64($buf);
}
#my $blob = <$fh>;
#my $b64 = MIME::Base64->encode_base64($blob);


$logger->debug("File: ", sub {Dumper($b64)});

# Create a text/plain part
my $text_plain = Email::MIME->create(
	attributes => {
		content_type => "text/plain"
	},
	body => 'This is plain text'
);

my $x_urlencode = Email::MIME->create(
	attributes => {
		content_type => "application/x-www-form-urlencoded"
	},
	body => 'sun=shine'
);

my $image = Email::MIME->create(
	attributes => {
		filename => "jpeg_attach.jpg",
		content_type => "image/jpeg",
		name => "attached_image.jpeg",
		encoding => "base64"
	},
	#body => $b64,
	body => io($image_file)->all,
);
$image->encoding_set("base64");

tester($x_urlencode,$text_plain,$image);



sub tester {
	my @parts = @_;
	my $to = 'sky.' . $token . '@localhost';
	my $from = 'null@localhost';
	my $email = Email::MIME->create(
		header_str => [
			From => $from,
			To => $to
		],
		parts => [@parts]
	);
	diag $email->debug_structure();
	sendmail($email);
}
1;


