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
use charnames ':full';

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool ();
use Cache::Memcached;
use DateTime;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Modules::This2That qw/:all/;
use Kynetx::Modules;
use Kynetx::Environments qw/:all/;
use Kynetx::Session qw/:all/;
use Kynetx::Configure qw/:all/;



use Kynetx::FakeReq qw/:all/;


use Data::Dumper;
$Data::Dumper::Indent = 1;

my $logger = get_logger();

my $preds = Kynetx::Modules::This2That::get_predicates();
my @pnames = keys (%{ $preds } );



my $r = Kynetx::Test::configure();

my $rid = 'cs_test';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

my $rule_name = 'foo';

my $rule_env = Kynetx::Test::gen_rule_env();

my $session = Kynetx::Test::gen_session($r, $rid);

my $test_count = 0;
my ($source,$result,$args,$function,$description);


# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($my_req_info, $rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
    $test_count++;
}


# XML conversion
my $XML = <<_XML_;
<sample_dataset>
        <seed name="Strawberries" type="fruit">
                <harvest_time>4 Hours</harvest_time>
                <cost type="coins">10</cost>
                <xp>1</xp>
                
        </seed>
        <seed name="Pink Roses" type="flower">
                <harvest_time>2 Days</harvest_time>
                <cost type="coins">120</cost>
                <xp>2</xp>
        </seed>
        <seed name="Tomatoes" type="fruit">
                <harvest_time>8 Hours</harvest_time>
                <cost type="coins">100</cost>
                <xp>1</xp>
        </seed>
        <seed name="Soybeans" type="vegetable">
                <harvest_time>1 Days</harvest_time>
                <cost type="coins">15</cost>
                <xp>2</xp>
        </seed>
        <tree name="Lemon Tree">
           <harvest_time>3 Days</harvest_time>
           <cost type="coins">475</cost>
        </tree>
    <tree name="Acai Tree">
       <harvest_time>2 Days</harvest_time>
       <cost type="dollars">27</cost>
    </tree>
</sample_dataset>
_XML_

my $JSON ='{"@encoding":"UTF-8","@version":"1.0","sample_dataset":{"tree":[{"cost":{"$t":"475","@type":"coins"},"@name":"Lemon Tree","harvest_time":{"$t":"3 Days"}},{"cost":{"$t":"27","@type":"dollars"},"@name":"Acai Tree","harvest_time":{"$t":"2 Days"}}],"seed":[{"cost":{"$t":"10","@type":"coins"},"xp":{"$t":"1"},"@name":"Strawberries","harvest_time":{"$t":"4 Hours"},"@type":"fruit"},{"cost":{"$t":"120","@type":"coins"},"xp":{"$t":"2"},"@name":"Pink Roses","harvest_time":{"$t":"2 Days"},"@type":"flower"},{"cost":{"$t":"100","@type":"coins"},"xp":{"$t":"1"},"@name":"Tomatoes","harvest_time":{"$t":"8 Hours"},"@type":"fruit"},{"cost":{"$t":"15","@type":"coins"},"xp":{"$t":"2"},"@name":"Soybeans","harvest_time":{"$t":"1 Days"},"@type":"vegetable"}]}}';


$description = "Convert xml string to json";
$source = 'this2that';
$function = 'xml2json';
$args = [$XML];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
is($result,$JSON,$description);
$test_count++;

# attr prefix
my $prefix = '_:_';
$description = "Change attr prefix";
$args = [$XML,{'attribute_prefix' => $prefix}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,re(qr/$prefix/), $description);

# content key
$prefix = '_t_';
$description = "Change content key";
$args = [$XML,{'content_key' => $prefix}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,re(qr/$prefix/), $description);

