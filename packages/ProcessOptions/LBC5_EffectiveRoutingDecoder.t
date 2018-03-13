use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC5", "PARAMETRIC__A7.2F2A+");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "PARAMETRIC", "Correctly returns #ML in test case");
is($codes->[1], "2", "Correctly returns #ML in test case");
is($codes->[2], "A+", "Correctly returns main code in test case");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC5", "PARAMETRIC__A7.2F3AMMI");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "PARAMETRIC", "Correctly returns #ML in test case");
is($codes->[1], "3", "Correctly returns #ML in test case");
is($codes->[2], "AM", "Correctly returns main code in test case");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC5", "METAL2__A70AI3N");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "METAL2", "Correctly returns #ML in test case");
is($codes->[1], "3", "Correctly returns #ML in test case");
is($codes->[2], "N", "Correctly returns main code in test case");



