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

# keys/values
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


# limit priorities

my $tech_limit = LimitRecord->new_from_hash({TECHNOLOGY=>"T",TEST_AREA=>"A",ITEM_TYPE=>"TECHNOLOGY", ETEST_NAME=>"TEST1"});
my $rout_limit = LimitRecord->new_from_hash({ITEM_TYPE=>"ROUTING", ETEST_NAME=>"TEST2"});
my $prog_limit = LimitRecord->new_from_hash({ITEM_TYPE=>"PROGRAM", ETEST_NAME=>"TEST2"});
my $dev_limit = LimitRecord->new_from_hash({ITEM_TYPE=>"DEVICE", ETEST_NAME=>"TEST1"});
my $bad_limit = LimitRecord->new_from_hash({ITEM_TYPE=>"SLDKFJSDF"});

is($dev_limit, LimitRecord->choose_highest_priority($dev_limit, $tech_limit), "Resolving TECH/DEV limits");
is($dev_limit, LimitRecord->choose_highest_priority($tech_limit, $dev_limit), "Resolving TECH/DEV limits");
is($prog_limit, LimitRecord->choose_highest_priority($prog_limit, $tech_limit), "Resolving TECH/PROG limits");
is($prog_limit, LimitRecord->choose_highest_priority($prog_limit, $rout_limit), "Resolving TECH/ROUT limits");
dies_ok(sub{LimitRecord->choose_highest_priority($prog_limit, $prog_limit)}, "Two limits at same item level");
dies_ok(sub{LimitRecord->choose_highest_priority($bad_limit, $prog_limit)}, "limit with unexpected item_type");

# resolving a table
my $resolved = LimitRecord->resolve_limit_table([$tech_limit, $dev_limit]);
ok(lists_identical($resolved, [$dev_limit]), "Correctly resolved tech and device limit");
$resolved = LimitRecord->resolve_limit_table([$rout_limit, $prog_limit]);
ok(lists_identical($resolved, [$prog_limit]), "Correctly resolved routing and program limit");  
$resolved = LimitRecord->resolve_limit_table([$tech_limit, $rout_limit, $prog_limit, $dev_limit]);
ok(lists_identical($resolved, [$dev_limit, $prog_limit]), "Correctly resolved four limits on two parameters, in the order that the parameters originally appeared");  
dies_ok(sub{LimitRecord->resolve_limit_table([$tech_limit, $rout_limit, $prog_limit, $dev_limit, $dev_limit]);}, "Multiple limits on the same item_type level on a parameter");

my $conflict_limit = {
    TECHNOLOGY  => "TEST_TECH",
    TEST_AREA   => "PARAMETRIC",
    ITEM_TYPE   => "TECHNOLOGY",
    ITEM        => "TECHNOLOGY",
    ETEST_NAME  => "TEST_PARM",
};

my $eol_limit = LimitRecord->new_from_hash($conflict_limit);
$conflict_limit->{"TEST_AREA"} = "METAL2";
my $m2_limit = LimitRecord->new_from_hash($conflict_limit);
$resolved = LimitRecord->resolve_limit_table([$m2_limit, $eol_limit]);
ok(lists_identical($resolved, [$m2_limit, $eol_limit]), "Successfully resolved the m2 and eol limits separately");


