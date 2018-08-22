package Keithley::AutoZ;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $autoz_sth;

sub is_autoz_module{
    my ($technology, $test_area, $test_module) = @_;
    my $sth = get_autoz_sth();
    $sth->execute($technology, $test_area, $test_module);
    my $records = $sth->fetchall_arrayref();
    return (scalar @{$records} > 0);
}

sub get_autoz_sth{
    unless (defined $autoz_sth){
        my $conn = Connect::read_only_connection('etest');
        my $sql = q{
            select
                test_module
            from
                autoz_modules
            where
                technology = ?
                and test_area = ?
                and test_module = ?
        };
        $autoz_sth = $conn->prepare($sql);
    }
    unless (defined $autoz_sth){
        confess "could not get autoz_sth";
    }
    return $autoz_sth;
}

1;
