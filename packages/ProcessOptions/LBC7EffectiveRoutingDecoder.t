use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "A140+DCU-HN-3");
is(scalar @{$codes}, 2, "Correct number of codes returned");
is($codes->[0], "3", "Correctly returns number of metal levels");
is($codes->[1], "HN", "Correctly Returns two char code");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "A140B3BA2");
is(scalar @{$codes}, 2, "Correct number of codes returned");
is($codes->[0], "3", "Correctly returns number of metal levels");
is($codes->[1], "BA", "Correctly Returns two char code");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "M140+2ADM");
is(scalar @{$codes}, 2, "Correct number of codes returned");
is($codes->[0], "2", "Correctly returns number of metal levels");
is($codes->[1], "AD", "Correctly Returns two char code");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "AAAAAADCU-123-D");}, "Unexpected LBC7 format");



