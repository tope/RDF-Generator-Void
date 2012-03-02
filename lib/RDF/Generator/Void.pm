package RDF::Generator::Void;

use 5.006;
use strict;
use warnings;
use RDF::Trine qw[iri literal blank variable statement];

=head1 NAME

RDF::Generator::Void - The great new RDF::Generator::Void!

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

=head2 new(inmodel => $mymodel, dataset_uri = URI->new($dataset_uri);

=cut

sub new {
  my ($class, %args) = @_;
  my $self = bless(\%args, $class);
  return $self;
}


=head2 generate

=cut

sub generate {
  my $self = shift;

  # Create a model for adding VoID description
  my $void_model = RDF::Trine::Model->temporary_model;

  # Define some namespace prefixes
  my $void = RDF::Trine::Namespace->new('http://rdfs.org/ns/void#');
  my $rdf = RDF::Trine::Namespace->new('http://www.w3.org/1999/02/22-rdf-syntax-ns#');
  my $xsd = RDF::Trine::Namespace->new('http://www.w3.org/2001/XMLSchema#');

  # Set some local variables that will be reused often
  my $uri = RDF::Trine::Node::Resource->new($self->{dataset_uri});
  my $model = $self->{inmodel};

  # Start generating the actual VoID statements
  $void_model->add_statement(statement($uri,
													$rdf->type,
													$void->Dataset
												  ));
  $void_model->add_statement(statement($uri,
													$void->triples,
													literal($model->size, undef, $xsd->integer)
									 ));
  return $void_model;
}

=head1 AUTHOR

Tope Omitola, C<< <tope.omitola at googlemail.com> >>

=head1 CONTRIBUTORS

Kjetil Kjernsmo

=head1 BUGS

Please report any bugs or feature requests to C<bug-rdf-generator-void at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=RDF-Generator-Void>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc RDF::Generator::Void


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=RDF-Generator-Void>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/RDF-Generator-Void>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/RDF-Generator-Void>

=item * Search CPAN

L<http://search.cpan.org/dist/RDF-Generator-Void/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Tope Omitola.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of RDF::Generator::Void
