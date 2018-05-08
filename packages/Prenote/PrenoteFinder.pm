package PrenoteFinder;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $prenote_from_pde_db_sth;
my $prenote_from_etest_db_sth;
my $prenote_base_dir = '/dm5pde_webdata/dm5pde/setup';


sub find_prenotes_for_device{
    my ($device) = @_;
    unless (-d $prenote_base_dir){
        confess "check configuration for the setup directory.  I cannot find prenotes in <$prenote_base_dir>";
    }
    
    my %prenotes;
    my $pde_notes = get_prenote_from_pde_db($device);
    Logging::diag("prenotes from pde : " . join(", ", @{$pde_notes}));
    my $etest_notes = get_prenote_from_etest_db($device);
    Logging::diag("prenotes from etest : " . join(", ", @{$etest_notes}));
    
    @prenotes{@{$pde_notes}} = "PDE" x scalar @{$pde_notes};	
    @prenotes{@{$etest_notes}} = "ETEST" x scalar @{$etest_notes};	
    
    my %folders;
    foreach my $prenote (keys %prenotes){
        my $prenote_lc = $prenote;
        $prenote_lc =~ tr/A-Z/a-z/;
        my $prenote_dir = "$prenote_base_dir/$prenote_lc";
        if (-d "$prenote_dir"){
            $folders{$prenote_dir} = $prenotes{$prenote};
        }
    }

    Logging::diag("Found prenote dirs with sources : " . Dumper(\%folders));
    return \%folders;
    
}

sub get_prenote_from_pde_db{
    my ($device) = @_;
    my $sth = get_prenote_from_pde_db_sth();
    $sth->execute($device);
    my $rows = $sth->fetchall_arrayref();
    my @prenotes = map {$_->[0]} @{$rows};
    return \@prenotes;
}

sub get_prenote_from_pde_db_sth{
    unless(defined $prenote_from_pde_db_sth){
        my $sql = q{select distinct device from devsetup_list where sms_dev = ?};
        my $conn = Connect::read_only_connection("pde");
        $prenote_from_pde_db_sth = $conn->prepare($sql);
    }
    unless(defined $prenote_from_pde_db_sth){
        confess "could not get prenote_from_pde_db_sth";
    }
    return $prenote_from_pde_db_sth;
}

sub get_prenote_from_etest_db{
    my ($device) = @_;
    my $sth = get_prenote_from_etest_db_sth();
    $sth->execute($device);
    my $rows = $sth->fetchall_arrayref();
    my @prenotes = map {$_->[0]} @{$rows};
    return \@prenotes;
}

sub get_prenote_from_etest_db_sth{
    unless(defined $prenote_from_etest_db_sth){
        my $sql = q{select distinct prenote from device_to_prenote_manual where device = ?};
        my $conn = Connect::read_only_connection("etest");
        $prenote_from_etest_db_sth = $conn->prepare($sql);
    }
    unless(defined $prenote_from_etest_db_sth){
        confess "could not get prenote_from_etest_db_sth";
    }
    return $prenote_from_etest_db_sth;
}

1;

