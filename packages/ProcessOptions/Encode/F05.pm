package Encode::F05;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::ProcessEncoder;
use ProcessOptions::Encode::Global;

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> defined by nameing convention

my $options;

sub get_codes{
	my $area = Encode::Global::get_area_codes();
	my $ml	= Encode::Global::get_num_ml_codes();
	return [$area, $ml];
}

1;
