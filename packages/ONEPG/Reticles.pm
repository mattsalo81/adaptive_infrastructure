package Reticles;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my %first_character_code_photomask = (
        D  => '6401',
        E  => '6408',
        A  => '6408',
        N  => '6408',
        8  => '6408',
        7  => '6408',
        '' => '6401',
);

sub convert_photomask_to_reticle{
	my ($mask) = @_;
	$mask =~ s/\s//g;
	$mask =~ s/\-//;
	if ($mask !~ m/^[A-Z]?[0-9]+$/){
		confess "Unexpected photomask format";
	}
	# convert first character
	foreach my $char (reverse sort keys %first_character_code_photomask){
		my $code = $first_character_code_photomask{$char};
		last if ($mask =~ s/^$char/$code/);
	}	
	return $mask;
}

1;
