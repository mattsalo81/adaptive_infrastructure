use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Lists;

my $list1 = ['A', 'B', 'C', undef, '1', 1];
my $list2 = ['A', 'B', 'C', undef, '1', 1];
my $list3 = ['B', 'A', '1', 1, 'C', undef];
my $list4 = ['HAM'];

ok(in_list('B', $list1), "can find an element that's there");
ok(!in_list('Bee movie', $list1), "can't find an element that's not there");

ok(subset([1, 2, 3], [-1, 0, 1, 2, 3, 4, 5]), "Identifies a subset of a superset");
ok(!subset([1, 2, 3, 10], [-1, 0, 1, 2, 3, 4, 5]), "Identifies a non-subset of a superset");

ok(lists_identical($list1, $list1), "can compare two identical lists");
ok(lists_identical($list1, $list2), "can compare two identical lists, but different references");
ok(!lists_identical($list1, $list3), "can compare two non-identical lists");

ok(have_same_elements($list1, $list1), "same list twice"); 
ok(have_same_elements($list1, $list2), "same list twice, different references"); 
ok(have_same_elements($list1, $list3), "same list twice, but mixed"); 
ok(!have_same_elements($list1, $list4), "different lists"); 

my $hash1 = {
    A   => "WOW",
    B   => "HOORAY",
    C   => undef,
    D   => 1,
};
my $hash2 = {
    D   => 1,
    B   => "HOORAY",
    A   => "WOW",
    C   => undef,
};
my $hash3 = {
    A   => "WOW",
    B   => "HOORAY",
    C   => undef,
    D   => 1,
    E   => "UHOH",
};

ok(hashes_identical($hash1, $hash1), "compares two identical references");
ok(hashes_identical($hash1, $hash2), "compares two identical hashes, but different references");
ok(!hashes_identical($hash1, $hash3), "compares two different hashes");
ok(!hashes_identical($hash3, $hash1), "compares two different hashes");


