package RDF::Generator::Void;

use 5.006;
use strict;
use warnings;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';
use Data::UUID;
use RDF::Trine qw[iri literal blank variable statement];
use RDF::Generator::Void::Stats;
# use less ();

# Define some namespace prefixes
my $void = RDF::Trine::Namespace->new('http://rdfs.org/ns/void#');
my $rdf  = RDF::Trine::Namespace->new('http://www.w3.org/1999/02/22-rdf-syntax-ns#');
my $xsd  = RDF::Trine::Namespace->new('http://www.w3.org/2001/XMLSchema#');
my $dct  = RDF::Trine::Namespace->new('http://purl.org/dc/terms/');

=head1 NAME

RDF::Generator::Void - Generate VoID descriptions based on data in an RDF model

=head1 VERSION

Version 0.01_14

Note that this is an early alpha release. It has pretty limited
functionality, and there may very significant changes in this module
coming up really soon.

=cut

our $VERSION = '0.01_14';

=head1 SYNOPSIS

  use RDF::Generator::Void;
  use RDF::Trine::Model;
  my $mymodel   = RDF::Trine::Model->temporary_model;
  [add some data to $mymodel here]
  my $generator = RDF::Generator::Void->new(inmodel => $mymodel);
  $generator->urispace('http://example.org');
  $generator->add_endpoints('http://example.org/sparql');
  my $voidmodel = $generator->generate;

=head1 DESCRIPTION

This module takes a L<RDF::Trine::Model> object as input to the
constructor, and based on the data in that model as well as data
supplied by the user, it creates a new model with a VoID description
of the data in the model.

For a description of VoID, see L<http://www.w3.org/TR/void/>.

=head1 METHODS

=head2 new(inmodel => $mymodel, dataset_uri => URI->new($dataset_uri));

The constructor. It can be called with two parameters, namely,
C<inmodel> which is a model we want to describe and C<dataset_uri>,
which is the URI we want to use for the description. Users should make
sure it is possible to get this with HTTP. If this is not possible,
you may leave this field empty so that a simple URN can be created for
you as a default.

=head2 C<inmodel>

Read-only accessor for the model used in description creation.

=head2 C<dataset_uri>

Read-only accessor for the URI to the dataset.

=cut

has inmodel => (
					 is       => 'ro',
					 isa      => 'RDF::Trine::Model',
					 required => 1,
					);

class_type 'URI';

subtype 'DatasetURI',
  as 'Object',
  where { $_->isa('RDF::Trine::Node::Resource') || $_->isa('RDF::Trine::Node::Blank') };

coerce 'DatasetURI',
  from 'URI',    via { iri("$_") },
  from 'Str',    via { iri($_) };

has dataset_uri => (
						  is       => 'ro',
						  isa      => 'DatasetURI',
						  lazy     => 1,
						  builder  => '_build_dataset_uri',
						  coerce   => 1,
						 );

sub _build_dataset_uri {
	my ($self) = @_;
	return iri sprintf('urn:uuid:%s', Data::UUID->new->create_str);
}

=head2 Property Attributes

The below attributes concern some essential properties in the VoID
vocabulary. They are mostly arrays, and can be manipulated using array
methods. Methods starting with C<all_> will return an array of unique
values. Methods starting with C<add_> takes a list of values to add,
and those starting with C<has_no_> return a boolean value, false if
the array is empty.

=head3 C<vocabulary>, C<all_vocabularies>, C<add_vocabularies>, C<has_no_vocabularies>

Methods to manipulate a list of vocabularies used in the dataset. The
values should be a string that represents the URI of a vocabulary.

=cut

has vocabulary => (
						 is       => 'rw',
						 traits   => ['Array'],
						 isa      => 'ArrayRef[Str]',
						 default  => sub { [] },
						 handles  => {
										  all_vocabularies    => 'uniq',
										  add_vocabularies    => 'push',
										  has_no_vocabularies => 'is_empty',
										 },
						);

=head3 C<endpoint>, C<all_endpoints>, C<add_endpoints>, C<has_no_endpoints>

Methods to manipulate a list of SPARQL endpoints that can be used to
query the dataset. The values should be a string that represents the
URI of a SPARQL endpoint.

=cut


has endpoint => (
					  is       => 'rw',
					  traits   => ['Array'],
					  isa      => 'ArrayRef[Str]',
					  default  => sub { [] },
					  handles  => {
										all_endpoints    => 'uniq',
										add_endpoints    => 'push',
										has_no_endpoints => 'is_empty',
									  },
					 );

=head3 C<title>, C<all_titles>, C<add_titles>, C<has_no_titles>

Methods to manipulate the titles of the datasets. The values should be
L<RDF::Trine::Node::Literal> objects, and should be set with
language. Typically, you would have a value per language.

=cut


has title => (
				  is       => 'rw',
				  traits   => ['Array'],
				  isa      => 'ArrayRef[RDF::Trine::Node::Literal]',
				  default  => sub { [] },
				  handles  => {
									all_titles    => 'uniq',
									add_titles    => 'push',
									has_no_titles => 'is_empty',
								  },
				 );


