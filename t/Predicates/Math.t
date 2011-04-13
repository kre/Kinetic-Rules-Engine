#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::Deep;
use Test::LongString;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use Data::Dumper;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Math qw/:all/;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;


use Kynetx::FakeReq qw/:all/;



#plan tests => 17;

my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);


my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();
my $key = "farmer";
my $data = "The rain in Spain stays mainly in the plain";


my $session = Kynetx::Test::gen_session($r, $rid);
my $logger = get_logger();

sub math_handle {
	my ($function,$args,$diag) = @_;
	my $val = do_math($my_req_info,$function,$args);
	my $vstring;
	if (1) {
		if (ref $val eq "ARRAY") {
			$vstring = "(" . join(",",@$val) . ")";
		} else {
			$vstring = $val;
		}
		$logger->debug( "$function(",join(",",@$args),") = $vstring");
	}
	return $val;
}

#goto ENDY;

#
# random
#
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');
like(do_math($my_req_info, 'random', [9]), qr/^\d$/, 'single digit');


like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');
like(do_math($my_req_info, 'random', [99]), qr/^\d{1,2}$/, 'single digit');


like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');
like(do_math($my_req_info, 'random', [999]), qr/^\d{1,3}$/, 'single digit');

like(do_math($my_req_info, 'md5', ["this is a test"]), qr/^([a-f0-9]){32}$/, 'md5 returns hex string');
like(do_math($my_req_info, 'sha1', ["this is a test"]), qr/^([a-f0-9]){40}$/, 'sha1 returns hex string');
like(do_math($my_req_info, 'hmac_sha1', [$data,$key]), qr/^(\C)+$/, 'hmac_sha1 returns hex string');
like(do_math($my_req_info, 'hmac_sha1_hex', [$data,$key]), qr/^([a-f0-9]){40}$/, 'hmac_sha1_hex returns hex string');
like(do_math($my_req_info, 'hmac_sha1_base64', [$data,$key]), qr/^([a-zA-Z0-9]){27}$/, 'hmac_sha1_base64 returns hex string');

like(do_math($my_req_info, 'hmac_sha256', [$data,$key]), qr/^(\C)+$/, 'hmac_sha256 returns hex string');
like(do_math($my_req_info, 'hmac_sha256_hex', [$data,$key]), qr/^([a-f0-9]){40,80}$/, 'hmac_sha256_hex returns hex string');
like(do_math($my_req_info, 'hmac_sha256_base64', [$data,$key]), qr/^([a-zA-Z0-9]){27,80}$/, 'hmac_sha256_base64 returns hex string');

ENDY:
like(math_handle( 'tan', [0.9]), qr/^\d+\.\d+$/, 'tangent');
like(math_handle( 'sin', [0.9]), qr/^\d+\.\d+$/, 'sine');
like(math_handle( 'cos', [0.9]), qr/^\d+\.\d+$/, 'cosine');

like(math_handle( 'cot', [0.9]), qr/^\d+\.\d+$/, 'cotangent');
like(math_handle( 'sec', [0.9]), qr/^\d+\.\d+$/, 'secant');
like(math_handle( 'csc', [0.9]), qr/^\d+\.\d+$/, 'cosecant');

like(math_handle( 'atan', [0.9]), qr/^\d+\.\d+$/, 'arctangent');
like(math_handle( 'asin', [0.9]), qr/^\d+\.\d+$/, 'arcsine');
like(math_handle( 'acos', [0.9]), qr/^\d+\.\d+$/, 'arccosine');

like(math_handle( 'acot', [1.505]), qr/^\d+\.\d+$/, 'arccotangent');
like(math_handle( 'asec', [1.505]), qr/^\d+\.\d+$/, 'arcsecant');
like(math_handle( 'acsc', [1.505]), qr/^\d+\.\d+$/, 'arccosecant');

like(math_handle( 'tanh', [3]), qr/^\d+\.\d+$/, 'hyperbolic tangent');
like(math_handle( 'sinh', [3]), qr/^\d+\.\d+$/, 'hyperbolic sine');
like(math_handle( 'cosh', [3]), qr/^\d+\.\d+$/, 'hyperbolic cosine');

like(math_handle( 'coth', [0.9]), qr/^\d+\.\d+$/, 'hyperbolic cotangent');
like(math_handle( 'sech', [0.9]), qr/^\d+\.\d+$/, 'hyperbolic secant');
like(math_handle( 'csch', [0.9]), qr/^\d+\.\d+$/, 'hyperbolic cosecant');

like(math_handle( 'atanh', [0.9]), qr/^\d+\.\d+$/, 'inverse arctangent');
like(math_handle( 'asinh', [0.9]), qr/^\d+\.\d+$/, 'inverse arcsine');
like(math_handle( 'acosh', [1.9]), qr/^\d+\.\d+$/, 'inverse arccosine');

