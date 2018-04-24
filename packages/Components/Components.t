use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Components::Components;
use DBI;

my $test_device = "TEST_DEVICE";
my $test_design = "TEST_CHIP";
my $test_comp   = "TEST_COMP";

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
