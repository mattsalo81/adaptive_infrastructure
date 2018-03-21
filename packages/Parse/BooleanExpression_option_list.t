use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use Parse::BooleanExpression;


my $list = [];
my $exp;

$list = ['OPT1','OPT2'];
$exp = "OPT1";
ok(BooleanExpression::does_opt_list_match_opt_string($list, $exp), "Successfully determines if \"$exp\" matches \"" . join(", ", @{$list}) . "\"");

$list = ['OPT1','OPT2'];
$exp = "OPT2";
ok(BooleanExpression::does_opt_list_match_opt_string($list, $exp), "Successfully determines if \"$exp\" matches \"" . join(", ", @{$list}) . "\"");

$list = ['OPT1','OPT2'];
$exp = "OPT3";
ok(!BooleanExpression::does_opt_list_match_opt_string($list, $exp), "Successfully determines if \"$exp\" matches \"" . join(", ", @{$list}) . "\"");

$list = ['OPT1','OPT2'];
$exp = "OPT1 && OPT2";
ok(BooleanExpression::does_opt_list_match_opt_string($list, $exp), "Successfully determines if \"$exp\" matches \"" . join(", ", @{$list}) . "\"");

$list = ['OPT1','OPT2'];
$exp = "OPT1 ^ OPT2";
ok(!BooleanExpression::does_opt_list_match_opt_string($list, $exp), "Successfully determines if \"$exp\" matches \"" . join(", ", @{$list}) . "\"");

$list = [];
$exp = "something";
ok(!BooleanExpression::does_opt_list_match_opt_string($list, $exp), "Successfully determines if \"$exp\" matches \"" . join(", ", @{$list}) . "\"");

$list = ['OPT1','OPT2'];
$exp = "1234";
dies_ok(sub{BooleanExpression::does_opt_list_match_opt_string($list, $exp)}, "cannot parse logpoints because logpoint not provided");

# case insensitivity
$list = ['OPT1','opt2'];
$exp = "opt1 && OPT2";
ok(BooleanExpression::does_opt_list_match_opt_string($list, $exp), "Successfully determines if \"$exp\" matches \"" . join(", ", @{$list}) . "\"");
