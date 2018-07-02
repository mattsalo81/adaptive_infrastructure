use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::CompositeOptions;
use Data::Dumper;
use SMS::LogpointRequirements;
use EffectiveRouting::Decoder;
use ProcessOptions::LogpointOptions;

# any routing that goes through 9300, 0050, 3355, and 3362, but not 9455 (aligns with database TEST cases)
my $routing = "A72AF3A+";
my $lpt = '0050';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");
$lpt = '9300';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");
$lpt = '9455';
ok(!LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing does not use $lpt");
$lpt = '3355';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");
$lpt = '3362';
ok(LogpointRequirements::does_routing_use_lpt($routing, $lpt), "Checking that test routing uses $lpt");

my @effrout = sort @{EffectiveRouting::Decoder::get_options_for_effective_routing("TEST_MATT")};
is(scalar @effrout, 2, "Correct number of options for effective routing");
is($effrout[0], "SHAZAM", "Correct option 0");
is($effrout[1], "WOW", "Correct option 1");

my @lpt = sort @{LogpointOptions::get_process_options_from_routing("TEST", $routing)};
is(scalar @lpt, 2, "Correct number of options for logpoints");
is($lpt[0], "DANG", "Correct option 0");
is($lpt[1], "SHAZAM", "Correct option 1");


my @basic = sort @{CompositeOptions::get_primary_options_for_routing_and_effective_routing("TEST", $routing, "TEST_MATT")};
is(scalar @basic, 3, "Correct number of options for basic list");
is($basic[0], "DANG", "Correct option 0");
is($basic[1], "SHAZAM", "Correct option 1");
is($basic[2], "WOW", "Correct option 2");

my @comp = sort @{CompositeOptions::get_composite_options_for_option_list("TEST", \@basic)};
# [WOW, SHAZAM, DANG, WOW2, WOW3, FOUND_IT]

my $i = 0;
is(scalar @comp, 6 , "Correct number of options for basic list");
is($comp[$i], "DANG", "Correct option $i"); $i++;
is($comp[$i], "FOUND_IT", "Correct option $i"); $i++;
is($comp[$i], "SHAZAM", "Correct option $i"); $i++;
is($comp[$i], "WOW", "Correct option $i"); $i++;
is($comp[$i], "WOW2", "Correct option $i"); $i++;
is($comp[$i], "WOW3", "Correct option $i"); $i++;

@comp = sort @{CompositeOptions::get_composite_options_for_option_list("TEST", ['WOW2'])};
is(scalar @comp, 3 , "Correct number of options for basic list");
is($comp[0], "BAD", "Correct option 0");
is($comp[1], "WOW2", "Correct option 1");
is($comp[2], "WOW3", "Correct option 2");

@comp = sort @{CompositeOptions::get_composite_options_for_routing_and_effective_routing("TEST", $routing, "TEST_MATT")};
$i = 0;
is(scalar @comp, 6 , "Correct number of options for basic list");
is($comp[$i], "DANG", "Correct option $i"); $i++;
is($comp[$i], "FOUND_IT", "Correct option $i"); $i++;
is($comp[$i], "SHAZAM", "Correct option $i"); $i++;
is($comp[$i], "WOW", "Correct option $i"); $i++;
is($comp[$i], "WOW2", "Correct option $i"); $i++;
is($comp[$i], "WOW3", "Correct option $i"); $i++;


