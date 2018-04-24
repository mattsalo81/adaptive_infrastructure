package Components;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $manual_designs_for_device_sth;
my $manual_components_for_design_sth;

sub get_all_components_for_device{
	my ($device) = @_;	
	# get components for reticles
	# get_all_components_for_chips
	# get manual components for chips
	
}






sub get_manual_components_for_design{
	my ($design) = @_;	
}

sub get_manual_designs_for_device{
	my ($device) = @_;
	
}

sub get_manual_designs_for_device_sth{
	unless (defined $manual_designs_for_device_sth){
	}
	unless (defined $manual_designs_for_device_sth){
}

1;
