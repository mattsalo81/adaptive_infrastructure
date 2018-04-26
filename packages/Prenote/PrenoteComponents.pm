package PrenoteComponents;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Data::Dumper;

sub get_components_from_prenote{
	my ($prenote_dir) = @_;
	unless (-d $prenote_dir){
		confess "Could not access directory $prenote_dir";
	}
	my @comp_files = glob "$prenote_dir/comp/*.CompCount.txt";
	my %components;
	foreach my $file (@comp_files){
		my $comps = parse_compcount_file($file);
		@components{@{$comps}} = ("$file") x scalar @{$comps};
	}
	return \%components;
}

sub parse_compcount_file{
	my ($file) = @_;
	open my $fh, $file or confess "could not open $file to parse component info";
	my @components;
	my $in_comp = 0;
	while(<$fh>){
		# move to header
		if (m/Component Usage/){
			$in_comp = 1;
			next
		}
		next unless $in_comp;
		# remove comments
		s/#.*//;
		# skip blank;
		next if m/^\s*$/;
		# pull component info
		if (m/^\s*([a-zA-Z0-9_]+)\s+([0-9]+)\s*/){
			my ($comp, $count) = ($1, $2);
			push @components, $comp if $count
		}
		# exit if done with components
		last if m/:/;
	} 
	close $fh;
	Logging::diag("Found " . (scalar @components) . " in file " . $file . " : " . Dumper(\@components));
	return \@components;
}

1;
