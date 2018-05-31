use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Components::FMEA;

my $test_tech = "TEST";

my $sth = FMEA::get_fmea_comps_sth();
ok(defined($sth), "Got fmea_comps_sth");

my $comps = FMEA::get_fmea_comps($test_tech);
ok(lists_identical($comps, ["FMEA_COMP1", "FMEA_COMP2"]), "Got known FMEA components from test technology");
