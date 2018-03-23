package FindPrenote;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use SubstringMatching;

print(Dumper(create_coordref_to_prenote_association("/dm5pde_webdata/dm5pde/setup/")));


sub get_all_prenotes_in_dir{
	my ($dir) = @_;
	my @prenotes;
	opendir my $dirh, $dir or confess "Could not open prenote dir";
	while (my $pg_name = readdir($dirh)){
		next if $pg_name =~ m/^\.\.?$/;
		push @prenotes, $pg_name;
	}
	return \@prenotes;
}

sub find_closest_match_in_list_to_device{
	my ($pg_names, $device) = @_;
	my $best_name;
	my $best;
	foreach my $pg_name (@{$pg_name}){
		my $substr_len = SubstringMatching::longest_common_substr($device, $pg_name);
		if ($substr_len > $best){
			$best = $substr_len;
			$best_name = $pg_name;
		}
	}
	if ($best > length($best_name) / 2){
		# matched half a thing
		return $best_name;
	}else{
		return undef;
	}
}

sub create_coordref_to_prenote_association{
	my ($dir) = @_;
	my $pg_names = get_all_prenotes_in_dir($dir);
	foreach my $pg_name (@{get_all_prenotes_in_dir($dir)}){
		my $subdir = "$dir/$pg_name";
		if (-d $subdir){
			my $coords = get_coordrefs_from_prenote_dir($subdir, $pg_name);
			foreach my $coord (@{$coords}){
				add_coord_to_lookup(\%lookup, $coord, $pg_name);
			}
		}
	}
	return \%lookup;	
}

sub add_coord_to_lookup{
	my ($lookup, $coord, $prenote) = @_;
	unless (defined $lookup->{$coord}){
		$lookup->{$coord} = [];
	}
	push @{$lookup->{$coord}}, $prenote;
}

sub get_coordrefs_from_prenote_dir{
	my ($prenote_dir, $pg_name) = @_;
	my @prenotes = glob "$prenote_dir/$pg_name*txt";
	my %coords;
        foreach my $prenote (@prenotes){
		my $coord = get_coordref_from_prenote($prenote);
		if (defined $coord){
			$coords{$coord} = "yep";
		}
        }
	return [keys %coords];
}

sub get_coordref_from_prenote{
	my ($prenote_path) = @_;
	my $file;
	if(open $file, $prenote_path){
		while (<$file>){
			if (m/^\s*coord\s*ref\s*:\s*(\S+)/i){
				my $coordref = $1;
				close $file;
				$coordref =~ tr/a-z/A-Z/;
				return $coordref;
			}
		}
		close $file;
	}else{
		# could not open prenote -> whatever
	}
	return undef;
}

1;
