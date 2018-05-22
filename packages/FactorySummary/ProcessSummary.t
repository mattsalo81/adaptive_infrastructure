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

# getting parmaeters from f_summary
my $parms = ProcessSummary::get_all_f_summary_parameters_for_technology("TEST_PARM_TECH");
is(scalar @{$parms}, 4, "Got all four parms");
my @parms = sort @{$parms};
is($parms[0], 'P1', "Correct Names");
is($parms[1], 'P2', "Correct Names");
is($parms[2], 'P3', "Correct Names");
is($parms[3], 'P4', "Correct Names");