# private elements
my @pe = ['harvest_time','xp'];
my $ajson = '{"@encoding":"UTF-8","@version":"1.0","sample_dataset":{"tree":[{"cost":{"$t":"475","@type":"coins"},"@name":"Lemon Tree"},{"cost":{"$t":"27","@type":"dollars"},"@name":"Acai Tree"}],"seed":[{"cost":{"$t":"10","@type":"coins"},"@name":"Strawberries","@type":"fruit"},{"cost":{"$t":"120","@type":"coins"},"@name":"Pink Roses","@type":"flower"},{"cost":{"$t":"100","@type":"coins"},"@name":"Tomatoes","@type":"fruit"},{"cost":{"$t":"15","@type":"coins"},"@name":"Soybeans","@type":"vegetable"}]}}';
$description = "delete private elements";
$args = [$XML,{'private_elements' => @pe}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$ajson, $description);

# empty elements
my @ee = ['cost'];
$ajson = '{"@encoding":"UTF-8","@version":"1.0","sample_dataset":{"tree":[{"cost":{},"@name":"Lemon Tree","harvest_time":{"$t":"3 Days"}},{"cost":{},"@name":"Acai Tree","harvest_time":{"$t":"2 Days"}}],"seed":[{"cost":{},"xp":{"$t":"1"},"@name":"Strawberries","harvest_time":{"$t":"4 Hours"},"@type":"fruit"},{"cost":{},"xp":{"$t":"2"},"@name":"Pink Roses","harvest_time":{"$t":"2 Days"},"@type":"flower"},{"cost":{},"xp":{"$t":"1"},"@name":"Tomatoes","harvest_time":{"$t":"8 Hours"},"@type":"fruit"},{"cost":{},"xp":{"$t":"2"},"@name":"Soybeans","harvest_time":{"$t":"1 Days"},"@type":"vegetable"}]}}';
$description = "Remove attributes and text of elements";
$args = [$XML,{'empty_elements' => @ee}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$ajson, $description);

# Private attrs
my @pa = ['name','encoding','version'];
$ajson = '{"sample_dataset":{"tree":[{"cost":{"$t":"475","@type":"coins"},"harvest_time":{"$t":"3 Days"}},{"cost":{"$t":"27","@type":"dollars"},"harvest_time":{"$t":"2 Days"}}],"seed":[{"cost":{"$t":"10","@type":"coins"},"xp":{"$t":"1"},"harvest_time":{"$t":"4 Hours"},"@type":"fruit"},{"cost":{"$t":"120","@type":"coins"},"xp":{"$t":"2"},"harvest_time":{"$t":"2 Days"},"@type":"flower"},{"cost":{"$t":"100","@type":"coins"},"xp":{"$t":"1"},"harvest_time":{"$t":"8 Hours"},"@type":"fruit"},{"cost":{"$t":"15","@type":"coins"},"xp":{"$t":"2"},"harvest_time":{"$t":"1 Days"},"@type":"vegetable"}]}}';
$description = "Remove attributes";
$args = [$XML,{'private_attributes' => @pa}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$ajson, $description);

# Force array
$ajson = '{"@encoding":"UTF-8","@version":"1.0","sample_dataset":{"tree":[{"cost":[{"$t":"475","@type":"coins"}],"@name":"Lemon Tree","harvest_time":[{"$t":"3 Days"}]},{"cost":[{"$t":"27","@type":"dollars"}],"@name":"Acai Tree","harvest_time":[{"$t":"2 Days"}]}],"seed":[{"cost":[{"$t":"10","@type":"coins"}],"xp":[{"$t":"1"}],"@name":"Strawberries","harvest_time":[{"$t":"4 Hours"}],"@type":"fruit"},{"cost":[{"$t":"120","@type":"coins"}],"xp":[{"$t":"2"}],"@name":"Pink Roses","harvest_time":[{"$t":"2 Days"}],"@type":"flower"},{"cost":[{"$t":"100","@type":"coins"}],"xp":[{"$t":"1"}],"@name":"Tomatoes","harvest_time":[{"$t":"8 Hours"}],"@type":"fruit"},{"cost":[{"$t":"15","@type":"coins"}],"xp":[{"$t":"2"}],"@name":"Soybeans","harvest_time":[{"$t":"1 Days"}],"@type":"vegetable"}]}}';
$description = "Force array";
$args = [$XML,{'force_array' => 1}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$ajson, $description);

