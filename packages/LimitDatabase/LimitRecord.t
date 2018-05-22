use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use LimitDatabase::LimitRecord;
use Data::Dumper;

# new empty
my $empty = LimitRecord->new_empty();
is(scalar keys %{$empty}, 0, "Empty hash ref");


# getter
my $man_lim = $empty;
dies_ok(sub{$man_lim->get("ETEST_NAME")}, "Accessing nonexistant value");
$man_lim->{"ETEST_NAME"} = "SOMETHING";
is($man_lim->get("ETEST_NAME"), "SOMETHING", "Accessing existant value");

# copier
my $lim = $man_lim->new_copy();
ok(hashes_identical($lim, $man_lim), "Copy structure");

# copier at areas
my $copies = $lim->create_copies_at_each_area(['AREA1', 'AREA2']);
is(scalar @{$copies}, 2, "Number of copies");
$man_lim->{"TEST_AREA"} = 'AREA1';
ok(hashes_identical($man_lim, $copies->[0]), "AREA1 set");
$man_lim->{"TEST_AREA"} = 'AREA2';
ok(hashes_identical($man_lim, $copies->[1]), "AREA2 set");

# set_item_type
$lim->set_item_type('DEVICE', 'some device');
is($lim->get("ITEM_TYPE"), 'DEVICE', "SET TO CORRECT ITEM_TYPE");
is($lim->get("ITEM"), 'some device', "SET TO CORRECT ITEM");
dies_ok(sub {$lim->set_item_type("I AM UNEXPECTED", "oOoOo")}, "Unexpected item type");

# DISPO = undef
$lim->{"DISPO"} = 'Y';
$lim->dummify();
is($lim->get("DISPO"), undef, "Dummified a known dummy record");

# copy_matching_f_summary_fields
my $f_sum = {ETEST_NAME=>"my name",DISPO=>"Y",SOMETHING_ELSE=>"uh oh"};
$lim->copy_matching_f_summary_fields($f_sum);
is($lim->get("ETEST_NAME"), "my name", "Copied over a known field from an f_summary");
is($lim->get("DISPO"), "Y", "Copied over a known field from an f_summary");
dies_ok(sub{$lim->get("SOMETHING_ELSE")}, "Checking to see if a non-standard field was copied over from f_summary record");

# merge
my $merged = LimitRecord->merge([]);
is($merged, undef, "merging 0 records resolves to undef");

$merged = LimitRecord->merge([$lim]);
is($lim, $lim, "Merging 1 records returns a reference to the record provided");

ok(LimitRecord->merge([$lim, $lim, $lim, $lim, $lim]), "Merges identical limits (by reference) ok");

my $lim1 = LimitRecord->new_empty();
my $lim2 = LimitRecord->new_empty();
ok(LimitRecord->merge([$lim1, $lim2]), "Merges identical records ok (*empty)");

$lim1->{"TECHNOLOGY"} = 'TECH';
ok($merged = LimitRecord->merge([$lim1, $lim2]), "Merges records with some fields existing/non-existing");
is($merged->{"TECHNOLOGY"}, 'TECH', "Correct merged result for technology");

$lim2->{"TECHNOLOGY"} = 'TACH';
dies_ok(sub{LimitRecord->merge([$lim1, $lim2])}, "Cannot resolve differing values (technology)");




