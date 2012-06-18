use inc::Module::Install;

name     'RDF-Generator-Void';
all_from 'lib/RDF/Generator/Void.pm';
readme_from 'lib/RDF/Generator/Void.pm';
author   q{Kjetil Kjernsmo <kjetilk@cpan.org>};
license  'perl';

test_requires 'Test::More' => 0.88;
test_requires 'Test::RDF'  => 0.20;
test_requires 'FindBin';

requires 'RDF::Trine';
requires 'URI';
requires 'Data::UUID';
requires 'Any::Moose';

author_tests('xt');

auto_set_repository;

resources
  bugtracker    => "https://github.com/kjetilk/RDF-Generator-Void/issues";

rdf_metadata;
#write_doap_changes;

sign;

WriteAll;

