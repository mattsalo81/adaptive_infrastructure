package EffectiveRouting;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use DBI;
use Carp;
use Data::Dumper;
use Logging;
use Switch;

#records are from SMS, reference extract.pm for format.

sub make_effective_routing{
	my ($rec) = @_;
	Logging::diag("Getting effective routing for device " . $rec->{"DEVICE"});
	my $tech = $rec->{"TECH"};
	my $eff = undef;
	switch ($tech){
		case "LBC8" {$eff = make_effective_routing_LBC8($rec)}
		case "LBC7" {$eff = make_effective_routing_LBC7($rec)}
		case "F05"  {$eff = make_effective_routing_F05($rec)}
	}	
	# Nothing special LBC5
	# Nothing special HPA07
	# Nothing special LBC8LV

	unless (defined $eff){
		$eff = $rec->{"ROUTING"};
	}
	unless (defined $eff){
		confess("no routing/tech specific eff_routing to generate effective routing.  Probably programmer's fault");
	}
	my $area = $rec->{"AREA"};
	unless (defined $area){
		confess("No test area defined to generate effective routing. Probably programmer's fault");
	}
	$eff = "$area" . "__" . $eff;
	return $eff;
}

sub make_effective_routing_LBC7{
	my ($rec) = @_;
        my $device = $rec->{"DEVICE"};
        my $prod_grp = $rec->{"PROD_GRP"};
        my $routing = $rec->{"ROUTING"};
        unless(defined $routing && defined $prod_grp && defined $device){
                confess("Missing crucial information to generate LBC7 effective routing. Probably programmer's fault\n");
        }
        Logging::diag("Looking for effective routing in prod_grp for tech LBC7 on device $device");
        my $eff_routing = $routing;
        if ($routing =~ m/(DCU|FVDCA)/){
                $eff_routing .= "-".substr($device,4,2);
                if ($prod_grp =~ m/\-([SDTQP67]LM)/){
                        my $xlm = $1;
                        my $num_metal = 1;
                        $num_metal = 2 if ($xlm =~ /DLM/);
                        $num_metal = 3 if ($xlm =~ /TLM/);
                        $num_metal = 4 if ($xlm =~ /QLM/);
                        $num_metal = 5 if ($xlm =~ /PLM/);
                        $num_metal = 6 if ($xlm =~ /6LM/);
                        $num_metal = 7 if ($xlm =~ /7LM/);
                        $eff_routing .= "-" . $num_metal;
                }else{
                        confess("Unable to get number of metal levels for effective routing from " . Dumper($rec) . "\n");
                }
        }
        return $eff_routing;

}

sub make_effective_routing_LBC8{
	my ($rec) = @_;
	my $device = $rec->{"DEVICE"};
	my $prod_grp = $rec->{"PROD_GRP"};   
	my $routing = $rec->{"ROUTING"};
	unless(defined $routing && defined $prod_grp && defined $device){
		confess("Missing crucial information to generate LBC8 effective routing. Probably programmer's fault\n");
	}
	Logging::diag("Looking for effective routing in prod_grp for tech LBC8 on device $device");
	my $eff_routing = $routing;
	if ($routing =~ m/DCU/){
		$eff_routing .= "-".substr($device,4,4);
		if ($prod_grp =~ m/\-([SDTQP67]LM)/){
			my $xlm = $1;
			my $num_metal = 1;
			$num_metal = 2 if ($xlm =~ /DLM/);
			$num_metal = 3 if ($xlm =~ /TLM/);
			$num_metal = 4 if ($xlm =~ /QLM/);
			$num_metal = 5 if ($xlm =~ /PLM/);
			$num_metal = 6 if ($xlm =~ /6LM/);
			$num_metal = 7 if ($xlm =~ /7LM/);
			$eff_routing .= '-' . $num_metal;
		}else{
			confess("Unable to get number of metal levels for effective routing from " . Dumper($rec) . "\n");
		}
	}
	return $eff_routing;
}

sub make_effective_routing_F05{
	my ($rec) = @_;
	my $strategy = $rec->{"FE_STRATEGY"};	
	my $routing = $rec->{"ROUTING"};
	unless (defined $strategy && defined $routing){
		confess("Missing crucial information to generate F05 effective routing.  Probably programmer's fault\n");
	}
	Logging::diag("looking for metal levels in fe_strategy for F05 device" . $rec->{"DEVICE"});
	my $eff_routing = $routing;
	if ($strategy =~ m/X(\d)L/){
		$eff_routing .= "-$1";
	}else{
		confess("Unable to get number of metal levels for effective routing from " . Dumper($rec) . "\n");
	}
	return $eff_routing;
}

1;
