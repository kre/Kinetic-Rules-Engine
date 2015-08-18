#!/usr/bin/perl
# Config script for kns_config.yml

use lib qw(/web/lib/perl
  ./perl
  );
use strict;

use IO::File;
use Data::Dumper;
use Carp;
use Cache::Memcached;

use Kynetx::Configure;
use Kynetx::MongoDB;
use Kynetx::Memcached;

use ConfMaker qw(:all);

Kynetx::Configure::configure();
Kynetx::MongoDB::init();
Kynetx::Memcached->init();

my $q = {
  'desc' => 'Replace MongoDB credentials',
  'default' => 'N'
};
my $replace = q_single($q);

exit(0) unless ($replace =~ m/^[Yy]/);

my $salt_size = 63;
my $config_file = "/web/etc/kns_config.yml";

my $dict_path = "/usr/share/dict/words";
my @DICTIONARY;
open DICT, $dict_path;
@DICTIONARY = <DICT>;

my $a = $DICTIONARY[rand(@DICTIONARY)];
my $b = $DICTIONARY[rand(@DICTIONARY)];
my $c = $DICTIONARY[rand(@DICTIONARY)];
my $d = $DICTIONARY[rand(@DICTIONARY)];

my $salt = salt();

chop $a;
chop $b;
chop $c;
chop $d;

my $phrase = Encode::encode("latin1",$a . $b);
my $phrase_id = add_dictionary($phrase);
my $password = Encode::encode("latin1",$c . $d);
my $password_id = add_dictionary($password);

my @creds = ();

my $tag = "######### MongoDB Credentials";
my $description = "Credentials for MongoDB";
push(@creds, "PCI_KEY: '$salt'\n");
push(@creds, "PCI_PHRASE: '$phrase_id'\n");
push(@creds, "PCI_PASSWORD: '$password_id'\n");

write_section($config_file,$tag,$description,\@creds);

print "\tn.b. Credentials have been added to kns_config.yml\n";
print "\tAny existing credentials have been replaced\n";


sub add_dictionary {
  my ($string) = @_;
  my $mongoid = MongoDB::OID->new();
  my $mongo_key = {
      "_id" => $mongoid
  };
  my $value = {'passphrase' => $string};
  my $result = Kynetx::MongoDB::update_value('dictionary', $mongo_key,$value,1,0,1);
  if (defined $result && ref $result eq "HASH") {
    my $id = $result->{'upserted'};
    return $id->to_string();
  }
}


sub salt {
  my @chars = ("A".."Z","a".."z",0..9,"_");
  my $salt;
  $salt .= $chars[rand @chars] for 0..$salt_size;
  return $salt;
}
