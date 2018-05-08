package Reticles;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $chips_for_reticle_base_sth;

my %first_character_code_photomask = (
        D  => '6401',
        E  => '6408',
        A  => '6408',
        N  => '6408',
        8  => '6408',
        7  => '6408',
        '' => '6401',
);

sub convert_photomask_to_reticle{
    my ($mask) = @_;
    $mask =~ s/\s//g;
    $mask =~ s/\-//;
    if ($mask !~ m/^[A-Z]?[0-9]+$/){
        confess "Unexpected photomask format";
    }
    # convert first character
    foreach my $char (reverse sort keys %first_character_code_photomask){
        my $code = $first_character_code_photomask{$char};
        last if ($mask =~ s/^$char/$code/);
    }	
    return $mask;
}

sub get_chips_for_reticle_base{
        my ($base) = @_;
        my $sth = get_chips_for_reticle_base_sth();
        $sth->execute($base) or confess "Could not get components for reticle base $base";
        my $rows = $sth->fetchall_arrayref();
        my @comps = map {$_->[0]} @{$rows};
        return \@comps;
}

sub get_chips_for_reticle_base_sth{
        unless (defined $chips_for_reticle_base_sth){
                my $sql = q{
                        select distinct
                                C.NAME
                        from
                                RONADMIN.reticles R
                                INNER JOIN RONADMIN.CHIPS_RETICLES CR
                                        on  CR.reticle_id = R.id
                                INNER JOIN RONADMIN.PG_SOURCES PGS
                                        on  CR.pg_source_id = PGS.id
                                INNER JOIN RONADMIN.chips c
                                        on  C.id = PGS.chip_id
                        where r.reticle_base = ?
                };
                my $conn = Connect::read_only_connection("onepg");
                $chips_for_reticle_base_sth = $conn->prepare($sql);
        }
        unless (defined $chips_for_reticle_base_sth){
                confess "Could not get chips_for_reticle_base_sth";
        };
        return $chips_for_reticle_base_sth;
}


1;