# Decode json
my $dJSON = Kynetx::Json::jsonToAst_w($JSON);
$description = "Decode JSON";
$args = [$XML,{'decode' => 1}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$dJSON, $description);

# Put it all together now
$dJSON = '{"sample_dataset":{"tree":[{"cost":{},"@name":"Lemon Tree","harvest_time":{"#PCDATA":"3 Days"}},{"cost":{},"@name":"Acai Tree","harvest_time":{"#PCDATA":"2 Days"}}]}}';
$description = "Multiple options";
$args = [$XML,{
	'private_attributes' => ['encoding','version'],
	'private_elements' => ['seed'],
	'empty_elements' => ['cost'],
	'content_key' => "#PCDATA",
	
}];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$dJSON, $description);


# base64 methods
$description = "Encode to base64";
$function = "string2base64";
my $plaintext = "SuperDuper: ascii";
my $expected = 'U3VwZXJEdXBlcjogYXNjaWk=';
$args = [$plaintext];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$expected, $description);

$description = "Decode from base64";
$function = "base642string";
my $base64 = 'U3VwZXJEdXBlcjogYXNjaWk=';
$expected = "SuperDuper: ascii";
$args = [$base64];
 
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$expected, $description);

$description = "URL safe encode to base64";
$function = "url2base64";
$plaintext = "3+4/7 = 1";
$expected = 'Mys0LzcgPSAx';
$args = [$plaintext];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$expected, $description);

$description = "URL safe decode from base64";
$function = "base642url";
$base64 = 'Mys0LzcgPSAx';
$expected = '3+4/7 = 1';
$args = [$base64];

$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$test_count++;
cmp_deeply($result,$expected, $description);


# twitter auth token
my $onamespace = "anon";
my $js;
my $anontoken = {
	'access_token' => '100844323-XqQfRm33tQqp54mmhKCfNF9VIOaxVISrIYTOTXOy',
	'access_token_secret' => 'QdGk4MGc2RiNuD5MHjL5GVk9m1h3SsooGeMWfUQb7f0'
};

my $keys = {
	'consumer_key' => 'jPlIPAk1gbigEtonC2yNA',
   	'consumer_secret' => '3HNb7NhKuqRIm2BuxKPSg6JYvMtLahvkMt6Std5SO0'
};

# these are anonymous consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  $onamespace,
  $keys);

my $turl = 'https://api.twitter.com/1.1/statuses/user_timeline.json';
my $num_t = 50;
my $user_id = "13524182"; #Dave Wiegel
$args = [$onamespace, {
		'url' => $turl,
		'params' => {
			'include_entities' => 'true',
			'include_rts' => 'true',
			'user_id' => $user_id,
			'count' => $num_t,
			'trim_user' => 1
		},
		'access_tokens' => $anontoken
	}];

$result = Kynetx::Modules::OAuthModule::run_function($my_req_info,$rule_env,$session,$rule_name,'get',$args);

my $twit_array = Kynetx::Json::decode_json($result->{'content'});
my $t_hash;
my $i = 0;
foreach my $tweet (@{$twit_array}) {
   $t_hash->{'a' . $i++} = $tweet;
}


######################
#Log::Log4perl->easy_init($DEBUG);
######################
my ($path,$path2,$opts,$l,$c);
$path = 'retweet_count';
$description = "Sorted Array function";
$opts = {
  'path' => [$path],
  'reverse' => 1,
};
$function = 'transform';
$args = [$twit_array,$opts];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$l = scalar @{$result};
cmp_deeply(
  $result->[0]->{$path} >= $result->[1]->{$path} &&
  $result->[0]->{$path} >= $result->[$l -1]->{$path},
  1, $description);
$test_count++;

#t_display($result,[$path]);

$path = 'retweet_count';
$path2 = 'favorite_count';
$description = "Sorted Array function,2 field sort";
$opts = [{
  'path' => [$path],
  'reverse' => 1,
  },
  {
    'path' => [$path2]
  }

];
$function = 'transform';
$args = [$twit_array,$opts];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$l = scalar @{$result};
cmp_deeply(
  $result->[0]->{$path} >= $result->[1]->{$path} &&
  $result->[0]->{$path} >= $result->[$l -1]->{$path},
  1, $description);
