package connection_info;
use warnings;
use strict;
use Carp;

my %connection_info = (
	sms		=>	['DBI:Oracle:SMSDWDE2','rptfw','rptfw'],
	sd_limits	=>	['DBI:Oracle:D5PDEDB','sd_limits','limpara'],
);


sub get_info_for{
	my ($name) = @_;
	my $info = $connection_info{$name};
	if (defined $info){
		return @{$info};
	}
	confess "Could not find connection information for <$name>\n";
}

1;
