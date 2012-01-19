package Kynetx::Predicates::Amazon::ItemLookup;

# file: Kynetx/Predicates/Amazon/ItemLookup.pm
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
#use warnings;

use Log::Log4perl qw(get_logger :levels);

use Apache2::Const;
use YAML::XS;
use URI::Escape qw(uri_escape_utf8);

use Data::Dumper;

use Kynetx::Session qw(:all);
use Kynetx::Memcached qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::Errors;
use Kynetx::Predicates::Amazon::ItemSearch qw/get_search_index/;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
        build
        get_locale
        )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

use constant DEFAULT_IDTYPE => 'ASIN';
use constant IDTYPE_REQUIRES_MERCHANTID => 'SKU';
use constant MAX_ITEMS => 10;
use constant DEFAULT_CONDITION => 'New';
use constant PRODUCT_CONDITION => ('New','Used','Collectible','Refurbished','All');
use constant MAX_OFFER_PAGE => 100;
use constant MAX_REVIEW_PAGE => 20;
use constant DEFAULT_LOCALE =>  'us';
use constant DEFAULT_RESPONSE_GROUP => 'Small';
use constant DEFAULT_RELATIONSHIP_TYPE => 'AuthorityTitle';
use constant RELATIONSHIP_TYPES => (
    'AuthorityTitle',
    'DigitalMusicArranger', 
    'DigitalMusicComposer',
    'DigitalMusicConductor',
    'DigitalMusicEnsemble',
    'DigitalMusicLyricist',
    'DigitalMusicPerformer',
    'DigitalMusicPrimaryArtist',   
    'DigitalMusicProducer',    
    'DigitalMusicRemixer', 
    'DigitalMusicSongWriter',
    'Episode',
    'Season',
    'Tracks',
);
use constant REVIEW_SORT_ORDERS => (
    '-HelpfulVotes',
    'HelpfulVotes',
    '-OverallRating',
    'OverallRating',
    'SubmissionDate'
);

sub build {
    my ($request,$args,$locale,$a_parm) = @_;
    my $logger = get_logger();
    $logger->debug("ilookup: ", sub { Dumper($args) } );
    $request->{'Operation'}='ItemLookup';
    $request->{'ItemId'} = get_item($args);
    my $idtype = get_item_idtype($args);
    $request->{'IdType'}=$idtype;
    $request->{'AssociateTag'} = Kynetx::Predicates::Amazon::get_associate_tag($args);
    if (Kynetx::Errors::mis_error($idtype)) {
        return $idtype;
    };
    if ($idtype ne DEFAULT_IDTYPE) {
        my $search_index = get_search_index('us',$args,$a_parm);
        # SKU requires a merchant identifier
        if ($idtype eq IDTYPE_REQUIRES_MERCHANTID) {
            my $merch_id = get_merchantid($args);
            if (Kynetx::Errors::mis_error($merch_id)) {
                merror($merch_id,"Merchant ID required for idtype: ".IDTYPE_REQUIRES_MERCHANTID,0);
                return $merch_id;
            }
        }
        $request->{'SearchIndex'}=$search_index;
    }
    $request->{'ResponseGroup'} = get_response_groups($args);
    $logger->trace("RG: ", sub {Dumper($request->{'ResponseGroup'})});
    get_lookup_parameters($request,$args);
    return $request;  
}



sub get_merchantid{
    my ($args) = @_;
    if (defined $args->{'merchantid'}) {
        return $args->{'merchantid'};
    } else {
        return merror("No merchant id supplied",1);
    }
    
    
}

sub get_condition {
    my ($args) = @_;
    my $logger = get_logger();
    if (defined $args->{'condition'}) {
        foreach my $allowed (PRODUCT_CONDITION) {
            $logger->trace("got: ",$args->{'condition'}," try: ",sub {Dumper($allowed)});
            if (uc($allowed) eq uc($args->{'condition'})) {
                return $allowed;
            }
        }
    }
    return DEFAULT_CONDITION;
}

sub get_offerpage {
    my ($args) = @_;
    if (defined $args->{'offerpage'} && $args->{'offerpage'} < MAX_OFFER_PAGE)  {
        return $args->{'offerpage'};
    } else {
        return 1;
    }
}

sub get_related_items_page {
    my ($args) = @_;
    if (defined $args->{'relateditemspage'})  {
        return $args->{'relateditemspage'};
    } else {
        return 1;
    }    
}

# this method is different because there are certain conditions
# where we want to ignore a customer value so we are going to 
# set the value here, rather than return it
sub set_relationship_type {
    my ($args,$request) = @_;
    my $rg = 'RelatedItems';
    my $logger = get_logger();
    # if there is a RelatedItem response group 
    # there has to be a relationshiptype value
    if (contains_response_group($request,$rg)) {            
        if (defined $args->{'relationshiptype'}) {            
            $request->{'RelationshipType'} = $args->{'relationshiptype'};
        } else {
            $logger->debug("RelationshipType requires response group: $rg");
            $request->{'RelationshipType'} = DEFAULT_RELATIONSHIP_TYPE;
        }
        if (defined $args->{'relateditems_page'}) {
            $request->{'RelatedItemsPage'} = $args->{'relateditems_page'};
        }
    }
}

