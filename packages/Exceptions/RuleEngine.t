use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Exceptions::ExceptionRules;
use Exceptions::RuleEngine;
use SMS::SMSSpec;
use SMS::FastTable;
use Database::Connect;
use Data::Dumper;

# generate test records
my @required_fields = qw(DEVICE TECHNOLOGY FAMILY COORDREF ROUTING EFFECTIVE_ROUTING LPT OPN COT CARD_FAMILY PROGRAM PROBER_FILE AREA RECIPE DEV_CLASS PROD_GRP);
my @record_format = qw(TECHNOLOGY DEVICE LPT OPN);
my @records = (
    [qw(TECH1 DEV1 9300 8820)],
    [qw(TECH2 DEV2 9300 8820)],
    [qw(TECH2 DEV3 9300 8820)],
    [qw(TECH1 DEV4 6152 8820)],
    [qw(TECH1 DEV4 6552 8820)],
    [qw(TECH1 DEV4 9455 8824)],
);
my @recs;
foreach my $rec (@records){
    my %rec;
    foreach my $req_field (@required_fields){
        $rec{$req_field} = "";
    }
    for(my $i = 0 ; $i < scalar @{$rec}; $i++){
        $rec{$record_format[$i]} = $rec->[$i];
    }
    push @recs, SMSSpec->new(\%rec);
}
my $ft = FastTable->new(\@recs);

# make rules
my $rule_useless = ExceptionRules->new_from_hash({});
my $rule_tech2 = ExceptionRules->new_from_hash({TECHNOLOGY=>"TECH2"});
my $rule_gt7000 = ExceptionRules->new_from_hash({TEST_LPT=>"/>7000/"});

my $found_recs;
my %found_id;

$found_recs = RuleEngine::get_matching_records_fasttable([], $ft);
is(scalar @{$found_recs}, 0, "Empty rule list");

print Dumper $ft;

$found_recs = RuleEngine::get_matching_records_fasttable([$rule_tech2], $ft);
%found_id = map {$_->unique_id() => $_} @{$found_recs};
is(scalar keys %found_id, 2, "Correct number or records to filter by tech2");
ok(defined($found_id{"DEV2 9300 8820"}), "Found correct record");
ok(defined($found_id{"DEV3 9300 8820"}), "Found correct record");

$found_recs = RuleEngine::get_matching_records_fasttable([$rule_tech2, $rule_tech2], $ft);
%found_id = map {$_->unique_id() => $_} @{$found_recs};
is(scalar keys %found_id, 2, "Correct number or records to filter by tech2 twice");
ok(defined($found_id{"DEV2 9300 8820"}), "Found correct record");
ok(defined($found_id{"DEV3 9300 8820"}), "Found correct record");

$found_recs = RuleEngine::get_matching_records_fasttable([$rule_tech2, $rule_gt7000], $ft);
%found_id = map {$_->unique_id() => $_} @{$found_recs};
is(scalar keys %found_id, 4, "Correct number or records to filter by tech2 or lpt>7000");
ok(defined($found_id{"DEV1 9300 8820"}), "Found correct record");
ok(defined($found_id{"DEV2 9300 8820"}), "Found correct record");
ok(defined($found_id{"DEV3 9300 8820"}), "Found correct record");
ok(defined($found_id{"DEV4 9455 8824"}), "Found correct record");


# everything test
dies_ok(sub{RuleEngine::get_matching_records_fasttable([$rule_useless], $ft)}, "Rule that applies to every device");


# database tests
my $trans = Connect::new_transaction("etest");
RuleEngine::clear_exception_table($trans);
ok(1, "Exception table cleared");
my $sth = RuleEngine::get_insert_exception_sth($trans);
ok(1, "Insert STH");
RuleEngine::insert_exception($sth, $recs[0], 10);
ok(1, "single exception inserted");
RuleEngine::insert_exceptions($sth, [@recs[1..4]], 11);
ok(1, "multiple exceptions inserted");
$trans->rollback();
ok(1, "Transaction rolled back");

