
package Kynetx::Rules;
# file: Kynetx/Rules.pm

use strict;
use warnings;


use SVN::Client;
use Log::Log4perl qw(get_logger :levels);


use Kynetx::Parser qw(:all);
use Kynetx::PrettyPrinter qw(:all);
use Kynetx::Json qw(:all);


use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
get_rule_set 
get_precondition_vars 
%actions 
%predicates
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



my($active,$test,$inactive) = (0,1,2);

# available actions
# should be a JS function; 
# mk_action will create a JS expression that applies it to appropriate arguments
# first arg MUST be uniq (a number unique to this rule action event)
# second arg MUST be cb (a callback function)
our %actions = (

    alert => 
      'function(uniq, cb, msg) {alert(msg)}',

    redirect => 
      'function(uniq, cb, url) {window.location = url}',

    float =>
      'function(uniq, cb, pos, top, side, url) {
        var id_str = \'kobj_\'+uniq;
        var div = document.createElement(\'div\');
        div.setAttribute(\'id\', id_str);
        div.setAttribute(\'style\', \'position: \' + pos + 
                                    \'; z-index: 9999;  \' +
                                    top + \'; \' + side + 
                                    \'; opacity: 0.999999; display: none\');
        var div2 = document.createElement(\'div\');
        var newtext = document.createTextNode(\'\');
        div2.appendChild(newtext);
        div.appendChild(div2);
        document.body.appendChild(div);
        new Ajax.Updater(id_str, url, {
                         aynchronous: true,
                         method: \'get\',
                         onComplete: cb
                        });
       }',
    popup =>
      'function(uniq, cb, top, left, width, height, url) {      
        var id_str = \'kobj_\'+uniq;
        var options = \'toolbar=no,menubar=no,resizable=yes,scrollbars=yes,alwaysRaised=yes,status=no\' +
                      \'left=\' + left + \', \' +
                      \'top=\' + top + \', \' +
                      \'width=\' + width + \', \' +
                      \'height=\' + height;
        open(url,id_str,options);
        callBacks();
       }',
    replace =>
      'function(uniq, cb, id, url) {
        new Ajax.Updater(id, url, {
                         aynchronous: true,
                         method: \'get\' ,
                         onComplete: cb
                         });   
        new Effect.Appear(id);
        }'
    );


# condition subfunctions
# first argument is a record of data about the request


sub get_geoip {
    # $field is on of the valid GeoIP record field names
    my ($req_info, $field) = @_;

    my @field_names = qw(
	    country_code
            country_code3
            country_name
            region
            city
            postal_code
            latitude
            longitude
            dma_code
            area_code);
    
    if(not defined $req_info->{'geoip'}->{$field}) {

	my $gi = Geo::IP->open("/web/share/GeoIP/GeoIPCity.dat", 
			       Geo::IP::GEOIP_STANDARD);

	my $record = $gi->record_by_addr($req_info->{'ip'});
	
	for my $name (@field_names) {
	    $req_info->{'geoip'}->{$name} = $record->$name;
	}
    }

    return $req_info->{'geoip'}->{$field};

}

sub get_weather {
    my ($req_info, $field) = @_;

    # for US locations only right now (with Yahoo!)
    
    my @field_names = qw(
          curr_temp
          curr_cond
          curr_cond_code
          tomorrow_low
          tomorrow_high
          tomorrow_cond
          tomorrow_cond_code
         );
    
    if(not defined $req_info->{'weather'}->{$field}) {

	my $zip = get_geoip($req_info, 'postal_code');


	# farenhiet hardwided in.  Should come from client
	my $content = 
	    LWP::Simple::get('http://xml.weather.yahoo.com/forecastrss?p='. 
			     $zip . '&u=f');

	my $rss = new XML::XPath->new(xml => $content);

	my $curr_cond = 
	    $rss ->find('/rss/channel/item/yweather:condition')->get_node(1);;

	$req_info->{'weather'}->{'curr_temp'} = 
	    $curr_cond->find('@temp'); 
	$req_info->{'weather'}->{'curr_cond'} = 
	    $curr_cond->find('@text'); 
	$req_info->{'weather'}->{'curr_cond_cond'} = 
	    $curr_cond->find('@code'); 
	$req_info->{'weather'}->{'timezone'} = 
	    $curr_cond->find('@date'); 
	$req_info->{'weather'}->{'timezone'} =~ s/.*(\w\w\w)$/$1/;


	my @forecast_cond = 
	      $rss->find('/rss/channel/item/yweather:forecast')->get_nodelist;

	$req_info->{'weather'}->{'tomorrow_low'} = 
	    $forecast_cond[0]->find('@low'); 
	$req_info->{'weather'}->{'tomorrow_high'} = 
	    $forecast_cond[0]->find('@high'); 
	$req_info->{'weather'}->{'tomorrow_cond'} = 
	    $forecast_cond[0]->find('@text'); 
	$req_info->{'weather'}->{'tomorrow_cond_code'} = 
	    $forecast_cond[0]->find('@code'); 
	

	my $astronomy = 
	    $rss->find('/rss/channel/yweather:astronomy')->get_node(1);

	$req_info->{'weather'}->{'sunrise'} = 
	    $$astronomy->find('@sunrise'); 
	$req_info->{'weather'}->{'sunset'} = 
	    $astronomy->find('@sunset'); 





    }

    my $logger = get_logger();
    $logger->debug("Weather for zip ($field): " ,
		   $req_info->{'geoip'}->{'postal_code'},
		   " -> ", 
		   $req_info->{'weather'}->{$field});


    return $req_info->{'weather'}->{$field};

}

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

	my $url = 
	    'http://www.webservicex.net//stockquote.asmx/GetQuote?symbol='. 
	    $symbol;

	my $content = LWP::Simple::get($url);



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


sub get_referer_data {

    my ($req_info,  $field) = @_;


    my @field_names = qw(
         protocol
         domain
         port
         path
         );
    
    if(not defined $req_info->{'referer_data'}->{$field}) {

	my $url = $req_info->{'referer'};
	$url =~ m|(\w+)://([^/:]+)(:\d+)?/([^?]*)(\?.*)?|; 
	$req_info->{'referer_data'}->{'protocol'} = $1;
	$req_info->{'referer_data'}->{'domain'} = $2;
	$req_info->{'referer_data'}->{'path'} = "/" . $4;
	if ($3 =~ /:(\d+)/) { 
	    $req_info->{'referer_data'}->{'port'} = $1;
	} else { 
	    $req_info->{'referer_data'}->{'port'} = 80;
	}
	if ($5 =~ /\?(.*)/) {
	    $req_info->{'referer_data'}->{'query'} = $1;
	} else {
	    $req_info->{'referer_data'}->{'query'} = '';
	}

	my $logger = get_logger();

	if($logger->is_debug()) {
	    foreach my $k (keys %{ $req_info->{'referer_data'} }) {
	    $logger->debug("Referer piece ($k): " . 
			   $req_info->{'referer_data'}->{$k}
		);
	    }
	}
	

    }

    return $req_info->{'referer_data'}->{$field};

}

my %search_engines = (
    'alexa.com' => 1,
    'alltheweb.com' => 1,
    'altavista.com' => 1,
    'aolsearch.aol.co.uk' => 1,
    'aolsearch.aol.com' => 1,
    'au.search.yahoo.com' => 1,
    'ca.search.yahoo.com' => 1,
    'de.search.yahoo.com' => 1,
    'dogpile.com' => 1,
    'excite.co.jp' => 1,
    'fr.search.yahoo.com' => 1,
    'google.ae' => 1,
    'google.at' => 1,
    'google.be' => 1,
    'google.ca' => 1,
    'google.ch' => 1,
    'google.cl' => 1,
    'google.co.cr' => 1,
    'google.co.il' => 1,
    'google.co.in' => 1,
    'google.co.jp' => 1,
    'google.co.kr' => 1,
    'google.co.nz' => 1,
    'google.co.th' => 1,
    'google.co.uk' => 1,
    'google.co.ve' => 1,
    'google.com' => 1,
    'google.com.ar' => 1,
    'google.com.au' => 1,
    'google.com.br' => 1,
    'google.com.co' => 1,
    'google.com.do' => 1,
    'google.com.hk' => 1,
    'google.com.mt' => 1,
    'google.com.mx' => 1,
    'google.com.my' => 1,
    'google.com.pa' => 1,
    'google.com.pe' => 1,
    'google.com.ph' => 1,
    'google.com.pk' => 1,
    'google.com.sa' => 1,
    'google.com.sg' => 1,
    'google.com.tr' => 1,
    'google.com.tw' => 1,
    'google.com.uy' => 1,
    'google.com.vn' => 1,
    'google.de' => 1,
    'google.dk' => 1,
    'google.es' => 1,
    'google.fi' => 1,
    'google.fr' => 1,
    'google.ie' => 1,
    'google.it' => 1,
    'google.lt' => 1,
    'google.lu' => 1,
    'google.lv' => 1,
    'google.mu' => 1,
    'google.nl' => 1,
    'google.no' => 1,
    'google.pl' => 1,
    'google.pt' => 1,
    'google.ro' => 1,
    'google.ru' => 1,
    'google.se' => 1,
    'google.sk' => 1,
    'hotbot.com' => 1,
    'infoseek.co.jp' => 1,
    'mamma.com' => 1,
    'ms101.mysearch.com' => 1,
    'search.aol.com' => 1,
    'search.com' => 1,
    'search.earthlink.net' => 1,
    'search.icq.com' => 1,
    'search.msn.co.uk' => 1,
    'search.msn.com' => 1,
    'search.msn.de' => 1,
    'search.msn.dk' => 1,
    'search.msn.fr' => 1,
    'search.naver.com' => 1,
    'search.netscape.com' => 1,
    'search.ninemsn.com.au' => 1,
    'search.yahoo.com' => 1,
    'tw.search.yahoo.com' => 1,
    'uk.search.yahoo.com' => 1,
    );



our %predicates = (
    'true' => sub  { 1; },
    'mobile' => sub  { 1; },

    'city' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $city = get_geoip($req_info, 'city');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
        $logger->debug("City: ". $city . " ?= " . $desired);

	return $city eq $desired;
	    
    },

    'outside_city' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $city = get_geoip($req_info, 'city');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes


	my $logger = get_logger();
	$logger->debug("City: ". $city . " ?= " . $desired);

	return !($city eq $desired);
	    
    },

    'state' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $state = get_geoip($req_info, 'region');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
	$logger->debug("State: ". $state . " ?= " . $desired);

	return $state eq $desired;
	    
    },

    'outside_state' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $state = get_geoip($req_info, 'region');

	my $desired = $args->[0];
	$desired =~ s/^'(.*)'$/$1/;  # for now, we have to remove quotes

	my $logger = get_logger();
	$logger->debug("State: ". $state . " ?= " . $desired);

	return !($state eq $desired);
	    
    },

    'warmer' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];
    
	my $temp = get_weather($req_info, 'curr_temp');

	my $logger = get_logger();
	$logger->debug("Weather for zip: " . 
		       $req_info->{'geoip'}->{'postal_code'} . 
		       " " . int($temp) . " ?> " . $desired);

	return int($temp) > $desired;

    },


    'tomorrow_cond' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	my $logger = get_logger();
	$logger->debug("Weather for zip: " . 
		       $req_info->{'geoip'}->{'postal_code'} . 
		       " " . int($tcond) . " ?= " . $desired);

	return int($tcond) == $desired;
   
    
    },

    'tomorrow_showers' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	return 
	    int($tcond) == 4 ||
	    int($tcond) == 6 || 
	    int($tcond) == 9 || 
	    int($tcond) == 11 || 
	    int($tcond) == 12;
   

    },

    'tomorrow_cloudy' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	return 
	    int($tcond) == 26 ||
	    int($tcond) == 27 || 
	    int($tcond) == 28|| 
	    int($tcond) == 29 || 
	    int($tcond) == 30 || 
	    int($tcond) == 44;
   

    },

    'tomorrow_snow' => sub  {
	my ($req_info, $rule_env, $args) = @_;

	my $tcond = get_weather($req_info, 'tomorrow_cond_code');

	return 
	    int($tcond) == 5 ||
	    int($tcond) == 7 || 
	    int($tcond) == 13 || 
	    int($tcond) == 14 || 
	    int($tcond) == 15 || 
	    int($tcond) == 16 || 
	    int($tcond) == 18 ||
	    int($tcond) == 42 ||
	    int($tcond) == 43 ||
	    int($tcond) == 46
	    ;
	
    },

    # time predicates

    'timezone' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $desired = $args->[0];

	my $tz = get_weather($req_info, 'timezone');

	return $tz eq $desired;
    },
   
    'daytime' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $sunrise = get_weather($req_info, 'sunrise');
	$sunrise =~ y/ /:/;
	my @sr = split(/:/, $sunrise);
	$sr[0] += 12 if $sr[2] eq 'pm';

	my $sunset = get_weather($req_info, 'sunset');
	$sunset =~ y/ /:/;
	my @ss = split(/:/, $sunset);
	$ss[0] += 12 if $ss[2] eq 'pm';

	my $tz = get_weather($req_info, 'timezone');

	$tz =~ s#E.T#America/New_York#;
	$tz =~ s#C.T#America/Chicago#;
	$tz =~ s#M.T#America/Denver#;
	$tz =~ s#P.T#America/Los_Angeles#;

	# this code has the potential of breaking badly when the server
        # clock/timzone is not set right...
	my $now = DateTime->now;  
	$now->set_time_zone($tz);


	my $srto = $now->clone;
	$srto->set_hour($sr[0]);
	$srto->set_minute($sr[1]);


	my $ssto = $now->clone;
	$ssto->set_hour($ss[0]);
	$ssto->set_minute($ss[1]);
	

	# returns 1 if a > b
	my $after_sunrise = DateTime->compare($now,$srto);
	my $before_sunset = DateTime->compare($ssto,$now);

	my $logger = get_logger();
	$logger->debug( 
	    "Time for cust: " . $now->hms . "($tz)  " . 
	    "After Sunrise: " . $after_sunrise . " " .
	    "Before Sunset: " . $before_sunset . " " 
	    );
	

	return $after_sunrise eq 1 && $before_sunset eq 1;
   
    
    },

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

    # referer predicates

    'search_engine_referer' => sub {
	my ($req_info, $rule_env, $args) = @_;

	my $domain = get_referer_data($req_info,'domain');
	$domain =~ s#^www\.(.*)$#$1# if($domain =~ m#^www\.#);

	return $search_engines{$domain};
    },

    );


