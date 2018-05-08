package Encode::Global;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::Encode::F05;
use ProcessOptions::Encode::HPA07;
use ProcessOptions::Encode::LBC5;
use ProcessOptions::Encode::LBC7;
use ProcessOptions::Encode::LBC8;
use ProcessOptions::Encode::LBC8LV;
use Switch;

# This package is used to generate the process codes used to populate the process code table.  It is highly technology dependent.

my @areas = (
    'GATE',
    'METAL1',
    'METAL2',
    'PARAMETRIC',
);

# return array-ref of process code structures, organized by their code_num
# process code structures are hash-refs, keys are the code, values are an array-ref of process options for that code
sub get_codes{
    my ($tech) = @_;
    my $codes;
    switch ($tech){
        case 'F05' 	{$codes = Encode::F05::get_codes()}
        case 'HPA07' 	{$codes = Encode::HPA07::get_codes()}
        case 'LBC5' 	{$codes = Encode::LBC5::get_codes()}
        case 'LBC7' 	{$codes = Encode::LBC7::get_codes()}
        case 'LBC8' 	{$codes = Encode::LBC8::get_codes()}
        case 'LBC8LV' 	{$codes = Encode::LBC8LV::get_codes()}
        else {
            confess("No defined method in Encode::Global for getting codes from <$tech>");
        }
    }
    return $codes;
}

sub parse_old_txt_format{
    my ($text) = @_;
    my @lines = split(/\n+/, $text);
    my %codes;
    foreach my $line (@lines){
        $line =~ s/^\s*//;
        next if $line =~ m/^#/;
        next if $line =~ m/^\s*$/;
        if ($line =~ m{^a-z0-9_ \.\+\/]}i){
            confess "Unexpected characters in line <$line>";
        }
        my @fields = split /\s+/, $line;
        my $code = shift @fields;
        if (defined $codes{$code}){
            push @{$codes{$code}}, @fields;
        }else{
            $codes{$code} = \@fields;
        }
    }
    return \%codes;
}

sub get_area_codes{
    my @been_to;
    my @after;
    my $prev;
    my %codes;
    foreach my $area (@areas){
        my @opts = ("AT_$area");
        push @been_to, $area;
        push @opts, map {"BEEN_TO_$_"} @been_to;
        push @after, $prev if(defined $prev);
        push @opts, map {"AFTER_$_"} @after;
        $prev = $area;
        $codes{$area} = \@opts;
    }
    return \%codes;
}

sub get_num_ml_codes{
    my %codes;
    my @been_to;
    my @pref = qw(S D T Q P SIX SEV);
    for (my $lv = 1; $lv <= scalar @pref; $lv++){
        my @opts = ($pref[$lv - 1] . "LM");
        my $num = "$lv" . "PLUS_LM";
        push @been_to, $num;
        push @opts, @been_to;
        $codes{$lv} = \@opts;
    }
    return \%codes;
}

1;
