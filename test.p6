use JSON::Schema <Test ./test.schema.json>;

say Test.^attributes;

my $a = Test.new;
say $a;

say $a.bla.new;

say $a;

#my $new = Test.new: '{"bla":"ble"}';

#say $new.perl;

#say Test.^attributes.map: { name => .name, accessor => .has_accessor};

#`<
say $new;
say $new.age
>
