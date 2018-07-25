use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use SpecFiles::GenerateSpec;

my ($tech, $area, $eff_rout, $prog, $comp) = @ARGV;

my $usage = qq{

    Usage :    $0 <TECHNOLOGY> <TEST_AREA> <EFFECTIVE_ROUTING> <PROGRAM> <COMP?1:0>

    prints the specfile for the given tech/area/routing/program.  
    if comp == 1, generates a component spec, otherwise generates a flow spec"

};

die $usage unless((defined $tech) and (defined $area) and (defined $eff_rout) and (defined $prog));

my $spec = GenerateSpec::get_spec($tech, $area, $eff_rout, $prog, $comp);
print $$spec . "\n\n";
