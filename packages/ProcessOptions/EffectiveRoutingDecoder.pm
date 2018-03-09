package EffectiveRoutingDecoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use ProcessOptions::ProcessDecoder;
use Switch;

sub get_options_for_routing{
	my ($technology, $routing) = @_;
	my $codes = get_codes_from_routing($technology, $routing);
	return get_options_for_code_array($technology, $codes);
}

# takes an array of codes
# each index is the code_num (so we can have multiple decoders per each bit/code in a routing)
# each value is the process code
# undef is okay
sub get_options_for_code_array{
	my ($technology, $codes) = @_;
        my %options;
	if (scalar @{$codes} == 0){
		confess "Tried to get process options, but not provided any process codes! Probably Programmer's Fault";
	}
        for (my $code_num = 0; $code_num < scalar @{$codes}; $code_num++){
                my $code = $codes->[$code_num];
                next unless defined $code;
                my $options = ProcessDecoder::get_options_for_code($technology, $code_num, $code);
                @options{@{$options}} = @{$options};
        }
	my @unique = sort keys %options;
	return \@unique;
}


# returns an array of codes
# $return->[0] is assumed to be code_type 0
# undef is okay to return, if no codes are found for that index
sub get_codes_from_routing{
	my ($technology, $routing) = @_;
	my $codes = [];
	switch($technology){
		case 'TEST' {$codes->[0] = substr($routing, 4, 6)}
		case 'LBC5' {$codes = LBC5_get_codes_from_routing($routing)}
		case 'HPA07' {$codes = HPA07_get_codes_from_routing($routing)}
		else {confess "No defined way to parse routings for technology <$technology>, need to edit <get_codes_from_routing>\n";}
	}
	return $codes;
}

# code 0 -> defined by nameing convention
# code 1 -> # of ML
sub LBC5_get_codes_from_routing{
	my ($routing) = @_;
	my $main_code = substr($routing, 6, 2);
	my $num_ml = substr($routing, 5, 1);
	if ($num_ml !~ m/^[0-4]$/ || $main_code eq ""){
		confess "Unexpected LBC5 routing format <$routing>";
	}
	return [$main_code, $num_ml];
}

# code 0 -> main naming convention
# code 1 -> # of ML
# code 2 -> flavor of hpa07
sub HPA07_get_codes_from_routing{
	# can't get iso from flavor code.  Could get it from the num ml
	my ($routing) = @_;
	my $main_code = substr($routing, 6, 2);
	my $num_ml = substr($routing, 5, 1);
	my $flavor_code = substr($routing, 1, 3);
	if ($num_ml !~ m/^[0-4]$/ || $main_code eq "" || $flavor_code !~ m/^10[0237]$/){
		confess "Unexpected HPA07 routing format <$routing>";
	}
	return [$main_code, $num_ml, $flavor_code];
}

sub LBC8_get_codes_from_routing{
	my ($routing) = @_;
	
}

1;
