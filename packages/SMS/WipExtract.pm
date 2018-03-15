package WipExtract;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use DBI;
use Database::Connect;

sub get_wip_query{
	Logging::debug("connecting to sms to query WIP");
	my $conn = Connect::read_only_connection("sms");
	my $sql = q{
		select 
			l.lot, 
			l.lpt, 
			l.cur_qty as wafers, 
			la.device
		from smsdw.lot l
		inner join smsdw.lot_act la
			on  la.facility = l.facility
			and la.lot = l.lot
			and la.act_seq = l.last_act_seq
		where
			l.facility = 'DP1DM5'
			and l.lpt < 'TRM'
			and la.tran_dttm > (Sysdate - 100)
			and la.device not like 'Q%'
			and la.device not like '_X%'
	};
	my $sth = $conn->prepare($sql);
	return $sth;
}

sub update_wip_extract{
	my $trans = Connect::new_transaction("etest");
	my $milestone = 1000;
	my $num_lots = 0;
	eval{
		# delete everything in WIP extract
		my $del_sth = $trans->prepare(q{delete from daily_wip_extract where 1=1});
		$del_sth->execute();
		# start pulling data from sms
		my $d_sth = get_wip_query();
		$d_sth->execute() or confess "Could not query SMS wip tables";
		my $u_sth = $trans->prepare(q{insert into daily_wip_extract (lot, device, lpt, wafers) values (?, ?, ?, ?)});
		while(my $rec = $d_sth->fetchrow_hashref("NAME_uc")){
			if (($num_lots % $milestone == 0) && $num_lots > 0){
				Logging::event("Added $num_lots lots to wip extract");
			}
			$num_lots++;
			$u_sth->execute($rec->{"LOT"}, $rec->{"DEVICE"}, $rec->{"LPT"}, $rec->{"WAFERS"});
		}
		$trans->commit();
		1;
	} or do {
		my $e = $@;
		$trans->rollback();
		confess "Encountered error, will not commit changes to wip extract : $e";
	}
}

1;
