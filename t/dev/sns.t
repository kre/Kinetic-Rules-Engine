use lib qw(/web/lib/perl);
use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;
use Data::Dumper;
Log::Log4perl->easy_init($INFO);

use Kynetx::Predicates::Amazon::SNS qw(:all);
use Kynetx::Predicates::Amazon::RequestSignatureHelper qw(
    kAWSAccessKeyId
    kAWSSecretKey
    kEndPoint
    kRequestMethod
    kRequestUri
    kSignatureParam
    kSignatureVersionParam
    kSignatureVersionValue
    kSignatureMethodParam
    kSignatureMethodValue
);
use Kynetx::Util qw(:all);
use Kynetx::Configure;

Kynetx::Configure::configure();
config_logging();
Log::Log4perl->easy_init($DEBUG);


my $logger = get_logger();
my $topic = "arn:aws:sns:us-east-1:207050638169:BitchinCamaro";

# get a random quote
$logger->debug("Get a random quote");
my $rquote = "contactless not, swipe again please";
my $ua = LWP::UserAgent->new;
my $quote_url = 'http://www.iheartquotes.com/api/v1/random?max_lines=4&show_permalink=false&show_source=0';
my $resp = $ua->request(GET $quote_url);
if ($resp->is_success) {
    $rquote = $resp->content;
    $rquote =~ s/\s+$//;
    $rquote =~ s/\\\r\\\n//;
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

my $subject = "$who $what $where";
my $protocol = "http";
my $endpoint = "http://64.55.47.131:8082/endpoint/kns/sns/FOO/BAR";


my $parm_hash = {
    kAWSAccessKeyId() => 'AKIAI3YUSFFKFNND6TRQ',
    kAWSSecretKey() => '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',
    'Subject' => $subject,
    'TopicArn' => $topic,
    'Message' => $rquote,
};

my $sns = Kynetx::Predicates::Amazon::SNS->new($parm_hash);

my $res =  $sns->dout();

print $res;

$sns->set_topic_attributes("DisplayName", $where);



$sns->Protocol($protocol);
$sns->Endpoint($endpoint);

#$sns->subscribe();
#die;

$sns->publish();
die;

$sns->NewTopicName($who);
my $n_topic = $sns->create_topic();
my $newARN = $n_topic->{'CreateTopicResponse'}->{'CreateTopicResult'}->{'TopicArn'};
$logger->debug("New topic: ", sub {Dumper($newARN)});

$sns->TopicArn($newARN);
$sns->delete_topic();

my $subs = $sns->list_subscriptions();
$logger->debug("Subscriptions: ", sub {Dumper($subs)});

$sns->TopicArn($topic);
$subs = $sns->list_subscriptions_by_topic();
$logger->debug("Subscriptions: ", sub {Dumper($subs)});

$subs = $sns->list_topics();
$logger->debug("Topics: ", sub {Dumper($subs)});
