#!/usr/local/bin/perl
##
##  printenv -- demo CGI program which just prints its environment
##

print "Content-type: text/plain; charset=iso-8859-1\n\n";
foreach $var (sort(keys(%ENV))) {
    $val = $ENV{$var};
    $val =~ s|\n|\\n|g;
    $val =~ s|"|\\"|g;
    print "${var}=\"${val}\"\n";
}


read( STDIN, $tmpStr, $ENV{ "CONTENT_LENGTH" } );
@parts = split( /\&/, $tmpStr );
foreach $part (@parts) {
    ( $name, $value ) = split( /\=/, $part );
    $value =~ ( s/%23/\#/g );
    $value =~ ( s/%2F/\//g );
    print "$name => $value\n";
}

