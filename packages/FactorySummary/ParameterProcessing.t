use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use FactorySummary::ParameterProcessing;
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


# parameter level logic
# basic input/output testing
my $records = [
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
my ($functional, $limits) = ParameterProcessing::_process_f_summary_parameter_records($records, $sms, $test_lambda);
is(scalar @{$limits}, 1, "Found exactly one limit for test case 1");
is($limits->[0]->{"TEST_AREA"}, "PARAMETRIC", "Correctly set to test area");
is($limits->[0]->{"ETEST_NAME"}, 'DIFF_OPT', "Correctly set to etest name");
is($limits->[0]->{"ITEM_TYPE"}, "TECHNOLOGY", "Correctly set at technology level");
is($limits->[0]->{"ITEM"}, 'TEST_GOOD_TECH', "Correctly set to technology");
is(scalar @{$functional}, 1, "Found exactly one functional parameter entry");
is(scalar keys %{$functional->[0]}, 4, "Found four fields in the functional parameter");
is($functional->[0]->{"TECHNOLOGY"}, 'TEST_GOOD_TECH', "Technology in functional parameter");
is($functional->[0]->{"EFFECTIVE_ROUTING"}, 'TEST1', "EFFECTIVE ROUTING in functional parameter");
is($functional->[0]->{"ETEST_NAME"}, 'DIFF_OPT', "ETEST name in functional parameter");
is($functional->[0]->{"TEST_AREA"}, 'PARAMETRIC', "ETEST name in functional parameter");

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
($functional, $limits) = ParameterProcessing::_process_f_summary_parameter_records($records, $sms, $test_lambda);
is(scalar @{$limits}, 2, "Found exactly 2 limits for test case 2");
is($limits->[0]->{"TEST_AREA"}, "PARAMETRIC", "Correctly set to test area");
is($limits->[0]->{"ETEST_NAME"}, 'DIFF_OPT', "Correctly set to etest name");
is($limits->[0]->{"ITEM_TYPE"}, "TECHNOLOGY", "Correctly set at technology level");
is($limits->[0]->{"ITEM"}, 'TEST_GOOD_TECH', "Correctly set to technology");
