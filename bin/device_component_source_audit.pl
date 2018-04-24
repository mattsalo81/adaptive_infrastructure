use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages/';
use Components::Components;
use Logging;
use Data::Dumper;

my ($device) = @ARGV;
unless (defined $device){
	print "Usage : $0 <device>\n\n";
	exit;
}

Logging::set_level("DIAG");
my $comps = Components::get_all_components_for_device($device);
