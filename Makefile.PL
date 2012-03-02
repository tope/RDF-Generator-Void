use inc::Module::Install;

name     'RDF-Generator-Void';
all_from 'lib/RDF/Generator/Void.pm';
author   q{Tope Omitola <tope.omitola@googlemail.com>};
license  'perl';

test_requires 'Test::More' => 0.88;
test_requires 'Test::RDF'  => 0.20;
test_requires 'FindBin';

requires 'RDF::Trine';
requires 'URI';

author_tests('xt');

auto_set_repository;
auto_set_bugtracker;

write_doap_changes;

WriteAll;

