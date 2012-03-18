use Test::More;
use Test::RDF;
use FindBin qw($Bin);
use URI;
use RDF::Trine;
use RDF::Trine::Parser;

my $base_uri = 'http://localhost';

my $testdata = $Bin . '/data/basic.ttl';
my $expected = $Bin . '/data/basic-expected.ttl';

use_ok("RDF::Generator::Void");

my $expected_void_model = RDF::Trine::Model->temporary_model;
my $data_model = RDF::Trine::Model->temporary_model;

my $parser     = RDF::Trine::Parser->new( 'turtle' );
$parser->parse_file_into_model( $base_uri, $testdata, $data_model );

my $void_gen = RDF::Generator::Void->new(dataset_uri => $base_uri . '/dataset',
													  inmodel => $data_model);

isa_ok($void_gen, 'RDF::Generator::Void');

my $void_model = $void_gen->generate($void_model);

isa_ok($void_model, 'RDF::Trine::Model');

$parser->parse_file_into_model( $base_uri, $expected, $expected_void_model );

are_subgraphs($expected_void_model, $void_model, 'Got the expected VoID description');

#diag(RDF::Trine::Serializer::Turtle->new->serialize_model_to_string($void_model));

done_testing;
