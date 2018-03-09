use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use SMS::EffectiveRouting;

# effective routing
# LBC8
my $record = {
	TECH		=>	'LBC8',
	DEVICE		=>	'M08_MSSOMESTUFF',
	ROUTING		=>	'WHATEVER',
	PROD_GRP	=>	'LBC8-DLM',
};
is(EffectiveRouting::make_effective_routing_LBC8($record), "WHATEVER", "LBC8 basic routing");
$record->{"ROUTING"} = "DCU";
is(EffectiveRouting::make_effective_routing_LBC8($record), "DCU-MS2", "LBC8 effective routing tests");
$record->{"PROD_GRP"} = "Doesn't work";
dies_ok(sub {EffectiveRouting::make_effective_routing_LBC8($record)}, "LBC8 effective routing tests - no metal level in prod grp");

# LBC7
my $record = {
        TECH            =>      'LBC7',
        DEVICE          =>      'M17_MSSOMESTUFF',
        ROUTING         =>      'WHATEVER',
        PROD_GRP        =>      'LBC7-DLM',
};
is(EffectiveRouting::make_effective_routing_LBC7($record), "WHATEVER", "LBC7 basic routing");
$record->{"ROUTING"} = "DCU";
is(EffectiveRouting::make_effective_routing_LBC7($record), "DCU-MS2", "LBC7 effective routing tests");
$record->{"PROD_GRP"} = "Doesn't work";
dies_ok(sub {EffectiveRouting::make_effective_routing_LBC7($record)}, "LBC7 effective routing tests - no metal level in prod grp");


# F05
my $record = {
        TECH            =>      'F05',
        DEVICE          =>      'M2HSOMESTUFF',
        ROUTING         =>      'WHATEVER',
        FE_STRATEGY     =>      'Something X2L',
};
is(EffectiveRouting::make_effective_routing_F05($record), "WHATEVER-2", "F05 basic routing");
$record->{"FE_STRATEGY"} = "Doesn't work";
dies_ok(sub {EffectiveRouting::make_effective_routing_F05($record)}, "F05 effective routing tests - no metal level in fe_strategy");
delete $record->{"FE_STRATEGY"};
dies_ok(sub {EffectiveRouting::make_effective_routing_F05($record)}, "F05 effective routing tests - no fe_strategy");





