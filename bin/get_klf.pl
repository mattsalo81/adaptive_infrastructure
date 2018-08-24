use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Keithley::KLFGen;

print usage() and exit unless (scalar @ARGV == 6);
my ($wpf, $tech, $area, $eff_rout, $prog, $use_arch) = @ARGV;
my $klf = KLFGen::make_klf_for_wpf($wpf, $tech, $area, $eff_rout, $prog, $use_arch);

print $klf;

sub usage{
return qq{

    Usage : $0 <production.wpf> <TECHNOLOGY> <TEST_AREA> <EFFECITVE_ROUTING> <PROGRAM> [USE_ARCHIVE]

    Extracts the production version of production.wpf to get a list of all parametres
    References the Limits Database for TECHNOLOGY/TEST_AREA/EFFECTIVE_ROUTING/PROGRAM to determine the requirements for each parameter
    Prints a KLF to match the Limits Database and the WPF
    
    optional USE_ARCHIVE parameter determines whether to use the ARCHIVE for the source of all files.
    Set USE_ARCHIVE to true to use archive.  set to 0 or leave undefined to use environment variables to find files

};
}
