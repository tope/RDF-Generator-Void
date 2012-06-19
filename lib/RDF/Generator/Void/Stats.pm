package RDF::Generator::Void::Stats;

use 5.006;
use strict;
use warnings;
use Any::Moose;

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


1;
