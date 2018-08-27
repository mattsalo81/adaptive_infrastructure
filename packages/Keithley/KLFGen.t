use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use Keithley::KLFGen;
use Data::Dumper;

my $known_wpfs = ["dmos5_LBC5X_MLM_r06.wpf", "dmos5_LBC5X_SLM_r06.wpf"];
my $known_parms = [qw(E_B45BVP_SLM E_B25BVP_SLM GOI_HEP)];
my $known_parm_lb = 500;

my $known_tech = "LBC5";
my $known_wpf = "dmos5_LBC5X_MLM_r06.wpf";
my $known_area = "PARAMETRIC";
my $known_rout = "LBC5_PARAMETRIC_3_CD";
my $known_prog = "M06CDC65310C0";

my $parm_hash = KLFGen::get_parameters_from_wpfs($known_wpfs, 1);
my $parms = [values %{$parm_hash}];
ok(scalar @{$parms} > $known_parm_lb, "Found at least $known_parm_lb parameters on known wpfs");
ok(subset($known_parms, $parms), "parameters found contained a subset of known parameters");

my $klf = KLFGen::make_klf_for_wpf($known_wpf, $known_tech, $known_area, $known_rout, $known_rout, $known_prog);
print $klf;
