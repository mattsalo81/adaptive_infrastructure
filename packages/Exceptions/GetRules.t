use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Data::Dumper;
use Exceptions::GetRules;

my $known_exception = 0;
my $known_inactive  = 1;
my $known_rule_on_known_exception = 0;
my $known_inactive_rule_on_known_exception = 1;
my $rule_test_exception = 1;
my $exp_test_invalid = 2;
my $exp_test_valid = 3;
my $pcd_test_invalid = 0;
my $pcd_test_valid = 1;

my $exceptions = Exceptions::GetRules::get_all_active_exceptions();
ok(in_list($known_exception, $exceptions), "Retreives known exception");
ok(!in_list($known_inactive, $exceptions), "Doesn't Retreive known Inactive exception");
my $rules = Exceptions::GetRules::get_rules_for_exception($known_exception);
my @rule_num = map {$_->{"RULE_NUMBER"}} @{$rules};
ok(in_list($known_rule_on_known_exception, \@rule_num), "Known rule on known exception");
ok(!in_list($known_inactive_rule_on_known_exception, \@rule_num), "Known Inactive rule on known exception");

# test PCD revision and expiration date
$rules = Exceptions::GetRules::get_rules_for_exception($rule_test_exception);
@rule_num = map {$_->{"RULE_NUMBER"}} @{$rules};
ok(!in_list($exp_test_invalid, \@rule_num), "Found known invalid exp based rule");
ok( in_list($exp_test_valid  , \@rule_num), "Found known   valid exp based rule");
ok(!in_list($pcd_test_invalid, \@rule_num), "Found known invalid pcd based rule");
ok( in_list($pcd_test_valid  , \@rule_num), "Found known   valid pcd based rule");
