package Decoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::CompositeOptions;
use ProcessOptions::OptionAssertions;

sub get_options_for_routing_and_effective_routing{
	my ($tech, $routing, $effective_routing) = @_;
	my $options = CompositeOptions::get_composite_options_for_routing_and_effective_routing($tech, $routing, $effective_routing);
	eval{
		OptionAssertions::try_all_assertions_against_routing_and_options($tech, $routing, $options);
		1;
	} or do {
		my $e = $@;
		confess "Could not get options because : $e";
	};
	return $options;
}

1;
