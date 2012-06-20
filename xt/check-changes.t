#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Test::More tests => 1;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

eval "use Test::RDF::DOAP::Version";
plan skip_all => "Test::RDF::DOAP::Version required" if $@;

doap_version_ok('RDF-Generator-Void', 'RDF::Generator::Void');
