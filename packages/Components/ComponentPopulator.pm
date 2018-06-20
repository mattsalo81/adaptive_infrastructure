package ComponentPopulator;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Components::ComponentFinder;
use Components::EffectiveComponents;
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

# updates all technologies
sub update_effective_component_info{
    my $techs = SMSDigest::get_all_technologies();
    my %unsatisfied;
    foreach my $tech (@{$techs}){
        my $unsatisfied = update_effective_components_for_tech($tech);
        $unsatisfied{$tech} = $unsatisfied;
    }
    foreach my $tech (keys %unsatisfied){
        my $num_prog = $unsatisfied{$tech};
        warn "$tech has $num_prog unsatisfied program" . ($num_prog == 1 ? "" : "s") . "\n";
    }
}



# pulls all devices/programs for technology
# looks at all the device's component info, (and fmea parameters), then generates program level component lists
# will not populate a program's component list if any devices are missing component information
# returns number of programs without component information
sub update_effective_components_for_tech{
    my ($tech) = @_;
    my $trans = Connect::new_transaction("etest");
    my $unsatisfied = 0;
    eval{
        clear_effective_components_table_for_tech($trans, $tech);
        my $spec_info = SMSDigest::get_entries_for_tech($tech);
        my $ins_sth = get_insert_effective_components_table_sth($trans);
        my %prog2dev;
        foreach my $record (@$spec_info){
            my $prog = $record->{"PROGRAM"};
            my $dev = $record->{"DEVICE"};
            confess "Program not defined in spec_info table" unless defined $prog;
            confess "Device not defined in spec_info table" unless defined $dev;
            $prog2dev{$prog} = {} unless defined $prog2dev{$prog};
            $prog2dev{$prog}->{$dev} = "yep";
        }
        foreach my $prog (keys %prog2dev){
            my @devices = keys %{$prog2dev{$prog}};
            my $comps = EffectiveComponents::generate_effective_components_for_devices($tech, \@devices);
            if (scalar @{$comps} == 0){
                $unsatisfied++;
            }
            foreach my $comp (@{$comps}){
                $ins_sth->execute($tech, $prog, $comp);
            }
        }
        $trans->commit();
        1;
    } or do {
        my $e = $@;
        $trans->rollback();
        confess "Could not updated effective components for $tech because : $e";
    };
    return $unsatisfied;
}

sub clear_effective_components_table_for_tech{
    my ($trans, $tech) = @_;
    my $sql = q{
        delete from effective_component_info
        where technology = ?
    };
    my $sth = $trans->prepare($sql);
    $sth->execute($tech);
}

sub get_insert_effective_components_table_sth{
    my ($trans) = @_;
    my $sql = q{
        insert into effective_component_info
        (technology, program, component) values
        (?, ?, ?)
    };
    my $sth = $trans->prepare($sql);
    return $sth;
}


1;
