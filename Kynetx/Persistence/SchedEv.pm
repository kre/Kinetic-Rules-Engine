package Kynetx::Persistence::SchedEv;
# file: Kynetx/Persistence/SchedEv.pm
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
use lib qw(
    /web/lib/perl
);


use Log::Log4perl qw(get_logger :levels);
use DateTime;
use DateTime::Event::Cron;
use Data::Dumper;
$Data::Dumper::Indent = 1;

use Schedule::Cron::Events;

# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
use Kynetx::Session qw(:all);
use Kynetx::Configure qw(:all);
use Kynetx::MongoDB qw(:all);
use Kynetx::Memcached qw(
    check_cache
    mset_cache
);
use Kynetx::Persistence::KEN qw(
    new_ken
);
use Kynetx::Modules::Event;
use MongoDB;
use MongoDB::OID;
use Digest::MD5 qw(
    md5_base64
);
use Data::UUID;
use Apache2::Const -compile => qw(OK DECLINED);
use Time::Local qw(timelocal);

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use constant COLLECTION => "schedev";
use constant TIMESPEC => "* * * * *";

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

# put exported names inside the "qw"
our %EXPORT_TAGS = (all => [
qw(
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} });

sub handler {
	my $r = shift;	
	
	# configure logging for production, development, etc.
	Kynetx::Util::config_logging($r);
	my $logger = get_logger();
	
	my $req = Apache2::Request->new($r);
  $r->pool->cleanup_register(\&_handler,$r);
  return Apache2::Const::OK;
}

sub _handler {
  my ($r) = @_;
	my $logger = get_logger();
	$r->subprocess_env( START_TIME => Time::HiRes::time );
	Log::Log4perl::MDC->put( 'site', "[no rid]" );
	Log::Log4perl::MDC->put( 'rule', '[global]' );    # no rule for now...
	
	Kynetx::Memcached->init();	
	
	my @path_components = split( /\//, $r->path_info );
	
	# 0 = "sky"
	# 1 = "schedule"
	my $sched_id = $path_components[2];
	my $proc_id = $path_components[3];
	$logger->debug("--------SchedEv Id: $sched_id-----------");
	
	if (defined $proc_id) {
    return Apache2::Const::DECLINED unless sched_verify($sched_id,$proc_id);	  
	}
	
	my ($schedEv, $esl, $event_response) = Kynetx::Modules::Event::send_scheduled_event($sched_id);
	my ($code,$status);
	my $now = time();
	if (defined $event_response) {
	  $code = $event_response->code();
	  $status = $event_response->status_line();
	} 
	if (defined $schedEv) {
	  if ($schedEv->{'once'}) {
	    $logger->debug("Expire $sched_id");
	    set_expiration($sched_id);
	  } else {
	    # figure the next scheduled date for a cron timespec
	    my $timespec = $schedEv->{'timespec'};
	    my $last = $schedEv->{'next_schedule'};	    
	    my $cron = new Schedule::Cron::Events( $timespec . ' /bin/foo',  Seconds => $now);
	    my $next = timelocal($cron->nextEvent);
	    if ($next == $last) {
	      $next = timelocal($cron->nextEvent);
	    }
	    update($sched_id,'next_schedule',$next);
	  }
    my $status = {
      'code' => $code,
	    'status' => $status,
	    'fired' => $now  
    };
    update($sched_id,'last',$status);
	  
	} else {
	  $logger->warn("--------Invalid SchedEv Id $sched_id--------");
	  return Apache2::Const::OK;
	}	
  $logger->debug("--------SchedEv END-----------");
	return Apache2::Const::OK;
}

sub set_expiration {
  my ($sched_id) = @_;
  Kynetx::MongoDB::set_ttl(COLLECTION,'expired',$sched_id);
}

sub put_sched_ev {
  my ($schedEv) = @_;
  my $logger = get_logger();
  if (defined $schedEv && ref $schedEv eq "HASH") {
    my $c = Kynetx::MongoDB::get_collection(COLLECTION);
    my $sid = $c->insert($schedEv);
    if ($sid) {
      return $sid->{'value'};
    } else {
      return undef;
    }
  } else {
    return undef;
  }  
}

sub update {
  my ($schedEv_id,$var,$val) = @_; 
  my $logger = get_logger();
  my $findandmodify;
	my $mongoid = MongoDB::OID->new("value" => $schedEv_id);
	my $query = {
		"_id" => $mongoid
	};
	my $update = {
	  '$set' => {
	    $var => $val
	  }
	};
	my $new_val = {
	  'new' => 1
	};
  $findandmodify = {
    'query' => $query,
    'update' => $update,
    'new' => $new_val
  };
  my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$findandmodify);
  return Kynetx::MongoDB::normalize($result);
}

