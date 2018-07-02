use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use EffectiveRouting::Generate;

my $eff;
my $record;

$record = {
    TECHNOLOGY  => "HPA07",
    AREA        => "PARAMETRIC",
    ROUTING     => "A100C3CA",
};
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "HPA07_PARAMETRIC_3_CA_100_NOTJ", "HPA07 Std routing");

$record->{"AREA"} = "METAL2";
$record->{"ROUTING"} = "M102W4ES";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "HPA07_METAL2_4_ES_102_NOTJ", "HPA07 Std routing");

$record->{"ROUTING"} = "M107J4MI";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "HPA07_METAL2_4_MI_107_J", "HPA07 Std routing - J");

$record->{"ROUTING"} = "M107J4VMI";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "HPA07_METAL2_4_MI_107_J", "HPA07 Std routing - Military");

$record->{"ROUTING"} = "M107-KS4H2";
dies_ok(sub{$eff = EffectiveRouting::Generate::make_from_sms_hash($record)}, "Unexpected HPA07 format");



