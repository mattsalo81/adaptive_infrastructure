use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my ($tech, $csv) = @ARGV;

my $usage = qq{

    Usage :     $0 <TECHNOLOGY> <COMP2BIT.csv>

    Synchronizes current technology bit mapping to provided csv

};

die $usage unless ((defined $tech) && (defined $csv));

# /dm5pde_webdata/dm5pde/adaptive_test/lbc5/lbc5_component_2_bit_v3.csv

open my $fh, $csv or die "could not open <$csv>";
my $trans = Connect::new_transaction('etest');
my $sth = $trans->prepare("delete from component_to_bit where technology = ?");
$sth->execute($tech);
$sth = $trans->prepare("insert into component_to_bit (technology, component, bit) values (?, ?, ?)");

my $header = <$fh>;
while (my $line = <$fh>){
    chomp $line;
    $line =~ s/\s//g;
    my ($comp, $bit) = split /,/, $line;
    $sth->execute($tech, $comp, $bit);
}
$trans->commit();
