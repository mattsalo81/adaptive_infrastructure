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

ok(lists_identical($list1, $list1), "can compare two identical lists");
ok(lists_identical($list1, $list2), "can compare two identical lists, but different references");
ok(!lists_identical($list1, $list3), "can compare two non-identical lists");

ok(have_same_elements($list1, $list1), "same list twice"); 
ok(have_same_elements($list1, $list2), "same list twice, different references"); 
ok(have_same_elements($list1, $list3), "same list twice, but mixed"); 
ok(!have_same_elements($list1, $list4), "different lists"); 


