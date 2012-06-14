package RDF::Generator::Void;

use 5.006;
use strict;
use warnings;
use Any::Moose;
use Any::Moose '::Util::TypeConstraints';
use Data::UUID;
use RDF::Trine qw[iri literal blank variable statement];

# Define some namespace prefixes
my $void = RDF::Trine::Namespace->new('http://rdfs.org/ns/void#');
my $rdf  = RDF::Trine::Namespace->new('http://www.w3.org/1999/02/22-rdf-syntax-ns#');
my $xsd  = RDF::Trine::Namespace->new('http://www.w3.org/2001/XMLSchema#');

=head1 NAME

RDF::Generator::Void - Generate voiD descriptions based on data in an RDF model

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  use RDF::Generator::Void;
  use RDF::Trine::Model;
  my $mymodel   = RDF::Trine::Model->temporary_model;
  [add some data to $mymodel here]
  my $generator = RDF::Generator::Void->new(inmodel => $mymodel);
  my $voidmodel = $generator->generate;

=head1 DESCRIPTION

This module takes a L<RDF::Trine::Model> object as input to the
constructor, and based on the data in that model, it creates a new
model with a voiD description of the data in the model.

=head1 METHODS

=head2 new(inmodel => $mymodel, dataset_uri = URI->new($dataset_uri));

=head2 inmodel

Read-only accessor

=head2 dataset_uri

Read-only accessor

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

sub _build_dataset_uri
{
  my ($self) = @_;
  return iri sprintf('urn:uuid:%s', Data::UUID->new->create_str);
}

has is_speedy => (
  is       => 'ro',
  isa      => 'Bool',
  default  => 0,
  );

has vocabulary => (
						 is       => 'ro',
						 traits   => ['Array'],
						 isa      => 'ArrayRef[RDF::Trine::Node::Resource]',
						 default  => sub { [] },
						 handles  => {
										 all_vocabularies    => 'elements',
										 add_vocabulary      => 'push',
										 map_vocabularies    => 'map',
										 filter_vocabularies => 'grep',
										 find_vocabulary     => 'first',
										 get_vocabulary      => 'get',
										 join_vocabularies   => 'join',
										 count_vocabularies  => 'count',
										 has_no_vocabularies => 'is_empty',
										 sorted_vocabularies => 'sort',
										},
						 coerce   => 1,
    );

coerce 'RDF::Trine::Node::Resource',
  from 'URI',    via { iri("$_") },
  from 'Str',    via { iri($_) };



has stats => (
  is       => 'rw',
  isa      => 'HashRef',
  lazy     => 1,
  builder  => '_build_stats',
  clearer  => 'clear_stats',
  );

sub _build_stats
{
  my ($self) = @_;
  
  my (%vocab_counter);
  
  $self->inmodel->get_statements->each(sub
  {
    my $st = shift;
    next unless $st->rdf_compatible;
    
    # wrap in eval, as this can potentially throw an exception.
    eval {
      my ($vocab_uri) = $st->predicate->qname;
      $vocab_counter{$vocab_uri}++;
    };
  });
  
  return +{
    vocabularies  => \%vocab_counter,
  };
}

=head2 generate

=cut

sub generate
{
  my $self = shift;

  $self->clear_stats;

  # Create a model for adding VoID description
  local $self->{void_model} =
  my $void_model = RDF::Trine::Model->temporary_model;

  # Start generating the actual VoID statements
  $void_model->add_statement(statement(
    $self->dataset_uri,
    $rdf->type,
    $void->Dataset,
  ));
  
  $self->_generate_triple_count;
  $self->_generate_most_common_vocabs unless $self->is_speedy;
  
  return $void_model;
}

sub _generate_triple_count
{
  my ($self) = @_;
  
  $self->{void_model}->add_statement(statement(
    $self->dataset_uri,
    $void->triples,
    literal($self->inmodel->size, undef, $xsd->integer),
  ));
}

sub _generate_most_common_vocabs
{
  my ($self) = @_;

  # Which vocabularies are most commonly used for predicates in the
  # dataset? Vocabularies used for less than 1% of triples need not
  # apply.
  my $threshold = $self->inmodel->size / 100;
  my %vocabs    = %{ $self->stats->{vocabularies} };
  my @common    = grep { $vocabs{$_} > $threshold } keys %vocabs;
  
  foreach my $vocab (@common)
  {
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

Please report any bugs you find to L<https://github.com/tope/RDF-Generator-Void/issues>


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

=item * Search CPAN

L<http://search.cpan.org/dist/RDF-Generator-Void/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Tope Omitola, Kjetil Kjernsmo, Toby Inkster.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of RDF::Generator::Void
