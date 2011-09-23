package Kynetx::Predicates::RSS;

# file: Kynetx/Predicates/Math.pm
# file: Kynetx/Predicates/Referers.pm
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

use lib qw(../../);

use Log::Log4perl qw(get_logger :levels);
use Data::Dumper;

use Kynetx::Util;
use Kynetx::Json;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION = 1.00;
our @ISA     = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (
    all => [
        qw(
          get_rss
          get_channel_names
          get_item_names
          )
    ]
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

my @channel_names = qw(
  title
  link
  description
  language
  copyright
  managingEditor
  webMaster
  pubDate
  lastBuildDate
  category
  generator
  docs
  cloud
  ttl
  image
  rating
  textInput
  skipHours
  skipDays
);

my @item_names = qw(
  title
  link
  description
  author
  category
  comments
  enclosure
  guid
  pubDate
  source
);

my %predicates = (
    'version' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger = get_logger();
        if ( my $rss = get_rss( $args, qr/^rss$/ ) ) {
            return $rss->{'@version'};
        } else {
            $logger->debug("RSS:version() data format error");
            return '';
        }
    },
    'items' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        return get_items($args);
    },
    'first' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger = get_logger();
        return get_items( $args, 0 );

    },
    'last' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $logger = get_logger();
        my $items  = get_items($args);
        my $count  = int(@$items);
        return $items->[ $count - 1 ];

    },
    'index' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $items = get_items( $args->[0] );
        my $count = $args->[1];
        $count = 1 unless ( defined $count && $count > 1 );
        return $items->[ $count - 1 ];

    },
    'random' => sub {
        my ( $req_info, $rule_env, $args ) = @_;
        my $items = get_items( $args->[0] );
        my $count = int(@$items);
        return $items->[ int( rand($count) ) ];

    },
);

sub get_predicates {
    return \%predicates;
}

sub get_rss {
    my ( $obj, $regexp ) = @_;
    my $logger = get_logger();
    my $ret_val;
    if ( ref $obj eq 'HASH' ) {
        foreach my $key ( keys %$obj ) {
            if ( $key =~ $regexp ) {
                return $obj->{$key};
            } else {
                $ret_val = get_rss( $obj->{$key}, $regexp );
                if ($ret_val) {
                    return $ret_val;
                }
            }
        }
    } elsif ( ref $obj eq 'ARRAY' ) {
        foreach my $element (@$obj) {
            $ret_val = get_rss( $element, $regexp );
            if ($ret_val) {
                return $ret_val;
            }
        }
    }
}

sub eval_rss {
    my ( $req_info, $rule_env, $session, $rule_name, $function, $args ) = @_;
    my $retval;
    if ( $function eq 'channel' ) {
        $retval = channel_elements($args);
    } elsif ( $function eq 'item' ) {
        $retval = item_elements($args);
    }

    return $retval;

}

sub get_items {
    my ( $args, $index ) = @_;
    my $logger = get_logger();
    my $rss = get_rss( $args, qr/^channel$/ );

    if ( defined $index && $index >= 0 ) {
        return $rss->{'item'}->[$index];
    } else {
        return $rss->{'item'};
    }
}


sub item_elements {
    my ($args) = @_;
    my $logger = get_logger();
    if ( ref $args eq 'ARRAY' && int($args) > 0 ) {
        my $rss    = $args->[0];
        my $ilist = get_rss( $rss, qr/^item$/ );
        Kynetx::Json::collapse($rss);
        my $iname  = $args->[1];
        my $nspace = $args->[2];
        my %found;
        my $key;
        map { $found{$_} = 1 } @item_names;
        if ( $found{$iname} ) {
            $key = $iname;
        } else {
            $key = "$nspace\$$iname";
        }
        $logger->debug( "Find RSS item value for : ", $key );
        # Check to see if we have a whole feed or a single item
        # if we have provided the item through KRL the 'item'
        # container won't exist
        if ( ref $rss eq "ARRAY" || $ilist ) {
            my @elements;
            my @ret_array;
            if ( ref $rss eq "ARRAY" ) {
                @elements = @$rss;
            } else {
                @elements = @$ilist;
            }
            foreach my $element (@elements) {
                push(@ret_array,$element->{$key});
            }
            return \@ret_array;
        } else {
            return $rss->{$key};

        }
    }

}

sub channel_elements {
    my ($args) = @_;
    my $logger = get_logger();
    if ( ref $args eq 'ARRAY' && int($args) > 0 ) {
        my $rss = get_rss( $args->[0], qr/^channel$/ );
        Kynetx::Json::collapse($rss);
        return merror("Invalid RSS feed") unless $rss;
        my $cname  = $args->[1];
        my $nspace = $args->[2];
        my %found;
        my $key;
        map { $found{$_} = 1 } @channel_names;

        if ( $found{$cname} ) {
            $key = $cname;
        } else {
            $key = "$nspace\$$cname";
        }
        $logger->debug( "Find RSS channel value for : ", $key );
        return  (Kynetx::Json::collapse ($rss->{$key}));
    }
    $logger->warn("not an array");
}

sub get_channel_names {
    return @channel_names;
}

sub get_item_names {
    return @item_names;
}

1;
