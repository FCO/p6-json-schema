use JSON5::Tiny;

enum SchemaType <object integer number string array>;

role JSON::Schema {
	has Str		$.str-json;
	has Any		$.json;

	multi method new(Str $data) {
		my $obj = ::?CLASS.bless;
		$obj.set-json($data);
		$obj
	}

	multi method new(Any $data) {
		my $obj = ::?CLASS.bless;
		$obj.set-data($data);
		$obj
	}

	method set-json(Str $!str-json) {
		$.set-data(from-json $!str-json)
	}

	method set-data($!json) {
		with $!json -> $data {
			$!str-json = to-json $data
		}
		#$!value = $!json
	}
}

sub camelize(Str $str --> Str) {
	$str.split(/\W/).map({.tc}).join("")
}

multi sub structurate(integer, ::Type, $json) {
	Type.^add_attribute: Attribute.new(
		:name('$!value'),
		:type(Str),
		:package(Type),
		:acessor<value>,
	)
}

multi sub structurate(string, ::Type, $json) {
	Type.^add_attribute: Attribute.new(
		:name('$!value'),
		:type(Str),
		:package(Type),
		:acessor<value>,
	)
}

multi sub structurate(object, ::Type, $json) {
	say Type;
	my %req := set @($json<required>);
	my %prop = $json<properties>.pairs;
	for %prop -> (:$key, :$value) {
		my $name = "\$!$key";
		note "Create attr $key {%req{$key} ?? "required" !! "not required"}";
		my $attr = Attribute.new(
			:name($name),
			:type(create-json-type(camelize($key), $value)),
			:package(Type),
			:has_accessor,
			:rw,
		);
		trait_mod:<is>($attr, :required) if %req{$key};
		Type.^add_attribute: $attr;
	}
}

multi sub structurate(array, ::Type, $json) {
	my @items = $json<items>.pairs;
	for @items -> $item {
		Type.^add_attribute: Attribute.new(
			:name('@!items'),
			:type(create-json-type(camelize(Type.name ~ "Item"), $item)),
			:package(Type)
			:has_accessor,
			:rw,
		)
	}
}

sub create-json-type(Str $name, $json-schema) {
	my SchemaType $type = do given $json-schema<type> {
		when "integer" {
			SchemaType::integer
		}
		when "string" {
			SchemaType::string
		}
		when "object" {
			SchemaType::object
		}
		default {
			say "Type '$_' not recognized";
			die "Type not recognized"
		}
	}

	my \tmp = Metamodel::ClassHOW.new_type(name => $name);
	tmp.^add_parent(Any);
	tmp.^add_role(JSON::Schema);

	structurate($type, tmp, $json-schema);

	with $json-schema<title> -> Str $title  {
		tmp.set_why($title)
	}

	tmp.^compose;

	tmp
}


role JSON::Schema[array] does JSON::Schema {
	has $.type = object;

}

sub EXPORT(*@files) {
	my %types;
	for @files -> $name, $file {
		%types{$name} = create-json-type($name, from-json $file.IO.slurp)
	}
	%types
}


