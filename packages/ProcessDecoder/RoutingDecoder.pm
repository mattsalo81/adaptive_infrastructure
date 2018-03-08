package RoutingDecoder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use LOGGING;
use ProcessDecoder::ProcessDecoder;
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
	my @codes;
	switch($technology){
		case 'TEST' {$codes[0] = substr($routing, 4, 6)}
		else {confess "No defined way to parse routings for technology <$technology>, need to edit <$0>\n";}
	}
	return \@codes;
}



1;
