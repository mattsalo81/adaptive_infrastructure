use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use SMS::LogpointRequirements;

my $routing_9300 = "M100C3L+";
my $routing_9455 = "A72AE2BE";

# parse_lpt_string
my ($req_lpt, $forb_lpt) = LogpointRequirements::parse_lpt_string("9300.!9455");
is(scalar @{$req_lpt}, 1, "Correct number of required logpoints");
is(scalar @{$forb_lpt}, 1, "Correct number of forbidden logpoints");
is($req_lpt->[0], "9300", "Correct required logpoint");
is($forb_lpt->[0], "9455", "Correct forbidden logpoint");

($req_lpt, $forb_lpt) = LogpointRequirements::parse_lpt_string("3333.!6666.9000");
is(scalar @{$req_lpt}, 2, "Correct number of required logpoints");
is(scalar @{$forb_lpt}, 1, "Correct number of forbidden logpoints");
is($req_lpt->[0], "3333", "Correct required logpoint");
is($req_lpt->[1], "9000", "Correct required logpoint");
is($forb_lpt->[0], "6666", "Correct forbidden logpoint");

($req_lpt, $forb_lpt) = LogpointRequirements::parse_lpt_string("");
is(scalar @{$req_lpt}, 0, "Correct number of required logpoints");
is(scalar @{$forb_lpt}, 0, "Correct number of forbidden logpoints");

dies_ok(sub {($req_lpt, $forb_lpt) = LogpointRequirements::parse_lpt_string("AYLM.3244")}, "Dies on unexpected inputs");

# get_routing_list_at_lpt
my $routings = LogpointRequirements::get_routing_list_at_lpt("9300");
ok(scalar keys %{$routings} > 100, "Pulled at least 100 routings that go through 9300");
ok(defined $routings->{$routing_9300}, "Example routing $routing_9300 identified as going through 9300");
ok(! defined($routings->{$routing_9455}), "Example routing $routing_9455 identified as not going through 9300");
$routings = LogpointRequirements::get_routing_list_at_lpt("100000");
is(scalar keys %{$routings}, 0, "Found no routings through lpt 100000");

# does_routing_match_lpt_lists
ok(LogpointRequirements::does_routing_match_lpt_lists($routing_9300, ['9300'], []), "Match routings by logpoints");
ok(LogpointRequirements::does_routing_match_lpt_lists($routing_9300, [], ['9455']), "Match routings by logpoints");
ok(LogpointRequirements::does_routing_match_lpt_lists($routing_9300, ['9300'], ['9455']), "Match routings by logpoints");
ok(! LogpointRequirements::does_routing_match_lpt_lists($routing_9455, ['9300'], []), "Match routings by logpoints");
ok(! LogpointRequirements::does_routing_match_lpt_lists($routing_9455, [], ['9455']), "Match routings by logpoints");
ok(! LogpointRequirements::does_routing_match_lpt_lists($routing_9455, ['9300'], ['9455']), "Match routings by logpoints");
# no logpoints -> never matches
ok(LogpointRequirements::does_routing_match_lpt_lists($routing_9455, [], []), "No requirements always match");

# does_routing_match_lpt_string
ok(LogpointRequirements::does_routing_match_lpt_string($routing_9300, "9300"), "Match routings by logpoint strings");
ok(LogpointRequirements::does_routing_match_lpt_string($routing_9300, "!9455"), "Match routings by logpoint strings");
ok(LogpointRequirements::does_routing_match_lpt_string($routing_9300, "9300.!9455"), "Match routings by logpoint strings");
ok(! LogpointRequirements::does_routing_match_lpt_string($routing_9455, "9300"), "Match routings by logpoint strings");
ok(! LogpointRequirements::does_routing_match_lpt_string($routing_9455, "!9455"), "Match routings by logpoint strings");
ok(! LogpointRequirements::does_routing_match_lpt_string($routing_9455, "9300.!9455"), "Match routings by logpoint strings");
ok(! LogpointRequirements::does_routing_match_lpt_string($routing_9455, ""), "Match routings by logpoint strings");
# null string -> never matches
ok(! LogpointRequirements::does_routing_match_lpt_string($routing_9300, ""), "Empty string never matches");

# get_list_of_routings_matching_lpt_string
my $testlist = [$routing_9300, $routing_9455];
my $results = LogpointRequirements::get_list_of_routings_matching_lpt_string($testlist, "9300.!9455");
is(scalar @{$results}, 1, "Identifies one routing correctly as 9300");
is($results->[0], $routing_9300, "Identifies correct routing as 9300");


