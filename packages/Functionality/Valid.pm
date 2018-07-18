package Functionality::Valid;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use Data::Dumper;

my $check_coordref_sth;

sub check_coordref{
    my ($tech, $coordref) = @_;
    Logging::diag("Checking if coordref <$coordref> is defined on tech <$tech>");
    my $sth = get_check_coordref_sth();
    $sth->execute($tech, $coordref);
    my $results = $sth->fetchall_arrayref();
    return scalar @{$results};
}

sub get_check_coordref_sth{
    unless (defined $check_coordref_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct
                s.coordref
            from       
                scribes s
            where
                s.technology = ?
                and s.coordref = ?
        };
        $check_coordref_sth = $conn->prepare($sql);
    }
    unless (defined $check_coordref_sth){
        confess "could not prepare check_coordref_sth";
    }
    return $check_coordref_sth;
}


my $check_test_group_sth;

# checks if test group is defined in collectible/functional table
sub check_test_group{
    my ($technology, $test_group) = @_;
    Logging::diag("Checking if group <$test_group> is valid on <$technology>");
    my $sth = get_check_test_group_sth();
    $sth->execute($technology, $test_group);
    my $results = $sth->fetchall_arrayref();
    return scalar @{$results};
}

sub get_check_test_group_sth{
    unless (defined $check_test_group_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct
                tc.test_group
            from 
                test_collectible tc
                inner join test_functional tf
                    on tf.technology = tc.technology
                    and tf.test_mod = tc.test_mod
            where
                tc.technology = ?
                and tc.test_group = ? 
        };
        $check_test_group_sth = $conn->prepare($sql);
    }
    unless (defined $check_test_group_sth){
        confess "Could not get check_test_group_sth";
    }
    return $check_test_group_sth;
}

1;
