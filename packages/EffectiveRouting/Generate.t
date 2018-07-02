use warnings;
use strict;
use Test::More 'no_plan';
use lib '/dm5/ki/adaptive_infrastructure/packages';
require Test::Homebrew_Exception;
require Test::Lists;
use EffectiveRouting::Generate;

my $record = {
    ROUTING     => "A7.2F2A+",
    DEVICE      => "M06CDC65310C0",
    TECHNOLOGY  => "LBC5",
    AREA        => "PARAMETRIC",
};

my $eff = EffectiveRouting::Generate::make_from_sms_hash($record);
print "$eff\n";

