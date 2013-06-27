#!/usr/bin/perl

use warnings;
use strict;

use RDF::Generator::Void;
use File::Slurp qw( edit_file_lines ) ;

my $oldver = $RDF::Generator::Void::VERSION;

my $newver = $ARGV[0];

edit_file_lines { s/(version\s+\=?\s*'?)$oldver('?)/$1$newver$2/ig } 'lib/RDF/Generator/Void.pm' ;

edit_file_lines { s/(Version) $oldver/$1 $newver/g } 't/data/basic-expected.ttl' ;

(my $eoldver = $oldver) =~ s/\./-/;
(my $enewver = $newver) =~ s/\./-/;

edit_file_lines { s/(v_)$eoldver/$1$enewver/g } 't/data/basic-expected.ttl' ;

edit_file_lines { s/(my:project :release)/$1 my:v_$enewver,/ } 'meta/changes.ttl' ;

1;
