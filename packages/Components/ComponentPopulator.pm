package ComponentPopulator;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Components::ComponentFinder;
use Database::Connect;

sub update_raw_components_for_device{
	my ($device) = @_;
	my $conn = Connect::read_only_connection("etest");
	my $dev_sql = q{select distinct device from daily_sms_extract};	
	my $dev
}

q
sub update_codes_for_all_techs{
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{select distinct technology from daily_sms_extract};
        my $sth = $conn->prepare($sql);
        $sth->execute() or confess "Could not get list of technologies from daily_sms_extract";
        my $techs = $sth->fetchall_arrayref();
        my @techs = map{$_->[0]} @{$techs};
        foreach my $tech (@techs){
                eval{
                        update_codes_for_tech($tech);
                        Logging::event("Updated $tech process encoding");
                        1;
                } or do {
                        my $e = $@;
                        Logging::error("Could not update $tech process encoding because of : $e");
                }
        }
}




1;
