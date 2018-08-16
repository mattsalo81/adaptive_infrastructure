use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::KLFGen;

print usage() and exit unless (scalar @ARGV == 5);
my ($wpf, $tech, $area, $eff_rout, $prog) = @ARGV;
my $klf = KLFGen::make_klf_for_wpf($wpf, $tech, $area, $eff_rout, $prog);

print $klf;

sub usage{
return qq{

    Usage : $0 <production.wpf> <TECHNOLOGY> <TEST_AREA> <EFFECITVE_ROUTING> <PROGRAM>

    Extracts the production version of production.wpf to get a list of all parametres
    References the Limits Database for TECHNOLOGY/TEST_AREA/EFFECTIVE_ROUTING/PROGRAM to determine the requirements for each parameter
    Prints a KLF to match the Limits Database and the WPF

};
}
