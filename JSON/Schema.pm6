use JSON5::Tiny;

enum SchemaType <object number string array>;

role JSON::Schema[Str $type] {
	has SchemaType	$.type		= SchemaType($type);
	has Str		$.str-json;
	has 		$.json;

	method !from-json(Str $json) {
		from-json $json
	}

	#method BUILDALL(|) {
	#	my $json = from-json $!str-json;
	#	if SchemaType($type) == object {
	#		$!json = $json<properties>
	#	}
	#}
}


sub EXPORT(*@files) {
	my %types;
	for @files -> $file {
		my $json = from-json $file.IO.slurp;
		my $name = $json<title>;
		my \tmp = Metamodel::ClassHOW.new_type(name => $name);
		tmp.^add_parent(Any);
		tmp.^add_role(JSON::Schema[$json<type>]);
		tmp.^compose;

		%types{$name} = tmp
	}
	%types
}


