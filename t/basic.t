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

my $void_model = $void_gen->generate($void_model);

$parser->parse_file_into_model( $base_uri, $expected, $expected_void_model );

isomorph_graphs($void_model, $expected_void_model);

done_testing;
