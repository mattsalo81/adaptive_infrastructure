package OptionAssertions;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Parse::BooleanExpression;

my $get_assertions_sth;

sub try_all_assertions_against_routing_and_options{
	my ($tech, $routing, $options) = @_;
	my $assertions = get_all_assertions($tech);
	my @failed;
	foreach my $assert (@{$assertions}){
		if (try_assertion_against_routing_and_options($assert, $routing, $options)){
			# do nothing
		}else{
			push @failed, $assert;
		}
	}
	if (scalar @failed > 0){
		confess "Routing <$routing> and options <"  . join(", ", @{$options}) . "> failed the following assertions <" . join(", ", @failed) . ">";
	}
	return 1;
}

sub try_assertion_against_routing_and_options{
	my ($assertion, $routing, $options) = @_;
	if(BooleanExpression::does_sms_routing_and_options_match_expression($routing, $options, $assertion)){
		Logging::debug("Assertion <$assertion> is true for routing <$routing> and options <" . join(", ", @{$options}) . ">");
		return 1;
	}else{
		Logging::debug("Assertion <$assertion> fails for routing <$routing> and options <" . join(", ", @{$options}) . ">");
		return 0;
	}
	return undef;
}

sub get_all_assertions{
	my ($tech) = @_;
	my $sth = get_assertion_query();
	unless($sth->execute($tech)){
		confess "Could not get all assertions for technology <$tech>";
	}
	my $matrix = $sth->fetchall_arrayref();
	my @assertions = map {$_->[0]} @{$matrix};
	return \@assertions;
}

sub get_assertion_query{
	unless (defined $get_assertions_sth){
		my $conn = Connect::read_only_connection("etest");
		my $sql = q{
			select 
				rule
			from
				opt_and_lpt_assertions
			where 
				technology = ?
		};
		$get_assertions_sth = $conn->prepare($sql);
	}
	unless (defined $get_assertions_sth){
		confess "Could not get get_assertions_sth";
	}
	return $get_assertions_sth;
}

1;
