use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Components::ComponentXref;

my $comps = ComponentXref::get_undefined_comps('TEST', 'TEST_DEVICE1');
ok(scalar @{$comps} > 0, "Undefined components on a test device");
is($comps->[0], 'UNDEFINED_COMP', "Returns list of undefined components for test device");

$comps = ComponentXref::get_undefined_comps('TEST', 'TEST_DEVICE2');
ok(scalar @{$comps} == 0, "No Undefined components on a fully defined test device");

