package effective_routing;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use DBI;
use DATABASE::connect;
use Carp;
use Data::Dumper;

#records are from SMS, reference extract.pm for format.

sub get_effective_routing{
	my ($rec) = @_;
	my $tech = $rec->{"TECH"};
	if ($tech eq "LBC8"){
		return get_effective_routing_LBC8($rec);
	}	
	
	my $routing = $rec->{"ROUTING"};
	unless (defined $routing){
		confess("no routing to generate effective routing.  Probably programmer's fault\n");
	}
	return $routing
}

sub get_effective_routing_LBC8{
	my ($rec) = @_;
	my $device = $rec->{"DEVICE"};
	my $prod_grp = $rec->{"PROD_GRP"};   
	my $routing = $rec->{"ROUTING"};
	unless(defined $routing && defined $prod_grp && defined $device){
		confess("Missing crucial information to generate LBC8 effective routing. Probably programmer's fault\n");
	}
	my $eff_routing = $routing;
	if ($routing =~ m/DCU/){
		$eff_routing .= "-".substr($device,4,2);
		if ($prod_grp =~ m/LBC8\-([SDT]LM)/){
			my $xlm = $1;
			my $num_metal = 1;
			$num_metal = 2 if ($xlm =~ /DLM/);
			$num_metal = 3 if ($xlm =~ /TLM/);
			$eff_routing .= $num_metal;
		}else{
			confess("Unable to get number of metal levels for effective routing from " . Dumper($rec) . "\n");
		}
	}
	return $eff_routing;
}

1;
