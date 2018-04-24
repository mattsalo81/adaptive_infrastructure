package Components;
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

# For all component purposes, If I refer to a "chip" or a "product" or a "design" I am refering to the same things.
# the ONEPG uses "chips", but historically in test we use the phrase "Design".


my $manual_designs_for_device_sth;
my $manual_components_for_design_sth;

sub get_all_components_for_device{
	my ($device) = @_;	
	# logical flow described on confluence

	# get photomasks from SMS
	my $masks = Photomasks::get_photomasks_for_device($device);

	# convert all photomasks to reticles
	my @reticles = map {Reticles::convert_photomask_to_reticle($_)} @{$masks};

	# get onepg chips and components (from reticles)
	my @onepg_chips;
	my @onepg_reticle_comps;
	foreach my $reticle (@reticles){
		my $chips = Reticles::get_chips_for_reticle_base($reticle);
		push @onepg_chips, @{$chips};
		my $comps = CompCount::get_components_for_reticle_base($reticle);
		push @onepg_reticle_comps, @{$comps};
	}

	# get manually added chips
	my $manual_chips = get_manual_designs_for_device($device);
	
	# create master chip list (in hash, so it's unique)
	my %all_chips;
	@all_chips{@onepg_chips} = @onepg_chips;
	@all_chips{@{$manual_chips}} = @{$manual_chips};

	# get onepg components (from all chips)
	my @onepg_chip_comps;
	my @etest_chip_comps;
	foreach my $chip (keys %all_chips){
		my $comps = CompCount::get_components_for_chip($chip);
		push @onepg_chip_comps, @{$comps};
		$comps = get_manual_components_for_design($chip);
		push @etest_chip_comps, @{$comps};
	}

	# combine all component sources;
	my %all_comps;
	@all_comps{@onepg_reticle_comps} = @onepg_reticle_comps;
	@all_comps{@onepg_chip_comps} = @onepg_chip_comps;
	@all_comps{@etest_chip_comps} = @etest_chip_comps;

	my @uniq_comps = keys %all_comps;

	return \@uniq_comps;
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
