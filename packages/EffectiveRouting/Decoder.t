use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use EffectiveRouting::Decoder;
use EffectiveRouting::Generate;

my ($tech, $codes) = EffectiveRouting::Decoder::get_codes_from_routing("TEST_TESTMATT");
is(scalar @{$codes}, 1, "basic get_codes_from_routing");
is($codes->[0], "TESTMATT", "basic get_codes_from_routing");

my $options = EffectiveRouting::Decoder::get_options_for_effective_routing("TEST_MATT");
is(@{$options}, 2, "Checking correct number of results for test case");
is(join(",", @{$options}), "SHAZAM,WOW", "Correct results for test case");

$options = EffectiveRouting::Decoder::get_options_for_effective_routing("TEST_undef_MATT");
is(@{$options}, 1, "Checking correct number of results for test case");
is(join(",", @{$options}), "HEYO", "correct results");

$options = EffectiveRouting::Decoder::get_options_for_effective_routing("TEST_MATT_MATT");
is(@{$options}, 3, "Checking correct number of results for test case");
is(join(",", sort @{$options}), "HEYO,SHAZAM,WOW", "Correct results");

