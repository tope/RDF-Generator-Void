#!/usr/bin/perl

use 5.006;
use strict;
use warnings;
use Test::More tests => 1;
use Test::RDF::DOAP::Version;

doap_version_ok('RDF-Generator-Void', 'RDF::Generator::Void');
