#!/usr/bin/perl
use LWP::Simple;

# Stress testing persistent vars
# This needs to be a proper test. 

# the issue this is looking for occurs when there's a clash between cached keys in persistent vars.
# The two calls are to different kens. 

my $i = 100;
while ($i-- > 0) {
    $fleet_channel = get("http://127.0.0.1/sky/cloud/b16x16/fleetChannel?_eci=8DCB7248-024F-11E4-9FCB-CEB8E71C24E1");

    print "$fleet_channel\n";

    $vi = get("http://127.0.0.1/sky/cloud/b16x17/vehicleSummary?_eci=9C66D8E2-024F-11E4-BB30-D0B8E71C24E1");
    print "$vi\n" ;
    last if $vi eq "[]";
}

