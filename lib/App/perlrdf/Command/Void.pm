package App::perlrdf::Command::Void;

use strict;
use warnings;
use utf8;

BEGIN {
    $App::perlrdf::Command::Void::AUTHORITY = 'cpan:KJETILK';
    $App::perlrdf::Command::Void::VERSION   = '0.01';
}

use App::perlrdf -command;

use namespace::clean;

use constant abstract      => q (Generate VoID description for a given store);
use constant command_names => qw( void );

use constant description   => <<'INTRO' . __PACKAGE__->store_help . <<'DESCRIPTION';
Retrieve a VoID description from an RDF::Trine::Store.
INTRO
 
Output files are specified the same way as for the 'translate' command. See
'filespec' for more details.
DESCRIPTION
 
use constant opt_spec => (
    __PACKAGE__->store_opt_spec,
    []=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>,
    [ 'output|o=s@',       'Output filename or URL' ],
    [ 'output-spec|O=s@',  'Output file specification' ],
    [ 'output-format|s=s', 'Output format (mnemonic: serialise)' ],
	 [ 'detail_level|l=i',  'The level of detail used for VoID (defaults to 2)', { default => 2 }  ],
	 [ 'void_urispace=s',   'The URI space a VoID dataset.' ],
	 [ 'used_vocabularies=s@', 'URIs of vocabularies used in the data' ],
	 [ 'endpoint_urls=s@',  'URLs of SPARQL Endpoints that holds the data' ],
    [ 'void_title=s',      'A title in English for the datasets' ], # TODO: Support more titles
	 [ 'license_uris=s@',   'URIs to licenses that regulates the use of the dataset'],
);
use constant usage_desc   => '%c void %o DATASET_URI';
 
sub execute
{
    use RDF::Trine qw( iri literal ) ;
    require App::perlrdf::FileSpec::OutputRDF;
	 use RDF::Generator::Void;

    my ($self, $opt, $arg) = @_;
 
    my $store = $self->get_store($opt);
    my $model = RDF::Trine::Model->new($store);
 
    my $dataset_uri = @$arg
        ? iri(shift @$arg)
        : $self->usage_error("No URI for the dataset is given");
 
    my @outputs = $self->get_filespecs(
        'App::perlrdf::FileSpec::OutputRDF',
        output => $opt,
    );
     
    push @outputs, map {
        App::perlrdf::FileSpec::OutputRDF->new_from_filespec(
            $_,
            $opt->{output_format},
            $opt->{output_base},
        )
    } @$arg;
     
    push @outputs,
        App::perlrdf::FileSpec::OutputRDF->new_from_filespec(
            '-',
            ($opt->{output_format} // 'NQuads'),
            $opt->{output_base},
        )
        unless @outputs;

	 my $generator = RDF::Generator::Void->new(inmodel => $model,
															 dataset_uri => $dataset_uri,
															 level => $opt->{detail_level},
															);
	 if ($opt->{void_urispace}) {
		$generator->urispace($opt->{void_urispace});
	 }
	 if ($opt->{endpoint_urls}) {
		$generator->add_endpoints(@{$opt->{endpoint_urls}});
	 }
	 if ($opt->{used_vocabularies}) {
		$generator->add_vocabularies(@{$opt->{used_vocabularies}});
	 }
	 if ($opt->{license_uris}) {
		$generator->add_licenses(@{$opt->{license_uris}});
	 }
	 if ($opt->{void_title}) {
		$generator->add_titles(literal($opt->{void_title}, 'en'));
	 }

	 my $description = $generator->generate;
 
    for (@outputs)
    {
        printf STDERR "Writing %s\n", $_->uri;
         
        eval {
            local $@ = undef;
            $_->serialize_model($description);
            1;
        } or warn "$@\n";
    }
}
 
1;
