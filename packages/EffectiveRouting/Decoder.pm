package EffectiveRouting::Decoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::ProcessDecoder;
use EffectiveRouting::Generate;
use Switch;

sub get_options_for_effective_routing{
    my ($effective_routing) = @_;
    my ($technology, $codes) = get_codes_from_routing($effective_routing);
    return ProcessDecoder::get_options_for_code_array($technology, $codes);
}

sub get_codes_from_routing{
    my ($effective_routing) = @_;
    my $codes = [];
    my ($technology, @codes) = split(/$EffectiveRouting::Generate::delineator/, $effective_routing);
    @codes = map {$_ eq $EffectiveRouting::Generate::undef_val ? undef : $_ } @codes;
    return ($technology, \@codes);
}

1;
