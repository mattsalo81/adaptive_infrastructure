use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use LimitDatabase::UpdateLimit;
use LimitDatabase::LimitRecord;
use Database::Connect;

my $trans = Connect::new_transaction("etest");
my $trans2 = Connect::new_transaction("etest");

my $limit = LimitRecord->new_from_hash({
    TECHNOLOGY  => "TEST_TECH",
    TEST_AREA   => "TEST_AREA",
    ITEM_TYPE   => "TECHNOLOGY",
    ITEM        => "TEST_TECH",
    ETEST_NAME  => "PARM5",
});
my $test_priorities = [0, 1];

my $priorities = UpdateLimit::get_priorities_used($trans, $limit);
ok(lists_identical($priorities, $test_priorities), "Found known test priorities in Limits Database");


is(UpdateLimit::get_new_priority([-1]), 0, "Got correct priority");
is(UpdateLimit::get_new_priority([0]), 1, "Got correct priority");
is(UpdateLimit::get_new_priority([0, 1]), 2, "Got correct priority");
is(UpdateLimit::get_new_priority([0, 1, 2, 3, 4, 5]), 6, "Got correct priority");
is(UpdateLimit::get_new_priority([0, 1, 3, 4, 6, 7, 9]), 2, "Got correct priority");
is(UpdateLimit::get_new_priority([]), 0, "Got correct priority");

$limit->set_priority(10);
UpdateLimit::insert_limit($trans2, $limit);
#  Need to figure out how to stop output from DBI
# dies_ok(sub{UpdateLimit::insert_limit($trans2, $limit)}, "inserting same record multiple times");


# insert a bunch of records
my $new_priorities = [0, 1, 2, 3, 4, 5, 6];
UpdateLimit::update_limit($trans, $limit);
UpdateLimit::update_limit($trans, $limit);
UpdateLimit::update_limit($trans, $limit);
UpdateLimit::update_limit($trans, $limit);
UpdateLimit::update_limit($trans, $limit);
ok(1, "Updating same record multiple times");
$priorities = UpdateLimit::get_priorities_used($trans, $limit);
ok(lists_identical($priorities, $new_priorities), "Found new, properly prioritized records in Limits Database");

my $priorities2 = UpdateLimit::get_priorities_used($trans2, $limit);
ok(!lists_identical($priorities, $priorities2), "Separate transactions do not have shared info");


$trans->rollback();
$trans2->rollback();


