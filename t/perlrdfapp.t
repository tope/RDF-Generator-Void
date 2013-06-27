use strict;
use warnings;
use Test::More;

eval { require App::perlrdf };
plan skip_all => "App::perlrdf needed for these tests" if ($@);
use App::Cmd::Tester;
use Test::RDF;
use FindBin qw($Bin);
use File::Temp qw(tempfile);

my $testdata = $Bin . '/data/basic.ttl';
my $expected = $Bin . '/data/basic-expected.ttl';

note 'First load the data into a SQLite DB';
my ($fh, $filename) = tempfile();
$fh->unlink_on_destroy( 1 );

my $load = test_app('App::perlrdf' => [ 'store_load', '-Q', $filename, $testdata ]);

like($load->stderr, qr|^Loading file:///\S+data/basic.ttl$|, 'Loading statement STDERR');
is($load->error, undef, 'threw no exceptions');
is($load->exit_code, 0, 'exit code 0');



done_testing();
