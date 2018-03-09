use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "A100C3CA");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "CA", "Correctly returns main code in test case");
is($codes->[1], "3", "Correctly returns #ML in test case");
is($codes->[2], "100", "Correctly returns HPA07 Flavor");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "M102W4ES");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "ES", "Correctly returns main code in test case");
is($codes->[1], "4", "Correctly returns #ML in test case");
is($codes->[2], "102", "Correctly returns HPA07 Flavor");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "M107A4MI");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "MI", "Correctly returns main code in test case");
is($codes->[1], "4", "Correctly returns #ML in test case");
is($codes->[2], "107", "Correctly returns HPA07 Flavor");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "M107-KS4H2");}, "Unexpected HPA07 format");



