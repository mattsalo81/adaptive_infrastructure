package SMSDigest;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Database::Connect;
use Logging;

sub get_all_records{
    my $sql = q{select * from daily_sms_extract};
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute() or confess "Could not get the daily_sms_extract";
    my @records;
    while (my $rec = $sth->fetchrow_hashref("NAME_uc")){
        push @records, $rec;
    }
    return \@records;
}

sub get_entries_for_tech{
    my ($tech) = @_;
    my $sql = q{select * from daily_sms_extract where technology = ?}; 
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute($tech) or confess "Could not get all records from daily_sms_extract for tech $tech";
    my @records;
    while (my $rec = $sth->fetchrow_hashref("NAME_uc")){
        push @records, $rec;
    }
    return \@records;
}

sub get_all_technologies{
    my $sql = q{select distinct technology from daily_sms_extract};
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute() or confess "Could not get list of technologies from daily_sms_extract";
    my $techs = $sth->fetchall_arrayref();
    my @techs = map{$_->[0]} @{$techs};
    return \@techs
}

sub get_all_devices_in_tech{
    my ($tech) = @_;
    my $sql = q{select distinct device from daily_sms_extract where technology = ?};
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute($tech) or confess "Could not get list of devices for $tech from daily_sms_extract";
    my $devices = $sth->fetchall_arrayref();
    my @devices = map{$_->[0]} @{$devices};
    return \@devices
}

sub get_all_effective_routings_in_tech{
    my ($tech) = @_;
    my $sql = q{select distinct effective_routing from daily_sms_extract where technology = ?};
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute($tech) or confess "Could not get list of effective_routing for $tech from daily_sms_extract";
    my $eff_rout = $sth->fetchall_arrayref();
    my @eff_rout = map{$_->[0]} @{$eff_rout};
    return \@eff_rout;
}

sub get_all_devices{
    my $sql = q{select distinct device from daily_sms_extract};
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute() or confess "Could not get list of devices from daily_sms_extract";
    my $devices = $sth->fetchall_arrayref();
    my @devices = map{$_->[0]} @{$devices};
    return \@devices
}

sub get_all_active_devices_in_tech{
    my $sql = q{
        select distinct 
            s.device 
        from 
            daily_sms_extract s
        where
            s.device in (select distinct device from daily_wip_extract)
    };
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute() or confess "Could not get list of active devices from daily_wip_extract";
    my $devices = $sth->fetchall_arrayref();
    my @devices = map{$_->[0]} @{$devices};
    return \@devices
}

sub get_all_devices_for_prog{
    my ($technology, $program) = @_;
    my $sql = q{
        select distinct
            s.device
        from 
            daily_sms_extract s
        where
            s.technology = ?
            and s.program = ?
    };
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute($technology, $program) or confess "Could not get list of devices for program";
    my $devices = $sth->fetchall_arrayref();
    my @devices = map{$_->[0]} @{$devices};
    return \@devices
}

sub get_all_active_devices{
    my $sql = q{select distinct device from daily_wip_extract};
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute() or confess "Could not get list of active devices from daily_wip_extract";
    my $devices = $sth->fetchall_arrayref();
    my @devices = map{$_->[0]} @{$devices};
    return \@devices
}

sub convert_sms_records_into_area_to_effective_routing_lookup{
    my ($sms_records) = @_;
    my %lookup;
    # build a unique list of all effecitve routing and test area combinations
    foreach my $rec (@{$sms_records}){
        my $area = $rec->{"AREA"};
        my $effective_routing = $rec->{"EFFECTIVE_ROUTING"};
        unless (defined $area){
            confess "Could not extract area from record";
        }
        unless (defined $effective_routing){
            confess "Could not extract effective routing from record";
        }
        $lookup{$area} = {} unless scalar keys %{$lookup{$area}};
        $lookup{$area}->{$effective_routing} = "yep";
    }
    # return a simplified list of test areas to effective routings
    my %area_to_routings;
    foreach my $area (keys %lookup){
        $area_to_routings{$area} = [keys %{$lookup{$area}}];
    }
    return \%area_to_routings;
}


1;
