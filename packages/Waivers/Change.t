use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Data::Dumper;
use Waivers::Change;
use LimitDatabase::LimitRecord;

# LSL tests
#    action  thing parm, value, change?  extract  exp_val
# all tests operate on same limit, so changes propogate to next test case
my @tests =(
    # LIMIT level tests
    # Enable/disable limits
    ['USE',   'SPEC',    undef,  1,   "DISPO",       "Y"],
    ['USE',   'SPEC',    undef,  0,   "DISPO",       "Y"],
    ['NO_USE','SPEC',    undef,  1,   "DISPO",       "N"],
    ['NO_USE','SPEC',    undef,  0,   "DISPO",       "N"],
    ['USE',   'REL',     undef,  1,   "RELIABILITY", "Y"],
    ['USE',   'REL',     undef,  0,   "RELIABILITY", "Y"],
    ['NO_USE','REL',     undef,  1,   "RELIABILITY", "N"],
    ['NO_USE','REL',     undef,  0,   "RELIABILITY", "N"],
    # SPEC LIMIT TESTS
    ['SET',     'LSL',           -10,    1,      "SPEC_LOWER",   -10], 
    ['SET',     'LSL',           -10,    0,      "SPEC_LOWER",   -10], 
    ['RELAX',   'LSL',           -20,    1,      "SPEC_LOWER",   -20], 
    ['RELAX',   'LSL',           -20,    0,      "SPEC_LOWER",   -20], 
    ['RELAX',   'LSL',           -15,    0,      "SPEC_LOWER",   -20], 
    ['TIGHTEN', 'LSL',           -30,    0,      "SPEC_LOWER",   -20], 
    ['TIGHTEN', 'LSL',           0,      1,      "SPEC_LOWER",   0], 
    ['TIGHTEN', 'LSL',           0,      0,      "SPEC_LOWER",   0], 
    ['SET',     'USL',           10,     1,      "SPEC_UPPER",   10], 
    ['SET',     'USL',           10,     0,      "SPEC_UPPER",   10], 
    ['RELAX',   'USL',           20,     1,      "SPEC_UPPER",   20], 
    ['RELAX',   'USL',           20,     0,      "SPEC_UPPER",   20], 
    ['RELAX',   'USL',           15,     0,      "SPEC_UPPER",   20], 
    ['TIGHTEN', 'USL',           30,     0,      "SPEC_UPPER",   20], 
    ['TIGHTEN', 'USL',           0,      1,      "SPEC_UPPER",   0], 
    ['TIGHTEN', 'USL',           0,      0,      "SPEC_UPPER",   0], 
    ['SET_REVERSED', 'SPEC',     undef,  1,      "REVERSE_SPEC_LIMIT", 'Y'],
    ['SET_REVERSED', 'SPEC',     undef,  0,      "REVERSE_SPEC_LIMIT", 'Y'],
    ['SET',     'LSL',           -10,    1,      "SPEC_LOWER",   -10], 
    ['SET',     'LSL',           -10,    0,      "SPEC_LOWER",   -10], 
    ['RELAX',   'LSL',           -20,    0,      "SPEC_LOWER",   -10], 
    ['RELAX',   'LSL',           -5,     1,      "SPEC_LOWER",   -5], 
    ['RELAX',   'LSL',           -5,     0,      "SPEC_LOWER",   -5], 
    ['TIGHTEN', 'LSL',           -30,    1,      "SPEC_LOWER",   -30], 
    ['TIGHTEN', 'LSL',           -30,    0,      "SPEC_LOWER",   -30], 
    ['TIGHTEN', 'LSL',           0,      0,      "SPEC_LOWER",   -30], 
    ['SET',     'USL',           10,     1,      "SPEC_UPPER",   10], 
    ['SET',     'USL',           10,     0,      "SPEC_UPPER",   10], 
    ['RELAX',   'USL',           20,     0,      "SPEC_UPPER",   10], 
    ['RELAX',   'USL',           5,      1,      "SPEC_UPPER",   5], 
    ['RELAX',   'USL',           5,      0,      "SPEC_UPPER",   5], 
    ['TIGHTEN', 'USL',           30,     1,      "SPEC_UPPER",   30], 
    ['TIGHTEN', 'USL',           30,     0,      "SPEC_UPPER",   30], 
    ['TIGHTEN', 'USL',           0,      0,      "SPEC_UPPER",   30], 
    ['SET_UNREVERSED','SPEC',    undef,  1,      "REVERSE_SPEC_LIMIT", 'N'],
    ['SET_UNREVERSED','SPEC',    undef,  0,      "REVERSE_SPEC_LIMIT", 'N'],
    # RELIABILITY LIMIT TESTS
    ['SET',     'LRL',           -10,    1,      "RELIABILITY_LOWER",   -10], 
    ['SET',     'LRL',           -10,    0,      "RELIABILITY_LOWER",   -10], 
    ['RELAX',   'LRL',           -20,    1,      "RELIABILITY_LOWER",   -20], 
    ['RELAX',   'LRL',           -20,    0,      "RELIABILITY_LOWER",   -20], 
    ['RELAX',   'LRL',           -15,    0,      "RELIABILITY_LOWER",   -20], 
    ['TIGHTEN', 'LRL',           -30,    0,      "RELIABILITY_LOWER",   -20], 
    ['TIGHTEN', 'LRL',           0,      1,      "RELIABILITY_LOWER",   0], 
    ['TIGHTEN', 'LRL',           0,      0,      "RELIABILITY_LOWER",   0], 
    ['SET',     'URL',           10,     1,      "RELIABILITY_UPPER",   10], 
    ['SET',     'URL',           10,     0,      "RELIABILITY_UPPER",   10], 
    ['RELAX',   'URL',           20,     1,      "RELIABILITY_UPPER",   20], 
    ['RELAX',   'URL',           20,     0,      "RELIABILITY_UPPER",   20], 
    ['RELAX',   'URL',           15,     0,      "RELIABILITY_UPPER",   20], 
    ['TIGHTEN', 'URL',           30,     0,      "RELIABILITY_UPPER",   20], 
    ['TIGHTEN', 'URL',           0,      1,      "RELIABILITY_UPPER",   0], 
    ['TIGHTEN', 'URL',           0,      0,      "RELIABILITY_UPPER",   0], 
    ['SET_REVERSED', 'REL',      undef,  1,      "REVERSE_RELIABILITY_LIMIT", 'Y'],
    ['SET_REVERSED', 'REL',      undef,  0,      "REVERSE_RELIABILITY_LIMIT", 'Y'],
    ['SET',     'LRL',           -10,    1,      "RELIABILITY_LOWER",   -10], 
    ['SET',     'LRL',           -10,    0,      "RELIABILITY_LOWER",   -10], 
    ['RELAX',   'LRL',           -20,    0,      "RELIABILITY_LOWER",   -10], 
    ['RELAX',   'LRL',           -5,     1,      "RELIABILITY_LOWER",   -5], 
    ['RELAX',   'LRL',           -5,     0,      "RELIABILITY_LOWER",   -5], 
    ['TIGHTEN', 'LRL',           -30,    1,      "RELIABILITY_LOWER",   -30], 
    ['TIGHTEN', 'LRL',           -30,    0,      "RELIABILITY_LOWER",   -30], 
    ['TIGHTEN', 'LRL',           0,      0,      "RELIABILITY_LOWER",   -30], 
    ['SET',     'URL',           10,     1,      "RELIABILITY_UPPER",   10], 
    ['SET',     'URL',           10,     0,      "RELIABILITY_UPPER",   10], 
    ['RELAX',   'URL',           20,     0,      "RELIABILITY_UPPER",   10], 
    ['RELAX',   'URL',           5,      1,      "RELIABILITY_UPPER",   5], 
    ['RELAX',   'URL',           5,      0,      "RELIABILITY_UPPER",   5], 
    ['TIGHTEN', 'URL',           30,     1,      "RELIABILITY_UPPER",   30], 
    ['TIGHTEN', 'URL',           30,     0,      "RELIABILITY_UPPER",   30], 
    ['TIGHTEN', 'URL',           0,      0,      "RELIABILITY_UPPER",   30], 
    ['SET_UNREVERSED','REL',     undef,  1,      "REVERSE_RELIABILITY_LIMIT", 'N'],
    ['SET_UNREVERSED','REL',     undef,  0,      "REVERSE_RELIABILITY_LIMIT", 'N'],
    # PARAMETER level tests
    # PASS_CRITERIA_PERCENT
    ['SET',     'PASS_CRITERIA_PERCENT',   .50,  1,   "PASS_CRITERIA_PERCENT", .50],
    ['SET',     'PASS_CRITERIA_PERCENT',   .50,  0,   "PASS_CRITERIA_PERCENT", .50],
    ['RELAX',   'PASS_CRITERIA_PERCENT',   .10,  1,   "PASS_CRITERIA_PERCENT", .10],
    ['RELAX',   'PASS_CRITERIA_PERCENT',   .10,  0,   "PASS_CRITERIA_PERCENT", .10],
    ['RELAX',   'PASS_CRITERIA_PERCENT',   .80,  0,   "PASS_CRITERIA_PERCENT", .10],
    ['TIGHTEN', 'PASS_CRITERIA_PERCENT',   .80,  1,   "PASS_CRITERIA_PERCENT", .80],
    ['TIGHTEN', 'PASS_CRITERIA_PERCENT',   .80,  0,   "PASS_CRITERIA_PERCENT", .80],
    ['TIGHTEN', 'PASS_CRITERIA_PERCENT',   .10,  0,   "PASS_CRITERIA_PERCENT", .80],
    # SAMPLING RATE
    ['SET',     'SAMPLING_RATE',   "9 SITE",  1,   "SAMPLING_RATE", "9 SITE"],
    ['SET',     'SAMPLING_RATE',   "9 SITE",  0,   "SAMPLING_RATE", "9 SITE"],
    ['RELAX',   'SAMPLING_RATE',   "5 SITE",  1,   "SAMPLING_RATE", "5 SITE"],
    ['RELAX',   'SAMPLING_RATE',   "RANDOM",  1,   "SAMPLING_RATE", "RANDOM"],
    ['RELAX',   'SAMPLING_RATE',   "RANDOM",  0,   "SAMPLING_RATE", "RANDOM"],
    ['RELAX',   'SAMPLING_RATE',   "5 SITE",  0,   "SAMPLING_RATE", "RANDOM"],
    ['RELAX',   'SAMPLING_RATE',   "9 SITE",  0,   "SAMPLING_RATE", "RANDOM"],
    ['TIGHTEN', 'SAMPLING_RATE',   "5 SITE",  1,   "SAMPLING_RATE", "5 SITE"],
    ['TIGHTEN', 'SAMPLING_RATE',   "9 SITE",  1,   "SAMPLING_RATE", "9 SITE"],
    ['TIGHTEN', 'SAMPLING_RATE',   "9 SITE",  0,   "SAMPLING_RATE", "9 SITE"],
    ['TIGHTEN', 'SAMPLING_RATE',   "5 SITE",  0,   "SAMPLING_RATE", "9 SITE"],
    ['TIGHTEN', 'SAMPLING_RATE',   "RANDOM",  0,   "SAMPLING_RATE", "9 SITE"],
    # DISPO_RULE
    ['SET',     'DISPO_RULE',      "OPAP",    1,   "DISPO_RULE",    "OPAP"],
    ['SET',     'DISPO_RULE',      "OPAP",    0,   "DISPO_RULE",    "OPAP"],
    ['SET',     'DISPO_RULE',      "OFAF",    1,   "DISPO_RULE",    "OFAF"],
    ['SET',     'DISPO_RULE',      "OFAF",    0,   "DISPO_RULE",    "OFAF"],
    # REPROBE_MAP
    ['SET',     'REPROBE_MAP',      "ALLSITE",  1,   "REPROBE_MAP",    "ALLSITE"],
    ['SET',     'REPROBE_MAP',      "ALLSITE",  0,   "REPROBE_MAP",    "ALLSITE"],
    ['SET',     'REPROBE_MAP',      'undef',    1,   "REPROBE_MAP",    'undef'],
    ['SET',     'REPROBE_MAP',      'undef',    0,   "REPROBE_MAP",    'undef'],
    # DEACTIVATE
    ['DISABLE',    "PARAMETER",      undef,    1,   "DEACTIVATE",    "Y"],
    ['DISABLE',    "PARAMETER",      undef,    0,   "DEACTIVATE",    "Y"],
    
    
    
);

