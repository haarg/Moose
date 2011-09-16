#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Moose::Util::TypeConstraints;

is( exception {
    subtype 'MyCollections' => as 'ArrayRef | HashRef';
}, undef, '... created the subtype special okay' );

{
    my $t = find_type_constraint('MyCollections');
    isa_ok($t, 'Moose::Meta::TypeConstraint');

    is($t->name, 'MyCollections', '... name is correct');

    my $p = $t->parent;
    isa_ok($p, 'Moose::Meta::TypeConstraint::Union');
    isa_ok($p, 'Moose::Meta::TypeConstraint');

    is($p->name, 'ArrayRef|HashRef', '... parent name is correct');

    ok($t->check([]), '... validated it correctly');
    ok($t->check({}), '... validated it correctly');
    ok(!$t->check(1), '... validated it correctly');
}

is( exception {
    subtype 'MyCollectionsExtended'
        => as 'ArrayRef|HashRef'
        => where {
            if (ref($_) eq 'ARRAY') {
                return if scalar(@$_) < 2;
            }
            elsif (ref($_) eq 'HASH') {
                return if scalar(keys(%$_)) < 2;
            }
            1;
        };
}, undef, '... created the subtype special okay' );

{
    my $t = find_type_constraint('MyCollectionsExtended');
    isa_ok($t, 'Moose::Meta::TypeConstraint');

    is($t->name, 'MyCollectionsExtended', '... name is correct');

    my $p = $t->parent;
    isa_ok($p, 'Moose::Meta::TypeConstraint::Union');
    isa_ok($p, 'Moose::Meta::TypeConstraint');

    is($p->name, 'ArrayRef|HashRef', '... parent name is correct');

    ok(!$t->check([]), '... validated it correctly');
    ok($t->check([1, 2]), '... validated it correctly');

    ok(!$t->check({}), '... validated it correctly');
    ok($t->check({ one => 1, two => 2 }), '... validated it correctly');

    ok(!$t->check(1), '... validated it correctly');
}

done_testing;
