use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Components::EffectiveComponents;

my $sth = EffectiveComponents::get_components_for_device_sth();
ok(defined $sth, "get components sth");

my $comps = EffectiveComponents::generate_merged_component_list_for_devices("TEST", []);
ok(lists_identical($comps, []), "Empty list of devices returns empty list of components");

$comps = EffectiveComponents::generate_merged_component_list_for_devices("TEST", ['DEV1']);
ok(lists_identical($comps, ['COMP1']), "Got known test device from table");

$comps = EffectiveComponents::generate_merged_component_list_for_devices("TEST", ['DEV1', 'DEV1', 'DEV1']);
ok(lists_identical($comps, ['COMP1']), "Got known test device from table");

$comps = EffectiveComponents::generate_merged_component_list_for_devices("TEST", ['DEV1', 'DEV1', 'DEV2']);
ok(have_same_elements($comps, ['COMP1', 'COMP2', 'COMP3']), "Got known test devices from table");

$comps = EffectiveComponents::generate_effective_components_for_devices("TEST", ['DEV1']);
ok(have_same_elements($comps, ['COMP1', 'FMEA_COMP1', 'FMEA_COMP2']), "got known test device with known FMEA comps");


my $test_tech = "TEST";
my $test_prog1 = "PROG1";
my $test_prog2 = "PROG2";
my $test_prog3 = "I DO NOT EXIST";


#check if sth defined
ok(EffectiveComponents::get_program_has_components_sth(), "got statement handle for component");
is(EffectiveComponents::get_number_components_on_program($test_tech, $test_prog1), 1, "found one component on $test_prog1");
is(EffectiveComponents::get_number_components_on_program($test_tech, $test_prog2), 2, "found two components on $test_prog2");
is(EffectiveComponents::get_number_components_on_program($test_tech, $test_prog3), 0, "found no components on $test_prog3");


