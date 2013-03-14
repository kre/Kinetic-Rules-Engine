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
use strict;
use warnings;
use lib qw(/web/lib/perl);

use Test::More;
use Test::LongString;
use Test::Deep;

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool;
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Facebook qw(
    get_predicates
    authorize
);
use Kynetx::Environments qw/:all/;
use Kynetx::Session;
use Kynetx::Configure;
use Kynetx::Parser;
use Kynetx::Predicates::Google::OAuthHelper;
use Kynetx::Json;
use Kynetx::Expressions qw/:all/;


use Kynetx::FakeReq;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;
use JSON::XS;

use Data::Dumper;
$Data::Dumper::Indent = 1;
Kynetx::Configure::configure();
my $logger = get_logger();



my $preds = Kynetx::Predicates::Facebook::get_predicates();
my @pnames = keys (%{ $preds } );
my $args;
my $resp;



my $r = Kynetx::Test::configure();

my $rule_env = Kynetx::Test::gen_rule_env();

my $rid = 'a144x22';

my $session = Kynetx::Test::gen_session($r,$rid);

my $gcal_tests = 0;


my $krl_src = <<_EOL_;
ruleset a144x22 {
meta {
  name "Facebook integration"
  description <<
    Facebook and OAuth2.0 test
  >>
  author ""
  // Uncomment this line to require Markeplace purchase to use this app.
  // authz require user
  logging off
  key facebook {
    "consumer_key" : "116360591732083",
    "consumer_secret" : "40bd6da5ca2047a9e882415688119a95"
  }
}

dispatch {
  // Some example dispatch domains
  // www.exmple.com
  // other.example.com
}

global {

}

rule first_rule is active {
  select using "" setting ()
  // pre {   }
  // notify("Hello World", "This is a sample rule.");
  noop();
}
}
_EOL_

my($js);

my $ast = Kynetx::Parser::parse_ruleset($krl_src);
#$logger->debug("Ruleset: ", sub {Dumper($ast)});

my $my_req_info = Kynetx::Test::gen_req_info($rid);
$my_req_info->{"$rid:ruleset_name"} = "a144x22";
$my_req_info->{"$rid:name"} = "Facebook dance";
$my_req_info->{"$rid:author"} = "MEH";
$my_req_info->{"$rid:description"} = "test rule for facebook data api";



my $keys = {'consumer_key' => '116360591732083',
	    'consumer_secret' => '40bd6da5ca2047a9e882415688119a95'
	   };

# these are KRE generic consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'facebook',
  $keys);

my $stored_keys = 
 Kynetx::Keys::get_key(
  $my_req_info,
  $rule_env,
  'facebook');

is_deeply($stored_keys, $keys, "Keys got stored right");
$gcal_tests++;


####

# get a random quote
$logger->debug("Get a random quote");
my $rquote = "contactless not, swipe again please";
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
my $quote_url = 'http://www.iheartquotes.com/api/v1/random?max_lines=4&show_permalink=false&show_source=0';
$resp = $ua->request(GET $quote_url);
if ($resp->is_success) {
    $rquote = $resp->content;
    $rquote =~ s/\s+$//;
}

# get a random bacon salt url
$logger->debug("Get a random baconsalt url");
my $min = 43;
my $count = 305;
my $bs_index = int(rand($count)) + $min;
my $rlink = "http://www.jdfoods.net/recipe/$bs_index/";

# get a random thumbnail
$logger->debug("Get a random thumbnail");
my $rpicture = 'http://lh4.ggpht.com/_EwU6hNFA-04/SvnVCk6sfFI/AAAAAAAAABI/4YNj3B1PAFA/fob.png';
my $max = 1000;
my $photo_index = int(rand($max)) +1;
my $picassa_url = "http://picasaweb.google.com/data/feed/api/all?q=kitty&start-index=$photo_index&max-results=1&kind=photo&alt=json";
$resp = $ua->request(GET $picassa_url);
if ($resp->is_success) {
    my $content = $resp->decoded_content;
    my $json = JSON::XS::->new->decode($content);
    if ($json) {
        my $thumb = $json->{'feed'}->{'entry'}->[0]->{'media$group'}->{'media$thumbnail'}->[0]->{'url'};
        if ($thumb) {
            $rpicture = $thumb;
        }
    }
} else {
    $logger->debug("Response: ", sub {Dumper($resp)});
}