sub set_review_page {
    my ($args,$request) = @_;
    my $logger = get_logger();
    if (defined $args->{'review_page'}) {
       if ($args->{'review_page'} < MAX_REVIEW_PAGE)  {
           $request->{'ReviewPage'} = $args->{'review_page'};
       } else {
           $logger->debug("Maximum page exceeded:",$args->{'review_page'});
           $request->{'ReviewPage'} = 1;
       }
       
    }  
    
}

# I can't guarantee the order that JSON arrays will return
sub set_review_sort {
    my ($args,$request) = @_;
    if (defined $args->{'review_sort'}) {
        my $test = $args->{'review_sort'};
        foreach my $element (REVIEW_SORT_ORDERS) {
            if ($element =~ m/^$test/i) {
                $request->{'ReviewSort'} = $element;
                return;
            }
        }
    }
}

sub set_tag_page {
    my ($args,$request) = @_;
    my $logger = get_logger();
    if (defined $args->{'tag_page'}) {
       if ($args->{'tag_page'} < MAX_REVIEW_PAGE)  {
           $request->{'TagPage'} = $args->{'tag_page'};
       } else {
           $logger->debug("Maximum page exceeded:",$args->{'tag_page'});
           $request->{'TagPage'} = 1;
       }       
    }      
}

sub set_tags_per_page {
    my ($args,$request) = @_;
    my $logger = get_logger();
    if (defined $args->{'tags_per_page'}) {
        $request->{'TagPage'} = $args->{'tag_page'};
    }       
} 

sub set_variation_page {
    my ($args,$request) = @_;
    my $logger = get_logger();
    if (defined $args->{'variation_page'}) {
        $request->{'VariationPage'} = $args->{'variation_page'};
    }           
} 

sub set_merchant_id {
    my ($args,$request) = @_;
    if (defined $args->{'merchantid'}) {
        $request->{'MerchantId'} = $args->{'merchantid'};
    }
}

sub set_search_index {
    my ($args,$locale) = @_;
    if (defined $args->{'search_index'}) {
        my $sindex = $args->{'search_index'};
        my $sparms = Kynetx::Predicates::Amazon::ItemSearch::get_search_index_parameters();
        foreach my $key (keys %$sparms) {
            
        }
        
    };
    
}

sub get_lookup_parameters {
    my ($request,$args) = @_;
    $request->{'Condition'} = get_condition($args);
    $request->{'OfferPage'} = get_offerpage($args);
    $request->{'RelatedItemsPage'} = get_related_items_page($args);
    set_relationship_type($args,$request);
    set_review_page($args,$request);
    set_tag_page($args,$request);
    set_tags_per_page($args,$request); 
    set_variation_page($args,$request);  
    set_merchant_id($args,$request);
}

sub get_item_idtype {
    my ($args) = @_;    
    if (defined $args->{'idtype'}) {
        return $args->{'idtype'};
    } else {
        return DEFAULT_IDTYPE;
    }
}

sub get_item {
    my ($args) = @_;
    my $item_ = $args->{'item_id'};
    if (defined $item_) {
        # check to see if there are more than one items
        if (ref $item_ eq 'ARRAY') {
            if (int(@$item_)> MAX_ITEMS) {
                return merror("ItemLookup can't query more than ".MAX_ITEMS." items");
            }
            return join(',',@$item_);
        } else {
            return $item_;
        }
        
    } else {
        return merror("item_id must be specified for ItemLookup");
    }
}

sub validate_response_group {
    my ($rg) = @_;
    my $response_group = Kynetx::Configure::get_config('RESPONSE_GROUP','AMAZON');
    my $rg_set = $response_group->{'item_lookup'};
    foreach my $element (@$rg_set) {
       if (uc($element) eq uc($rg)) {
           return $element;
       }
    }
    return 0;
}

sub get_response_groups {
    my ($args) = @_;
    my $logger = get_logger();
    my $group_ = $args->{'response_group'};
    $logger->trace("rg from args: ", sub { Dumper($group_)});
    if (defined $group_) {
        my @rg;
        my @temp;
        if (ref $group_ eq 'ARRAY') {
            @temp = @$group_;
        } else {
            push(@temp,$group_);
        }
        foreach my $element (@temp){
            if (my $propercase = validate_response_group($element)) {
                push(@rg,$propercase);
            } else {
                $logger->debug("$element is not a valid ItemLookup response group");
            }
        }        
        if (int(@rg) > 0) {
            return join(",",@rg);
        } else {
            return DEFAULT_RESPONSE_GROUP;
        }
    } else {
        return DEFAULT_RESPONSE_GROUP;
    }
    
}

sub contains_response_group {
    my ($request,$test) = @_;
    my $rg = $request->{'ResponseGroup'};
    return ($rg =~ m/$test/i);
}


1;
