package ComponentXref;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use SMS::SMSDigest;

my $lookup_table = 'component_name_translation';
my $raw_table = 'raw_component_info';
my $output_table = 'component_info';

my $device_fully_defined_sth;

sub update_component_info{
	my $techs = SMSDigest::get_all_technologies();
	my %unsatisfied;
	foreach my $tech (@{$techs}){
		my $unsatisfied = update_component_info_for_tech($tech);
		$unsatisfied{$tech} = $unsatisfied;
	}
	foreach my $tech (keys %unsatisfied){
		my $num_dev = $unsatisfied{$tech};
		warn "$tech has $num_dev unsatisfied device" . ($num_dev == 1 ? "" : "s") . "\n";
	}
}

sub update_component_info_for_tech{
	my ($tech) = @_;
	my $devices = SMSDigest::get_all_devices_in_tech($tech);
	Logging::event("Updating component info for $tech");
	my $trans = Connect::new_transaction("etest");
	my %undefined_devices;
	eval{
		my $del_sql = qq{delete from $output_table where technology = ? and device = ?};
		my $del_sth = $trans->prepare($del_sql);
		my $upd_sth = $trans->prepare(get_update_etest_comps_sql());
		foreach my $device (@{$devices}){
			Logging::debug("Updating component info for $device");
			# wipe old information
			$del_sth->execute($tech, $device);
			my $undefined_comps = get_undefined_comps($tech, $device);
			if (scalar @{$undefined_comps}){
				$undefined_devices{$device} = [@{$undefined_comps}];
				Logging::diag("$device has undefined components " . join(", ", @{$undefined_comps}));
			}else{
				Logging::diag("Updating component information for $device");
				$upd_sth->execute($tech, $device);
			}
		}
		$trans->commit();	
		1;
	} or do {
		my $e = $@;
		$trans->rollback();
		confess "Could not update component info for $tech because :\n$e";
	};

	# print undefined component to STDERR
	Logging::event("Successfully updated $tech component info");
	if (scalar keys %undefined_devices){
		warn("Undefined components for technology $tech\n");
		foreach my $device (keys %undefined_devices){
			foreach my $component (@{$undefined_devices{$device}}){
				warn "$device,$component\n";
			}
		}
	}
	# return number of undefined devices
	return (scalar keys %undefined_devices);
}

sub get_undefined_comps{
	my ($tech, $device) = @_;
	my $sth = get_device_fully_defined_sth();
	$sth->execute($tech, $device);
	my $rows = $sth->fetchall_arrayref();
	my @undefined_comps = map {$_->[0]} @{$rows};

	return \@undefined_comps;
}

sub get_device_fully_defined_sth{
	unless (defined $device_fully_defined_sth){
		my $sql = qq{
			select 
				rc.component
			from
				$raw_table rc
			where
				rc.technology = ?
				and rc.device = ?
				and rc.component not in (
					select distinct 
						l.raw_name
					from
						$lookup_table l
					where
						l.technology = rc.technology
					)
		};
		my $conn = Connect::read_only_connection('etest');
		$device_fully_defined_sth = $conn->prepare($sql);
	}
	unless (defined $device_fully_defined_sth){
		confess "could not get device_fully_defined_sth";
	}
	return $device_fully_defined_sth;
}

sub get_update_etest_comps_sql{
	my $sql = qq{
		insert into $output_table o (technology, device, component)
		select distinct 
			rc.technology,
			rc.device,
			l.etest_name 
		from
			$raw_table rc
			inner join $lookup_table l
				on  l.technology = rc.technology
				and l.raw_name = rc.component
		where
			rc.technology = ?
			and rc.device = ?
	};
	return $sql;
}

1;
