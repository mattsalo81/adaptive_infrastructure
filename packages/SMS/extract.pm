package extract;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use DBI;
use DATABASE::connect;
use Carp;
use Data::Dumper;

my %family2tech;

sub update_sms_table{
	my $table = 'etest_daily_sms_extract';
	my $trans = connect::new_transaction("sd_limits");
	eval{
		# empty table in transaction
		my $e_sth = $trans->prepare("delete from $table where 1 = 1");
		$e_sth->execute();

		# get SMS data
		my $d_sth = get_device_extract_handle();		
		$d_sth->execute();

		# prepare upload handle and bind variables
		my $u_sql = qq{
			insert into $table (DEVICE, TECHNOLOGY, FAMILY, COORDREF, ROUTING, 
					    EFFECTIVE_ROUTING, LPT, COT, PROGRAM, 
					    PROBER_FILE, RECIPE, AREA, OPN, CARD_FAMILY) values 
					    (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		};
		my $u_sth = $trans->prepare($u_sql);
		my ($device, $technology, $family, $coordref, $routing, $effective_routing, $lpt, 
		    $cot, $program, $prober_file, $recipe, $area, $opn, $card_family);

		# enter the download/scrub/upload loop
		while (my $rec = $d_sth->fetchrow_hashref("NAME_uc")){
			# set bound variables
			$device = $rec->{"DEVICE"};
			$family = $rec->{"FAMILY"};
			$technology = get_technology_from_family($family);
			$coordref = $rec->{"COORDREF"};
			$routing = $rec->{"ROUTING"};
			$lpt = $rec->{"LPT"};
			$program = $rec->{"PROGRAM"};
			$prober_file = $rec->{"PROBER_FILE"};
			$opn = $rec->{"OPN"};
			$card_family = $rec->{"CARD_FAMILY"};

			# TODO:
			$effective_routing = "WHATEVER";
			$cot = "N";
			$recipe = "WHATEVER";
			$area = "WHATEVER";
			
			# error checking on KPARMS
			next unless defined $coordref;
			next unless defined $program;
			next unless defined $prober_file;
			next unless defined $card_family;
			# upload
			$u_sth->execute($device, $technology, $family, $coordref, $routing, $effective_routing, $lpt, 
		    			$cot, $program, $prober_file, $recipe, $area, $opn, $card_family);
		}
		
		$trans->commit();
		1;
	} or do {
		my $e = $@;
		$trans->rollback();
		confess "Could not update daily sms extract! : <$e>\n";
	}
}

sub is_COT{
}

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
	  kparm_resolve(dm.facility, dm.device, '704', '7161', rfd.lpt, ofd.opn, '704') as card_family,
	  kparm_resolve(dm.facility, dm.device, '704', '5300', '0000', '0000', '704') as coordref
	  
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