# need predicates already defined for this
$predicates{'nighttime'} = sub {
    return ! $predicates{'daytime'}(@_)

};




sub get_precondition_test {
    my $rule = shift;

    $rule->{'pagetype'}{'pattern'};
}

sub get_precondition_vars {
    my $rule = shift;

    $rule->{'pagetype'}{'vars'};
}


# this returns the right rules for the caller and site
# this is a point where things could be optimixed in the future
sub get_rule_set {
    my ($site, $caller, $svn_conn, $memd) = @_;

    my $logger = get_logger();
    $logger->debug("Getting rules for $caller");

    my $rules = optimize_rules(
	          get_rules_from_repository($site, $svn_conn, $memd),$site);


    my @new_set;
    my %new_env;

    foreach my $rule ( @{ $rules->{$site} } ) {

	if($rule->{'state'} eq 'active') {  # optimize??
	    # test the pattern, captured values are stored in @captures

	    if(my @captures = $caller =~ get_precondition_test($rule)) {

		push @new_set, $rule;

		# store the captured values from the precondition to the env
		my $cap = 0;
		foreach my $var ( @{ get_precondition_vars($rule)}) {

		    $logger->debug("[select var] $var -> $captures[$cap]");

		    $new_env{"$rule->{'name'}:$var"} = $captures[$cap++];

		}
                    
    
	    } else {
		$logger->debug("[not selected] $rule->{'name'} ");
		
	    }
    
	}
    
    }
    
    return (\@new_set, \%new_env);

}

