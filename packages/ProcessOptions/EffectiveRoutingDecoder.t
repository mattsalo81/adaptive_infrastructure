use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use ProcessOptions::EffectiveRoutingDecoder;

throws_ok(sub {EffectiveRoutingDecoder::get_codes_from_routing("not a real tech", "whatever")}, "No defined way to parse routing", "Throws error when encountering new tech");
my $codes = EffectiveRoutingDecoder::get_codes_from_routing("TEST", "TESTMATT");
is(scalar @{$codes}, 1, "basic get_codes_from_routing");
is($codes->[0], "MATT", "basic get_codes_from_routing");

ok(ProcessDecoder::get_options_for_code_array("EMPTY", []), "testing empty code array");
my $options;

$options = ProcessDecoder::get_options_for_code_array("TEST", ['MATT']);
is(@{$options}, 2, "Checking correct number of results for test case");
is(join(",", @{$options}), "SHAZAM,WOW", "Correct results for test case");

$options = ProcessDecoder::get_options_for_code_array("TEST", [undef, 'MATT']);
is(@{$options}, 1, "Checking correct number of results for test case");
is(join(",", @{$options}), "HEYO", "correct results");

$options = ProcessDecoder::get_options_for_code_array("TEST", ['MATT','MATT']);
is(@{$options}, 3, "Checking correct number of results for test case");
is(join(",", sort @{$options}), "HEYO,SHAZAM,WOW", "Correct results");

