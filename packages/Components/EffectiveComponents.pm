package EffectiveComponents;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Components::FMEA;
use SMS::SMSDigest;

# for populating and retreiving effective component information
# includes FMEA parameters in information
my $components_for_device_sth;
my $program_has_components_sth;
my $components_sth;


# generates a merged list of components for a list of devices, and adds in the fmea components
# returns empty list if any devices do not have component information
sub generate_effective_components_for_devices{
    my ($technology, $devices) = @_;
    my $comps = generate_merged_component_list_for_devices($technology, $devices);
    if(scalar @{$comps} == 0){
        return [];
    }else{
        my $fmea = FMEA::get_fmea_comps($technology);
        my %uniq;
        @uniq{@{$comps}} = @{$comps};
        @uniq{@{$fmea}} = @{$fmea};
        my @eff_comps = keys %uniq;
        return \@eff_comps;
    }
}

# generate a merged list of components for a list of devices (from device_component_info)
# returns empty list if any devices do not have component information
sub generate_merged_component_list_for_devices{
    my($technology, $devices) = @_;
    my %effective_components;
    my $have_comps = undef;
    foreach my $device (@{$devices}){
        $have_comps = 1 unless defined $have_comps;
        my $comps = get_components_for_device($technology, $device);
        if (scalar @{$comps} == 0){
            Logging::debug("Device $device has no components associated with it");
            $have_comps = 0;
        }
        @effective_components{@{$comps}} = @{$comps};
    }
    if (not defined $have_comps or $have_comps == 0){
        return [];
    }  
    my @uniq = keys %effective_components;
    return \@uniq;
}

sub get_components_for_device{
    my ($tech, $dev) = @_;
    my $sth = get_components_for_device_sth();
    $sth->execute($tech, $dev);
    my $rows = $sth->fetchall_arrayref();
    my @components = map {$_->[0]} @{$rows};
    return \@components;
}

sub get_components_for_device_sth{
    unless (defined $components_for_device_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select 
                component
            from
                device_component_info
            where
                technology = ?
                and device = ?
        };
        $components_for_device_sth = $conn->prepare($sql);
    }
    unless (defined $components_for_device_sth){
        confess "Could not get components_for_device_sth";
    }
    return $components_for_device_sth;
}

sub get_number_components_on_program{
    my ($technology, $program) = @_;
    my $sth = get_program_has_components_sth();
    $sth->execute($technology, $program);
    # return first value of first record
    return $sth->fetchrow_arrayref()->[0];
}

sub get_program_has_components_sth{
    unless (defined $program_has_components_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select
                count(component)
            from
                effective_component_info
            where
                TECHNOLOGY = ?
                and program = ?
        };
        $program_has_components_sth = $conn->prepare($sql);
    }
    unless (defined $program_has_components_sth){
        confess "could not get program_has_components_sth";
    }
    return $program_has_components_sth;
}

sub get_effective_components{
    my ($tech, $program) = @_;
    my $sth = get_components_sth();
    $sth->execute($tech, $program);
    my $rows = $sth->fetchall_arrayref();
    my @components = map {$_->[0]} @{$rows};
    return \@components;
}

sub get_components_sth{
    unless (defined $components_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select 
                component
            from
                effective_component_info
            where
                technology = ?
                and program = ?
        };
        $components_sth = $conn->prepare($sql);
    }
    unless (defined $components_sth){
        confess "Could not get components sth";
    }
    return $components_sth;
}

1;