# function tests
my $l = LimitRecord->new_from_hash({ETEST_NAME => "PARM"});
$l->dummify();
$l->set("DEACTIVATE", "N");
ok(defined Waivers::Change->new("ACTION", "THING", "PARAMETER", "VALUE"), "constructor");

my $tnum = 0;
my $parm = "PARM";
my $possible_success = 1;
foreach my $test (@tests){
    my ($action, $thing, $value, $change, $extract, $exp_val) = @{$test};
    $change *= $possible_success;
    my $c = Waivers::Change->new($action, $thing, $parm, $value);
    my $changed = $c->apply($l);
    ok(!($change xor $changed), "Test $tnum " . ($changed ? "changed" : "did not change") . " when expected " . ($change ? "to change" : "not to change") . " $extract");
    is($l->{$extract}, $exp_val, "Test $tnum expected value of " . (defined $exp_val ? $exp_val : "undef" ));
    $tnum++;
}

# return tests but this time with a different parameter so no changes can be made
$l = LimitRecord->new_from_hash({ETEST_NAME => "PARM"});
$l->dummify();
$l->set("DEACTIVATE", "N");

$parm = "DIFF_PARM";
$possible_success = 0;
foreach my $test (@tests){
    my ($action, $thing, $value, $change, $extract, $exp_val) = @{$test};
    $change *= $possible_success;
    my $old_val = $l->{$extract};
    my $c = Waivers::Change->new($action, $thing, $parm, $value);
    my $changed = $c->apply($l);
    my $new_val = $l->{$extract};
    ok(!($change xor $changed), "Test $tnum " . ($changed ? "changed" : "did not change") . " when expected " . ($change ? "to change" : "not to change") . " $extract");
    is($old_val, $new_val, "$extract value of " . (defined $old_val ? $old_val : "undef") . " did not change (" . (defined $new_val ? $new_val : "undef") . ")");
    $tnum++;
}


# edge cases
my $c = Waivers::Change->new("AAAaAA", "PARAMETER", "PARM", undef);
dies_ok(sub{$c->apply($l)}, "Unkown action type");
$c = Waivers::Change->new("SET", "WONKY", "PARM", undef);
dies_ok(sub{$c->apply($l)}, "Unkown thing type");






