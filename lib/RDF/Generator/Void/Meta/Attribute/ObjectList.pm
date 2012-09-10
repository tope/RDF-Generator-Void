package RDF::Generator::Void::Meta::Attribute::ObjectList;

use Moose::Role;
#use Data::Dumper;

with (
    'Moose::Meta::Attribute::Native::Trait::Array',
);

around _process_options => sub {
	my $orig = shift;
	my (undef, $attr_name, $options) = @_;
	
	$options->{is}  = 'rw';
	$options->{isa} = 'ArrayRef[Str]' unless exists $options->{isa};

	if ($attr_name =~ /^_(.+)/) {
		$attr_name = $1;
		$options->{init_arg} = $attr_name;
	}
	
	# WTF isn't this like crazy to add traits to the class in a trait. Hmm, Nah, that's okay.
	$options->{traits} = [] unless exists $options->{traits};
	push @{ $options->{traits} }, 'Moose::Meta::Attribute::Native::Trait::Array';
	
	$options->{default} = sub {[]};
	$options->{handles} = {
								  sprintf("add_%s", $attr_name) => 'push',
								  sprintf("all_%s", $attr_name) => 'uniq',
								  sprintf("has_no_%s", $attr_name) => 'is_empty',
								 };
	$orig->(@_);
};



1;
