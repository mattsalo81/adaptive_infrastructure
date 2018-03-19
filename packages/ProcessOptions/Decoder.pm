package Decoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::LogpointOptions;
use ProcessOptions::EffectiveRoutingDecoder;
use Database::Connect;
use Parse::BooleanExpression;

my $get_comp_options_sth;

sub check_options_against_assertions{
	my ($tech, $options) = @_;
	
}

sub get_composite_options_for_routing_and_effective_routing{
	my ($tech, $routing, $effective_routing) = @_;
	my $basic = get_basic_options_for_routing_and_effective_routing($tech, $routing, $effective_routing);
	my $comp = get_composite_options_for_option_list($tech, $basic);
	return $comp;
}

sub get_basic_options_for_routing_and_effective_routing{
	my ($tech, $routing, $effective_routing) = @_;
	my ($eff_opt, $lpt_opt);
	eval{
		$eff_opt = EffectiveRoutingDecoder::get_options_for_effective_routing($tech, $effective_routing);
		$lpt_opt = LogpointOptions::get_process_options_from_routing($tech, $routing);
		1;
	} or do {
		my $e = $@;
		confess "Could not get process options for routing <$routing> and effective_routing <$effective_routing> because : $e";
	};
	my %uniq;
	@uniq{@{$eff_opt}} = @{$eff_opt};
	@uniq{@{$lpt_opt}} = @{$lpt_opt};
	return [keys %uniq];
}

sub get_composite_options_for_option_list{
	my ($tech, $orig_options) = @_;
	my @options = @{$orig_options};
	my $sth = get_composite_options_query();
	unless($sth->execute($tech)){
		confess "Could not execute query to get composite options for <$tech>";
	}
	my $rulesets = $sth->fetchall_arrayref();
	foreach my $ruleset (@{$rulesets}){
		my ($priority, $rule, $composite_option) = @{$ruleset};
		if(BooleanExpression::does_opt_list_match_opt_string(\@options, $rule)){
			push @options, $composite_option;
		}
	}
	return \@options;
}

sub get_composite_options_query{
	unless (defined($get_comp_options_sth)){
		my $conn = Connect::read_only_connection("etest");
		my $sql = q{
			select distinct
				priority,
				process_option_rule, 
				process_option
			from 
				option_to_option
			where
				technology = ?
			order by priority
		};
		$get_comp_options_sth = $conn->prepare($sql);
	}
	unless (defined($get_comp_options_sth)){
		confess "Could not get get_comp_options_sth";
	}
	return $get_comp_options_sth;
}



1;
