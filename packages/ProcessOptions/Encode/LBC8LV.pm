package Encode::LBC8LV;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging; 
use ProcessOptions::Encode::Global;

my @bit1_options = ("POVIATOP","METTOP","FRAM","METDCU","ALCAP");
my @bit2_options = ("CTOPM2_11","TFR","CTOPM2_13","ISO");
my @bit3_options = ("PLACEHOLDER","THINTOX","NLDD","NLDD2","NLDD3");
my @bit4_options = ("PBL_PATTERN","DEEPN","NDRN","DWELL","LVTN");

# code 0 -> Test Area
# code 1 -> # of ML
# code 2 -> char 1
# code 3 -> char 2
# code 4 -> char 3
# code 5 -> char 4

sub get_codes{
	my $area = Encode::Global::get_area_codes();
	my $ml = Encode::Global::get_num_ml_codes();
	my $char1 = permute_32(\@bit1_options);
	my $char2 = permute_16(\@bit2_options);
	my $char3 = permute_32(\@bit3_options);
	my $char4 = permute_32(\@bit4_options);
	return [$area, $ml, $char1, $char2, $char3, $char4];
}

sub permute_32{
	my ($options) = @_;
	my %codes;
	my @encoding = qw(B C D F G H J K L M N P Q R S T E 0 1 2 3 4 5 6 7 8 9 V W X Y Z);
	my ($bit1, $bit2, $bit3, $bit4, $bit5);
	for (my $val = 0; $val<32; $val++){
		my $bit = $val;
		$bit5 = int($bit/16);
		$bit -= 16*$bit5;
		$bit4 = int($bit/8);
		$bit -= 8*$bit4;
		$bit3 = int($bit/4);
		$bit -= 4*$bit3;
		$bit2 = int($bit/2);
		$bit -= 2*$bit2;
		$bit1 = $bit;
		my $code = $encoding[$val];
		my @options = ();
		push @options, $options->[0] if $bit1;
		push @options, $options->[1] if $bit2;
		push @options, $options->[2] if $bit3;
		push @options, $options->[3] if $bit4;
		push @options, $options->[4] if $bit5;
		$codes{$code} = \@options;
	}
	return \%codes;
}

sub permute_16{
	my ($options) = @_;
        my %codes;
        my @encoding = qw(1 2 3 4 5 6 7 8 B C J R V X 9 Z);
        my ($bit1, $bit2, $bit3, $bit4);
        for (my $val = 0; $val<16; $val++){
		my $bit = $val;
                $bit4 = int($bit/8);
                $bit -= 8*$bit4;
                $bit3 = int($bit/4);
                $bit -= 4*$bit3;
                $bit2 = int($bit/2);
                $bit -= 2*$bit2;
                $bit1 = $bit;
                my $code = $encoding[$val];
                my @options = ();
                push @options, $options->[0] if $bit1;
                push @options, $options->[1] if $bit2;
                push @options, $options->[2] if $bit3;
                push @options, $options->[3] if $bit4;
                $codes{$code} = \@options;
        }
        return \%codes;
}

1;
