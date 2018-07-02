use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "PARA__A110+DCU-C1U6-2");
is(scalar @{$codes}, 4, "Correct number of codes returned");
is($codes->[0], "PARA", "Correctly returns test area");
is($codes->[1], "2", "Correctly returns number of metal levels");
is($codes->[2], "C1U", "Correctly Returns first bit");
is($codes->[3], "6", "Correctly Returns optional fourth bit");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "M1__A110131NF");
is(scalar @{$codes}, 4, "Correct number of codes returned");
is($codes->[0], "M1", "Correctly returns test area");
is($codes->[1], "3", "Correctly returns number of metal levels");
is($codes->[2], "1NF", "Correctly Returns first bit");
is($codes->[3], "NONE", "Correctly Returns optional fourth bit");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "M2__A11013LEF6");
is(scalar @{$codes}, 4, "Correct number of codes returned");
is($codes->[0], "M2", "Correctly returns test area");
is($codes->[1], "3", "Correctly returns number of metal levels");
is($codes->[2], "LEF", "Correctly Returns first bit");
is($codes->[3], "6", "Correctly Returns optional fourth bit");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "TST__A110+ZZ");}, "Unexpected LBC8 format");



