#!/usr/bin/perl -w

use strict;
use warnings;
use lib qw(/web/lib/perl);

use Test::More;
use Test::LongString;
use Test::Deep qw(
    cmp_deeply
    superbagof
    bag
    superhashof
    subhashof
    subbagof
    re
    ignore
    array_each
);

use Apache::Session::Memcached;
use DateTime;
use APR::URI;
use APR::Pool;
use Cache::Memcached;


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);
#Log::Log4perl->easy_init($DEBUG);

use Kynetx::Test;
use Kynetx::Predicates::Google;
use Kynetx::Environments;
use Kynetx::Session;
use Kynetx::Configure;
use Kynetx::Parser;
use Kynetx::Rules;
use Kynetx::Predicates::Google::OAuthHelper;


use Kynetx::FakeReq;

use Data::Dumper;
$Data::Dumper::Indent = 1;
Kynetx::Configure::configure();
my $logger = get_logger();



my $preds = Kynetx::Predicates::Google::get_predicates();
my @pnames = keys (%{ $preds } );
my $args;


my ($search_term,$eid,$val,$json,$js);


my $r = Kynetx::Test::configure();

my $rid = 'a144x16';

# test choose_action and args

my $my_req_info = Kynetx::Test::gen_req_info($rid);

$my_req_info->{"$rid:ruleset_name"} = "a144x16";
$my_req_info->{"$rid:name"} = "OAuth smoke dance";
$my_req_info->{"$rid:author"} = "MEH";
$my_req_info->{"$rid:description"} = "test rule for google data api";

my $rule_env = Kynetx::Test::gen_rule_env();
my $rule_name = "foo";


my $keys = 
  {'consumer_key' => 'kynetx.com',
   'consumer_secret' => '6aXgrwSCnpLutnJy0W8Vg5Tq'
  };

# these are KRE generic consumer tokens
($js, $rule_env) = 
 Kynetx::Keys::insert_key(
  $my_req_info,
  $rule_env,
  'google',
  $keys);


my $rightnow = Kynetx::Predicates::Time::get_time($my_req_info,'now',[{'timezone'=>'America/Denver'}]);
my $dow = Kynetx::Predicates::Time::get_time($my_req_info,'strftime',[$rightnow,"%u"
]);
#my $doww = Kynetx::Predicates::Time::get_time($my_req_info,'strftime',[$rightnow,"%d %w"]);
# Find Friday
my $offset = 5 - $dow;
if ($offset < 0) {
    $offset = 5 - $offset;
}
my $dstuff = Kynetx::Predicates::Time::get_time($my_req_info,'new',["2010-08-08T17:45"]);
my $friday = Kynetx::Predicates::Time::get_time($my_req_info,'add',["$rightnow",{"days"=>$offset}]);

my $fri_morn = Kynetx::Predicates::Time::ISO8601($friday)->set_hour(16)->truncate("to" => "hour");
my $fri_aft = Kynetx::Predicates::Time::get_time($my_req_info,'add',["$fri_morn",{"hours"=>4}]);
my $afri_morn = Kynetx::Predicates::Time::get_time($my_req_info,'atom',
    ["$fri_morn"]);
    #["$fri_morn",{'tz'=>'America/Denver'}]);
my $afri_aft = Kynetx::Predicates::Time::get_time($my_req_info,'atom',
    ["$fri_aft",{'tz'=>'America/Denver'}]);

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $session = Kynetx::Test::gen_session($r,'a144x16');

my $atoken = '1/xPC6_XCDp4UDrTui9vJR9Jo9uOuZ_TIHjUGxdJ0VV1c';
my $atoken_secret = 'EQUsSkHPrMPZ-BZ4jotxq_bQ';
#my $atoken = '1/mL1V01Uzz-EefEevlllhjASDJzosp5giNX-AIjgAVhk';
#my $atoken_secret = 'O/ulsQfjJgEUJFs70ghkt8pf';

my $scope = {
        'url' => 'http://www.google.com/calendar/feeds/',
        'surl' => 'https://www.google.com/calendar/feeds/',
        'dname' => 'Calendar',
        'turl' => 'https://www.google.com/calendar/feeds/default/settings',

};

my $email_re = qr/(\w+)\@\w+\.\w+/;
my $email_value = {
    '$t' => re($email_re)
};

my $str_value = superhashof({
    '$t' => re(qw/.*/)
});

my $date_re = qr/\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\d+/;
my $date_value = {
    '$t' => re($date_re)
};

my $author_value = {
    'email' => $email_value,
    'name' => $str_value
};

my $category_value = {
    'scheme' => $str_value,
    'term' => $str_value
};

my $generator_value = {
    'version' => $str_value,
    '$t' => $str_value,
    'uri' => $str_value
};

my $card_re = qr/\d+/;
my $cardinal_value = {
    '$t' => re($card_re)
};

my $ord_re = qr/[123456789]\d*/;
my $ordinal_value = {
    '$t' => re($ord_re)
};

