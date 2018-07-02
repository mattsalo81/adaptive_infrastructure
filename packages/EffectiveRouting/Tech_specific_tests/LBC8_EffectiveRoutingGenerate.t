use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use EffectiveRouting::Generate;

my $eff;
my $record;

$record = {
    TECHNOLOGY  => "LBC8",
    AREA        => "PARAMETRIC",
    DEVICE      => "M08_MJS1_SOMESTUFF",
    ROUTING     => "A110131NF",
    PROD_GRP    => "LBC8-QLM",
};
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC8_PARAMETRIC_3_1NF_NONE", "LBC8 Std routing - 9 chars");

$record->{"ROUTING"} = "A11013LEF6";
$record->{"AREA"} = "METAL2";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC8_METAL2_3_LEF_6", "LBC8 Std routing - 10 chars");

$record->{"ROUTING"} = "A110+DCU";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC8_METAL2_4_MJS_1", "LBC8 Std routing - 10 chars");

$record->{"ROUTING"} = "A110+ZZ";

dies_ok(sub{$eff = EffectiveRouting::Generate::make_from_sms_hash($record);}, "Unexpected LBC8 format");



