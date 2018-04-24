package Components;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

# For all component purposes, If I refer to a "chip" or a "product" or a "design" I am refering to the same things.
# the ONEPG uses "chips", but historically in test we use the phrase "Design".


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
