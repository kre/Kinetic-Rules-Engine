package Kynetx::Rules;
# file: Kynetx/Rules.pm

use strict;
use warnings;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ qw(get_rule_set get_precondition_vars %actions) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;



my($active,$test,$inactive) = (0,1,2);

# available actions
# should be a JS function; 
# mk_action will create a JS expression that applies it to appropriate arguments
our %actions = (

    alert => 
      'function(uniq, msg) {alert(msg)}',

    redirect => 
      'function(uniq, url) {window.location = url}',

    float =>
      'function(uniq, pos, top, side, url) {
        var id_str = \'kobj_\'+uniq;
        var div = document.createElement(\'div\');
        div.setAttribute(\'id\', id_str);
        div.setAttribute(\'style\', \'position: \' + pos + 
                                    \'; z-index: 9999;\' + 
                                    top + \';\' + side + 
                                    \'; opacity: 0.999999; display: none\');
        var div2 = document.createElement(\'div\');
        var newtext = document.createTextNode(\'\');
        div2.appendChild(newtext);
        div.appendChild(div2);
        document.body.appendChild(div);
        new Ajax.Updater(id_str, url, {
                         aynchronous: true,
                         method: \'get\' });
       }',
    popup =>
      'function(uniq, top, left, width, height, url) {      
        var id_str = \'kobj_\'+uniq;
        var options = \'toolbar=no,menubar=no,resizable=yes,scrollbars=yes,alwaysRaised=yes,status=no\' +
                      \'left=\' + left + \', \' +
                      \'top=\' + top + \', \' +
                      \'width=\' + width + \', \' +
                      \'height=\' + height;
        open(url,id_str,options);
       }',
    replace =>
      'function(uniq, id, url) {
        new Ajax.Updater(id, url, {
                         aynchronous: true,
                         method: \'get\' });
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
	


    }

    return $req_info->{'weather'}->{$field};

}

sub true { 1; }

sub city {
    my ($req_info, $rule_env, $args) = @_;

    my $city = get_geoip($req_info, 'city');

    my $desired = $args->[0];

    Apache2::ServerUtil->server->warn("City: ". $city . " ?= " . $desired);

    return $city eq $desired;
    
    
}

sub warmer {
    my ($req_info, $rule_env, $args) = @_;

    my $desired = $args->[0];
    
    my $temp = get_weather($req_info, 'curr_temp');

    Apache2::ServerUtil->server->warn("Weather for zip: " . 
				      $req_info->{'geoip'}->{'postal_code'} . 
				      " " . int($temp) . " ?> " . $desired);

    return int($temp) > $desired;

}


sub tomorrow_cond {
    my ($req_info, $rule_env, $args) = @_;

    my $desired = $args->[0];

    my $tcond = get_weather($req_info, 'tomorrow_cond_code');

    Apache2::ServerUtil->server->warn("Weather for zip: " . 
				      $req_info->{'geoip'}->{'postal_code'} . 
				      " " . int($tcond) . " ?= " . $desired);

    return int($tcond) == $desired;
   
    
}

sub tomorrow_showers {
    my ($req_info, $rule_env, $args) = @_;

    my $tcond = get_weather($req_info, 'tomorrow_cond_code');

    return 
	int($tcond) == 4 ||
	int($tcond) == 6 || 
	int($tcond) == 9 || 
	int($tcond) == 11 || 
	int($tcond) == 12;
   

}

sub tomorrow_snow {
    my ($req_info, $rule_env, $args) = @_;

    my $tcond = get_weather($req_info, 'tomorrow_cond_code');

    return 
	int($tcond) == 5 ||
	int($tcond) == 7 || 
	int($tcond) == 13 || 
	int($tcond) == 14 || 
	int($tcond) == 15 || 
	int($tcond) == 16 || 
	int($tcond) == 18;
   

}


# rules 
# this is a parse tree for the eventual DB stored rule program specific to each 
# site id
my %rules = (



    10 => {   # www.windley.com
	test1 => {
	    state => $active,
	    pre_condition => {
		test => qr%/archives/(\d+)/(\d+)/%,
		vars => ["year", "month"],
	    },
	    condition => {
		predicate => \&tomorrow_showers,
		args => [],
	    },
	    pre => {
		decls => [{name => 'tc',
			   source => {weather => 'tomorrow_cond_code'}},
			  {name => 'city',
			   source => {geoip => 'city'}}
		    ],
	    },
	    action => {
		delay => 0,
		name => 'float', 
		args => [{str => 'absolute'}, 
			 {str => 'top: 10px'}, 
			 {str => 'right: 10px'}, 
			 {prim => {op => '+',
				   args => [{str => '/tmp/weather.php?city='},
					    {var => 'city'},
					    {str => '&tc='},
					    {var => 'tc'},
				           ]}}],
		effect => 'appear',
		draggable => 1,
		scrolls => 1,
	    },
	},
	test1 => {
	    state => $active,
	    pre_condition => {
		test => qr%/essays/(.*)/%,
		vars => ["year"],
	    },
	    condition => {
		predicate => \&true,
		args => [],
	    },
	    action => {
		delay => 0,
		name => 'popup', 
		args => [{str => '125'}, 
			 {str => '125'}, 
			 {str => '400'}, 
			 {str => '250'},
			 {str => 'http://127.0.0.1/div.html'}],
		effect => 'onpageexit',
	    },
	},
    },    




    

    12 => {  # www.newegg.com
	test => {  # unique rule id for each site
	    name => "Brand alert",
	    state => $inactive,
	    pre_condition => {
		test => qr%Brand=(.+)&name=(.*)%,
		vars => ["brand", "name"],
	    },
	    condition => {
		predicate => \&true,
		args => ['Seattle'],
	    },
	    action => {
		delay => 1,
		name => 'alert', 
		args => [{str => 'This is alert for Newegg!'}],
	    }
	},
	test1 => {
	    state => $active,
	    pre_condition => {
		test => qr%Brand=(.+)&name=(.*)%,
		vars => ["brand", "name"],
	    },
	    condition => {
		predicate => \&true,
		args => []
	    },
		    action => {
			delay => 0,
			name => 'float', 
			args => [{str => 'absolute'}, 
				 {str => 'top: 10px'}, 
				 {str => 'right: 10px'}, 
				 {str => 'http://127.0.0.1/div.html'}],
			effect => 'appear',
			draggable => 1,
			scrolls => 1,
		}
	},
    },    

    14 => {  # 127.0.0.1
	test => {
	    state => $active,
	    pre_condition => {
		test=> qr/test.html$/,
		vars => [],
	    },
	    condition => {
		predicate => \&city,
		args => ['Seattle'],
	    },
	    action => {
		delay => 1,
		name => 'alert', 
		args => [{str => 'This is my third alert!'}],
	    }
	},

	test1a => {
	    state => $inactive,
	    pre_condition => {
		test=> qr/test1.html$/,
		vars => [],
	    },
	    condition => {
		predicate => \&true,
		args => []
	    },
		    action => {
			delay => 0,
			name => 'redirect', 
			args => [{str => '/redirect.html'}],
		}
	},

	test1b => {
	    state => $active,
	    pre_condition => {
		test=> qr/test1.html$/,
		vars => [],
	    },
	    condition => {
		predicate => \&true,
		args => []
	    },
		    action => {
			delay => 0,
			name => 'float', 
			args => [{str => 'absolute'}, 
				 {str => 'top: 10px'}, 
				 {str => 'right: 10px'}, 
				 {str => '/div.html'}],
			effect => 'appear',
			draggable => 1,
			scrolls => 1,
		}
	},
	
	test2 => {
	    state => $active,
	    pre_condition => {
		test=> qr/test2.html$/,
		vars => [],
	    },
	    condition => {
		predicate => \&true,
		args => []
	    },
		    action => {
			delay => 0,
			name => 'replace', 
			args => [{str => 'replace-me'}, 
				 {str => '/replace.html'}],
		}
	},
	
	test3a => {
	    state => $active,
	    pre_condition => {
		test=> qr/test3.html$/,
		vars => [],
	    },
	    condition => {
		predicate => \&true,
		args => []
	    },
		    action => {
			delay => 0,
			name => 'float', 
			args => [{str => 'absolute'}, 
				 {str => 'top: 10px'}, 
				 {str => 'right: 10px'}, 
				 {str => '/div.html'}],
		}
	},
	
	test3b => {
	    state => $active,
	    pre_condition => {
		test=> qr/test3.html$/,
		vars => [],
	    },
	    condition => {
		predicate => \&true,
		args => []
	    },
		    action => {
			delay => 3,
			name => 'replace', 
			args => [{str => 'replace-me'}, 
				 {str => '/replace.html'}],
		}
	},
    },
    );


sub get_precondition_test {
    my $rule = shift;

    $rule->{'pre_condition'}{'test'};
}

sub get_precondition_vars {
    my $rule = shift;

    $rule->{'pre_condition'}{'vars'};
}


# this returns the right rules for the referer and site
# this is a point where things could be optimixed in the future
sub get_rule_set {
    my $site = shift;
    my $referer = shift;

    my %new_set;
    my %new_env;

    foreach my $site_id (keys %rules ) {

	next if ($site_id != $site);

	foreach my $rule_name (keys %{ $rules{$site_id} } ) {

#    Apache2::ServerUtil->server->warn("Checking rule: ". $rule_name);




	    if($rules{$site_id}->{$rule_name}->{'state'} == $active) {
		# test the pattern, captured values are stored in @captures
		if(my @captures = 
		        $referer =~ 
		            get_precondition_test($rules{$site_id}->{$rule_name})) {


#    Apache2::ServerUtil->server->warn("Var for rule $rule_name: $captures[0]");

		    $new_set{$rule_name} = $rules{$site_id}->{$rule_name};

		    # store the captured values from the precondition to the env
		    my $cap = 0;
		    foreach my $var ( @{ get_precondition_vars($rules{$site_id}->{$rule_name})}) {

#    Apache2::ServerUtil->server->warn("Var for rule $rule_name: $var -> $captures[$cap]");

			$new_env{"$rule_name:$var"} = $captures[$cap++];

		    }
                    
    
		}

	    }

	}
    }
    
    return (\%new_set, \%new_env);

}





1;
