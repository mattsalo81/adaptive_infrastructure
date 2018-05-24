use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Components::ComponentXref;

my $test_tech = "TEST";
my $test_dev1 = "DEV1";
my $test_dev2 = "DEV2";
my $test_dev3 = "I DO NOT EXIST";

my $comps = ComponentXref::get_undefined_comps('TEST', 'TEST_DEVICE1');
ok(scalar @{$comps} > 0, "Undefined components on a test device");
is($comps->[0], 'UNDEFINED_COMP', "Returns list of undefined components for test device");

$comps = ComponentXref::get_undefined_comps('TEST', 'TEST_DEVICE2');
ok(scalar @{$comps} == 0, "No Undefined components on a fully defined test device");

#check if sth defined
ok(ComponentXref::get_device_has_components_sth(), "got statement handle for component");
is(ComponentXref::get_number_components_on_device($test_tech, $test_dev1), 1, "found one component on $test_dev1");
is(ComponentXref::get_number_components_on_device($test_tech, $test_dev2), 2, "found two components on $test_dev2");
is(ComponentXref::get_number_components_on_device($test_tech, $test_dev3), 0, "found no components on $test_dev3");
