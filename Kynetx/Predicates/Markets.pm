package Kynetx::Predicates::Markets;
# file: Kynetx/Predicates/Markets.pm

use strict;
use warnings;

use Log::Log4perl qw(get_logger :levels);

use Kynetx::Memcached qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [ 
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;


# constants used in this module
use constant SERVICE_URL => 
      'http://www.webservicex.net//stockquote.asmx/GetQuote?symbol=';

use constant SERVICE_EXPIRES => 60*20; # 20 minutes


my %predicates = (

    # market predicates

    'djia_up_more_than' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $threshold = $args->[0];

	my $dji = get_stocks($req_info, '^DJI', 'change');

	# force the string to a num
	# 10 is an arbitrary threshold...
	return int($dji) > $threshold;
    },

    'djia_down_more_than' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $threshold = $args->[0];

	my $dji = get_stocks($req_info, '^DJI', 'change');

	# force the string to a num
	# 10 is an arbitrary threshold...
	return int($dji) < (0 - $threshold);
    },


    );


sub get_predicates {
    return \%predicates;
}

# condition subfunctions
# first argument is a record of data about the request

sub get_stocks {
    my ($req_info, $symbol, $field) = @_;


    my @field_names = qw(
         symbol
         last
         date
         time
         change
         open
         high
         low
         volume
         previous_close
         name
         );
    
    if(not defined $req_info->{'stocks'}->{$symbol}->{$field}) {

	my $url = SERVICE_URL . $symbol;

	my $content = get_remote_data($url, SERVICE_EXPIRES); 

	$content =~ s#.*<string.*>(.*)</string>.*#$1#ms;
	$content =~ s#&lt;#<#g;
	$content =~ s#&gt;#>#g;

	my $logger = get_logger();
#	$logger->debug("Quote for symbol ($symbol): " . 
#		       $content . " using " .$url 
#	    );



	my $rss = new XML::XPath->new(xml => $content);

	my $quote = 
	    $rss ->find('/StockQuotes/Stock')->get_node(1);;

	foreach my $field (@field_names) {
	    my $v = $quote->find(ucfirst($field));

	    my $logger = get_logger();
	    $logger->debug(
		"Value for: " . ucfirst($field) . ' = ' . $v 
		);
	    
	    $req_info->{'stocks'}->{$symbol}->{$field} = $v;
	}




    }

    return $req_info->{'stocks'}->{$symbol}->{$field};

}



1;
