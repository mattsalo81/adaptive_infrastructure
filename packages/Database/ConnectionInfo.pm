package ConnectionInfo;
use warnings;
use strict;
use Carp;

# contains all information necessary for logging into a database
# originally used Mark's SWAT::DATABASE but had issues with testware's TNSNAMES.ORA.

my %connection_info = (
    sms		=>	['DBI:Oracle:SMSDWDE2','rptfw','rptfw'],
    sd_limits	=>	['DBI:Oracle:D5PDEDB','sd_limits','limpara'],
    etest		=>	['DBI:Oracle:D5PDEDB','etest','DM5etest'],
    #wcrepo		=>	['DBI:Oracle://lepftds.itg.ti.com:1521','PTWAFER_RO','3fL5ug9ZPP6dY9u4'],
    wcrepo		=>	['DBI:Oracle://lepftds.itg.ti.com:1521','PTWAFER_RO','Z0YF8mZmJS5Xos9t'],
    onepg_staging	=>	['DBI:Oracle://lesonepg.itg.ti.com:1521', 'RO_DM5PARA', 'i9WPkrlUVD3p'],
    onepg		=>	['DBI:Oracle://leponepg.itg.ti.com:1521', 'RO_DM5PARA', '1Adaptive!'],
    # soon - missing table access
    # wcrepo	=>	['DBI:Oracle://lepftds.itg.ti.com:1521','DM5ETEST','1Adaptive'],
    pde		=>	['DBI:Oracle:D5PDEDB', 'sd_pde', 'sitepde'],
);

sub get_info_for{
    my ($name) = @_;
    my $info = $connection_info{$name};
    if (defined $info){
        return @{$info};
    }
    confess "Could not find connection information for <$name>\n";
}

1;
