package Kynetx::Predicates::Math;
# file: Kynetx/Predicates/Math.pm
# file: Kynetx/Predicates/Referers.pm
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
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Digest::MD5 qw/md5_hex/;
use Digest::SHA1 qw/sha1_hex/;
use Digest::SHA qw/hmac_sha1 hmac_sha1_hex hmac_sha1_base64
				hmac_sha256 hmac_sha256_hex hmac_sha256_base64/;
use Math::Trig;
use Math::Trig ':radial';
use Math::Trig ':great_circle';

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
do_math
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

my %predicates = (

		 );
my $funcs = {};		 

sub get_predicates {
    return \%predicates;
}


sub do_math {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $val;

    my $f = $funcs->{$function};
    if ( defined $f ) {
    	
        eval {
        	$val = $f->( $req_info, $function, $args );
        };
        if ($@) {
        	$logger->warn("Math error: $@");
        	return undef;
        } else {
        	return $val;
        }
    } else {
        $logger->debug("Function ($function) undefined");
    }


}

sub sha1 {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = sha1_hex($args->[0]);
	
	return $val;
}
$funcs->{'sha1'} = \&sha1;



sub random {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = int(rand $args->[0]);
	
	return $val;
}
$funcs->{'random'} = \&random;

sub md5 {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = md5_hex($args->[0]);
	
	return $val;
}
$funcs->{'md5'} = \&md5;

sub _hmac_sha1 {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $data = $args->[0];
    my $key = $args->[1];
    my $digest = hmac_sha1($data,$key);
    return $digest;	
}
$funcs->{'hmac_sha1'} = \&_hmac_sha1;

sub _hmac_sha1_hex {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $data = $args->[0];
    my $key = $args->[1];
    my $digest = hmac_sha1_hex($data,$key);
    return $digest;	
}
$funcs->{'hmac_sha1_hex'} = \&_hmac_sha1_hex;

sub _hmac_sha1_base64 {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $data = $args->[0];
    my $key = $args->[1];
    my $digest = hmac_sha1_base64($data,$key);
    return $digest;	
}
$funcs->{'hmac_sha1_base64'} = \&_hmac_sha1_base64;


sub _hmac_sha256 {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $data = $args->[0];
    my $key = $args->[1];
    my $digest = hmac_sha256($data,$key);
    return $digest;	
}
$funcs->{'hmac_sha256'} = \&_hmac_sha256;

sub _hmac_sha256_hex {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $data = $args->[0];
    my $key = $args->[1];
    my $digest = hmac_sha256_hex($data,$key);
    return $digest;	
}
$funcs->{'hmac_sha256_hex'} = \&_hmac_sha256_hex;

sub _hmac_sha256_base64 {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
    my $data = $args->[0];
    my $key = $args->[1];
    my $digest = hmac_sha256_base64($data,$key);
    return $digest;	
}
$funcs->{'hmac_sha256_base64'} = \&_hmac_sha256_base64;









# standard math functions
sub _exp {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = exp($args->[0]);
	
	return $val;
}
$funcs->{'exp'} = \&_exp;

sub _int {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = int($args->[0]);
	
	return $val;
}
$funcs->{'int'} = \&_int;

sub _abs {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = abs($args->[0]);
	
	return $val;
}
$funcs->{'abs'} = \&_abs;

sub _log {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = log($args->[0]);
	
	return $val;
}
$funcs->{'log'} = \&_log;

sub _sqrt {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = sqrt($args->[0]);
	
	return $val;
}
$funcs->{'sqrt'} = \&_sqrt;



# trig

sub _tan {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = tan($args->[0]);
	
	return $val;
}
$funcs->{'tan'} = \&_tan;

sub _sin {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = sin($args->[0]);
	
	return $val;
}
$funcs->{'sin'} = \&_sin;

sub _cos {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = cos($args->[0]);
	
	return $val;
}
$funcs->{'cos'} = \&_cos;

# arcus
sub _atan {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = atan($args->[0]);
	
	return $val;
}
$funcs->{'atan'} = \&_atan;

sub _asin {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = asin($args->[0]);
	
	return $val;
}
$funcs->{'asin'} = \&_asin;

sub _acos {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = acos($args->[0]);
	
	return $val;
}
$funcs->{'acos'} = \&_acos;

# cofunctions

sub _cot {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = cot($args->[0]);
	
	return $val;
}
$funcs->{'cot'} = \&_cot;

sub _sec {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = sec($args->[0]);
	
	return $val;
}
$funcs->{'sec'} = \&_sec;

sub _csc {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = csc($args->[0]);
	
	return $val;
}
$funcs->{'csc'} = \&_csc;

# arcus cofunctions
sub _acot {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = acot($args->[0]);
	
	return $val;
}
$funcs->{'acot'} = \&_acot;

sub _asec {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = asec($args->[0]);
	
	return $val;
}
$funcs->{'asec'} = \&_asec;

sub _acsc {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = acsc($args->[0]);
	
	return $val;
}
$funcs->{'acsc'} = \&_acsc;

# hyperbolic
sub _tanh {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = tanh($args->[0]);
	
	return $val;
}
$funcs->{'tanh'} = \&_tanh;

sub _sinh {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = sinh($args->[0]);
	
	return $val;
}
$funcs->{'sinh'} = \&_sinh;

