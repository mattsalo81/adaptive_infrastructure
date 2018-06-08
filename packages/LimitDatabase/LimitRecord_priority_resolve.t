use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use LimitDatabase::LimitRecord;
use Data::Dumper;

my $lim = LimitRecord->new_empty();

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

# limit priorities

my $tech_limit = LimitRecord->new_from_hash({TECHNOLOGY=>"T",TEST_AREA=>"A",ITEM_TYPE=>"TECHNOLOGY", ETEST_NAME=>"TEST1"});
my $rout_limit = LimitRecord->new_from_hash({TECHNOLOGY=>"T",TEST_AREA=>"A",ITEM_TYPE=>"ROUTING", ETEST_NAME=>"TEST2"});
my $prog_limit = LimitRecord->new_from_hash({TECHNOLOGY=>"T",TEST_AREA=>"A",ITEM_TYPE=>"PROGRAM", ETEST_NAME=>"TEST2"});
my $dev_limit = LimitRecord->new_from_hash({TECHNOLOGY=>"T",TEST_AREA=>"A",ITEM_TYPE=>"DEVICE", ETEST_NAME=>"TEST1"});
my $bad_limit = LimitRecord->new_from_hash({TECHNOLOGY=>"T",TEST_AREA=>"A",ITEM_TYPE=>"SLDKFJSDF"});

is($dev_limit, LimitRecord->choose_highest_priority($dev_limit, $tech_limit), "Resolving TECH/DEV limits");
is($dev_limit, LimitRecord->choose_highest_priority($tech_limit, $dev_limit), "Resolving TECH/DEV limits");
is($prog_limit, LimitRecord->choose_highest_priority($prog_limit, $tech_limit), "Resolving TECH/PROG limits");
is($prog_limit, LimitRecord->choose_highest_priority($prog_limit, $rout_limit), "Resolving TECH/ROUT limits");
dies_ok(sub{LimitRecord->choose_highest_priority($prog_limit, $prog_limit)}, "Two limits at same item level");
dies_ok(sub{LimitRecord->choose_highest_priority($bad_limit, $prog_limit)}, "limit with unexpected item_type");

# resolving a table
my $resolved = LimitRecord->resolve_limit_table([$tech_limit, $dev_limit]);
ok(lists_identical($resolved, [$dev_limit]), "Correctly resolved tech and device limit");
is($dev_limit->get_predecessor(), $tech_limit, "Tech limit set as dev limit's predecessor");
$resolved = LimitRecord->resolve_limit_table([$rout_limit, $prog_limit]);
ok(lists_identical($resolved, [$prog_limit]), "Correctly resolved routing and program limit");  
is($prog_limit->get_predecessor(), $rout_limit, "ROUT limit set as prog limit's predecessor");
$resolved = LimitRecord->resolve_limit_table([$tech_limit, $rout_limit, $prog_limit, $dev_limit]);
ok(lists_identical($resolved, [$dev_limit, $prog_limit]), "Correctly resolved four limits on two parameters, in the order that the parameters originally appeared");  
is($dev_limit->get_predecessor(), $tech_limit, "Tech limit set as dev limit's predecessor");
is($prog_limit->get_predecessor(), $rout_limit, "ROUT limit set as prog limit's predecessor");
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

$conflict_limit->{"TECHNOLOGY"} = "OTHER_TECH";
my $m2_other_tech_limit = LimitRecord->new_from_hash($conflict_limit);
$resolved = LimitRecord->resolve_limit_table([$m2_limit, $m2_other_tech_limit]);
ok(lists_identical($resolved, [$m2_limit, $m2_other_tech_limit]), "Successfully resolved two limits on different technologies separately");