# get a random words
$logger->debug("Get random words");

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $what = $DICTIONARY[rand(@DICTIONARY)];
my $who = $DICTIONARY[rand(@DICTIONARY)];
my $where = $DICTIONARY[rand(@DICTIONARY)];
chomp($what);
chomp($where);
chomp($who);
my $rname = $what;
my $rdesc = "Choose: $where or $who";


#my $access_token = '116360591732083%7C1a33592a274963b96efba17a-100001078761602%7C6OFOTw6d2QVuPT723pD1j_GfnEE.';
#my $access_token = '116360591732083|30ec777ae0102eed70d58563-100001078761602|6Wwer9_uOj3isLpRwZkh7ncyPrk.';
my $appid = '116360591732083';
my $test_user = '100001078761602';
my $postid = '100001078761602_109264155786209';
my $access_token = '116360591732083%7C448158f9353c108533ad95f9.1-100001078761602%7CpJeVJH72BhPGJEe07Jy1_n4aUzA';

my $rule_name = "foo";


my $config_test = Kynetx::Configure::get_config('FACEBOOK');
$logger->trace("Conf file: ", sub {Dumper($config_test)});
my $config_elements = {
    'facebook' => {
        'urls' => superhashof({
            'access_token_url' => ignore(),
            'authorization_url' => ignore()
        }),
        'scope' => superhashof({
            'publish_stream' => ignore(),
            'create_event' => ignore(),
            'rsvp_event' => ignore(),
            'sms' => ignore(),
            'offline_access' => ignore()
        }),
        'objects' => superhashof( {
            'album' => ignore(),
            'event' => ignore(),
            'user' => ignore(),
        }),
        'picture' => {
            'type' => array_each(ignore()),
            'ssl' => ignore()
        },
        'search' => {
            'type' => array_each(ignore())
        },
        'paging' => array_each(ignore()),
        'writes' => ignore(),
    }
};

my $email_re = re(qw/\w+@\w+.\w+/);
my $num_re = re(qr(\d+));
my $html_re = re(qr(http[s]?:\/\/) );


my $test_metadata = {
  'timezone' => re(qr(-?\d\d?)),
  'education' => ignore(),
  'name' => 'Kay Netticks',
  'last_name' => 'Netticks',
  'email' => $email_re,
  'updated_time' => ignore(),
  'metadata' => ignore(),
  'id' => $test_user,
  'about' => ignore(),
  'first_name' => 'Kay',
  'gender'  => 'male',
  'verified' => bool(1)
};

my $prog_meta = {
    'link' => "http://www.facebook.com/apps/application.php?id=$appid",
    'subcategory' => 'Communication',
    'name' => 'KTest Appy',
    'type' => 'application',
    'metadata' => ignore(),
    'category' => 'Utilities',
    'id' => $appid
};

my $post_meta = {
    'icon' => $html_re,
    'actions' => ignore(),
    'caption' => ignore(),
    'from' =>ignore(),
    'metadata' => {
        'connections' => {
            'comments' => $html_re,
            'likes' => ignore(),
        }
    },
    'id' => ignore(),
    #'privacy' => ignore(), ## FB change ##
    'picture' => $html_re,
    'link' => $html_re,
    'name' => ignore(),
    'attribution' => ignore(),
    'created_time' => ignore(),
    'description' => ignore(),
    'message' => ignore(),
    'updated_time' => ignore(),
    'type' => 'link',
};

my $empty_response = {
  'data' => []
};

my $post_object = superhashof({
    'created_time' => ignore(),
    'updated_time' => ignore(),
    'from' => ignore(),
    'type' => ignore(),
    'id' => $num_re,
});

my $search_object = superhashof({
    'created_time' => ignore(),
    'updated_time' => ignore(),
    'from' => ignore(),
    'type' => ignore(),
});

my $user_object = superhashof({
   'name' => ignore(),
   'id' => $num_re
});

my $page_object = superhashof({
    'name' => ignore(),
    'id' => $num_re,
    'category' => ignore()
});

