use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
use EffectiveRouting::Generate;

my $eff;
my $record;

$record = {
    TECHNOLOGY  => "LBC7",
    AREA        => "PARAMETRIC",
    DEVICE      => "M17_MS...",
    ROUTING     => "A140B3BA2",
    PROD_GRP    => "LBC7-DLM",
};
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC7_PARAMETRIC_3_BA", "LBC7 Std routing");

$record->{"ROUTING"} = "A140+DCU";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC7_PARAMETRIC_2_MS", "LBC7 DCU routing");

delete $record->{"PROD_GRP"};
dies_ok(sub{$eff = EffectiveRouting::Generate::make_from_sms_hash($record)}, "No prod group defined, but DCU routing");

$record->{"ROUTING"} = "A140+FVDCA";
dies_ok(sub{$eff = EffectiveRouting::Generate::make_from_sms_hash($record)}, "No prod group defined, but FVDCA routing");

$record->{"AREA"} = "METAL2";
$record->{"PROD_GRP"} = "LBC7-TLM";
$eff = EffectiveRouting::Generate::make_from_sms_hash($record);
is($eff, "LBC7_METAL2_3_MS", "LBC7 FVDCA routing");

$record->{"ROUTING"} = "AAAAAAAAA";
dies_ok(sub{$eff = EffectiveRouting::Generate::make_from_sms_hash($record)}, "Unexpected format");
