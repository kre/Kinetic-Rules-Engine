#!/usr/bin/perl -w

use lib qw(
  /web/lib/perl
  /web/etc
);
use strict;

use Log::Log4perl qw(get_logger :levels);
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Response;
use HTTP::Message;
use Data::Dumper;
use Getopt::Std;

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
use amazon_credentials qw(
  get_key_id
  get_access_key
);

use Kynetx::Util qw(:all);
use Kynetx::Configure;
use Kynetx::Directives qw(
  set_options
);
use Kynetx::Json qw(
  get_items
);
use DateTime::Format::ISO8601;

Kynetx::Configure::configure();
Log::Log4perl->easy_init($INFO);
my $logger = get_logger();

use vars qw(
  %opt
);

my $opt_string = 'hlas:m:v:T:S:P:D:N:';
getopts( "$opt_string", \%opt );
&usage() if $opt{'h'};

if ( exists $opt{'v'} && $opt{'v'} eq '2' ) {
    Log::Log4perl->easy_init($TRACE);
    $logger->trace("Verbose output enabled");

} elsif ( exists $opt{'v'} && $opt{'v'} eq '1' ) {
    Log::Log4perl->easy_init($DEBUG);
    $logger->debug("Detailed output enabled: ");
} elsif ( exists $opt{'v'} && $opt{'v'} eq '0' ) {

    # no logging
} elsif ( exists $opt{'v'} ) {
    usage("Requires a log level: $0 -v <0 | 1 | 2>");
}

# need the kynetx Amazon credentials

my $key    = get_key_id();
my $secret = get_access_key();

#my $topics = get_topics();

$logger->trace("Amazon user cred: $key");

if ( $opt{'l'} ) {
    pprint( "Topics:", get_topics() );
}

if ( $opt{'a'} ) {
    pprint( "Subscriptions", get_subscriptions() );
}

if ( exists $opt{'s'} ) {
    $logger->debug( "Get subscriptions for topic: ", $opt{'s'} );
    if ( $opt{'s'} eq '' ) {
        usage("Topic required: $0 -s <topic> ");
    }
    my $topic = get_topic( $opt{'s'} );
    pprint( "Subscribers to: $topic", get_topic_subscriptions($topic) );
}

if ( $opt{'T'} ) {
    my $topic = get_topic( $opt{'T'} );
    if ( $opt{'m'} ) {
        my $rid = $opt{'m'};
        usage("Cache target and topic required: $0 -m <'all' | rid> -T <topic>")
          unless ( $topic && $rid );
        do_publish( $topic, $rid );
    } elsif ( $opt{'S'} ) {
        my $subscriber = $opt{'S'};
        my $endpoint;

        usage(
"You must specify a Topic and Subscriber: $0 -S <IP address[:port] | email> -T <topic>"
        ) unless ( $subscriber && $topic );

        my $protocol = $opt{'P'};
        if ( !$protocol ) {
            $protocol = 'http' unless ( $subscriber =~ m/\w+@\w+\.\w+/ );
        }
        $protocol = $protocol || 'email';
        if ( $protocol =~ m/^http/ ) {
            $endpoint = "$protocol://$subscriber/endpoint/kns/sns/";
        } else {
            $endpoint = $subscriber;
        }
        pprint( "Found:", "$topic, $endpoint, $protocol" );
        my $s = get_subscription( $topic, $endpoint, $protocol );

    } elsif ( $opt{'N'} ) {
        my $displayname = $opt{'N'};
        usage(
"You must specify a Topic and new DisplayName: $0 -D <displayname> -T <topic>"
        ) unless ( $displayname && $topic );
        my $resp = do_rename( $topic, $displayname  );
        pprint("Set DisplayName to $displayname",$resp);
    } else {
        my $s = new_topic( $opt{'T'} );
        pprint( "New SNS Topic:", $s );
    }
} elsif ( $opt{'D'} ) {
    my $topic = get_topic( $opt{'D'} );
    my $msg;
    my $resp;
    if ($topic) {
        $msg  = "Deleting $topic";
        $resp = do_delete($topic);
    } else {
        $msg  = $opt{'D'} . " is not a valid topic: ";
        $resp = get_topics();
    }
    pprint( $msg, $resp );
}

sub do_rename {
    my ( $topic, $displayname ) = @_;
    my $hash = { 'TopicArn' => $topic };
    my $parm = {
        'DisplayName' => $displayname
    };
    my $sns  = get_sns($hash);
    my $resp = $sns->set_topic_attributes($parm);
    if ($resp) {
        return 'ok';
    } else {
        return 'failed';
    }

}

