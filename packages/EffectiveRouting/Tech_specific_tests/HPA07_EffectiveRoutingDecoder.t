use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "PARAMETRIC__A100C3CA");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "PARAMETRIC", "Correctly returns test area in test case");
is($codes->[1], "3", "Correctly returns #ML in test case");
is($codes->[2], "CA", "Correctly returns main code in test case");
is($codes->[3], "100", "Correctly returns HPA07 Flavor");
is($codes->[4], "NOTJ", "Correctly returns ISOJ");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "METAL1__M102W4ES");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "METAL1", "Correctly returns Test area in test case");
is($codes->[1], "4", "Correctly returns #ML in test case");
is($codes->[2], "ES", "Correctly returns main code in test case");
is($codes->[3], "102", "Correctly returns HPA07 Flavor");
is($codes->[4], "NOTJ", "Correctly returns ISOJ");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "BARF__M107J4MI");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "BARF", "Correctly returns test area");
is($codes->[1], "4", "Correctly returns #ML in test case");
is($codes->[2], "MI", "Correctly returns main code in test case");
is($codes->[3], "107", "Correctly returns HPA07 Flavor");
is($codes->[4], "J", "Correctly returns ISOJ");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("HPA07", "TEST__M107-KS4H2");}, "Unexpected HPA07 format");



