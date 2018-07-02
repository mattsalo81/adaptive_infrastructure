use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::OptionAssertions;
use ProcessOptions::CompositeOptions;
use SMS::LogpointRequirements;
use ProcessOptions::Decoder;

my $routing = "A72AF3A+";
my $eff_rout = "TEST_MATT";

# check the assertions for TEST
my $asserts = OptionAssertions::get_all_assertions("TEST");
ok(defined $asserts, "Got assertions without dying");
my @asserts = sort @{$asserts};
is(scalar @asserts, 2, "Found both assertions");
is($asserts[0], "DANG && WOW", "Found first assertion");
is($asserts[1], "DUMMY -> DANG", "Found first assertion");

#check that test routing TESTMATT is okay
my @comp = sort @{CompositeOptions::get_composite_options_for_routing_and_effective_routing("TEST", $routing, "TEST_MATT")};
my $i = 0;
is(scalar @comp, 6 , "Correct number of options for basic list");
is($comp[$i], "DANG", "Correct option $i"); $i++;
is($comp[$i], "FOUND_IT", "Correct option $i"); $i++;
is($comp[$i], "SHAZAM", "Correct option $i"); $i++;
is($comp[$i], "WOW", "Correct option $i"); $i++;
is($comp[$i], "WOW2", "Correct option $i"); $i++;
is($comp[$i], "WOW3", "Correct option $i"); $i++;

# check that routing is okay
my $lpt;
# any routing that goes through 9300, 0050, 3355, and 3362, but not 9455 (aligns with database TEST cases)
$lpt = '0050';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");
$lpt = '9300';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");
$lpt = '9455';
ok(!LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing does not use $lpt");
$lpt = '3355';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");
$lpt = '3362';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");

ok(Decoder::get_options_for_routing_and_effective_routing("TEST", $routing, $eff_rout), "Successfully returns options (probably, didn't check them but I check them in other tests)");
dies_ok(sub{Decoder::get_options_for_routing_and_effective_routing("TESTFAIL", $routing, $eff_rout)}, "Fail test");


1;
