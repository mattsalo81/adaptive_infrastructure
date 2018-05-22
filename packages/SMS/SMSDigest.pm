package SMSDigest;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Database::Connect;
use Logging;

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

sub get_all_active_devices{
    my $sql = q{select distinct device from daily_wip_extract};
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute() or confess "Could not get list of active devices from daily_wip_extract";
    my $devices = $sth->fetchall_arrayref();
    my @devices = map{$_->[0]} @{$devices};
    return \@devices
}

1;
