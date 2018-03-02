package extract;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use DBI;
use DATABASE::connect;

my %family2tech;

sub get_technology_from_family{
	my ($family) = @_;
	$family =~ tr/[a-z]/[A-Z]/;
	unless (defined $family2tech{$family}){
		my $conn = connect::read_only_connection("sd_limits");
		my $sql = "select technology from etest_family_to_technology where UPPER(family) = ?";
		my $sth = $conn->prepare($sql);
		$sth->execute($family);
		my ($technology) = $sth->fetchrow_array();
		unless (defined $technology){
			$technology = "UNDEF";
		}
		$family2tech{$family} = $technology;
	}
	return $family2tech{$family};
} 

sub get_device_extract_handle{
	my $conn = connect::read_only_connection("sms");
	my $extract_sql = q{
	select 
	  dm.device, 
	  dm.class,
	  dm.family,
	  dm.prod_grp,
	  dm.fe_stratgy,
	  
	  dm.routing,
	  rfd.lpt,
	  rfd.opnset,
	  ofd.opn,
	  kparm_resolve(dm.facility, dm.device, '704', '7160', rfd.lpt, ofd.opn, '704') as program,
	  kparm_resolve(dm.facility, dm.device, '704', '7162', rfd.lpt, ofd.opn, '704') as prober_file,
	  kparm_resolve(dm.facility, dm.device, '704', '7161', rfd.lpt, ofd.opn, '704') as probe_card
	  
	from 
	  smsdw.dm_device_attributes dm
	  inner join smsdw.routing_def rd
		on  rd.facility = dm.facility
		and rd.routing = dm.routing
		and rd.status = 'A'
	  inner join smsdw.routing_flw_def rfd
		on  rfd.facility = rd.facility
		and rfd.routing = rd.routing
		and rfd.rev = rd.rev
		and rfd.lpt in ('6152', '6652', '6279', '6778', '9300', '9455')
	  inner join smsdw.opnset_def od
		on  od.facility = rfd.facility
		and od.opnset = rfd.opnset
		and od.status = 'A'
	  inner join smsdw.opnset_flw_def ofd
		on  ofd.facility = od.facility
		and ofd.opnset = od.opnset
		and ofd.rev = od.rev
		and ofd.opn in ('8820', '8822', '8823', '8827')
	where 
	  dm.facility = 'DP1DM5'
	  and dm.status = 'A'
	  and (dm.prod_grp in ('PRIME', 'DEV') or dm.dev_group in ('PRIME', 'DEV'))
	  and dm.device not like '%DMD%'
	  and dm.device not like '%MX'
	};
	my $sth = $conn->prepare($extract_sql);
	return $sth;
}

1;