sub optimize_rules {
    my ($rules, $site) = @_;

    foreach my $rule ( @{ $rules->{$site} } ) {

	# precompile pattern regexp
	$rule->{'pagetype'}->{'pattern'} = 
	    qr!$rule->{'pagetype'}->{'pattern'}!;

    }

    return $rules;
}


sub get_rules_from_repository{

    my ($site, $svn_conn, $memd) = @_;

    my $logger = get_logger();

    my $ruleset = $memd->get("ruleset:$site");
    if ($ruleset) {
	$logger->debug("Using cached ruleset for $site");
	return $ruleset;
    } 


    my ($ctx, $svn_url) = get_svn_conn($svn_conn);

    my %d;
    my $info = sub {
	my( $path, $info, $pool ) = @_;
	$d{$path} = $info->last_changed_rev();
    };

    my $ext;
    foreach $ext ('.krl','.json') {
	eval {
	    $ctx->info($svn_url.$site.$ext, 
		       undef,
		       'HEAD',
		       $info,
		       0           # don't recurse
		);
	};
	if($@) {  # catch file doesn't exist...
	    $d{$site.$ext} = -1;
	}
    }

    if ($d{$site.'.krl'} eq -1 && $d{$site.'.json'} eq -1) {
	$logger->debug("Didn't find any rules, returning fake ruleset");
	return parse_ruleset("ruleset $site {}");
    }


    if($d{$site.'.krl'} > $d{$site.'.json'}) {
	$ext = '.krl';
    } else {
	$ext = '.json';
    }

    $logger->debug("Using the $ext version: ", $d{$site.$ext});
    

    # open a variable as a filehandle (for weird SVN::Client stuff)
    my $krl;
    open(FH, '>', \$krl) or die "Can't open memory file: $!";
    $ctx->cat (\*FH,
	       $svn_url.$site.$ext, 
	       'HEAD');

    $logger->debug("Found rules for $site");

    # return the abstract syntax tree regardless of source
    if($ext eq '.krl') {
	$ruleset = parse_ruleset($krl);
    } else {
	$ruleset = jsonToAst($krl);
    }

    $logger->debug("Caching ruleset for $site");
    $memd->set("ruleset:$site", $ruleset);
    return $ruleset;    

}

sub get_svn_conn {
    my($svn_conn) = @_;
    my $logger = get_logger();

    my ($svn_url,$username,$passwd);
    if ($svn_conn) {
	($svn_url,$username,$passwd) = split(/\|/, $svn_conn);
    } else {
	$svn_url = 'svn://127.0.0.1/rules/client/';
	$username = 'web';
	$username = 'foobar';
    }

    
    $logger->debug("Connecting to rule repository at $svn_url");


    my $simple_prompt = sub {
	my $cred = shift;
	my $realm = shift;
	my $default_username = shift;
	my $may_save = shift;
	my $pool = shift;

	$cred->username($username);
	$cred->password($passwd);
    };

    # returns a list with the connection and the URL
    return (new SVN::Client(
		auth => [SVN::Client::get_simple_provider(),
			 SVN::Client::get_simple_prompt_provider($simple_prompt,2),
			 SVN::Client::get_username_provider()]
	    ), 
	    $svn_url)

    

}




1;
