package ProcessSummary;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use SMS::SMSDigest;

sub process_f_summary_for_tech{
	my ($tech) = @_;
	eval{
		my $effective_routings = SMSDigest::get_all_effective_routings_in_tech($tech);
		my $conn = Connect::read_only_connection('etest');		

		







		1;
	} or do {

	}	
}

sub get_f_summary_records_for_tech{
	my ($tech) = @_;
	my $conn = Connect::read_only_connection('etest');
	$conn->{FetchHashKeyName} = 'NAME_uc';
	my $sql = q{select * from f_summary where technology = ?};
	my $sth = $conn->prepare($sql);
	$sth->execute($tech);
	my $recs = $sth->fetchall_arrayref({});
	return $recs;
}

sub process_f_summary_record{
	my ($record) = @_;
		

}


1;
