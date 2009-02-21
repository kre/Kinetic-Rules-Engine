#!/usr/bin/perl -w 

use lib qw(/web/lib/perl);
use strict;

use Test::More;
use Test::LongString;

use APR::URI;
use APR::Pool ();


# most Kyentx modules require this
use Log::Log4perl qw(get_logger :levels);
Log::Log4perl->easy_init($INFO);

use Kynetx::Test qw/:all/;
use Kynetx::Predicates::Useragent qw/:all/;
use Kynetx::JavaScript qw/:all/;


my $preds = Kynetx::Predicates::Useragent::get_predicates();
my @pnames = keys (%{ $preds } );



my $BYU_req_info;
$BYU_req_info->{'referer'} = 'http://www.byu.edu'; # Utah (BYU)
$BYU_req_info->{'pool'} = APR::Pool->new;
$BYU_req_info->{'ua'} = 'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.6) Gecko/2009011912 Firefox/3.0.6';

my $no_referer_req_info;
$no_referer_req_info->{'pool'} = APR::Pool->new;

my %rule_env = ();

my @fields = qw(
browser_name
browser_version
browser_version_major
browser_version_minor
os
os_type
os_version
language
language_code
);

my @ua_strings = (
['Mozilla/4.7 [en] (WinNT; U)',
 'Netscape','4.7','4','7','WinNT','Windows','NT','English','en'],
['Mozilla/4.0 (compatible; MSIE 5.01; Windows NT)',
 'Internet Explorer','5.01','5','01','Windows NT','Windows NT',undef,undef,undef],
['Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; T312461; .NET CLR 11.4322)',
 'Internet Explorer','6.0','6','0','Windows NT 5.0','Windows NT','2000',undef,undef],
['Mozilla/4.0 (compatible; MSIE 5.0; Windows NT 4.0) Opera 5.11 [en]',
 'Internet Explorer','5.0','5','0','Windows NT 4.0','Windows NT','4.0','English','en'],
['Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/20040612 Firefox/0.8',
 'Firefox','0.8','0','8','Linux i686','Linux','i686',undef,''],
# 'Mozilla/5.0 (Windows; U; Windows NT 5.0; en-US; rv:1.0.2) Gecko/20030208 Netscape/7.02',
# 'Mozilla/5.0 (compatible; Konqueror/3.2; Linux) (KHTML, like Gecko)',
# 'Lynx/2.8.4rel.1 libwww-FM/2.14 SSL-MM/1.4.1 OpenSSL/0.9.6h',
);

plan tests => int(@fields) * int(@ua_strings) + int(@pnames);

# check that predicates at least run without error
my @dummy_arg = (0);
foreach my $pn (@pnames) {
    ok(&{$preds->{$pn}}($BYU_req_info, \%rule_env,\@dummy_arg) ? 1 : 1, "$pn runs");
}


foreach my $uas (@ua_strings) {
#    diag $uas->[0];
   
    $BYU_req_info->{'useragent'} = undef; # set it up for another try
    $BYU_req_info->{'ua'} = $uas->[0];
    my $i = 1;
    foreach my $f (@fields) {
       is(get_useragent($BYU_req_info,$f),$uas->[$i],"Checking $f");
       $i++;
    }
}

1;


