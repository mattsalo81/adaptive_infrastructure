use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

my $codes;

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "PARA__A140+DCU-HN-3");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "PARA", "correctly returns test area");
is($codes->[1], "3", "Correctly returns number of metal levels");
is($codes->[2], "HN", "Correctly Returns two char code");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "M1__A140B3BA2");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "M1", "correctly returns test area");
is($codes->[1], "3", "Correctly returns number of metal levels");
is($codes->[2], "BA", "Correctly Returns two char code");

$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "M2__M140+2ADM");
is(scalar @{$codes}, 3, "Correct number of codes returned");
is($codes->[0], "M2", "correctly returns test area");
is($codes->[1], "2", "Correctly returns number of metal levels");
is($codes->[2], "AD", "Correctly Returns two char code");

dies_ok(sub{$codes = EffectiveRoutingDecoder::get_codes_from_routing("LBC7", "FOO__AAAAAADCU-123-D");}, "Unexpected LBC7 format");



