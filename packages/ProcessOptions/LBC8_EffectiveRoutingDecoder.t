use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "PARA__A110+DCU-C1U6-2");
is(scalar @{$codes}, 6, "Correct number of codes returned");
is($codes->[0], "PARA", "Correctly returns test area");
is($codes->[1], "2", "Correctly returns number of metal levels");
is($codes->[2], "C", "Correctly Returns first bit");
is($codes->[3], "1", "Correctly Returns second bit");
is($codes->[4], "U", "Correctly Returns third bit");
is($codes->[5], "6", "Correctly Returns optional fourth bit");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "M1__A110131NF");
is(scalar @{$codes}, 6, "Correct number of codes returned");
is($codes->[0], "M1", "Correctly returns test area");
is($codes->[1], "3", "Correctly returns number of metal levels");
is($codes->[2], "1", "Correctly Returns first bit");
is($codes->[3], "N", "Correctly Returns second bit");
is($codes->[4], "F", "Correctly Returns third bit");
is($codes->[5], "", "Correctly Returns optional fourth bit");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "M2__A11013LEF6");
is(scalar @{$codes}, 6, "Correct number of codes returned");
is($codes->[0], "M2", "Correctly returns test area");
is($codes->[1], "3", "Correctly returns number of metal levels");
is($codes->[2], "L", "Correctly Returns first bit");
is($codes->[3], "E", "Correctly Returns second bit");
is($codes->[4], "F", "Correctly Returns third bit");
is($codes->[5], "6", "Correctly Returns optional fourth bit");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC8", "TST__A110+ZZ");}, "Unexpected LBC8 format");



