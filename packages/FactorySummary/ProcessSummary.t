use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use FactorySummary::ProcessSummary;
use Data::Dumper;

# data extraction
# check to see if we get records
my $records = ProcessSummary::get_f_summary_records_for_parameter('TEST_GOOD_TECH', 'EXISTS');
is( $records->[0]->{"ETEST_NAME"}, "EXISTS", "Found a record that we know exists");
ok(! defined $records->[1], "Didn't find anything unexpected");

# check to see
$records = ProcessSummary::get_f_summary_records_for_parameter('TEST_GOOD_TECH', 'DIFF_OPT');
ok(in_list($records->[0]->{"PROCESS_OPTIONS"}, ["OPTION1"]), "Found known process options on a known parameter");
ok(in_list($records->[1]->{"PROCESS_OPTIONS"}, ["OPTION2"]), "Found known process options on a known parameter");
ok($records->[0]->{"PROCESS_OPTIONS"} ne $records->[1]->{"PROCESS_OPTIONS"}, "Found 2 distinct process options on a known parmaeter");
ok(! defined $records->[2], "Didn't find anything unexpected");

# parameter level logic
# basic input/output testing
$records = [
          {
            'TECHNOLOGY' => 'TEST_GOOD_TECH',
            'PROCESS_OPTIONS' => 'OPTION1',
            'DEACTIVATE' => 'N',
            'DISPO_RULE' => 'OPAP',
            'ETEST_NAME' => 'DIFF_OPT',
          },
        ];
my $sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
];
my ($functional, $limits) = ProcessSummary::process_f_summary_parameter_records($records, $sms);
is(scalar @{$limits}, 1, "Found exactly one limit for test case 1");
is($limits->[0]->{"TEST_AREA"}, "PARAMETRIC", "Correctly set to test area");
is($limits->[0]->{"ETEST_NAME"}, 'DIFF_OPT', "Correctly set to etest name");
is($limits->[0]->{"ITEM_TYPE"}, "TECHNOLOGY", "Correctly set at technology level");
is($limits->[0]->{"ITEM"}, 'TEST_GOOD_TECH', "Correctly set to technology");

# multiple parameter records
$records = [
          {
            'TECHNOLOGY' => 'TEST_GOOD_TECH',
            'PROCESS_OPTIONS' => 'OPTION1',
            'DEACTIVATE' => 'N',
            'DISPO_RULE' => 'OPAP',
            'ETEST_NAME' => 'DIFF_OPT',
          },
          {
            'TECHNOLOGY' => 'TEST_GOOD_TECH',
            'PROCESS_OPTIONS' => 'OPTION2',
            'DEACTIVATE' => 'N',
            'DISPO_RULE' => 'OPAP',
            'ETEST_NAME' => 'DIFF_OPT',
          },
        ];
$sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
];
($functional, $limits) = ProcessSummary::process_f_summary_parameter_records($records, $sms);
is(scalar @{$limits}, 1, "Found exactly one limit for test case 2");
is($limits->[0]->{"TEST_AREA"}, "PARAMETRIC", "Correctly set to test area");
is($limits->[0]->{"ETEST_NAME"}, 'DIFF_OPT', "Correctly set to etest name");
is($limits->[0]->{"ITEM_TYPE"}, "TECHNOLOGY", "Correctly set at technology level");
is($limits->[0]->{"ITEM"}, 'TEST_GOOD_TECH', "Correctly set to technology");


# death tests for required fields
$sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING1 => "TEST1"},
];
dies_ok(sub{ProcessSummary::process_f_summary_parameter_records($records, $sms)}, "Dies when any sms record missing an AREA");
$sms = [
    {AREA1 => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
];
dies_ok(sub{ProcessSummary::process_f_summary_parameter_records($records, $sms)}, "Dies when any sms record missing an Effective routing");


