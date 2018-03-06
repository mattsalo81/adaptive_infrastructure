package associate;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use LOGGING;
use DATABASE::connect;
use DBI;

# associates all coordrefs to their waferconfigs. 
my $get_wcf_sth;

sub get_wcf_for_coordref{
	my ($coordref) = @_;
	unless (defined $get_wcf_sth){
		LOGGING::diag("preparing statement handle to find attachments of wcrepo\n");
		my $wcrepo = connect::read_only_connection("wcrepo");
		my $sql = q{select distinct WAFERCONFIGFILE from wcrepo.zonal_summary where UPPER(WAFERCONFIGFILE) like ?};
		$get_wcf_sth = $wcrepo->prepare($sql);
	}
	LOGGING::diag("Looking for <$coordref> in attachments of wcrepo\n");
	my $search = "\%_${coordref}_\%";
	$search =~ tr/a-z/A-Z/;	
	$get_wcf_sth->execute($search);
	my $matches = $get_wcf_sth->fetchall_arrayref();
	if(scalar @{$matches} == 0){
		confess "Could not find a wcf for <$coordref>\n";
	}else{
		if (scalar @{$matches} == 1){
			return $matches->[0]->[0];
		}else{
			# flatten the deep list
			my @matches = map {$_->[0]} @{$matches};
			return choose_latest_wcf(@matches);	
		}
	}
}

# given a list of wcf names to choose from, returns one or dies
sub choose_latest_wcf{
	my @wcf = @_;
	my %wcf;
	if (scalar @wcf == 0){
		confess "No waferconfigs provided, probably programmer's fault";
	}
	# extract the date, skipping any unkown formats
	foreach my $wcf (@wcf){
		# DMOS5_18F05.24L_BF741698_20140407190107_wfcfg.xml
		my ($fab, $prod_grp, $coordref, $date, $filetype, $garbage) = split("_", $wcf);
		next if defined $garbage;
		next if $filetype ne "wfcfg.xml";
		next if length($date) != 14;
		$wcf{$date} = $wcf;
	}
	# no valid formats found
	if (scalar keys %wcf == 0){
		confess "Could not find any recognized naming conventions in : <" . join(", ", @wcf) . ">\n"
	}	
	my @sorted_dates = sort {$a <=> $b} keys %wcf;
	my $latest = pop @sorted_dates;
	return $wcf{$latest};
}

sub update_lookup_table{
	# prepare download handle to get coordrefs
	LOGGING::event("Updating coordref -> wcr lookup table");
	my $etest = connect::read_only_connection("etest");
	my $download_sql = q{select distinct coordref from etest_daily_sms_extract};
	my $download_sth = $etest->prepare($download_sql);
	
	# start upload transaction
	my $trans = connect::new_transaction("etest");
	eval{
		# clear old table
		my $delete_sql = q{delete from etest_coordref2wcrepo where 1=1};
		$trans->prepare($delete_sql)->execute();
		$download_sth->execute();
		
		# prepare upload sth
		my $upload_sql = q{insert into etest_coordref2wcrepo (coordref, WAFERCONFIGFILE) values (?,?)};
		my $up_sth = $trans->prepare($upload_sql);
	
		# start populating the lookup
		my $coordrefs = $download_sth->fetchall_arrayref();
		foreach my $rec(@{$coordrefs}){
			LOGGING::diag("Processing coordref " . $rec->[0]);
#			eval{
				my $wcf = get_wcf_for_coordref($rec->[0]);
				$up_sth->execute($rec->[0], $wcf);	
				1;
#			} or do{
#				my $e = $@;
#				warn "Could not find wcf for <" . $rec->[0] . "> because\n";
#			};
		}
		$trans->commit();
		1;
	} or do{
		my $e = $@;
		$trans->rollback();
		confess "Could not update lookup table because of : $e\n";
	}
}




1;
