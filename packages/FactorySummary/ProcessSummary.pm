package ProcessSummary;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use SMS::SMSDigest;

my $f_summary_records_for_parameter_sth;
my $factory_summary_table = "f_summary";

sub process_f_summary_for_tech{
    my ($tech) = @_;
    eval{
        my $effective_routings = SMSDigest::get_all_effective_routings_in_tech($tech);
        my $conn = Connect::read_only_connection('etest');

    






        1;
    } or do {

    }
}

# returns array of hash-refs for records on parameter/tech.  Keys in hashref are all uppercase
sub get_f_summary_records_for_parameter{
    my ($tech, $parameter) = @_;
    my $sth = get_f_summary_records_for_parameter_sth();
    $sth->execute($tech, $parameter);
    my @records;
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        push @records, $rec;
    }
    return \@records;
}

sub get_f_summary_records_for_parameter_sth{
    unless (defined $f_summary_records_for_parameter_sth){
        my $conn = Connect::read_only_connection('etest');
        my $sql = qq{
            select 
                * 
            from 
                $factory_summary_table
            where 
                technology = ?
                and etest_name = ?
        };
        $f_summary_records_for_parameter_sth = $conn->prepare($sql);
    }
    unless (defined $f_summary_records_for_parameter_sth){     
        confess "could not get f_summary_records_for_parameter_sth";
    }
    return $f_summary_records_for_parameter_sth;
}


sub process_f_summary_record{
    my ($record) = @_;

}


1;
