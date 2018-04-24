use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use ONEPG::CompCount;

my $known_reticle = "6408640400";
my $known_component = "EEPROM_LATCH";
my $known_chip = "C65310A0";

my $sth = CompCount::get_components_for_reticle_base_sth();
ok(defined($sth), "Successfully got statement handle");

my $comps = CompCount::get_components_for_reticle_base($known_reticle);
ok(in_list($known_component, $comps), "Found known component on known reticle");

$sth = CompCount::get_components_for_chip_sth();
ok(defined($sth), "Successfully got statement handle");

$comps = CompCount::get_components_for_chip($known_chip);
ok(in_list($known_component, $comps), "Found known component on known chip");
