use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Exceptions::ExceptionRules;
use Data::Dumper;
use SMS::FastTable;
use Logging;
use SMS::SMSSpec;

# we expect errors when using the exception system
*TMP_STDERR = *STDERR;
*STDERR = *STDOUT;

my $known_9300_8820_rout = "A100C3L+";
my $known_9455_8820_rout = "A100C3MP";
my $known_6152_8827_9300_8820_rout = "A140+3BA";

# Logging::set_level("DIAG");

my $rule = ExceptionRules->new_from_hash({});
my @keys = keys %{$rule};
ok(scalar @keys > 5, "at least 5 rules defined in rule from empty hash");
ok(defined $rule->{"DEVICE"}, "At least one rule is for DEVICE");

# test all lambda generator functions are functional
foreach my $field (keys %ExceptionRules::field_filter_actions){
    my ($type, $lambda_gen) = @{$ExceptionRules::field_filter_actions{$field}};
    ok($type eq "INDEX" || $type eq "RECORD", "$field lambda_gen type INDEX or RECORD");
    is(ref($lambda_gen), "CODE", "$field reference type is a code ref");
    if (ref($lambda_gen) eq "CODE"){
        my $lambda = $rule->$lambda_gen();
        is(ref($lambda), "CODE", "$field reference type generates a code ref when run on a rule"); 
        if ($type eq "INDEX"){
            my $index = $ExceptionRules::index_translator{$field};
            ok(defined $index, "Entry for $field in index translator");
        }
    }
}

# set up test records
my @test_format = qw(TECHNOLOGY FAMILY DEV_CLASS ROUTING COORDREF PROGRAM LPT DEVICE PROD_GRP EFFECTIVE_ROUTING OPN COT);
my @test_records = (
    ['WAV_TEST', 'TFAM1', 'TCLASS1', "$known_9300_8820_rout", 'TCOORD1', 'TEST_PROG0', 9300, 'TEST_DEV_0', 'TPGRP0', 'TDBROUT1', '8820', 'N'],
    ['WAV_TEST', 'TFAM2', 'TCLASS1', "$known_9300_8820_rout", 'TCOORD1', 'TEST_PROG1', 9300, 'TEST_DEV_1', 'TPGRP1', 'TDBROUT1', '8820', 'N'],
    ['WAV_TEST', 'TFAM1', 'TCLASS2', "$known_9300_8820_rout", 'TCOORD1', 'TEST_PROG2', 9300, 'TEST_DEV_2', 'TPGRP1', 'TDBROUT1', '8820', 'N'],
    ['WAV_TEST', 'TFAM1', 'TCLASS1', "$known_9455_8820_rout", 'TCOORD1', 'TEST_PROG3', 9300, 'TEST_DEV_3', 'TPGRP1', 'TDBROUT1', '8820', 'N'],
    ['WAV_TEST', 'TFAM1', 'TCLASS1', "$known_9300_8820_rout", 'TCOORD2', 'TEST_PROG4', 9300, 'TEST_DEV_4', 'TPGRP1', 'TDBROUT1', '8820', 'N'],
    ['WAV_TEST', 'TFAM1', 'TCLASS1', "$known_9300_8820_rout", 'TCOORD1', 'TEST_PROG5', 9455, 'TEST_DEV_5', 'TPGRP1', 'TDBROUT1', '8820', 'N'],
    ['WAV_TEST', 'TFAM1', 'TCLASS1', "$known_9300_8820_rout", 'TCOORD1', 'TEST_PROG6', 9300, 'TEST_DEV_6', 'TPGRP2', 'TDBROUT1', '8820', 'N'],
    ['WAV_TEST', 'TFAM1', 'TCLASS1', "$known_9300_8820_rout", 'TCOORD1', 'TEST_PROG7', 9300, 'TEST_DEV_7', 'TPGRP1', 'TDBROUT2', '8820', 'N'],
    ['WAV_TEST', 'TFAM2', 'TCLASS2', "$known_9455_8820_rout", 'TCOORD2', 'TEST_PROG7', 9455, 'TEST_DEV_8', 'TPGRP2', 'TDBROUT2', '8820', 'N'],
    ['WAV_TEST', 'TFAM3', 'TCLASS3', "$known_6152_8827_9300_8820_rout", 'TCOORD3', 'TEST_PROG8', 0000, 'TEST_DEV_9', 'TPGRP3', 'TDBROUT3', '8823', 'N'],
    ['WAV_TEST', 'TFAM3', 'TCLASS3', "$known_6152_8827_9300_8820_rout", 'TCOORD4', 'TEST_PROG8', 0000, 'TEST_DEV_10','TPGRP3', 'TDBROUT3', '8820', 'N'],
    ['WAV_TEST', 'TFAM1', 'TCLASS1', "$known_9300_8820_rout", 'TCOORD5', 'TEST_PROG7', 9300, 'TEST_DEV_11','TPGRP1', 'TDBROUT2', '8823', 'Y'],
);