sub do_publish {
    my ( $topic, $rid ) = @_;
    my $directive = Kynetx::Directives->new("kns");
    $topic =~ m/.+:(\w+)$/;
    my $action = $1;
    my $options = { 'action' => $action };
    if ( $rid ne 'all' ) {
        $options->{'rid'} = $rid;
    }
    $directive->set_options($options);
    my $json = Kynetx::Json::astToJson( $directive->to_directive() );
    $logger->trace( "Flush directive: ", $json );
    my $r = _send_message( $topic, $json );
    $logger->debug( "Pub Resp: ", sub { Dumper($r) } );

    #pprint("Message sent:",$msgId);

}

sub _send_message {
    my ( $topic, $msg ) = @_;
    my $timestamp = DateTime->now;
    my $hash = {
                 'Subject'  => "KNS admin request $timestamp",
                 'TopicArn' => $topic,
                 'Message'  => $msg
    };
    my $sns = get_sns($hash);
    my $r   = $sns->publish();
    $logger->debug( "Pub resp: ", sub { Dumper($r) } );
}

sub get_topic_subscriptions {
    my ($topic) = @_;
    my $hash = { 'TopicArn' => $topic };
    my $sns  = get_sns($hash);
    my $o    = $sns->list_subscriptions_by_topic();
    my $list = Kynetx::Json::get_items( $o, "Endpoint" );
    return $list;
}

sub get_subscriptions {
    my $sns = get_sns();
    my $t   = $sns->list_subscriptions();
    my $list;
    my $o = Kynetx::Json::get_items( $t, "member" );
    return $o;

    #$logger->debug("Subscriptions: ", sub {Dumper($t)});
}

sub do_delete {
    my ($topic) = @_;
    my $hash = { 'TopicArn' => $topic };
    my $sns  = get_sns($hash);
    my $resp = $sns->delete_topic();
    if ($resp) {
        return 'ok';
    } else {
        return 'failed';
    }
}

sub get_subscription {
    my ( $topic, $endpoint, $protocol ) = @_;
    my $hash = {
                 'TopicArn' => $topic,
                 'Endpoint' => $endpoint,
                 'Protocol' => $protocol
    };
    my $sns = get_sns($hash);
    return $sns->subscribe();
}

sub get_topic {
    my ($name) = @_;
    my $list = get_topics();
    my %found;
    map { $found{$_} = 1 } @{$list};
    if ( $found{$name} ) {
        return $name;
    } else {

        # Search for the TopicARN via text portion
        #my $regexp = qr($)
        foreach my $element (@$list) {
            if ( $element =~ m/.+$name$/ ) {
                return $element;
            }
        }
    }
}

sub get_topics {
    my $sns = get_sns();
    my $t   = $sns->list_topics();
    my $list;
    my $o = Kynetx::Json::get_items( $t, "TopicArn" );
    return $o;
}

sub new_topic {
    my ($name) = @_;
    my $hash = { 'NewTopicName' => $name };
    my $sns  = get_sns($hash);
    my $r    = $sns->create_topic();
    my $o    = Kynetx::Json::get_obj( $r, "TopicArn" );
    return $o;
}

sub get_sns {
    my ($hash) = @_;
    my $param = {
                  kAWSAccessKeyId() => $key,
                  kAWSSecretKey()   => $secret
    };
    if ( defined $hash and ref $hash eq 'HASH' ) {
        foreach my $key ( keys %{$hash} ) {
            $param->{$key} = $hash->{$key};
        }
    }
    my $sns = Kynetx::Predicates::Amazon::SNS->new($param);
    return $sns;
}

sub pprint {
    my ( $header, $obj ) = @_;
    print "$header\n";
    rprint($obj);
}

sub rprint {
    my ( $obj, $t ) = @_;
    return undef unless ($obj);
    my $ref = ref $obj;
    $t = ' ' unless ($t);
    if ( $ref eq 'ARRAY' ) {
        foreach my $element ( @{$obj} ) {
            rprint( $element, $t );
            print "\n";
        }
    } elsif ( $ref eq 'HASH' ) {
        my $indent = $t . '  ';
        foreach my $hkey ( keys %{$obj} ) {
            my $value = $obj->{$hkey};
            rprint( $hkey,  $t );
            rprint( $value, $indent );
        }
    } elsif ( defined $obj and $ref eq '' ) {
        print "$t$obj\n";
    } else {
        print " else $ref $obj\n";
    }
}

sub usage {
    my ($header) = @_;
    print STDERR <<EOF;
$header

Manage KNS via SNS

Options:

    -h                          : display this message
    -l                          : List topics
    -a                          : List all subscriptions
    -s <topic>                  : List subscriptions by Topic
    -v 0 | 1 | 2                : show detailed output (use -vv for highest level of detail)
    -m <count | stats | rid>    : Send a 'cache status' message (requires: -T <topic>)

 *SNS management*

    -T <topic>                                  : Create SNS Topic
    -D <topic>                                  : Delete SNS Topic
    -S <IP address[:port] | email> -T <topic>   : Subscribe to Topic
    -P http | https | email                     : Protocol to use for subscription
    -N <displayname>                            : Change DisplayName (default: AWS Notifications)

EOF
    exit;
}
