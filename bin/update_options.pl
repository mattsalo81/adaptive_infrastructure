use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::Decoder;
use SMS::SMSDigest;

foreach my $tech (@{SMSDigest::get_all_technologies()}){
	Decoder::upload_effective_routing_options_for_tech($tech);
}
