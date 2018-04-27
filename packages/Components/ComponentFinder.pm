package ComponentFinder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use SMS::Photomasks;
use ONEPG::Reticles;
use ONEPG::CompCount;
use Prenote::PrenoteComponents;

# For all component purposes, If I refer to a "chip" or a "product" or a "design" I am refering to the same things.
# the ONEPG uses "chips", but historically in test we use the phrase "Design".


my $manual_designs_for_device_sth;
my $manual_components_for_design_sth;

sub get_all_components_for_device{
	my ($device) = @_;	
	# logical flow described on confluence
	Logging::debug("Looking for component information for $device");

	# get photomasks from SMS
	my $masks = Photomasks::get_photomasks_for_device($device);
	Logging::diag("Photomasks : " . join(", ", @{$masks}));

	# convert all photomasks to reticles
	my @reticles = map {Reticles::convert_photomask_to_reticle($_)} @{$masks};
	Logging::diag("Reticles : " . join(", ", @reticles));

	# get onepg chips and components (from reticles)
	my %onepg_chips;
	my %onepg_reticle_comps;
	foreach my $reticle (@reticles){
		my $chips = Reticles::get_chips_for_reticle_base($reticle);
		@onepg_chips{@{$chips}} = ("N") x scalar @{$chips};
		my $comps = CompCount::get_components_for_reticle_base($reticle);
		@onepg_reticle_comps{@{$comps}} = ("N") x scalar @{$comps};
	}
	Logging::diag("Chips from ONEPG : " . Dumper \%onepg_chips);
	Logging::diag("Components from ONEPG : " . Dumper \%onepg_reticle_comps);

	# get manually added chips
	my $manual_chips = get_manual_designs_for_device($device);
	Logging::diag("Manually applied chips : " . join(", ", @{$manual_chips}));
	
	# create master chip list 
	my %all_chips = (%onepg_chips);
	@all_chips{@{$manual_chips}} = ("Y") x scalar @{$manual_chips};

	# get onepg components (from all chips)
	my %onepg_chip_comps;
	my %etest_chip_comps;
	foreach my $chip (keys %all_chips){
		my $manual = $all_chips{$chip};
		my $comps = CompCount::get_components_for_chip($chip);
		@onepg_chip_comps{@{$comps}} = ($manual) x scalar @{$comps};
		$comps = get_manual_components_for_design($chip);
		@etest_chip_comps{@{$comps}} = ($manual) x scalar @{$comps};
	}
	Logging::diag("ONEPG Components from chip lists : " . Dumper \%onepg_chip_comps);
	Logging::diag("Manual Components from chip lists : " . Dumper \%etest_chip_comps);

	# get components from prenotes
	my $prenote_comps = PrenoteComponents::get_components_for_device($device);
	Logging::diag("Components from prenotes : " . Dumper $prenote_comps);

	# combine all component sources;
	my %all_comps = (%onepg_reticle_comps, %onepg_chip_comps, %etest_chip_comps);
	@all_comps{keys %{$prenote_comps}} = ("N") x scalar keys %{$prenote_comps};
	
	Logging::diag("All Components : " . Dumper(\%all_comps));

	return \%all_comps;
}

sub get_manual_components_for_design{
	my ($design) = @_;	
        my $sth = get_manual_components_for_design_sth();
        $sth->execute($design) or confess "Could not get components for design $design";
        my $rows = $sth->fetchall_arrayref();
        my @comps  = map {$_->[0]} @{$rows};
        return \@comps;
}

sub get_manual_designs_for_device{
	my ($device) = @_;
        my $sth = get_manual_designs_for_device_sth();
        $sth->execute($device) or confess "Could not get designs for device $device";
        my $rows = $sth->fetchall_arrayref();
        my @designs  = map {$_->[0]} @{$rows};
        return \@designs;
}

sub get_manual_designs_for_device_sth{
	unless (defined $manual_designs_for_device_sth){
		my $sql = q{
			select distinct	design from etest.device_to_design_manual where device = ?
		};
		my $conn = Connect::read_only_connection("etest");
		$manual_designs_for_device_sth = $conn->prepare($sql);
	}
	unless (defined $manual_designs_for_device_sth){
		confess "Could not get manual_designs_for_device_sth";
	}
	return $manual_designs_for_device_sth;
}

sub get_manual_components_for_design_sth{
        unless (defined $manual_components_for_design_sth){
                my $sql = q{
                        select distinct component from etest.design_to_components_manual where design = ?
                };
                my $conn = Connect::read_only_connection("etest");
                $manual_components_for_design_sth = $conn->prepare($sql);
        }
        unless (defined $manual_components_for_design_sth){
                confess "Could not get manual_components_for_design_sth";
        }
        return $manual_components_for_design_sth;
}

1;
