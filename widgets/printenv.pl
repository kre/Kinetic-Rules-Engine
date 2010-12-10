#!/usr/local/bin/perl -w
##
##  printenv -- demo CGI program which just prints its environment
##

use strict;

use lib qw(/web/lib/perl);


print "Content-type: text/plain; charset=iso-8859-1;\n";
print "Flipper: hello world!; \n\n";
foreach my $var (sort(keys(%ENV))) {
    my $val = $ENV{$var};
    $val =~ s|\n|\\n|g;
    $val =~ s|"|\\"|g;
    print "${var}=\"${val}\"\n";
}

my $tmpStr;
read( STDIN, $tmpStr, $ENV{ "CONTENT_LENGTH" } );
if ($ENV{'CONTENT_TYPE'} eq 'application/x-www-form-urlencoded') {
  my @parts = split( /\&/, $tmpStr );
  foreach my $part (@parts) {
    my ( $name, $value ) = split( /\=/, $part );
    $value =~ ( s/%23/\#/g );
    $value =~ ( s/%2F/\//g );
    print "$name => $value\n";
  }

} else {
   print $tmpStr, "\n";
}
