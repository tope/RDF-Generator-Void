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
my $expected_void_model = RDF::Trine::Model->temporary_model;
$parser->parse_file_into_model( $base_uri, $expected, $expected_void_model );

void_tests('void', '-Q', $filename, '-l', '1', $base_uri . '/dataset#foo' );

sub void_tests {
  my @args = @_;
  note 'Run tests for ' . join(" ", @args);
  my $result = test_app('App::perlrdf' => \@args);

  is($result->error, undef, 'VoID threw no exceptions');
  is($result->exit_code, 0, 'VoID exit code 0');
  ok($result->stdout, 'VoID sends result to STDOUT');

  warn $result->stdout;

  my $data_model = RDF::Trine::Model->temporary_model;
  $parser->parse_into_model( $base_uri, $result->stdout, $data_model );

  are_subgraphs($data_model, $expected_void_model, 'Got the expected VoID description with generated data');
}

done_testing();
