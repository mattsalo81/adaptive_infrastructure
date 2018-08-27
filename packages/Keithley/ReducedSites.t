use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::ReducedSites;

my $test_inner_tech = "TEST_INNER";
my $test_outer_tech = "TEST_OUTER";


ok( Keithley::ReducedSites::uses_inner_five_sites($test_inner_tech), "Found test tech set to INNER");
ok(!Keithley::ReducedSites::uses_inner_five_sites($test_outer_tech), "Found test tech set to OUTER");
dies_ok(sub{Keithley::ReducedSites::uses_inner_five_sites("I DO NOT EXIST")}, "non-configured technology");