my $event_object = superhashof({
    'end_time' => ignore(),
    'start_time' => ignore(),
    'name' => ignore(),
    'id'=> $num_re,
});

my $link_object = $post_object;

my $search_results = superhashof({
    'data' => array_each($search_object)
});

my $list_object = {
#    'paging' => {
#        'previous' => $html_re,
#        'next' => $html_re
#    },
    'data' => array_each(ignore())
};

cmp_deeply($config_test,$config_elements,"Facebook config file test");
$gcal_tests++;

my $scope_str = 'publish_stream,create_event,rsvp_event,sms,offline_access,email,read_stream';
my @scope_arry = split(",",$scope_str);
#my $auth_re = redirect_uri=.+ruleset.+fb_callback.+scope=$scope_str/;
my $url_re = qr/var KOBJ_facebook_notice.+https:\/\/graph.facebook.com\/oauth\/authorize/;
my $result = Kynetx::Predicates::Facebook::authorize($my_req_info, $rule_env, $session, {},{},[\@scope_arry]);
cmp_deeply($result,re($url_re), "Authorize URL");
$gcal_tests++;

my $cid_re = qr/client_id=$appid/;
cmp_deeply($result,re($cid_re), "Authorize URL (client id)");
$gcal_tests++;

my $s_re = qr/scope=$scope_str/;
cmp_deeply($result,re($s_re), "Authorize URL (client id)");
$gcal_tests++;

isnt(Kynetx::Predicates::Facebook::authorized($my_req_info,$rule_env,$session,$rule_name,'null',['publish_stream']),
    "Random calls aren't authorized");
$gcal_tests++;


Kynetx::Predicates::Google::OAuthHelper::store_token($rid,$session,'access_token',$access_token,'facebook');

my $description;
my $expected;
my $results;
my $city_id;
my $sifted;
my $phil_id;
my $message;
my $picture;
my $link;
my $name;
my $post_description;

#Log::Log4perl->easy_init($DEBUG);

##
$description = "FQL call";
$expected = [{
  'last_name' => 'Netticks',
  'uid' => $test_user,
  'first_name' => 'Kay',	
}];
$args = ["select uid, first_name, last_name from user where uid = me()"];
test_facebook('fql',$args,$expected,$description,0);


##
$description = "Use FQL call to get permissions";
$expected = [
  {
    'friends_groups' => re("[01]"),
    'friends_birthday' => re("[01]"),
    'publish_stream' => re("[01]"),
    'user_likes' => re("[01]"),
    'user_interests' => re("[01]"),
    'friends_status' => re("[01]"),
    'user_online_presence' => re("[01]"),
    'email' => re("[01]"),
    'user_activities' => re("[01]"),
    'user_status' => re("[01]"),
    'ads_management' => re("[01]"),
    'user_about_me' => re("[01]"),
    'read_friendlists' => re("[01]"),
    'user_website' => re("[01]"),
    'read_insights' => re("[01]"),
    'friends_likes' => re("[01]"),
    'user_birthday' => re("[01]"),
    'user_religion_politics' => re("[01]"),
    'friends_about_me' => re("[01]"),
    'user_videos' => re("[01]"),
    'user_groups' => re("[01]"),
    'read_requests' => re("[01]"),
    'friends_checkins' => re("[01]"),
    'offline_access' => re("[01]"),
    'user_photos' => re("[01]"),
    'friends_events' => re("[01]"),
    'friends_hometown' => re("[01]"),
    'rsvp_event' => re("[01]"),
    'friends_photos' => re("[01]"),
    'user_photo_video_tags' => re("[01]"),
    'friends_activities' => re("[01]"),
    'friends_relationships' => re("[01]"),
    'friends_online_presence' => re("[01]"),
    'sms' => re("[01]"),
    'friends_videos' => re("[01]"),
    'friends_location' => re("[01]"),
    'user_events' => re("[01]"),
    'friends_religion_politics' => re("[01]"),
    'friends_website' => re("[01]"),
    'manage_pages' => re("[01]"),
    'user_hometown' => re("[01]"),
    'friends_interests' => re("[01]"),
    'friends_education_history' => re("[01]"),
    'xmpp_login' => re("[01]"),
    'friends_work_history' => re("[01]"),
    'user_checkins' => re("[01]"),
    'friends_notes' => re("[01]"),
    'user_relationships' => re("[01]"),
    'create_event' => re("[01]"),
    'user_education_history' => re("[01]"),
    'manage_friendlists' => re("[01]"),
    'publish_checkins' => re("[01]"),
    'user_work_history' => re("[01]"),
    'friends_photo_video_tags' => re("[01]"),
    'user_notes' => re("[01]"),
    'user_location' => re("[01]"),
    'read_stream' => re("[01]")
  }
];
$args = [];
test_facebook('permissions',$args,$expected,$description,0);
#goto ENDY;

