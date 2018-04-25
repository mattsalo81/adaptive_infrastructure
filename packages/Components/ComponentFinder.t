use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Data::Dumper;
use Components::ComponentFinder;
use DBI;

my $test_device = "TEST_DEVICE";
my $test_design = "TEST_CHIP";
my $test_comp   = "TEST_COMP";

my $known_device = "M06EBEC65310B0";
my $known_component = "EEPROM_LATCH";
my $known_chip = "C65310B0";

my $pretend_device = "TEST_C65310B0";

#ComponentFinder.pm:sub get_manual_designs_for_device_sth{
my $sth = ComponentFinder::get_manual_components_for_design_sth();
ok(defined $sth, "got manual_components_for_design_sth");

#ComponentFinder.pm:sub get_manual_components_for_design_sth{

$sth = ComponentFinder::get_manual_designs_for_device_sth();
ok(defined $sth, "Got manual_designs_for_device sth");

#ComponentFinder.pm:sub get_manual_designs_for_device{
my $designs = ComponentFinder::get_manual_designs_for_device($test_device);
ok(in_list($test_design, $designs), "Found a known manual design for test device");

#ComponentFinder.pm:sub get_manual_components_for_design{
my $comps = ComponentFinder::get_manual_components_for_design($test_design);
ok(in_list($test_comp, $comps), "Found a known manual component for test design");

# general tests
$comps = ComponentFinder::get_all_components_for_device($test_device);
ok(defined $comps->{$test_comp}, "Found the manually configured component through a manual device-> chip association");
is($comps->{$test_comp}, "Y", "Manually configured component was flagged as manual");

my $real_comps = ComponentFinder::get_all_components_for_device($known_device);
ok(defined $real_comps->{$known_component}, "Found a manually identified component in a real device");
is($real_comps->{$known_component}, "N", "Independantly found component was flagged as not-manual");

my $pretend_comps = ComponentFinder::get_all_components_for_device($pretend_device);
ok(defined $pretend_comps->{$known_component}, "Manually linked a device to a chip, then found a component from the real chip");
is($pretend_comps->{$known_component}, "Y", "Manually configured component was flagged as manual");

my @list1 = keys %{$real_comps};
my @list2 = keys %{$pretend_comps};

ok(have_same_elements(\@list1, \@list2), "Manually linked a device to a chip, then found all the components of the real chip");