sub _cosh {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = cosh($args->[0]);
	
	return $val;
}
$funcs->{'cosh'} = \&_cosh;

# hyperbolic co-functions
sub _coth {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = coth($args->[0]);
	
	return $val;
}
$funcs->{'coth'} = \&_coth;

sub _sech {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = sech($args->[0]);
	
	return $val;
}
$funcs->{'sech'} = \&_sech;

sub _csch {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = csch($args->[0]);
	
	return $val;
}
$funcs->{'csch'} = \&_csch;

# hyperbolic arcus
sub _atanh {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = 'null';
        $val = atanh($args->[0]) unless ($args->[0] == 0);
	
	return $val;
}
$funcs->{'atanh'} = \&_atanh;

sub _asinh {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = asinh($args->[0]);
	
	return $val;
}
$funcs->{'asinh'} = \&_asinh;


sub _acosh {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = acosh($args->[0]);
	
	return $val;
}
$funcs->{'acosh'} = \&_acosh;

# hyberbolic co-functions
sub _acoth {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = acoth($args->[0]);
	
	return $val;
}
$funcs->{'acoth'} = \&_acoth;

sub _asech {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = asech($args->[0]);
	
	return $val;
}
$funcs->{'asech'} = \&_asech;

sub _acsch {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = acsch($args->[0]);
	
	return $val;
}
$funcs->{'acsch'} = \&_acsch;



sub _atan2 {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = atan2($args->[0],$args->[1]);
	
	return $val;
}
$funcs->{'atan2'} = \&_atan2;


sub _deg2rad {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = deg2rad($args->[0]);
	
	return $val;
}
$funcs->{'deg2rad'} = \&_deg2rad;

sub _grad2rad {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = grad2rad($args->[0]);
	
	return $val;
}
$funcs->{'grad2rad'} = \&_grad2rad;

sub _rad2deg {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = rad2deg($args->[0]);
	
	return $val;
}
$funcs->{'rad2deg'} = \&_rad2deg;

sub _grad2deg {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = grad2deg($args->[0]);
	
	return $val;
}
$funcs->{'grad2deg'} = \&_grad2deg;

sub _deg2grad {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = deg2grad($args->[0]);
	
	return $val;
}
$funcs->{'deg2grad'} = \&_deg2grad;

sub _rad2grad {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = rad2grad($args->[0]);
	
	return $val;
}
$funcs->{'rad2grad'} = \&_rad2grad;

sub _pi {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = pi;
	
	return $val;
}
$funcs->{'pi'} = \&_pi;

# angle conversions
sub _cartesian_to_cylindrical {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = cartesian_to_cylindrical($args->[0],$args->[1],$args->[2]);
	
	return \@val;
}
$funcs->{'cartesian_to_cylindrical'} = \&_cartesian_to_cylindrical;

sub _cartesian_to_spherical {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = cartesian_to_spherical($args->[0],$args->[1],$args->[2]);
	
	return \@val;
}
$funcs->{'cartesian_to_spherical'} = \&_cartesian_to_spherical;

sub _cylindrical_to_cartesian {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = cylindrical_to_cartesian($args->[0],$args->[1],$args->[2]);
	
	return \@val;
}
$funcs->{'cylindrical_to_cartesian'} = \&_cylindrical_to_cartesian;

sub _cylindrical_to_spherical {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = cylindrical_to_spherical($args->[0],$args->[1],$args->[2]);
	
	return \@val;
}
$funcs->{'cylindrical_to_spherical'} = \&_cylindrical_to_spherical;

sub _spherical_to_cartesian {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = spherical_to_cartesian($args->[0],$args->[1],$args->[2]);
	
	return \@val;
}
$funcs->{'spherical_to_cartesian'} = \&_spherical_to_cartesian;

sub _spherical_to_cylindrical {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = spherical_to_cylindrical($args->[0],$args->[1],$args->[2]);
	
	return \@val;
}
$funcs->{'spherical_to_cylindrical'} = \&_spherical_to_cylindrical;

# Great circle functions
sub _great_circle_distance {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = great_circle_distance($args->[0],$args->[1],$args->[2],$args->[3],$args->[4]);
	
	return $val;
}
$funcs->{'great_circle_distance'} = \&_great_circle_distance;

sub _great_circle_direction {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = great_circle_direction($args->[0],$args->[1],$args->[2],$args->[3]);
	
	return $val;
}
$funcs->{'great_circle_direction'} = \&_great_circle_direction;
$funcs->{'great_circle_bearing'} = \&_great_circle_direction;

sub _great_circle_destination {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my $val = great_circle_destination($args->[0],$args->[1],$args->[2],$args->[3]);
	
	return $val;
}
$funcs->{'great_circle_destination'} = \&_great_circle_destination;

sub _great_circle_midpoint {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = great_circle_midpoint($args->[0],$args->[1],$args->[2],$args->[3]);
	
	return \@val;
}
$funcs->{'great_circle_midpoint'} = \&_great_circle_midpoint;

sub _great_circle_waypoint {
    my ($req_info, $function, $args) = @_;
    my $logger = get_logger();
	my @val = great_circle_waypoint($args->[0],$args->[1],$args->[2],$args->[3],$args->[4]);
	
	return \@val;
}
$funcs->{'great_circle_waypoint'} = \&_great_circle_waypoint;




1;