##
$description = "Use FQL call to get specific permissions";
$expected = [{
	"sms"=> re("[01]"),
	"email"=> re("[01]"),
	"friends_about_me"=> re("[01]")
}];
$args = [["sms","email","friends_about_me"]];
test_facebook('permissions',$args,$expected,$description,0);


##
my $alex = '1615033098';
$description = "Facebook get with id";
$expected = $user_object;
$expected->{'bio'} =  ignore();

$args = [{'id' => $alex}];
test_facebook('get',$args,$expected,$description,0);

##
$description = "Get object picture";
$expected = re(qr(https:\/\/.+jpg|png|gif$));
$args = [{'type' => 'square','return_ssl_resources' => 1}];
test_facebook('picture',$args,$expected,$description,0);

##
$description = "Get object picture";
$expected = re(qr(http:\/\/.+jpg|png|gif$));
$args = [{'type' => 'square','return_ssl_resources' => 0}];
test_facebook('picture',$args,$expected,$description,0);


## Get the fbid for Lehi
my $city= "Lehi, Utah";
$description = "Facebook Location search";
$expected = superhashof({'data' => array_each($user_object)});
$args = [{'type' => 'page',
    'q' => $city
}];
$results = test_facebook('search',$args,$expected,$description,0);

$sifted = sift_data($results,"name",$city);
if ($sifted) {
    $city_id = $sifted->{'id'};
}
$logger->trace("Found city id: ", $city_id);

## Get the correct id for Windley
$description = "Facebook user search";
$expected = superhashof({'data' => array_each($user_object)});
$args = [{'type' => 'user',
    'q' => 'phil windley'
}];
$results = test_facebook('search',$args,$expected,$description,0);
$logger->trace("User search for Windley: ", sub {Dumper($results)});


if (defined $results) {
    my @windleys = @{$results->{'data'}};
    foreach my $phil (@windleys) {
        my $mexpected = $user_object;
        my $pid = $phil->{'id'};
        my $pargs = [{'id'=> $pid}];

        my $meta_phil = test_facebook('get',$pargs,$mexpected,$description,0);
        my $phil_loc = sift_data($meta_phil,'location');
        if ($phil_loc && $phil_loc->{'location'}->{'id'} &&
                $phil_loc->{'location'}->{'id'} eq $city_id) {
            $phil_id = $meta_phil->{'id'};
            last;
        }
    }
}

if ($phil_id) {
    $description = "get phil feed";
    $expected = $list_object;
    $args = [{'id'=>$phil_id,'connection'=>'feed'}];
    $results = test_facebook('get',$args,$expected,$description,0);
    $logger->debug("Phil's feed: ",sub{Dumper($results)});
}

##
my $post_args = {
   'id' =>  $test_user,
   'connection' => 'feed',
   'message' => $rquote,
   'picture' => $rpicture,
   'link' => $rlink,
   'name' => $rname,
   'description' => $rdesc,
   'subject' => 'failwhale',
};
my $post_id = test_post($my_req_info, $rule_env, $session,$post_args,200);




##
$description = "Get specific user metadata";
$expected = superhashof($test_metadata);
$args = [$test_user];
test_facebook('metadata',$args,$expected,$description,0);


##
#$description = "Get alternate object metadata";
#$expected =  superhashof($post_meta);
#$args = [{'id' => $postid}];
#test_facebook('metadata',$args,$expected,$description,0);

##
$description = "Get object picture";
$expected = re(qr(https:\/\/.+jpg|png|gif$));
$args = [];
test_facebook('picture',$args,$expected,$description,0);

