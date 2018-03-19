package LogpointOptions;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Parse::BooleanExpression;

# this package handles all the logic for checking for process options in a routing based on the logpoints used

my $get_all_options_sth;
my $get_lpt_rules_sth;
my $table = "logpoint_to_option";

sub get_process_options_from_routing{
	my ($tech, $routing) = @_;
	my $sth = get_lpt_rules_query();
	$sth->execute($tech) or confess "Could not get logpoint -> process options rules for <$tech>";
	my $rules = $sth->fetchall_arrayref();
	my %options;
	foreach my $rule (@{$rules}){
		my ($logpoint_expression, $option) = @{$rule};
		if (BooleanExpression::does_sms_routing_match_lpt_string($routing, $logpoint_expression)){
			$options{$option} = "yep";
		}
	}
	return [keys %options];
}

sub get_lpt_rules_query{
	unless (defined $get_lpt_rules_sth){
		my $conn = Connect::read_only_connection("etest");
		my $sql = qq{
			select 
				LPT_RULE, PROCESS_OPTION
			from
				$table
			where
				technology = ?
		};
		$get_lpt_rules_sth = $conn->prepare($sql);
	}
	unless (defined $get_lpt_rules_sth){
		confess "Could not get get_lpt_rules_sth";
	}
	return $get_lpt_rules_sth;
}

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
		my $sql = qq{
			select distinct
				process_option
			from 
				$table
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
