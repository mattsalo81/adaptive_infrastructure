use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use ONEPG::Reticles;

my $known_reticle = "6408640400";
my $known_component = "EEPROM_LATCH";
my $known_chip = "C65310A0";

is(Reticles::convert_photomask_to_reticle(" E662-336"),"6408662336", "Successfully converted photomask");
is(Reticles::convert_photomask_to_reticle("662-336 "),"6401662336", "Successfully converted photomask, trailing whitespace");
dies_ok(sub{Reticles::convert_photomask_to_reticle("ASDF")}, "Successfully recognizes unexpected formats");

#get_chips_for_reticle_base_sth
my $sth = Reticles::get_chips_for_reticle_base_sth();
ok(defined($sth), "Successfully got statement handle");

my $chips = Reticles::get_chips_for_reticle_base($known_reticle);
ok(in_list($known_chip, $chips), "Found known chip in reticle list");

