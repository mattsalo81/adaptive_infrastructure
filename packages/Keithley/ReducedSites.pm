package Keithley::ReducedSites;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $io_sth;
my %uses_inner;

# returns true if technology uses inner five sites
# returns false if technology uses outer five sites
# dies otherwise
sub uses_inner_five_sites{
    my ($technology) = @_;
    unless (defined $uses_inner{$technology}){
        my $sth = get_io_sth();
        $sth->execute($technology);
        my $rec = $sth->fetchrow_arrayref();
        unless(defined $rec){
            confess "Technology <$technology> does not have a setting for INNER/OUTER five sites!";
        }
        my $io = $rec->[0];
        if ($io eq "INNER"){
            $uses_inner{$technology} = 1;
        }elsif ($io eq "OUTER"){
            $uses_inner{$technology} = 0;
        }else{
            confess "Unexpected INNER/OUTER value <$io> for technology <$technology>";
        }
    }
    return $uses_inner{$technology};
}

sub get_io_sth{
    unless (defined $io_sth){
        my $conn = Connect::read_only_connection('etest');
        my $sql = q{
            select
                five_site_preference
            from
                technology_5_site
            where
                technology = ?
        };
        $io_sth = $conn->prepare($sql);
    }
    unless (defined $io_sth){
        confess "Could not get io_sth";
    }
    return $io_sth;
}

1;
