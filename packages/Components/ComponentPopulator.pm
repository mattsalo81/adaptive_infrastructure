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

sub update_components{
	foreach my $tech (@{SMSDigest::get_all_technologies()}){
		update_components_for_tech($tech);
	}
}

sub update_components_for_tech{
	my ($tech) = @_;
	my $table = "raw_component_info";
	my $trans = Connect::new_transaction("etest");
	Logging::event("Updating raw components for $tech devices");
	eval{
		# get delete sth
		my $del_sql = qq{delete from $table where device = ?};
		my $del_sth = $trans->prepare($del_sql);
		# get ins sth
		my $ins_sql = qq{insert into $table (technology, device, component, manual) values (?, ?, ?, ?)};
		my $ins_sth = $trans->prepare($ins_sql);
		# delete + insert
		foreach my $device (@{SMSDigest::get_all_devices_in_tech($tech)}){
			Logging::debug("Processing raw components for $device");
			$del_sth->execute($device);
			my $components = ComponentFinder::get_all_components_for_device($device);
			foreach my $comp (keys %{$components}){
				$ins_sth->execute($tech, $device, $comp, $components->{$comp});
			}
		}
		$trans->commit();
		1;
	} or do {
		my $e = $@;
		$trans->rollback();
		confess "Could not update components for $tech devices because :\n $e";
	}	
}




1;
