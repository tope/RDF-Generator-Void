use inc::Module::Install;

name     'RDF-Generator-Void';
all_from 'lib/RDF/Generator/Void.pm';
author   q{Tope Omitola <tope.omitola@googlemail.com>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

