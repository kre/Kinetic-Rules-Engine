#!/usr/bin/perl
# Adapted from http://www.cyberciti.biz/tips/howto-write-perl-script-to-monitor-disk-space.html
use strict;
use warnings;

use Filesys::DiskSpace;
use Getopt::Std;
use Log::Log4perl qw(get_logger :levels);
use Mail::SendGrid;
use Mail::SendGrid::Transport::REST;


use Kynetx::Configure qw/:all/;

my $logger=get_logger();

 # configure KNS
Kynetx::Configure::configure();

# file system to monitor
my $dir = "/home";
 
# warning level
my $diskspace_warning_level=get_config("DISK_SPACE_THRESHOLD") || 100;

# check diskspace 
# get df
my ($fs_type, $fs_desc, $used, $avail, $fused, $favail) = df $dir;
 
# calculate 
my $df_free = (($avail) / ($avail+$used)) * 100.0;

my $out;
 
# compare 
if ($df_free < $diskspace_warning_level) {
 $out .= sprintf("WARNING Low Disk Space on $dir : %0.2f%% ()\n",$df_free);
}
 

if (defined $out) {


    my $this_host = get_config("EVAL_HOST");
    # email setup
    my $acct_system_owner =  Kynetx::Configure::get_config('ACCT_SYSTEM_OWNER') || "KRE System";
    my $acct_system_owner_email =  Kynetx::Configure::get_config('ACCT_SYSTEM_OWNER_EMAIL') || 'noreply@'. $this_host;
 
    my $to = get_config("SERVER_ADMIN");
    my $subject='KRE System Check Alert';

    $out .= "\n$acct_system_owner on ". $this_host;
    warn $out;

    my $sg = Mail::SendGrid->new( from => $acct_system_owner_email,
				  to => $to,
				  subject => $subject,
				  text => $out,
				);

    #disable click tracking filter for this request
    $sg->disableClickTracking();

    #set a category
    $sg->header->setCategory('system_check_alert');

    

    my $trans = Mail::SendGrid::Transport::REST->new( username =>  Kynetx::Configure::get_config('SENDGRID_USERNAME'), 
						      password =>  Kynetx::Configure::get_config('SENDGRID_PASSWORD') );

      my $error = $trans->deliver($sg);
      if ($error) {
	  my $msg = "Sendgrid error sending system check alert: " . $error;
	  $logger->warn($msg);
	  warn $msg;
      }
}