##
$description = "Get object picture";
$expected = re(qr(https:\/\/.+jpg|png|gif$));
$args = [$appid];
test_facebook('picture',$args,$expected,$description,0);

##
$description = "Get object picture";
$expected = re(qr(https:\/\/.+jpg|png|gif$));
$args = [{'type' => 'square'}];
test_facebook('picture',$args,$expected,$description,0);

##
$description = "Get object picture";
$expected = re(qr(https:\/\/.+jpg|png|gif$));
$args = [{'type' => 'large'}];
test_facebook('picture',$args,$expected,$description,0);

##
$description = "Facebook get album for default user";
$expected = superhashof($list_object);
$args = [{'connection' => 'albums'}];
test_facebook('get',$args,$expected,$description,0);


##
$description = "Facebook get feed for default user";
$expected = superhashof($list_object);
$args = [{'connection' => 'feed','fields' => "id"}];
test_facebook('get',$args,$expected,$description,0);

##
$description = "Facebook get home for default user";
$expected = superhashof($list_object);
$args = [{'connection' => 'home'}];#,'type'=>'user'}];
test_facebook('get',$args,$expected,$description,0);

##
$description = "Facebook fields for user";
$expected = $config_test->{'facebook'}->{'objects'}->{'user'}->{'properties'};
$args = ['user'];
test_facebook('fields',$args,$expected,$description,0);

##
$description = "Facebook feed for status";
$expected = $config_test->{'facebook'}->{'objects'}->{'status'}->{'feed'};
$args = ['status'];
test_facebook('feed',$args,$expected,$description,0);

##
$description = "Facebook connections for page";
$expected = $config_test->{'facebook'}->{'objects'}->{'page'}->{'connections'};
$args = ['page'];
test_facebook('connections',$args,$expected,$description,0);

##
$description = "Facebook arguments for feed";
$expected = $config_test->{'facebook'}->{'writes'}->{'feed'}->{'parm'};
$args = ['feed'];
test_facebook('writes',$args,$expected,$description,0);

##
$description = "Get active user metadata";
$expected = superhashof($test_metadata);
$args = [];
test_facebook('metadata',$args,$expected,$description,0);

##
$description = "search news feed";
$expected = subhashof($list_object);
$args = [{'type' => 'home',
    'q' => 'P Windley'
}];
test_facebook('search',$args,$expected,$description,0);


##
$description = "Get object picture";
$expected = re(qr(https:\/\/.+jpg|png|gif$));
$args = [{'type' => 'square'},300];
test_facebook('picture',$args,$expected,$description,0);

##
$description = "Facebook get ids for default solargroovy and Kay Netticks";
my $uname1 = "solargroovy";
my $uname2 = "Windley";
$expected = {$uname1 => ignore(),$uname2 => ignore()};
$args = [{'ids' => "$uname1,$uname2"}];
test_facebook('ids',$args,$expected,$description,0);

##
$description = "Facebook specific profile information for default user";
my $f1 = "last_name";
my $f2 = "email";
$expected = {'id' => $num_re,$f1=> ignore(),$f2 => ignore()};
$args = [{'fields' => "$f1,$f2"}];
test_facebook('get',$args,$expected,$description,0);

##
$description = "Facebook specific profile information for default user";
$f1 = "last_name";
$f2 = "email";
my $f3 = "first_name";
$expected = {'id' => $num_re,$f1=> ignore(),$f2 => ignore(),$f3=>ignore()};
$args = [{'fields' => [$f1,$f2,$f3]}];
test_facebook('get',$args,$expected,$description,0);



##
$description = "Force Facebook error: okay to ignore \"Facebook request failed\"";
$expected = [];
$args = [{'type' => 'home',
    'q' => 'windley&q='
}];
test_facebook('search',$args,$expected,$description,0);

##
$description = "Facebook post search";
$expected = superhashof({'data' => array_each($post_object)});
$args = [{'type' => 'post',
    'q' => 'windley'
}];
test_facebook('search',$args,$expected,$description,0);

##
$description = "Facebook page search";
$expected = superhashof({'data' => array_each($page_object)});
$args = [{'type' => 'page',
    'q' => 'windley'
}];
test_facebook('search',$args,$expected,$description,0);

