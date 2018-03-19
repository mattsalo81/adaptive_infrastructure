use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages/';
use ProcessOptions::EffectiveRoutingDecoder;

my ($tech, $routing) = @ARGV;
my $options = EffectiveRoutingDecoder::get_options_for_routing($tech, $routing);
print(join("\n", sort@{$options}) . "\n");