$test_count++;

#t_display($result,[$path,$path2]);

$path = 'created_at';
$description = "Sorted Array function, date";
my $format = '%a %b %d %H:%M:%S %z %Y';
$opts = {
  'path' => [$path],
  'compare' => 'datetime',
  'date_format' => $format
  
};
$function = 'transform';
$args = [$twit_array,$opts];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$l = scalar @{$result};
$a = Kynetx::KTime->parse_datetime($result->[0]->{$path},$format)->epoch;
$b = Kynetx::KTime->parse_datetime($result->[1]->{$path},$format)->epoch;
$c = Kynetx::KTime->parse_datetime($result->[$l -1]->{$path},$format)->epoch;
cmp_deeply(
   $a <= $b && $b <= $c,
  1, $description);
$test_count++;

#t_display($result,[$path]);

$path = 'retweet_count';
$path2 = 'created_at';
$description = "Sorted Array function,2 field sort, number & datetime";
$format = '%a %b %d %H:%M:%S %z %Y';
$opts = [{
  'path' => [$path],
  'reverse' => 1,
  },
  {
    'path' => [$path2],
    'compare' => 'datetime',
    'date_format' => $format
  }

];
$function = 'transform';
$args = [$twit_array,$opts];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
$l = scalar @{$result};

cmp_deeply(
  $result->[0]->{$path} >= $result->[1]->{$path} &&
  $result->[0]->{$path} >= $result->[$l -1]->{$path},
  1, $description);
$test_count++;



#t_display($result,[$path,$path2]);
$path = 'retweet_count';
$path2 = 'created_at';
$format = '%a %b %d %H:%M:%S %z %Y';
$description = "Sorted Array function,2 field sort, number & datetime";
$opts = [{
  'path' => [$path],
  'reverse' => 1,
  'compare' => 'string'
  },
  {
    'path' => [$path2],
    'compare' => 'datetime',
    'date_format' => $format
  }

];
$function = 'transform';
$args = [$twit_array,$opts];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
$l = scalar @{$result};
$a = $result->[0]->{$path};
$b = $result->[1]->{$path};
$c = $result->[$l - 1]->{$path};

$logger->debug("A: $a");
$logger->debug("B: $b");
$logger->debug("C: $c");
cmp_deeply(
   "$a" ge "$b" && "$b" ge "$c",
  1, $description);
$test_count++;


$description = "Sort tweets by retweet count";
$function = "transform";
$opts = {
  'path' => ['retweet_count'],
  'compare' => 'numeric',
  'reverse' => 1
};
$expected = scalar (@{$twit_array});

$args = [$t_hash,$opts];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));

$l = scalar @{$result};

cmp_deeply($l,$expected, $description);
$test_count++;


is(($t_hash->{$result->[0]}->{$path} >= $t_hash->{$result->[1]}->{$path}) &&
    ($t_hash->{$result->[0]}->{$path} >= $t_hash->{$result->[$l -1]}->{$path}),1, $description);
$test_count++;


$description = "Check index and limit option (slice)";
my $index = 10;
$l = 10;
$opts = {
  'path' => ['retweet_count'],
  'compare' => 'numeric'
};
my $gopts = {
  'index' => $index,
  'limit' => $l
};
$args = [$t_hash,$opts,$gopts];
$result = Kynetx::Expressions::den_to_exp(
            Kynetx::Modules::eval_module($my_req_info,
                       $rule_env,
                       $session,
                       $rule_name,
                       $source,
                       $function,
                       $args
                      ));
                      
                   
is(($t_hash->{$result->[0]}->{$path} >= $t_hash->{$result->[1]}->{$path}) &&
    ($t_hash->{$result->[0]}->{$path} >= $t_hash->{$result->[$l -1]}->{$path}),'', $description);
$test_count++;