my $when_value = {
    'endTime' => re($date_re),
    'startTime' => re($date_re)
};

my $entry_elements = {
        'content' => $str_value,
        'author' => array_each($author_value),
        'category' => ignore(),
        'id' => ignore(),
        'link' => ignore(),
        'published' => $date_value,
        'title' => $str_value,
        'updated' => $date_value,
        #'xmlns' => ignore(),

};
my $atom_entry_template = {
    'entry' => $entry_elements,
    'version' => ignore(),
    'encoding' => ignore()

};

my $app_entry_template = {
        #'xmlns$app' => ignore(),
        'app$edited' => $date_value,
};

my $gd_entry_template = {
        #'xmlns$gd' => ignore(),
        'gd$comments' => ignore(),
        'gd$etag' => ignore(),
        'gd$eventStatus' => ignore(),
        'gd$kind' => ignore(),
        'gd$transparency' => ignore(),
        'gd$visibility' => ignore(),
        'gd$when' => array_each(superhashof($when_value)),
        'gd$where' => ignore(),
        'gd$who' => ignore(),

};

my $gcal_entry_template = {
        #'xmlns$gCal' => ignore(),
        'gCal$anyoneCanAddSelf' => ignore(),
        'gCal$guestsCanInviteOthers' => ignore(),
        'gCal$guestsCanModify' => ignore(),
        'gCal$guestsCanSeeGuests' => ignore(),
        'gCal$sequence' => ignore(),
        'gCal$uid' => ignore(),
};

my $gcal_feed_template = {
    'gCal$timesCleaned' => ignore(),
    'gCal$timezone' => ignore(),
    'xmlns$gCal' => ignore(),
};

my $gd_feed_template = {
    'gd$etag' => ignore(),
    'gd$kind' => ignore(),
    'xmlns$gd' => ignore(),

};

my $opensearch_feed_template = {
    'openSearch$itemsPerPage' => $cardinal_value,
    'openSearch$startIndex' => $ordinal_value,
    'openSearch$totalResults' => $cardinal_value,
    #'xmlns$openSearch' => $str_value

};

my $feed_elements = {
    'title' => $str_value,
    'id' => $str_value,
    'link' => array_each(ignore()),
    'subtitle' => $str_value,
    'updated' => $date_value,
    'author' => array_each($author_value),
    'category' => ignore(),
    'generator' => ignore(), #$generator_value
    'xmlns' => ignore(),
};

my $atom_feed_template = {
    'feed' => $feed_elements,
    'encoding' => ignore(),
    'version' => ignore()
};

my $g_atom_entry =  {%$atom_entry_template};
$g_atom_entry->{'entry'} = superhashof({%{$g_atom_entry->{'entry'}},
    %$app_entry_template,
    %$gcal_entry_template,
    %$gd_entry_template
});




my $gcal_tests = 0;
my $dt_now = DateTime->now('time_zone' => 'MST');
my $dt_week = DateTime->now('time_zone' => 'MST');
$dt_week->add('days' => 1);
my $f = DateTime::Format::RFC3339->new();
my $now = $f->format_datetime($dt_now);
my $later = $f->format_datetime($dt_week);
my $what = $DICTIONARY[rand(@DICTIONARY)];
my $who = $DICTIONARY[rand(@DICTIONARY)];
my $where = $DICTIONARY[rand(@DICTIONARY)];
chomp($what);
chomp($where);
chomp($who);
my $qtime = $dt_week->ymd() . " " . $dt_week->hms();
my $rtime = $dt_week->ymd() . "T" . $dt_week->hour() . ":" . $dt_week->minute();
my $rcomments = "$what with $who at $where";
my $rwords = "$rcomments $qtime";
$rwords =~ s/[\t\n\r]//g;

isnt(Kynetx::Predicates::Google::authorized($my_req_info,$rule_env,$session,$rule_name,'null',['calendar']),
    "Random calls aren't authorized");
$gcal_tests++;

contains_string(Kynetx::Predicates::Google::authorize($my_req_info, $rule_env, $session, {},{},['calendar']), "https://www.google.com/accounts/OAuthAuthorizeToken?oauth_token", "authorize gets a URL");
$gcal_tests++;

Kynetx::Predicates::Google::OAuthHelper::store_token($rid,$session,'access_token_secret',$atoken_secret,'google','Calendar');
Kynetx::Predicates::Google::OAuthHelper::store_token($rid,$session,'access_token',$atoken,'google','Calendar');

#goto ENDY;

#### Create a calendar entry so we can can do dynamic tests
$args = {"quickadd" => $rwords};
$json = Kynetx::Predicates::Google::eval_google($my_req_info,$rule_env,$session,$rule_name,'add',['calendar',$args]);
$val = $json->{'entry'}->{'gCal$uid'}->{'value'};
$val =~ m/^(\w+)\@google.com/;
my $created_event_id= $1;
$logger->debug("event id", $created_event_id);
$logger->debug("entry", sub { Dumper($json)});
cmp_deeply($json,$g_atom_entry,"Create an event");
$gcal_tests++;

