use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use FactorySummary::ProcessSummary;
use Data::Dumper;
use Carp;

# used for decoupling process option checks from process option db
my $test_lambda = sub {
    my ($effective_routing, $record) = @_;
    my $options = $record->{"PROCESS_OPTIONS"};
    unless (defined $options){
        confess "Could not get process options";
    }
    if ($options eq "TRUE"){
        return 1;
    }elsif ($options eq "FALSE"){
        return 0;
    }else{
        confess "Unexpected option type $options";
    }
};

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
            'PROCESS_OPTIONS' => 'TRUE',
            'DISPO_RULE' => 'OPAP',
            'ETEST_NAME' => 'DIFF_OPT',
          },
        ];
my $sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
];
my ($functional, $limits) = ProcessSummary::_process_f_summary_parameter_records($records, $sms, $test_lambda);
is(scalar @{$limits}, 1, "Found exactly one limit for test case 1");
is($limits->[0]->{"TEST_AREA"}, "PARAMETRIC", "Correctly set to test area");
is($limits->[0]->{"ETEST_NAME"}, 'DIFF_OPT', "Correctly set to etest name");
is($limits->[0]->{"ITEM_TYPE"}, "TECHNOLOGY", "Correctly set at technology level");
is($limits->[0]->{"ITEM"}, 'TEST_GOOD_TECH', "Correctly set to technology");

# multiple parameter records
$records = [
          {
            'TECHNOLOGY' => 'TEST_GOOD_TECH',
            'PROCESS_OPTIONS' => 'TRUE',
            'DISPO_RULE' => 'OPAP',
            'ETEST_NAME' => 'DIFF_OPT',
          },
          {
            'TECHNOLOGY' => 'TEST_GOOD_TECH',
            'PROCESS_OPTIONS' => 'FALSE',
            'DISPO_RULE' => 'OPAP',
            'ETEST_NAME' => 'DIFF_OPT',
          },
        ];
$sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
];
($functional, $limits) = ProcessSummary::_process_f_summary_parameter_records($records, $sms, $test_lambda);
is(scalar @{$limits}, 2, "Found exactly 2 limits for test case 2");
is($limits->[0]->{"TEST_AREA"}, "PARAMETRIC", "Correctly set to test area");
is($limits->[0]->{"ETEST_NAME"}, 'DIFF_OPT', "Correctly set to etest name");
is($limits->[0]->{"ITEM_TYPE"}, "TECHNOLOGY", "Correctly set at technology level");
is($limits->[0]->{"ITEM"}, 'TEST_GOOD_TECH', "Correctly set to technology");
is($limits->[1]->{"TEST_AREA"}, "PARAMETRIC", "Correctly set to test area");
is($limits->[1]->{"ETEST_NAME"}, 'DIFF_OPT', "Correctly set to etest name");
is($limits->[1]->{"ITEM_TYPE"}, "EFFECTIVE_ROUTING", "Correctly set at effective routing level");
is($limits->[1]->{"ITEM"}, 'TEST1', "Correctly set to effective routing");

$sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST2"},
];
($functional, $limits) = ProcessSummary::_process_f_summary_parameter_records($records, $sms, $test_lambda);
is(scalar @{$limits}, 3, "Found exactly 3 limits for test case 3 - multiple effective routings");

$sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
    {AREA => "METAL2", EFFECTIVE_ROUTING => "TEST1"},
];
($functional, $limits) = ProcessSummary::_process_f_summary_parameter_records($records, $sms, $test_lambda);
is(scalar @{$limits}, 4, "Found exactly 4 limits for test case 4 - multiple test areas (2 tech and 2 eff rout)");
my @temp = sort map {$_->get('TEST_AREA')} @{$limits};
is($temp[0], 'METAL2', 'Found one METAL2 record');
is($temp[1], 'METAL2', 'Found two METAL2 record');
is($temp[2], 'PARAMETRIC', 'Found one PARAMETRIC record');
is($temp[3], 'PARAMETRIC', 'Found two PARAMETRIC record');
@temp = sort map {$_->get('ITEM')} @{$limits};
is($temp[0], 'TEST1', 'Found one effective routing record');
is($temp[1], 'TEST1', 'Found two effective routing record');
is($temp[2], 'TEST_GOOD_TECH', 'Found one TECH record');
is($temp[3], 'TEST_GOOD_TECH', 'Found two TECH record');
@temp = sort map {$_->get('ITEM_TYPE')} @{$limits};
is($temp[0], 'EFFECTIVE_ROUTING', 'Found one EFFECTIVE_ROUTING record');
is($temp[1], 'EFFECTIVE_ROUTING', 'Found two EFFECTIVE_ROUTING record');
is($temp[2], 'TECHNOLOGY', 'Found one TECHNOLOGY record');
is($temp[3], 'TECHNOLOGY', 'Found two TECHNOLOGY record');




# death tests for required fields
$sms = [
    {AREA => "PARAMETRIC", EFFECTIVE_ROUTING1 => "TEST1"},
];
dies_ok(sub{ProcessSummary::_process_f_summary_parameter_records($records, $sms, $test_lambda)}, "Dies when any sms record missing an Effective routing");
$sms = [
    {AREA1 => "PARAMETRIC", EFFECTIVE_ROUTING => "TEST1"},
];
dies_ok(sub{ProcessSummary::_process_f_summary_parameter_records($records, $sms, $test_lambda)}, "Dies when any sms record missing an AREA");