=head3 C<license>, C<all_licenses>, C<add_licenses>, C<has_no_licenses>

Methods to manipulate a list of licenses that regulates the use of the
dataset. The values should be a string that represents the URI of a
license.

=cut

has license => (
					 is       => 'rw',
					 traits   => ['Array'],
					 isa      => 'ArrayRef[Str]',
					 default  => sub { [] },
					 handles  => {
									  all_licenses    => 'uniq',
									  add_licenses    => 'push',
									  has_no_licenses => 'is_empty',
									 },
					);

=head3 C<urispace>, C<has_urispace>

This method is used to set the URI prefix string that will match the
entities in your dataset. The computation of the number of entities
depends on this being set. C<has_urispace> can be used to check if it
is set.

=cut

has urispace => (
					  is        => 'rw',
					  isa       => 'Str',
					  predicate => 'has_urispace',
					 );

=head2 C<stats>, C<clear_stats>, C<has_stats>

Method to compute a statistical summary for the data in the dataset,
such as the number of entities, predicates, etc. C<clear_stats> will
clear the statistics and C<has_stats> will return true if exists.

=cut

has stats => (
				  is       => 'rw',
				  isa      => 'RDF::Generator::Void::Stats',
				  lazy     => 1,
				  builder  => '_build_stats',
				  clearer  => 'clear_stats',
				  predicate => 'has_stats',
				 );

sub _build_stats {
	my ($self) = @_;
	return RDF::Generator::Void::Stats->new(generator => $self);
}


=head2 generate

Returns the VoID as an RDF::Trine::Model.

=cut

sub generate {
	my $self = shift;

	# Create a model for adding VoID description
	local $self->{void_model} =
	  my $void_model = RDF::Trine::Model->temporary_model;

	# Start generating the actual VoID statements
	$void_model->add_statement(statement(
													 $self->dataset_uri,
													 $rdf->type,
													 $void->Dataset,
													));

	if ($self->has_urispace) {
		$void_model->add_statement(statement(
														 $self->dataset_uri,
														 $void->uriSpace,
														 literal($self->urispace)
														));
		$self->_generate_counts($void->entities, $self->stats->entities);
	}

	$self->_generate_counts($void->distinctSubjects, $self->stats->subjects);
	$self->_generate_counts($void->properties, $self->stats->properties);
	$self->_generate_counts($void->distinctObjects, $self->stats->objects);


	foreach my $endpoint ($self->all_endpoints) {
		$void_model->add_statement(statement(
														 $self->dataset_uri,
														 $void->sparqlEndpoint,
														 iri($endpoint)
														));
	}

	foreach my $title ($self->all_titles) {
		$void_model->add_statement(statement(
														 $self->dataset_uri,
														 $dct->title,
														 $title
														));
	}
 
	foreach my $license ($self->all_licenses) {
		$void_model->add_statement(statement(
														 $self->dataset_uri,
														 $dct->license,
														 iri($license)
														));
	}


	$void_model->add_statement(statement(
													 $self->dataset_uri,
													 $void->triples,
													 literal($self->inmodel->size, undef, $xsd->integer),
													));
	$self->_generate_most_common_vocabs($self->stats) if $self->has_stats;
  
	return $void_model;
}

sub _generate_counts {
	my ($self, $predicate, $count) = @_;
	return undef unless $self->has_stats;
	$self->{void_model}->add_statement(statement(
																$self->dataset_uri,
																$predicate,
																literal($count, undef, $xsd->integer),
															  ));
}

sub _generate_most_common_vocabs {
	my ($self) = @_;

	# Which vocabularies are most commonly used for predicates in the
	# dataset? Vocabularies used for less than 1% of triples need not
	# apply.
	my $threshold = $self->inmodel->size / 100;
	my %vocabs    = %{ $self->stats->vocabularies };
	$self->add_vocabularies(grep { $vocabs{$_} > $threshold } keys %vocabs);
  
	foreach my $vocab ($self->all_vocabularies) {
		$self->{void_model}->add_statement(statement(
																	$self->dataset_uri,
																	$void->vocabulary,
																	iri($vocab),
																  ));
	}
}


=head1 AUTHORS

Kjetil Kjernsmo
Toby Inkster
Tope Omitola, C<< <tope.omitola at googlemail.com> >>

=head1 BUGS

Please report any bugs you find to L<https://github.com/kjetilk/RDF-Generator-Void/issues>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc RDF::Generator::Void

The Perl and RDF community website is at L<http://www.perlrdf.org/>
where you can also find a mailing list to direct questions to.

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/RDF-Generator-Void>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/RDF-Generator-Void>

=item * MetaCPAN

L<https://metacpan.org/module/RDF::Generator::Void>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Tope Omitola, Kjetil Kjernsmo, Toby Inkster.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;										  # End of RDF::Generator::Void
