package Bits;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Components::ComponentXref;

my $bits_sth;
my $undefined_sth;
our $no_comp_error = "Device does not have any components in the database";
our $not_associated_error = "The following components are not associated to a bit: ";

sub get_bits_for_device{
    my ($technology, $device) = @_;
    Logging::event("Getting Component bits for device $device");
    
    # check that device has components
    my $num_comps = ComponentXref::get_number_components_on_device($technology, $device);
    if ($num_comps == 0){
        confess "$no_comp_error";
    }
    # check that all components are associated to a bit
    my $unresolved = get_undefined_components_on_device($technology, $device);
    if(scalar @{$unresolved} > 0){
        confess "$not_associated_error <" . join(", ", @{$unresolved}) . ">\n";
    }

    # get bits
    my $sth = get_bits_sth();
    $sth->execute($technology, $device);
    my $records = $sth->fetchall_arrayref();
    my @dirty_bits = map {$_->[0]} @{$records};

    # remove negative + 0 bits
    my $clean_bits = remove_zero_or_negative_bits(\@dirty_bits);

    return $clean_bits;
}

sub remove_zero_or_negative_bits{
    my ($bits) = @_;
    my @clean_bits = map {$_ > 0 ? ($_) : ()} @{$bits};
    return \@clean_bits;
}

sub get_undefined_components_on_device{
    my ($technology, $device) = @_;
    my $sth = get_undefined_sth();
    $sth->execute($technology, $device); 
    my $records = $sth->fetchall_arrayref();
    my @components = map {$_->[0]} @{$records};
    return \@components;
}

sub get_bits_sth{
    unless (defined $bits_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct
                c2b.bit
            from
                component_info ci
                inner join component_to_bit c2b
                    on  c2b.technology = ci.technology
                    and c2b.component = ci.component
            where
                ci.technology = ?
                and ci.device = ?
            order by c2b.bit
        };
        $bits_sth = $conn->prepare($sql);
    }
    unless (defined $bits_sth){
        confess "could not get bits_sth";
    }
    return $bits_sth;
}


sub get_undefined_sth{
    unless (defined $undefined_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct
                ci.component
            from 
                component_info ci
            where
                ci.technology = ?
                and ci.device = ?
                and ci.component not in(
                    select distinct
                        c2b.component
                    from 
                        component_to_bit c2b
                    where
                        c2b.technology = ci.technology
                )
                
        };
        $undefined_sth = $conn->prepare($sql);
    }
    unless (defined $undefined_sth){
        confess "could not get undefined_sth";
    }
    return $undefined_sth;
}


1;
