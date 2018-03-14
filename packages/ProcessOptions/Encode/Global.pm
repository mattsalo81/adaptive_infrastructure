package Encode::Global;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my @areas = (
	'GATE',
	'METAL1',
	'METAL2',
	'PARAMETRIC',
);

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