like(math_handle( 'acoth', [1.9]), qr/^\d+\.\d+$/, 'inverse hyperbolic cotangent');
like(math_handle( 'asech', [0.9]), qr/^\d+\.\d+$/, 'inverse hyperbolic secant');
like(math_handle( 'acsch', [0.9]), qr/^\d+\.\d+$/, 'inverse hyperbolic cosecant');

like(math_handle( 'atan2', [1.505,.9]), qr/^\d+\.\d+$/, 'arctangent(y,x)');

like(math_handle( 'deg2rad', [180]), qr/^\d+\.\d+$/, 'deg2rad');
like(math_handle( 'grad2rad', [4]), qr/^\d+\.\d+$/, 'grad2rad');
like(math_handle( 'rad2deg', [1.5]), qr/^\d+\.\d+$/, 'rad2deg');
is(math_handle( 'grad2deg', [200]), 180, 'grad2deg');
is(math_handle( 'deg2grad', [90]), 100, 'deg2grad');
like(math_handle( 'rad2grad', [3.1415962]), qr/^200\.0\d+/, 'rad2grad');

like(math_handle( 'pi', []), qr/^3\.1415\d+/, 'pi');

diag "Expect some error messages here as we're testing error catching";
# catch errors
is(math_handle( 'atanh', [-1]), undef, 'Error: Logarithm of zero');
is(math_handle( 'cot', [0]), undef, 'Error: Divide by zero');

cmp_deeply(math_handle( 'cartesian_to_cylindrical', [1.1,1.5,1.7]), 
	bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'cartesian to cylindrical conversion');
cmp_deeply(math_handle( 'cartesian_to_spherical', [1.1,1.5,1.7]), 
	bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'cartesian_to_spherical conversion');
cmp_deeply(math_handle( 'cylindrical_to_cartesian', [1.1,1.5,1.7]), 
	bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'cylindrical_to_cartesian conversion');
cmp_deeply(math_handle( 'cylindrical_to_spherical', [1.1,1.5,1.7]), 
	bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'cylindrical_to_spherical conversion');
cmp_deeply(math_handle( 'spherical_to_cartesian', [2.02,1.5,.574]), 
	bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'spherical_to_cartesian conversion');
cmp_deeply(math_handle( 'spherical_to_cylindrical', [2.02,1.5,.574]), 
	bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'spherical_to_cylindrical conversion');

like(math_handle( 'deg2rad', [-0.5]), qr/^-\d+\.\d+$/, 'deg2rad');
like(math_handle( 'deg2rad', [90 - 51.3]), qr/^\d+\.\d+$/, 'deg2rad');
like(math_handle( 'deg2rad', [139.8]), qr/^\d+\.\d+$/, 'deg2rad');
like(math_handle( 'deg2rad', [90 - 35.7]), qr/^\d+\.\d+$/, 'deg2rad');
like(math_handle( 'great_circle_distance', 
	[-0.00872664625997165,
	  0.675442420521806,
	  2.43997029428807, 
	  0.947713783832921,
	  6378]), qr/^960\d\.\d+/, 'great_circle_distance (km)');

like(math_handle( 'great_circle_distance', 
	[-0.00872664625997165,
	  0.675442420521806,
	  2.43997029428807, 
	  0.947713783832921]), qr/^1\.50\d+/, 'great_circle_distance (radians)');

like(math_handle( 'great_circle_direction', 
	[-0.00872664625997165,
	  0.675442420521806,
	  2.43997029428807, 
	  0.947713783832921]), qr/^0\.54\d+/, 'great_circle_direction');

cmp_deeply(math_handle( 'great_circle_midpoint', 
	[-0.00872664625997165,
	  0.675442420521806,
	  2.43997029428807, 
	  0.947713783832921]), bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'great_circle_midpoint');

cmp_deeply(math_handle( 'great_circle_waypoint', 
	[-0.00872664625997165,
	  0.675442420521806,
	  2.43997029428807, 
	  0.947713783832921,0.75]), bag(re(qr/^\d+\.\d+$/),re(qr/^\d+\.\d+$/)), 'great_circle_waypoint');

like(math_handle( 'exp', [2]), qr/^\d+\.\d+$/, 'exponent');
is(math_handle( 'int', [2.999]), 2, 'int');
is(math_handle( 'abs', [-2]), 2, 'absolute value');
like(math_handle( 'log', [7.389]), qr/^1\.99\d+$/, 'logarithm');
like(math_handle( 'sqrt', [7.389]), qr/^2\.7\d+$/, 'square root');


done_testing();


1;


