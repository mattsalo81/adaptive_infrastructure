use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "M183+4B3L5");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "4", "Correctly returns number of metal levels");
is($codes->[1], "B", "Correctly Returns first char");
is($codes->[2], "3", "Correctly Returns second char");
is($codes->[3], "L", "Correctly Returns third char");
is($codes->[4], "5", "Correctly Returns fourth char");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "M180S4B5YB");
is(scalar @{$codes}, 5, "Correct number of codes returned");
is($codes->[0], "4", "Correctly returns number of metal levels");
is($codes->[1], "B", "Correctly Returns first char");
is($codes->[2], "5", "Correctly Returns second char");
is($codes->[3], "Y", "Correctly Returns third char");
is($codes->[4], "B", "Correctly Returns fourth char");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "M180-KISO4");}, "Unexpected LBC8 format");



