use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use EffectiveRouting::Generate;

my $eff;
my $record;

$record = {
    TECHNOLOGY  => "F05",
    AREA        => "PARAMETRIC",
    FE_STRATEGY => "X2L",
};
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "F05_PARAMETRIC_2", "F05 Std routing");

$record->{"FE_STRATEGY"} = "X5L";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "F05_PARAMETRIC_5", "F05 Std routing");


delete $record->{"FE_STRATEGY"};
dies_ok(sub {$eff = EffectiveRouting::Generate::make_from_sms_hash($record)}, "Undefined FE STRATEGY");



