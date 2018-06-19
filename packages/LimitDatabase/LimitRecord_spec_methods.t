use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use LimitDatabase::LimitRecord;
use Data::Dumper;

my $limit;

# sampling rate conversion
$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"5 SITE"});
is($limit->how_many_sites_to_test(), 5, "5 SITE sampling");
$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"9 SITE"});
is($limit->how_many_sites_to_test(), 9, "9 SITE sampling");
$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"NEIN SIGHTS"});
dies_ok(sub{$limit->how_many_sites_to_test()}, "Unkown sampling rate");

# spec number
$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"5 SITE",PASS_CRITERIA_PERCENT=>.75});
is($limit->get_num_fails(), 2, "2 sites fail for pass rate of 75% on 5 sites");

$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"9 SITE",PASS_CRITERIA_PERCENT=>.75});
is($limit->get_num_fails(), 3, "3 sites fail for pass rate of 75% on 9 sites");

$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"5 SITE",PASS_CRITERIA_PERCENT=>.80});
is($limit->get_num_fails(), 1, "1 sites fail for pass rate of 80% on 5 sites");

$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"9 SITE",PASS_CRITERIA_PERCENT=>.80});
is($limit->get_num_fails(), 2, "2 sites fail for pass rate of 80% on 9 sites");

# weirder spec numbers

$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"9 SITE",PASS_CRITERIA_PERCENT=>.801});
is($limit->get_num_fails(), 2, "1 sites fail for pass rate of 80.1% on 9 sites");

$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"5 SITE",PASS_CRITERIA_PERCENT=>.1});
is($limit->get_num_fails(), 5, "5 sites fail for pass rate of 10% on 5 sites");

$limit = LimitRecord->new_from_hash({SAMPLING_RATE=>"5 SITE",PASS_CRITERIA_PERCENT=>.99});
is($limit->get_num_fails(), 1, "1 sites fail for pass rate of 99% on 5 sites");

# spec generation
$limit = LimitRecord->new_from_hash({
    ETEST_NAME                  => "TEST_PARM",
    SAMPLING_RATE               => "5 SITE",
    PASS_CRITERIA_PERCENT       => .75,
    DISPO                       => 'N',
    SPEC_LOWER                  => -10,
    SPEC_UPPER                  => 10,
    REVERSE_SPEC_LIMIT          => 'N',
    RELIABILITY                 => 'N',
    RELIABILITY_LOWER           => -1,
    RELIABILITY_UPPER           => 1,
    REVERSE_RELIABILITY_LIMIT   => 'N',
    DEACTIVATE                  => 'N',
});

my $scrap = $limit->get_scrap_entry();
is($scrap, undef, "has scrap limits but not set to dispo");
my $rel = $limit->get_reliability_entry();
is($rel, undef, "Has reliability limits but not set to reliabiliy");

# set to scrap
$limit->{"DISPO"} = 'Y';
$scrap = $limit->get_scrap_entry();
ok(lists_identical($scrap, ['TEST_PARM', 2, -10, 10, 1, 6]), "Got a standard scrap limit");
$rel = $limit->get_reliability_entry();
is($rel, undef, "Has reliability limits but not set to reliabiliy");

# set to rel
$limit->{"RELIABILITY"} = 'Y';
$scrap = $limit->get_scrap_entry();
ok(lists_identical($scrap, ['TEST_PARM', 2, -10, 10, 1, 6]), "Got a standard scrap limit");
$rel = $limit->get_reliability_entry();
ok(lists_identical($rel, ['TEST_PARM', 1, -1, 1, 1, 2]), "Got a standard reliability limit");

# Modify things
$limit->{"SAMPLING_RATE"} = '9 SITE';
$limit->{"SPEC_LOWER"} = -20;
$limit->{"REVERSE_SPEC_LIMIT"} = 'Y';
$limit->{"REVERSE_RELIABILITY_LIMIT"} = 'Y';
$scrap = $limit->get_scrap_entry();
ok(lists_identical($scrap, ['TEST_PARM', 3, -20, 10, 0, 6]), "Got a standard scrap limit");
$rel = $limit->get_reliability_entry();
ok(lists_identical($rel, ['TEST_PARM', 1, -1, 1, 0, 2]), "Got a standard reliability limit");

# deactivate
$limit->{"DEACTIVATE"} = 'Y';

$scrap = $limit->get_scrap_entry();
is($scrap, undef, "Is a scrap but is deactivated");
$rel = $limit->get_reliability_entry();
is($rel, undef, "Is a reliability but is deactivated");

# comments
my $comment;
$limit = LimitRecord->new_from_hash({ITEM_TYPE=>"TECHNOLOGY",LIMIT_COMMENTS=>"WHATEVER"});
$comment = $limit->get_comment();
is($comment, 'WHATEVER', "Comment");

$limit->{"LIMIT_COMMENTS"} = undef;
$comment = $limit->get_comment();
is($comment, undef, "Comment undef");

# component checking
my $comp_hash = {COMP1=>"yep", COMP2=>"yep"};

$limit = LimitRecord->new_from_hash({COMPONENT=>undef});
ok($limit->required_by_component_hash($comp_hash), "undefined component is required");

$limit = LimitRecord->new_from_hash({COMPONENT=>""});
ok($limit->required_by_component_hash($comp_hash), "empty component is required");

$limit = LimitRecord->new_from_hash({COMPONENT=>"   \t"});
ok($limit->required_by_component_hash($comp_hash), "whitespace component is required");

$limit = LimitRecord->new_from_hash({COMPONENT=>"COMP3"});
ok(!$limit->required_by_component_hash($comp_hash), "component not in hash is not required");

$limit = LimitRecord->new_from_hash({COMPONENT=>"COMP1"});
ok($limit->required_by_component_hash($comp_hash), "component in hash is required");

# component filtering
my @comps = qw(COMP1 COMP2 COMP3);
my @unfiltered_limits = (
    LimitRecord->new_from_hash({COMPONENT=>undef}),
    LimitRecord->new_from_hash({COMPONENT=>""}),
    LimitRecord->new_from_hash({COMPONENT=>"   "}),
    LimitRecord->new_from_hash({COMPONENT=>"COMP4"}),
    LimitRecord->new_from_hash({COMPONENT=>"COMP5"}),
    LimitRecord->new_from_hash({COMPONENT=>"COMP5"}),
    LimitRecord->new_from_hash({COMPONENT=>"COMP1"}),
    LimitRecord->new_from_hash({COMPONENT=>"COMP2"}),
);
my @expected_limits = (@unfiltered_limits[0..2], @unfiltered_limits[6..7]);
my @filtered_limits = @unfiltered_limits;
my $num_removed = LimitRecord->filter_limit_table_by_component(\@filtered_limits, \@comps);
is($num_removed, 3, "Correct number of components removed");
ok(lists_identical(\@filtered_limits, \@expected_limits), "Correct limits filtered out");



