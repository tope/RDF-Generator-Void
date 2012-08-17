use Test::More;
use Test::RDF;
use FindBin qw($Bin);
use URI;
use RDF::Trine qw(literal statement iri);
use RDF::Trine::Parser;
use utf8;

my $builder = Test::More->builder;
binmode $builder->output, ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output, ":utf8";

my $base_uri = 'http://localhost';

my $testdata = $Bin . '/data/generated.ttl';
my $expected = $Bin . '/data/generated-expected.ttl';

use_ok("RDF::Generator::Void");

my $expected_void_model = RDF::Trine::Model->temporary_model;
my $data_model = RDF::Trine::Model->temporary_model;

my $parser     = RDF::Trine::Parser->new( 'turtle' );

$parser->parse_file_into_model( $base_uri, $testdata, $data_model );


my $void_gen = RDF::Generator::Void->new(dataset_uri => 'http://example.org/',
													  inmodel => $data_model);
$void_gen->urispace('http://example.org/subjects/');

isa_ok($void_gen, 'RDF::Generator::Void');

my $test_model = $void_gen->generate;

isa_ok($test_model, 'RDF::Trine::Model');

$parser->parse_file_into_model( $base_uri, $expected, $expected_void_model );

isomorph_graphs($test_model, $expected_void_model, 'Got the expected VoID description with generated data');


use RDF::Trine::Serializer;
my $ser = RDF::Trine::Serializer->new('turtle', namespaces => {dc => $dc, rdf => $rdf, rdfs => $rdfs, owl => $owl, foaf => $foaf, xsd => $xsd, rel => $rel, void => iri('http://rdfs.org/ns/void#')});
note $ser->serialize_model_to_string($test_model);

done_testing;
