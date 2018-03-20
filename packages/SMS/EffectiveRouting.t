use strict;
use Test::More "no_plan";
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use SMS::EffectiveRouting;

# effective routing
# LBC8
my $record = {
	TECH		=>	'LBC8',
	DEVICE		=>	'M08_MJS1_SOMESTUFF',
	ROUTING		=>	'WHATEVER',
	PROD_GRP	=>	'LBC8-DLM',
	AREA		=>	'PARAMETRIC',
};
is(EffectiveRouting::make_effective_routing($record), "PARAMETRIC__WHATEVER", "LBC8 basic routing");
$record->{"ROUTING"} = "DCU";
$record->{"AREA"} = "METAL1";
is(EffectiveRouting::make_effective_routing($record), "METAL1__DCU-MJS1-2", "LBC8 effective routing tests");
$record->{"PROD_GRP"} = "Doesn't work";
dies_ok(sub {EffectiveRouting::make_effective_routing($record)}, "LBC8 effective routing tests - no metal level in prod grp");

# LBC7
my $record = {
        TECH            =>      'LBC7',
        DEVICE          =>      'M17_MSSOMESTUFF',
        ROUTING         =>      'WHATEVER',
        PROD_GRP        =>      'LBC7-DLM',
	AREA		=>	'PARAMETRIC',
};
is(EffectiveRouting::make_effective_routing($record), "PARAMETRIC__WHATEVER", "LBC7 basic routing");
$record->{"ROUTING"} = "DCU";
is(EffectiveRouting::make_effective_routing($record), "PARAMETRIC__DCU-MS-2", "LBC7 effective routing tests");
$record->{"PROD_GRP"} = "Doesn't work";
dies_ok(sub {EffectiveRouting::make_effective_routing($record)}, "LBC7 effective routing tests - no metal level in prod grp");



# F05
my $record = {
        TECH            =>      'F05',
        DEVICE          =>      'M2HSOMESTUFF',
        ROUTING         =>      'WHATEVER',
        FE_STRATEGY     =>      'Something X2L',
	AREA		=>	'PARAMETRIC',
};
is(EffectiveRouting::make_effective_routing($record), "PARAMETRIC__WHATEVER-2", "F05 basic routing");
$record->{"FE_STRATEGY"} = "Doesn't work";
dies_ok(sub {EffectiveRouting::make_effective_routing($record)}, "F05 effective routing tests - no metal level in fe_strategy");
delete $record->{"FE_STRATEGY"};
dies_ok(sub {EffectiveRouting::make_effective_routing($record)}, "F05 effective routing tests - no fe_strategy");

# LBC5
my $lbc5_record = {
        TECH            =>      'LBC5',
        DEVICE          =>      'M06ORWHATEVER',
        ROUTING         =>      'WHATEVER',
	AREA		=>	'PARAMETRIC',
};
is(EffectiveRouting::make_effective_routing($lbc5_record), "PARAMETRIC__WHATEVER-X", "LBC5X basic routing");
$lbc5_record->{"DEVICE"} = "M05ORWHATEVER";
is(EffectiveRouting::make_effective_routing($lbc5_record), "PARAMETRIC__WHATEVER", "LBC5 basic routing");





