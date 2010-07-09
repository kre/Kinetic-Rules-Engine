package amazon_credentials;

use strict;

use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

our $VERSION     = 1.00;
our @ISA         = qw(Exporter);

our %EXPORT_TAGS = (all => [ 
qw(
get_key_id
get_access_key
) ]);
our @EXPORT_OK   =(@{ $EXPORT_TAGS{'all'} }) ;

use vars qw($aws_access_key_id $aws_secret_access_key);

# this is all the machines that are running memcached
my $aws_access_key_id     = '0GEYA8DTVCB3XHM819R2';
my $aws_secret_access_key = 'I4TrjKcflLnchhsEzjlNju/s9EHiqdOScbyqGgn+';

sub get_key_id {
    return $aws_access_key_id;
}

sub get_access_key {
    return $aws_secret_access_key;
}

1;