sub update_lock {
  my ($schedEv_id,$old_id,$new_id) = @_;  
  my $logger = get_logger();
  my $findandmodify;
	my $mongoid = MongoDB::OID->new("value" => $schedEv_id);
	my $query = {
		"_id" => $mongoid,
		"cron_id" => $old_id
	};
	my $update = {
	  '$set' => {
	    'cron_id' => $new_id
	  }
	};
	my $new_val = {
	  'new' => 1
	};
	
  $findandmodify = {
    'query' => $query,
    'update' => $update,
    'new' => $new_val
  };
  my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$findandmodify);
  return Kynetx::MongoDB::normalize($result);
}

sub get_and_lock {
  my ($schedEv_id,$cron_id) = @_;
  my $logger = get_logger();
  my $findandmodify;
	my $mongoid = MongoDB::OID->new("value" => $schedEv_id);
	my $query = {
		"_id" => $mongoid,
		"cron_id" => {
        '$exists' => 0
     }
	};
	my $update = {
	  '$set' => {
	    'cron_id' => $cron_id
	  }
	};
	my $new_val = {
	  'new' => 1
	};
	
  $findandmodify = {
    'query' => $query,
    'update' => $update,
    'new' => $new_val
  };
  my $result = Kynetx::MongoDB::find_and_modify(COLLECTION,$findandmodify);
  return Kynetx::MongoDB::normalize($result);
  
}

sub get_sched_ev {
  my ($schedEv_id) = @_;
  my $logger = get_logger();
	my $mongoid = MongoDB::OID->new("value" => $schedEv_id);
	my $mongo_key = {
		"_id" => $mongoid
	};
	my $result = Kynetx::MongoDB::get_value(COLLECTION,$mongo_key);
  return Kynetx::MongoDB::normalize($result);
}

sub delete_sched_ev {
  my ($schedEv_id,$ken,$rid) = @_;
  my $logger = get_logger();
	my $mongoid = MongoDB::OID->new("value" => $schedEv_id);
	my $mongo_key = {
		"_id" => $mongoid,
		"ken" => $ken,
		"source" => $rid
	};
  my $result = Kynetx::MongoDB::delete_value(COLLECTION,$mongo_key);
  if (defined $result && ref $result eq "HASH") {
    if ($result->{'ok'}) {
      return $result->{'n'};
    }
  }
  
  return 0;
}

sub delete_entity_sched_ev {
  my ($ken,$rid) = @_;
  my $key = {
    'ken' => $ken,
    'source' => $rid
  };
  my $list = get_schedev_list($key);
  my $count = 0;
  foreach my $id (@{$list}) {
    my $status = delete_sched_ev($id,$ken,$rid);
    if ($status) {
      $count++;
    }
  }
  return $count;
}

sub count_by_cron_id {
  my $logger = get_logger();
  my $key = 'cron_id',
  my $filter = { 
    "timespec" => {
         '$exists' => 1
       }
  };
  my $list = Kynetx::MongoDB::unique_elements(COLLECTION,$key,$filter);
  $logger->debug("Unique $key: ", sub {Dumper($list)});
  my $count_list;
  for my $cron_id (@{$list}) {
    my $key = {
      'cron_id' => $cron_id
    };
    my $count = Kynetx::MongoDB::count_elements(COLLECTION,$key);
    $count_list->{$cron_id} = $count;
  }
  return $count_list;
}

sub set_cron_id {
  my ($c_id) = @_;
  my $logger = get_logger();
  my $c = Kynetx::MongoDB::get_collection(COLLECTION);
  my $key = {
      "cron_id" => {
        '$exists' => 0
      }
  };
  my $update = {
    {'$set' => {cron_id => $c_id}}
  };
  my $result = $c->update($key,$update,{multiple => 1});
  $logger->debug("Set $c_id: ", sub {Dumper($result)});  
}

sub sched_verify {
  my ($schedEv_id,$cron_id) = @_;
  my $logger = get_logger();
  my $schedev = get_sched_ev($schedEv_id);
  my $active_cron_id = $schedev->{'cron_id'};
  if (defined $schedev->{'timespec'}) {
    if ($active_cron_id == $cron_id) {
      return 1;
    } else {
      return 0;
    }
  } elsif (defined $schedev->{'once'}) {
    # check to see if the event has already been processed
    if (sched_cache_hit($schedev)) {
      $logger->debug("Schedule $schedEv_id failed verification, removing");
      my $ken = $schedev->{'ken'};
      my $rid = $schedev->{'source'};
      delete_sched_ev($schedEv_id,$ken,$rid);
      return 0
    } else {
      my $timeout = 172800; # 2 days
      my $key = sched_cache_key($schedev);
      Kynetx::Memcached::mset_cache($key,1,$timeout);
      return 1;
    }
    
  }

}

