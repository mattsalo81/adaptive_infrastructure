package Photomasks;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $photomasks_for_device_sth;

sub get_photomasks_for_device{
	my ($device) = @_;
	my $sth = get_photomasks_for_device_sth();
	$sth->execute($device) or confess "Could not get photomasks for device $device";
	my $rows = $sth->fetchall_arrayref();
	my @photomasks = map {$_->[0]} @{$rows};
	return \@photomasks;
}

sub get_photomasks_for_device_sth{
	unless (defined $photomasks_for_device_sth){
		my $sql = q{
			select distinct 
				oo.photomask
	                from 
				device_rev dr
				inner join opn_override oo
					on  oo.facility = dr.facility
					and oo.device = dr.device
					and oo.grp_type = dr.grp_type
					and oo.rev = dr.rev
				inner join entity_def ed
					on  ed.facility = oo.facility
					and ed.grp_type = '706'
	                where 
				dr.facility = 'DP1DM5'
				and dr.device = ?
	                	and dr.grp_type = '704'
				and dr.status = 'A'
	                	and oo.photomask = ed.entity
	                	and oo.opn = '3600'
		};
		my $conn = Connect::read_only_connection('sms');
		$photomasks_for_device_sth = $conn->prepare($sql);
	}
	unless (defined $photomasks_for_device_sth){
		confess "Could not get photomasks_for_device_sth";
	}
	return $photomasks_for_device_sth;
}

1;
