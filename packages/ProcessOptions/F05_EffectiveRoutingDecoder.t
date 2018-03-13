use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("F05", "PARAMETRIC__90C5RS2PBI-5");
is(scalar @{$codes}, 2, "Correct number of codes returned");
is($codes->[0], "PARAMETRIC", "Correctly returns test area in test case");
is($codes->[1], "5", "Correctly returns #ML in test case");

dies_ok(sub {EffectiveRoutingDecoder::get_codes_from_routing("F05", "PARAMETRIC__A9.0C5RS4D")}, "Dies on bad format");



