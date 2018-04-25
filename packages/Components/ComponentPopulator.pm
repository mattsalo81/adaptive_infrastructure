package ComponentPopulator;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Components::ComponentFinder;
use Database::Connect;
use SMS::SMSDigest;
#	my $devices = SMSDigest::get_all_devices();

sub update_components_for_tech{
	my ($tech) = @_;
	my $table = "raw_component_info";
	my $trans = Connect::new_transaction("etest");
	eval{
		# get delete sth
		my $del_sql = q{delete from $table where device = ?};
		my $del_sth = $trans->prepare($del_sql);
		# get ins sth
		my $ins_sql = q{insert into $table (device, component, manual) values (?, ?, ?)};
		my $ins_sth = $trans->prepare($ins_sql);

	} or do {

	}	


}


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
