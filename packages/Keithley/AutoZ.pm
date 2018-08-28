package Keithley::AutoZ;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $autoz_sth;
my %autoz_mod;

sub is_autoz_module_sms_rec{
    my ($sms_rec, $test_module) = @_;
    my $tech = $sms_rec->get("TECHNOLOGY");
    my $area = $sms_rec->get("AREA");
    return is_autoz_module($tech, $area, $test_module);
}

sub is_autoz_module{
    my ($technology, $test_area, $test_module) = @_;
    my $key = "$technology  $test_area  $test_module";
    unless(defined $autoz_mod{$key}){
        $autoz_mod{$key} = _is_autoz_module($technology, $test_area, $test_module);
    }
    return $autoz_mod{$key};
}

sub _is_autoz_module{
    my ($technology, $test_area, $test_module) = @_;
    my $sth = get_autoz_sth();
    $sth->execute($technology, $test_area, $test_module);
    my $rec = $sth->fetchrow_arrayref();
    unless(defined $rec){
        confess "Alignment module <$test_module> for <$technology> at <$test_area> is not defined in database";
    }
    my $autoz = $rec->[0];
    return 1 if $autoz eq 'Y';
    return 0 if $autoz eq 'N';
    confess "unexpected autoz value <$autoz> (expect 'Y'/'N')";
}

sub get_autoz_sth{
    unless (defined $autoz_sth){
        my $conn = Connect::read_only_connection('etest');
        my $sql = q{
            select
                autoz
            from
                alignment_modules
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
