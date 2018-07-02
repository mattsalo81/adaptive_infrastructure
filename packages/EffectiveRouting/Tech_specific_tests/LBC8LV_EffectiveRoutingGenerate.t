use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use EffectiveRouting::Generate;

my $eff;
my $record;

$record = {
    TECHNOLOGY  => "LBC8LV",
    AREA        => "PARAMETRIC",
    ROUTING     => "M183+4B3L5",
};
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC8LV_PARAMETRIC_4_B_3_L_5", "LBC8LV Std routing");

$record->{"ROUTING"} = "M180S4B5YB";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC8LV_PARAMETRIC_4_B_5_Y_B", "LBC8LV Std routing");

$record->{"ROUTING"} = "M180-KISO4";
dies_ok(sub{$eff = EffectiveRouting::Generate::make_from_sms_hash($record)}, "Unexpected LBC8LV format");



