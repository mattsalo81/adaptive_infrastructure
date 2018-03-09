use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "A110+DCU-C1U6-2");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "2", "Correctly returns number of metal levels");
is($codes->[1], "C", "Correctly Returns first bit");
is($codes->[2], "1", "Correctly Returns second bit");
is($codes->[3], "U", "Correctly Returns third bit");
is($codes->[4], "6", "Correctly Returns optional fourth bit");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "A110131NF");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "3", "Correctly returns number of metal levels");
is($codes->[1], "1", "Correctly Returns first bit");
is($codes->[2], "N", "Correctly Returns second bit");
is($codes->[3], "F", "Correctly Returns third bit");
is($codes->[4], "", "Correctly Returns optional fourth bit");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "A11013LEF6");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "3", "Correctly returns number of metal levels");
is($codes->[1], "L", "Correctly Returns first bit");
is($codes->[2], "E", "Correctly Returns second bit");
is($codes->[3], "F", "Correctly Returns third bit");
is($codes->[4], "6", "Correctly Returns optional fourth bit");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "A110+ZZ");}, "Unexpected LBC8 format");



