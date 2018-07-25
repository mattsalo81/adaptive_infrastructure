use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use EffectiveRouting::Generate;

my $eff;
my $record;

$record = {
    TECHNOLOGY  => "LBC5",
    AREA        => "PARAMETRIC",
    DEVICE      => "M06...",
    ROUTING     => "A7.2F2A+",
};
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC5_PARAMETRIC_2_A+", "LBC5X Std routing");

$record->{"ROUTING"} = "A7.2F3AMMI";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC5_PARAMETRIC_3_AM", "LBC5X Std routing");

$record->{"DEVICE"} = "M05...";
$record->{"AREA"} = "METAL2";
$record->{"ROUTING"} = "A70AI3N";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC5_METAL2_3_?N?", "LBC5 standard + METAL2");

