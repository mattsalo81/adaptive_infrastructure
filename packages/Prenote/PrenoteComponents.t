use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Prenote::PrenoteComponents;
use Logging;

my $known_file = "/dm5pde_webdata/dm5pde/setup/as5634a0/comp/AS5634A0.CompCount.txt";
my $known_component = "NCH_NAT_LV1";
my $avoid = "NADJUST";
my $known_prenote_dir = "/dm5pde_webdata/dm5pde/setup/as5634a0";
my $known_device = "M06EBMAS5634A0";

my $comps = PrenoteComponents::parse_compcount_file($known_file);
ok(in_list($known_component, $comps), "Successfully found a known component in a known compcount file");

$comps = PrenoteComponents::get_components_from_prenote($known_prenote_dir);
ok(defined $comps->{$known_component}, "Successfully found a known component in a known PG_DIR");
ok(! defined $comps->{$avoid}, "avoiding something that isn't a component in a known PG_DIR");

dies_ok(sub{PrenoteComponents::get_components_from_prenote("/yuser/bean/locale")}, "nonexistant file dir");
dies_ok(sub{PrenoteComponents::parse_compcount_file("/yuser/bean/locale")}, "nonexistant file dir");

$comps = PrenoteComponents::get_components_for_device($known_device);
ok(defined $comps->{$known_component}, "Successfully found a known component on a known device");
