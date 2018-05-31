package FMEA;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $fmea_comps_sth;

sub get_fmea_comps{
    my ($tech) = @_;
    Logging::debug("Fetching FMEA components for $tech");
    my $sth = get_fmea_comps_sth();
    $sth->execute($tech);
    my $records = $sth->fetchall_arrayref();
    my @fmea = map {$_->[0]} @{$records};
    return \@fmea;
}

sub get_fmea_comps_sth{
    unless (defined $fmea_comps_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select 
               component
            from
                fmea_components
            where
                technology = ? 
            order by component
        };
        $fmea_comps_sth = $conn->prepare($sql);
    }
    unless (defined $fmea_comps_sth){
        confess "Could not get fmean_comps_sth";
    }
    return $fmea_comps_sth;
}


1;
