use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Data::Dumper;
use Components::Components;
use DBI;

my $test_device = "TEST_DEVICE";
my $test_design = "TEST_CHIP";
my $test_comp   = "TEST_COMP";

my $known_device = "M06EBEC65310B0";
my $known_component = "EEPROM_LATCH";
my $known_chip = "C65310A0";

#Components.pm:sub get_manual_designs_for_device_sth{
my $sth = Components::get_manual_components_for_design_sth();
ok(defined $sth, "got manual_components_for_design_sth");

#Components.pm:sub get_manual_components_for_design_sth{

$sth = Components::get_manual_designs_for_device_sth();
ok(defined $sth, "Got manual_designs_for_device sth");

#Components.pm:sub get_manual_designs_for_device{
my $designs = Components::get_manual_designs_for_device($test_device);
ok(in_list($test_design, $designs), "Found a known manual design for test device");

#Components.pm:sub get_manual_components_for_design{
my $comps = Components::get_manual_components_for_design($test_design);
ok(in_list($test_comp, $comps), "Found a known manual component for test design");

# general tests
$comps = Components::get_all_components_for_device($test_device);
ok(in_list($test_comp, $comps), "Found the manually component through a manual device-> chip association");

$comps = Components::get_all_components_for_device($known_device);
print Dumper $comps;

