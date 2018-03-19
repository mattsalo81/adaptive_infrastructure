use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::LogpointOptions;
use Parse::BooleanExpression;

my $routing = "M100C3L+";

# dependent on TEST cases defined in the SQL config for the table
my @opts = sort @{LogpointOptions::get_all_options_for_tech("TEST")};
is(scalar @opts, 4, "Gets correct number of process options");
is($opts[0], "DANG", "gets correct options");
is($opts[1], "NICE", "gets correct options");
is($opts[2], "SHAZAM", "gets correct options");
is($opts[3], "WOW", "gets correct options");

ok(BooleanExpression::does_routing_match_lpt_string($routing, "9300 & 0050 & 3355 & ! 3362 & ! 9455"), "Double checking the assumptions I made when selecting this routing");


@opts = sort @{LogpointOptions::get_process_options_from_routing("TEST", $routing)};
is(scalar @opts, 3, "Found three process options for routing");
is($opts[0], "DANG", "Correctly finds first option");
is($opts[1], "NICE", "Correctly finds second option");
is($opts[2], "SHAZAM", "Correctly finds third option");
