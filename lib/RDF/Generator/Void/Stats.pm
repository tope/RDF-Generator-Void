package RDF::Generator::Void::Stats;

use 5.006;
use strict;
use warnings;
use Moose;

=head1 NAME

RDF::Generator::Void::Stats - Generate statistics needed for good VoID descriptions

=head1 SYNOPSIS

Typically called for you by L<RDF::Generator::Void> as:

  my $stats = RDF::Generator::Void::Stats->new(generator => $self);


=head2 METHODS

=head3 C<< BUILD >>

Called by Moose to initialize an object.

=head3 C<generator>

Parameter to the constructor, to pass a L<RDF::Generator::Void> object.

=head3 C<vocabularies>

A hashref used to find common vocabularies in the data.

=head3 C<entities>

The number of distinct entities, as defined in the specification.

=head3 C<properties>

The number of distinct properties, as defined in the specification.

=head3 C<subjects>

The number of distinct subjects, as defined in the specification.

=head3 C<objects>

The number of distinct objects, as defined in the specification.



=cut


has vocabularies => ( is => 'rw', isa => 'HashRef' );

has entities => ( is => 'rw', isa => 'Int' );

has properties => ( is => 'rw', isa => 'Int' );

has subjects => ( is => 'rw', isa => 'Int' );

has objects => ( is => 'rw', isa => 'Int' );

has generator => (
					 is       => 'ro',
					 isa      => 'RDF::Generator::Void',
					 required => 1,
					);

sub BUILD {
	my ($self) = @_;
  
	my (%vocab_counter, %entities, %properties, %subjects, %objects);

	my $gen = $self->generator;
	$gen->inmodel->get_statements->each(sub {
		my $st = shift;
		next unless $st->rdf_compatible;
		
		# wrap in eval, as this can potentially throw an exception.
		eval {
			my ($vocab_uri) = $st->predicate->qname;
			$vocab_counter{$vocab_uri}++;
		};

		if ($gen->has_urispace) {
			# Compute entities
			(my $urispace = $gen->urispace) =~ s/\./\\./g;
			$entities{$st->subject->uri_value} = 1 if ($st->subject->uri_value =~ m/^$urispace/);
		}
		
		$subjects{$st->subject->uri_value} = 1;
		$properties{$st->predicate->uri_value} = 1;
		$objects{$st->object->sse} = 1;
	});
	
	$self->vocabularies(\%vocab_counter);
	$self->entities(scalar keys %entities);
	$self->properties(scalar keys %properties);
	$self->subjects(scalar keys %subjects);
	$self->objects(scalar keys %objects);
	
}

=head1 FURTHER DOCUMENTATION

Please see L<RDF::Generator::Void> for further documentation.

=head1 AUTHORS AND COPYRIGHT


Please see L<RDF::Generator::Void> for information about authors and copyright for this module.


=cut

1;
