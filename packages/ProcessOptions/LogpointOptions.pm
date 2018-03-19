package LogpointOptions;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

# this package handles all the logic for checking for process options in a routing based on the logpoints used

my $get_all_options_sth;

sub get_all_options_for_tech{
	my ($tech) = @_;
	my $sth = get_all_options_for_tech_query();
	unless($sth->execute($tech)){
		confess "Could not get all process option (logpoint rules) for tech <$tech>";
	}
	my $opts = $sth->fetchall_arrayref();
	my @opts = map {$_->[0]} @{$opts};
	return \@opts;
}

sub get_all_options_for_tech_query{
	unless(defined $get_all_options_sth){
		my $conn = Connect::read_only_connection("etest");
		my $sql = q{
			select distinct
				process_option
			from 
				logpoint_to_option
			where 
				technology = ?
		};
		$get_all_options_sth = $conn->prepare($sql);
	}
	unless(defined $get_all_options_sth){
		confess "could not get get_all_options_sth";
	}
	return $get_all_options_sth;
}

1;
