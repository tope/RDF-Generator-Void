package RDF::Generator::Void::Meta::Attribute::ResourceList;
use Moose::Role;
use Data::Dumper;

with (
    'Moose::Meta::Attribute::Native::Trait::Array',
);

around _process_options => sub {
	my $orig = shift;
	my (undef, $attr_name, $options) = @_;
	
	$options->{is} = 'rw';
	$options->{isa} = 'ArrayRef[Str]';
	
	# WTF isn't this like crazy to add traits to the class in a trait. Hmm, Nah, that's okay.
	$options->{traits} //= [];
	push @{ $options->{traits} }, 'Moose::Meta::Attribute::Native::Trait::Array';
	
	$options->{default} = sub {[]};
	$options->{handles} = {
								  sprintf("add_%s", $attr_name) => 'push',
								  sprintf("all_%s", $attr_name) => 'uniq',
								 };
	warn "DaHUT " . Data::Dumper::Dumper($options->{handles});
	$orig->(@_);
};



1;
