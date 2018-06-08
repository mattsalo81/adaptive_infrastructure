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
ok(!$empty->is_dummy(), "Empty limit is not a dummy");


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
ok($lim->is_dummy(), "Dummy limit registers as one");

# copy_matching_f_summary_fields
my $f_sum = {ETEST_NAME=>"my name",DISPO=>"Y",SOMETHING_ELSE=>"uh oh"};
$lim->copy_matching_f_summary_fields($f_sum);
is($lim->get("ETEST_NAME"), "my name", "Copied over a known field from an f_summary");
is($lim->get("DISPO"), "Y", "Copied over a known field from an f_summary");
dies_ok(sub{$lim->get("SOMETHING_ELSE")}, "Checking to see if a non-standard field was copied over from f_summary record");

# keys/values
my $lim1 = LimitRecord->new_empty();
my $lim2 = LimitRecord->new_empty();

my @keys = LimitRecord->get_ordered_keys();
ok(scalar @keys > 10, "Found at least 10 keys");
ok(in_list("TECHNOLOGY", \@keys), "Found TECHNOLOGY in keys");

$lim1->{"TECHNOLOGY"} = "TEST";
my @values = $lim1->get_ordered_values();
is(scalar @keys, scalar @values, "Same number of keys and values");
ok(in_list("TEST", \@values), "Found TECHNOLOGY in values");

for (my $i = 0; $i < scalar @keys; $i++){
    if ($keys[$i] eq 'TECHNOLOGY'){
        is($values[$i], "TEST", "Found technology key and value at same index");
    }
}

# new/populate from hash

my $hash = {
    TECHNOLOGY => "TESTHASH",
};

$lim = LimitRecord->new_from_hash($hash);
is($lim->{"TECHNOLOGY"}, "TESTHASH", "Created new LimitRecord from hash");

$hash = {
    MANEATER    => "here she comes",
};

dies_ok(sub{$lim = LimitRecord->new_from_hash($hash)}, "Creating LimitRecord from hash with unexpected field");

