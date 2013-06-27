use strict;
use warnings;
use Test::More;

eval { require App::perlrdf };
plan skip_all => "App::perlrdf needed for these tests" if ($@);
use App::Cmd::Tester;
use Test::RDF;
use FindBin qw($Bin);
use File::Temp qw(tempfile);

my $base_uri = 'http://localhost';

my $testdata = $Bin . '/data/basic.ttl';
my $expected = $Bin . '/data/basic-expected.ttl';

note 'First load the data into a SQLite DB';
my ($fh, $filename) = tempfile( UNLINK => 1, SUFFIX => '.sqlite');

my $load = test_app('App::perlrdf' => [ 'store_load', '-Q', $filename, $testdata ]);

like($load->stderr, qr|^Loading file:///\S+data/basic.ttl$|, 'Loading statement STDERR');
is($load->error, undef, 'Loading threw no exceptions');
is($load->exit_code, 0, 'Loading has exit code 0');

note 'Now test the VoID generation';

my $parser     = RDF::Trine::Parser->new( 'turtle' );

my $result = test_app('App::perlrdf' => [ 'void', '-Q', $filename, '-l', '1', $base_uri . '/dataset#foo' ]);

is($result->error, undef, 'VoID 1 threw no exceptions');
is($result->exit_code, 0, 'VoID 1 exit code 0');
ok($result->stdout, 'VoID 1 sends result to STDOUT');

my $data_model = RDF::Trine::Model->temporary_model;
$parser->parse_into_model( $base_uri, $result->stdout, $data_model );
my $expected_void_model = RDF::Trine::Model->temporary_model;
$parser->parse_file_into_model( $base_uri, $expected, $expected_void_model );

are_subgraphs($data_model, $expected_void_model, 'Got the expected VoID description with generated data');


done_testing();