my @formatted_records;

foreach my $record (@test_records){
    my $rec = {};
    for (my $i = 0; $i < scalar @test_format; $i++){
        $rec->{$test_format[$i]} = $record->[$i];
    }
    push @formatted_records, SMSSpec->new($rec);
}
        
# set up test cases
my @rule_format = qw(FAMILY DEV_CLASS ROUTING COORDREF PROGRAM TEST_LPT DEVICE PROD_GRP EFFECTIVE_ROUTING PROCESS_OPTION LPT TECHNOLOGY FUNCTIONALITY COT);
my @regex_tests_unorganized = (
['TFAM1',  'TCLASS1',  "$known_9300_8820_rout",  'TCOORD1',        'TEST_PROG0',  9300,  'TEST_DEV_0',  'TPGRP0',  'TDBROUT1',  '',            '',            '',          '', ''],
['TFAM2',  'TCLASS2',  "$known_9455_8820_rout",  'TCOORD2',        'TEST_PROG7',  9455,  'TEST_DEV_8',  'TPGRP2',  'TDBROUT2',  '',            '',            '',          '', ''],
['TFAM2',  '',         '',             '',               '',            '',    '',            '',        '',          '',            '',            '',          '', ''],
['',       'TCLASS2',  '',             '',               '',            '',    '',            '',        '',          '',            '',            '',          '', ''],
['',       '',         "$known_9455_8820_rout",  '',               '',            '',    '',            '',        '',          '',            '',            '',          '', ''],
['',       '',         '',             'TCOORD2',        '',            '',    '',            '',        '',          '',            '',            '',          '', ''],
['',       '',         '',             '',               'TEST_PROG7',  '',    '',            '',        '',          '',            '',            '',          '', ''],
['',       '',         '',             '',               '',            9455,  '',            '',        '',          '',            '',            '',          '', ''],
['',       '',         '',             '',               '',            '',    '/.*[246]/',   '',        '',          '',            '',            '',          '', ''],
['',       '',         '',             '',               '',            '',    '',            'TPGRP2',  '',          '',            '',            '',          '', ''],
['',       '',         '',             '',               '',            '',    '',            '',        'TDBROUT2',  '',            '',            '',          '', ''],
['',       '',         '',             '',               '',            '',    '',            '',        '',          '',            '',            '',          '', 'Y'],
# process options and logpoint tests
['',       '',         '',             '',               '',            '',    '',            '',        '',          'opt1.!OPT2',  '',            '',          '', ''],
['',       '',         '',             '',               '',            '',    '',            '',        '',          '',            '9300',        '',          '', ''],
['',       '',         '',             '',               '',            '',    '',            '',        '',          '',            '!9455',       '',          '', ''],
['',       '',         '',             '',               '',            '',    '',            '',        '',          '',            '9300 -> 6152',  '',          '', ''],
# basic functionality db tests here
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'SIMPLE_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'SIMPLE_RESOLVE:!SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'SIMPLE_RESOLVE:SF.SIMPLE_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'SIMPLE_RESOLVE:SF.SIMPLE_RESOLVE:!SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'MULTI_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'MISSING_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'MISSING_RESOLVE:NF', ''],
# moderate functionality db
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PRECEDENCE_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PRECEDENCE_RESOLVE:TOP:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PRECEDENCE_RESOLVE:ANY:NF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PRECEDENCE_RESOLVE:ANY:!NF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PRECEDENCE_RESOLVE:ANY:NSF1', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PRIORITY_RESOLVE:NSF2', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PRIORITY_RESOLVE:NSF1', ''],
# advanced functionality db
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PROCESS_OPTION_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'PROCESS_OPTION_RESOLVE:NF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'LOGPOINT_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'LOGPOINT_RESOLVE:NF', ''],
# fringe cases in functionaly db
['',       '',         '',             '/TCOORD4/',      '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'SIMPLE_RESOLVE:!SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'TYP0_TEST:NF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'TYP0_TEST:!NF', ''],
['',       '',         '',             '/TCOORD[123]/',  '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'UNDEFINED_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[123]/',  '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'UNDEFINED_RESOLVE:!SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'INCOMPLETE_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'INCOMPLETE_RESOLVE:!SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'CONFLICT_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'CONFLICT_RESOLVE:!SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'GAP_RESOLVE:SF', ''],
['',       '',         '',             '/TCOORD[12]/',   '',            '',    '',            '',        '',          '',            '',            'WAV_TEST',  'GAP_RESOLVE:!SF', ''],
);
my @rule_hashes;
foreach my $rule_array (@regex_tests_unorganized){
    my $rule = {};
    for(my $i =0; $i < scalar @rule_format; $i++){
        my $key = $rule_format[$i];
        my $val = $rule_array->[$i];
        $rule->{$key} = $val;
    }
    push @rule_hashes, $rule;
};
my @correct_devices = (
    ['TEST_DEV_0'],
    ['TEST_DEV_8'],
    ['TEST_DEV_1','TEST_DEV_8'],
    ['TEST_DEV_2','TEST_DEV_8'],
    ['TEST_DEV_3','TEST_DEV_8'],
    ['TEST_DEV_4','TEST_DEV_8'],
    ['TEST_DEV_7','TEST_DEV_8', 'TEST_DEV_11'],
    ['TEST_DEV_5','TEST_DEV_8'],
    ['TEST_DEV_2','TEST_DEV_4','TEST_DEV_6'],
    ['TEST_DEV_6','TEST_DEV_8'],
    ['TEST_DEV_7','TEST_DEV_8', 'TEST_DEV_11'],
    ['TEST_DEV_11'],
    # process options and logpoint solutions
    ['TEST_DEV_7','TEST_DEV_8', 'TEST_DEV_11'],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_4','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7','TEST_DEV_9','TEST_DEV_10','TEST_DEV_11'],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_4','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7','TEST_DEV_9','TEST_DEV_10','TEST_DEV_11'],
    ['TEST_DEV_10','TEST_DEV_3','TEST_DEV_8','TEST_DEV_9'],
    # basic functionality db solutions
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7'],
    ['TEST_DEV_4','TEST_DEV_8'],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7'],
    [],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_4','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7','TEST_DEV_8'],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7'],
    ['TEST_DEV_4','TEST_DEV_8'],
    # moderate functionality db solutions
    ['TEST_DEV_4','TEST_DEV_8'],
    ['TEST_DEV_4','TEST_DEV_8'],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_4','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7','TEST_DEV_8'],
    ['TEST_DEV_4','TEST_DEV_8'],
    ['TEST_DEV_4','TEST_DEV_8'],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7'],
    ['TEST_DEV_4','TEST_DEV_8'],
    # advanced functionality db solutions
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_5','TEST_DEV_6','TEST_DEV_8'],
    ['TEST_DEV_4','TEST_DEV_7'],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7','TEST_DEV_8'],
    ['TEST_DEV_3','TEST_DEV_4'],
    # fringe cases in functionality db solutions
    [],
    [],
    [],
    ['TEST_DEV_0','TEST_DEV_1','TEST_DEV_2','TEST_DEV_3','TEST_DEV_4','TEST_DEV_5','TEST_DEV_6','TEST_DEV_7','TEST_DEV_8'],
    [],
    [],
    [],
    [],
    ['TEST_DEV_4','TEST_DEV_8'],
    [],
    ['TEST_DEV_4','TEST_DEV_8'],
);


is(scalar @rule_hashes, @correct_devices, "Same number of tests and solutions");

for(my $i = 0; $i < scalar @rule_hashes; $i++){
    my $t = FastTable->new(\@formatted_records);
    my $rule_hash = $rule_hashes[$i];
    my $rule = ExceptionRules->new_from_hash($rule_hash);
    Logging::debug(Dumper $rule);
    Logging::debug(Dumper $t);
    $rule->filter_fasttable($t);
    Logging::diag(Dumper $t);
    my @got_devices = map {$_->{"DEVICE"}} @{$t->get_all_records()};
    ok(have_same_elements(\@got_devices, $correct_devices[$i]), "Rule Filter Test $i")
        or diag("matched <'" . join("','", sort @got_devices) . "'> when should have matched <'" . join("','", sort @{$correct_devices[$i]}) . "'>\n");


}





*STDERR = *TMP_STDERR;