#h_display($t_hash,$result,[$path]);

######################
#goto ENDY;
######################

ENDY:
done_testing($test_count);

sub h_display {
  my ($hash,$tweets,$fields) = @_;
  $logger->debug("Sample: ",sub {Dumper($hash->{$tweets->[0]})});
  my $header = "id\t\t";
  foreach my $f (@{$fields}) {
    $header .= "$f\t"
  }
  $logger->debug($header);
  foreach my $tweet (@{$tweets}) {
    my $id = $hash->{$tweet}->{'id'};
    my $row = "$id\t\t";
    foreach my $f (@{$fields}) {
      $row .= $hash->{$tweet}->{$f}."\t"
    }
    $logger->debug($row);
  }
  
}

sub t_display {
  my ($tweets,$fields) = @_;
  $logger->debug("Sample: ",sub {Dumper($tweets->[0])});
  my $header = "id\t\t";
  foreach my $f (@{$fields}) {
    $header .= "$f\t"
  }
  $logger->debug($header);
  foreach my $tweet (@{$tweets}) {
    my $id = $tweet->{'id'};
    my $row = "$id\t\t";
    foreach my $f (@{$fields}) {
      $row .= $tweet->{$f}."\t"
    }
    $logger->debug($row);
  }
}

__DATA__

{
	"0001" : {
		"type": "donut",
		"name": "Cake",
		"ppu": 0.45,
		"ppc": 1,
		"batters":
			{
				"batter":
					[
						{ "id": "1001", "type": "Regular" },
						{ "id": "1002", "type": "Chocolate" },
						{ "id": "1003", "type": "Blueberry" },
						{ "id": "1004", "type": "Devil's Food" }
					]
			},
		"topping":
			[
				{ "id": "5001", "type": "None" },
				{ "id": "5002", "type": "Glazed" },
				{ "id": "5005", "type": "Sugar" },
				{ "id": "5007", "type": "Powdered Sugar" },
				{ "id": "5006", "type": "Chocolate with Sprinkles" },
				{ "id": "5003", "type": "Chocolate" },
				{ "id": "5004", "type": "Maple" }
			]
	},
	"0002" : 	{
		"type": "donut",
		"name": "Raised",
		"ppu": 0.55,
		"ppc": 10,
		"batters":
			{
				"batter":
					[
						{ "id": "1001", "type": "Regular" }
					]
			},
		"topping":
			[
				{ "id": "5001", "type": "None" },
				{ "id": "5002", "type": "Glazed" },
				{ "id": "5005", "type": "Sugar" },
				{ "id": "5003", "type": "Chocolate" },
				{ "id": "5004", "type": "Maple" }
			]
	},
  "0003":	{
		"type": "donut",
		"name": "Old Fashioned",
		"ppu": 0.551,
		"ppc": 100,
		"batters":
			{
				"batter":
					[
						{ "id": "1001", "type": "Regular" },
						{ "id": "1002", "type": "Chocolate" }
					]
			},
		"topping":
			[
				{ "id": "5001", "type": "None" },
				{ "id": "5002", "type": "Glazed" },
				{ "id": "5003", "type": "Chocolate" },
				{ "id": "5004", "type": "Maple" }
			]
	},
		"0004" : {
		"type": "muffin",
		"name": "Poppy seed",
		"ppu": 0.75,
		"ppc": 2,
		"batters":
			{
				"batter":
					[
						{ "id": "1001", "type": "Regular" },
						{ "id": "1002", "type": "Chocolate" },
						{ "id": "1003", "type": "Blueberry" },
						{ "id": "1004", "type": "Devil's Food" }
					]
			},
		"topping":
			[
				{ "id": "5001", "type": "None" },
				{ "id": "5002", "type": "Glazed" },
				{ "id": "5005", "type": "Sugar" },
				{ "id": "5007", "type": "Powdered Sugar" },
				{ "id": "5006", "type": "Chocolate with Sprinkles" },
				{ "id": "5003", "type": "Chocolate" },
				{ "id": "5004", "type": "Maple" }
			]
	}	
}