sub sched_cache_hit {
  my ($schedev) = @_;
  my $logger = get_logger();
  my $key = sched_cache_key($schedev);
  $logger->debug("Check cache: $key");
  my $found = Kynetx::Memcached::check_cache($key);
  if ($found) {
    $logger->debug("Check cache: found");
    return 1;
  } else {
    $logger->debug("Check cache: not found");
    return 0;
  }
}

sub sched_cache_key {
  my ($sched_ev) = @_;
  my $id = $sched_ev->{"_id"};
  my $ken = $sched_ev->{"ken"};
  my $key = "_sched_". $id . $ken;
  return $key;
}

sub schedev_query {
  my ($ken,$key) = @_;
  my $logger = get_logger();
  my $c = Kynetx::MongoDB::get_collection(COLLECTION);
  if (ref $key eq "HASH") {
    $key->{'ken'} = $ken;
    $logger->trace("Key: ", sub {Dumper($key)});
    my @list = ();
    my $cursor = $c->find($key);
    while (my $object = $cursor->next) {
      my $mongoid = $object->{'_id'}->{'value'};
      $logger->trace("ID: $mongoid");
      my $etype;
      if ($object->{'once'}) {
        $etype = 'once'
      } else {
        $etype = 'repeat'
      }
      my $next = $object->{'next_schedule'};
      my $domain = $object->{'domain'};
      my $event_name = $object->{'event_name'};
      my $rid = $object->{'source'};
      my @temp = [$mongoid,"$domain/$event_name",$etype,$rid,$next];
      push(@list,@temp);
    }
    return \@list;
  } 
  return undef; 
}


sub get_schedev_list {
  my ($key) = @_;
  my $logger = get_logger();
  my $c = Kynetx::MongoDB::get_collection(COLLECTION);
  my @list = ();
  my $cursor = $c->find($key)->sort({'next_schedule' => 1});
  while (my $object = $cursor->next) {
    my $mongoid = $object->{'_id'}->{'value'};
    if ($mongoid) {
      push(@list,$mongoid);
    } 
  }
  return \@list;
}

sub clear_cron_ids {
  my ($key) = @_;
  $key = {} unless (defined $key);
  my $logger = get_logger();
  my $c = Kynetx::MongoDB::get_collection(COLLECTION);
  my $result = $c->update($key,{'$unset' => {cron_id => 1}},{multiple => 1,safe => 1});
  if (defined $result) {
    my $num = $result->{'n'};
    $logger->debug("Found ($num) to clear for : ",sub {Dumper($key)});
    return $num;
  }
  return 0;
}

sub single_event {
  my ($ken,$rid,$domain,$eventname,$timespec,$attr) = @_;
  my $epoch = DateTime->now->epoch;
  my $logger = get_logger();
  return undef unless (
    ((defined $ken) && 
      (defined $rid) && 
      (defined $domain) && 
      (defined $eventname))
    ); 
  my $dt = Kynetx::Predicates::Time::ISO8601($timespec);
  if ($dt) {
    my $sched =  $dt->epoch();
    if ($sched > $epoch) {
      $epoch = $sched;
    }
  }
  my $doc = {
    'ken' => $ken,
    'source' => $rid,
    'domain' => $domain,
    'event_name' => $eventname,
    'once' => $timespec,
    'next_schedule' => $epoch 
  };
  
  if (defined $attr) {
    $doc->{'event_attrs'} = $attr;
  }
  
  $logger->trace("Doc: ", sub {Dumper($doc)});
  my $sched_event_id = put_sched_ev($doc);
  return $sched_event_id;  
}

sub repeating_event {
  my ($ken,$rid,$domain,$eventname,$timespec,$attr) = @_;
  my $logger = get_logger();
  # data validation
  # scheduling is going to be relatively expensive so I can keep processing
  # times to the minimum
  return undef unless (
    ((defined $ken) && 
      (defined $rid) && 
      (defined $domain) && 
      (defined $eventname))
    ); 
  
  my $timezone = DateTime::TimeZone::UTC->new;
  
  if (ref $attr eq "HASH" && $attr->{'timezone'}) {
    $timezone = $attr->{'timezone'};
  }
  my $dt = DateTime->now;
  $dt->set_time_zone($timezone);
  
  
  
  my $cron = DateTime::Event::Cron->new(cron => $timespec,user_mode => 0);
  
  my $next = $cron->next($dt)->epoch();
  
  $logger->debug("Orig: " , $cron->original);
  $logger->debug("Next time: ",$next);  
  my $doc = {
    'ken' => $ken,
    'source' => $rid,
    'domain' => $domain,
    'event_name' => $eventname,
    'timespec' => $timespec,
    'next_schedule' => $next
  };
  
  if (defined $attr) {
    $doc->{'event_attrs'} = $attr;
  }
  
  $logger->trace("Doc: ", sub {Dumper($doc)});
  my $sched_event_id = put_sched_ev($doc);
  return $sched_event_id;
}


1;