###### General tests against eval_google
my ($expected,$temp,$description);

### Calendar
$description = "Find specific event";
$expected = $atom_entry_template;
$temp = {
        'gCal$uid' => {
            'value' => re(qr/$created_event_id\@google.com/)
        }
};
$expected->{'entry'} = superhashof({
    %{$expected->{'entry'}},
    %$temp,
});
$args = { "feed" => "event", "userid" => 'kynetxtest@gmail.com',"eventid" => "$created_event_id"
};
test_google('calendar','get',$args,$expected,$description,0);

##
$description = "Get calendar events (10)";
$expected = $atom_feed_template;
my $detail = $feed_elements;
$detail->{'entry'} = array_each(superhashof({%$app_entry_template,
    %$gcal_entry_template,
    %$entry_elements
}));
$expected->{'feed'} = superhashof({%$detail,%$opensearch_feed_template});
$args = {"feed" => "event"};
test_google('calendar','get',$args,$expected,$description,0);


##
$description = "Basic projection test";
$expected = $atom_feed_template;
$detail = $feed_elements;
$detail->{'entry'} = array_each(superhashof({%$entry_elements}));
$expected->{'feed'} = superhashof({%$detail,%$opensearch_feed_template});
$args = {"feed" => "event","projection" => "basic"};
test_google('calendar','get',$args,$expected,$description,0);


##
$description = "free-busy projection test--search for Friday lunch starts at 12";
my $mdate_re = qr/\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\d+/;
my $mwhen_value = {
    'endTime' => re($date_re),
    'startTime' => re($mdate_re)
};

my $mgd_test = {
    'gd$when' => array_each(superhashof($mwhen_value)),
};
$expected = $atom_feed_template;
$detail = $feed_elements;
$detail->{'entry'} = array_each(superhashof({%$mgd_test}));
$expected->{'feed'} = superhashof({%$feed_elements,%$opensearch_feed_template});
$args = {"feed" => "event", "projection"=>"free-busy",
    "start-min"=>"$afri_morn","start-max"=>"$afri_aft"};
test_google('calendar','get',$args,$expected,$description,0);




##
$description = "free-busy projection test--search for Friday lunch starts at 11 PST";
$mdate_re = qr/\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\d+/;
$mwhen_value = {
    'endTime' => re($date_re),
    'startTime' => re($mdate_re)
};

$mgd_test = {
    'gd$when' => array_each(superhashof($mwhen_value)),
};
$expected = $atom_feed_template;
$detail = $feed_elements;
$detail->{'entry'} = array_each(superhashof({%$mgd_test}));
$expected->{'feed'} = superhashof({%$feed_elements,%$opensearch_feed_template});

$args = {"feed" => "event", "ctz"=>"America/Los Angeles", "projection"=>"free-busy",
    "start-min"=>"$afri_morn","start-max"=>"$afri_aft"};
test_google('calendar','get',$args,$expected,$description,0);


##
$description = "Full projection test";
$expected = $atom_feed_template;
$detail = $feed_elements;
$detail->{'entry'} = array_each(superhashof({%$entry_elements}));
$expected->{'feed'} = superhashof({%$detail,%$opensearch_feed_template});
$args = {"feed" => "event","projection" => "full"};
test_google('calendar','get',$args,$expected,$description,0);



##
my $start = $afri_morn;
my $end = $afri_aft;
$description = "Composite projection test";
$expected = $atom_feed_template;
$detail = $feed_elements;
$detail->{'entry'} = array_each(superhashof({%$entry_elements}));
$expected->{'feed'} = superhashof({%$detail,%$opensearch_feed_template});
$args = {"feed" => "event","projection" => "composite",
    "start-min"=>"$start","start-max"=>"$end",
    "ctz"=>"America/Denver"};
test_google('calendar','get',$args,$expected,$description,0);

ENDY:

###
#$description = "AKO test";
#$expected = $atom_feed_template;
#$detail = $feed_elements;
#$detail->{'entry'} = array_each(superhashof({%$entry_elements}));
#$expected->{'feed'} = superhashof({%$detail,%$opensearch_feed_template});
#$args = {"feed" => "event","projection" => "full",
#    "singleevents" => "true", "orderby" => "starttime","sortorder"=>"a",
#    "q" => "Open Appointment Time", "userid" => "dms\@kynetx.com",
#    "fields" => "entry(title,id,gd:when)"};
#test_google('calendar','get',$args,$expected,$description,1);


Kynetx::Session::session_cleanup($session);

sub test_google {
    my ($scope_str,$function,$args,$expected,$description,$debug) = @_;
    $gcal_tests++;
    my $json = Kynetx::Predicates::Google::eval_google($my_req_info,$rule_env,$session,$rule_name,$function,[$scope_str,$args]);
    if ($debug) {
        $logger->info("Returned from eval_google: ", sub { Dumper($json)});
    }
    cmp_deeply($json,$expected,$description);
}

plan tests => $gcal_tests;

1;


