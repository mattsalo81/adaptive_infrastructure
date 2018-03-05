use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use SMS::effective_routing;

# effective routing
# LBC8
my $record = {
	TECH		=>	'LBC8',
	DEVICE		=>	'M08_MSSOMESTUFF',
	ROUTING		=>	'WHATEVER',
	PROD_GRP	=>	'LBC8-DLM',
};
is(effective_routing::get_effective_routing_LBC8($record), "WHATEVER", "LBC8 basic routing");
$record->{"ROUTING"} = "DCU";
is(effective_routing::get_effective_routing_LBC8($record), "DCU-MS2", "LBC8 effective routing tests");
$record->{"PROD_GRP"} = "Doesn't work";
dies_ok(sub {effective_routing::get_effective_routing_LBC8($record)}, "LBC8 effective routing tests - no metal level in prod grp");