##
$description = "Facebook event search";
$expected = superhashof({'data' => array_each($event_object)});
$args = [{'type' => 'event',
    'q' => 'bacon'
}];
test_facebook('search',$args,$expected,$description,0);

##
$description = "Facebook group search";
$expected = superhashof({'data' => array_each($user_object)});
$args = [{'type' => 'group',
    'q' => 'bacon'
}];
test_facebook('search',$args,$expected,$description,0);


##
#my $link_id = '511048495_446064733495';
$description = "Facebook get with id";
$expected = $link_object;
$expected->{'from'} = {
    'name' => 'Steve Fulling',
    'id' => ignore()
};
$args = [{'id' => $post_id}];
test_facebook('get',$args,$expected,$description,0);

##
# offset no longer supported
$description = "Facebook post search with paging (limit)";
$expected = superhashof({'data' => array_each($post_object)});
$args = [{'type' => 'post',
    'q' => 'windley',
    'limit' =>3
}];
test_facebook('search',$args,$expected,$description,0);


##
my $link_id = '511048495_446064733495';
$description = "Facebook get messages for link";
$expected = superhashof({'data' => array_each(ignore)});
$args = [{'id'=>$link_id,'connection' => 'comments'}];
test_facebook('get',$args,$expected,$description,0);


##
#my $post_id = '641349049_124260134272950';
$post_args = {
   'id' =>  $post_id,
   'connection' => 'likes'
};
Kynetx::Predicates::Facebook::post_to_facebook($my_req_info, $rule_env, $session, {},{},[$post_args]);


##
$description = "Facebook post search with paging (since,until)";
$expected = superhashof({'data' => array_each($post_object)});
$args = [{'type' => 'post',
    'q' => 'windley',
    'since' =>'2010-05-18',
    'until' => 'yesterday'
}];
test_facebook('search',$args,$expected,$description,0);

##
$description = "Facebook home/news search";
$expected = $search_results;
$args = [{'type' => 'home',
    'q' => 'windley'
}];
test_facebook('search',$args,$expected,$description,0);

ENDY:

Kynetx::Session::session_cleanup($session);

sub test_post {
    my ($my_req_info, $rule_env, $session, $post_args,$code) = @_;
    Kynetx::Predicates::Facebook::post_to_facebook($my_req_info, $rule_env, $session, {},{},[$post_args],['res']);
    $result = lookup_rule_env('res',$rule_env);
    my $rcode = $result->{'status_code'};
    my $rstatus = $result->{'status_line'};
    my $content = $result->{'content'};
    my $ast = Kynetx::Json::jsonToAst($content);
    #$logger->info("Post: ", sub {Dumper($result)});
    my $id = $ast->{'id'};
    cmp_deeply($rcode,$code,$rstatus || "Post request: " . sub {Dumper($post_args)});
    $gcal_tests++;
    return $id;
}

sub sift_data {
    my ($results,$key,$value) = @_;
    my $logger = get_logger();
    my $regexp;
    if ($value){
        $regexp = qr($value);
    } ;
    if (ref $results eq 'ARRAY') {
        my @arry = @$results;
        foreach my $element (@arry) {
            return sift_data($element,$key,$value);
        }
    } elsif (ref $results eq 'HASH') {
        if (defined $results->{$key}) {
            $logger->trace("$key defined");
            return $results->{$key} unless ($value);
            my $mvalue = $results->{$key};
            if ($mvalue =~ m/$regexp/) {
                return $results;
            }
        } else {
            foreach my $mkey (keys %$results) {
                return sift_data($results->{$mkey},$key,$value);
            }
        }
    }
}

sub test_facebook {
    my ($function,$args,$expected,$description,$debug) = @_;
    $gcal_tests++;
    my $json = Kynetx::Predicates::Facebook::eval_facebook($my_req_info,$rule_env,$session,$rule_name,$function,$args);
    if ($debug) {
        $logger->info($description);
        $logger->info("Returned from eval_facebook: ", sub { Dumper($json)});
    }
    cmp_deeply($json,$expected,$description);
    return $json;
}

plan tests => $gcal_tests;

1;


