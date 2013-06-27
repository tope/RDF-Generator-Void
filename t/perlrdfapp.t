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


my $load = test_app('App::perlrdf' => qw(store_load -Q $filename -o - $testdata));

is($load->stderr, '', 'nothing sent to STDERR');
is($load->error, undef, 'threw no exceptions');
is($load->exit_code, 0, 'exit code 0');

done_testing();
