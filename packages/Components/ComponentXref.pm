package ComponentXref;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $lookup_table = 'component_name_translation';
my $raw_table = 'raw_component_info';
my $output_table = 'component_info';
my $device_fully_defined_sth;


sub get_undefined_comps{
	my ($device) = @_;
	my $sth = get_device_fully_defined_sth();
	$sth->execute($device);
	my $rows = $sth->fetchall_arrayref();
	my $undefined_comps = map {$_->[0]} @{$rows};
	return $undefined_comps;
}

sub get_device_fully_defined_sth{
	unless (defined $device_fully_defined_sth){
		my $sql = qq{
			select 
				rc.component
			from
				$raw_table rc
			where
				rc.device = ?
				and raw.component not in (
					select distinct 
						l.raw_name
					from
						$lookup_table l
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

1;
