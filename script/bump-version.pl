#!/usr/bin/perl

use warnings;
use strict;

use RDF::Generator::Void;
use File::Slurp qw( edit_file ) ;

my $oldver = $RDF::Generator::Void::VERSION;

my $newver = $ARGV[0];

edit_file { s/(version =?\s*) $oldver/$1 $newver/ig } 'lib/RDF/Generator/Void.pm' ;

