package ProcessSummary;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use SMS::SMSDigest;
use LimitDatabase::LimitRecord;

my $f_summary_records_for_parameter_sth;
my $factory_summary_table = "f_summary";


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

# sth getter
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

# takes 
#               arrayref of hashrefs for a particular parameter from the f_summary
#               an arrayref of hashrefs from the SMS digest (Needs at least EFFECTIVE_ROUTING and AREA)
# returns array of 
#               arrayref of hashref of matching effective_routings->[test_areas,matched]
#               arrayref of records to add to limitsdb)
sub process_f_summary_parameter_records{
    my ($records, $digest_records) = @_;
    my @limit_records;

    # handle missing records
    if (scalar @{$records} == 0){
        confess "No records from f_summary to process";
    }
    
    # get unique list of test areas->effective_routings from digest_records
    my %test_areas;
    foreach my $sms (@{$digest_records}){
        my $area = $sms->{"AREA"};
        my $effective_routing = $sms->{"EFFECTIVE_ROUTING"};
        unless (defined $area){
            confess "Found an SMS record without a test area";
        }
        unless (defined $effective_routing){
            confess "Found an SMS record without an effective routing";
        }
        unless (defined $test_areas{$area}){
            $test_areas{$area} = {}
        }
        $test_areas{$area}->{$effective_routing} = "yep";
    }

    # create the technology level record
    my $tech_rec = LimitRecord->new_copy_from_f_summary($records->[0]);
    $tech_rec->set_item_type('TECHNOLOGY', $tech_rec->get('TECHNOLOGY'));
    if(scalar @{$records} > 1){
        # records will be set at the effective routing, so dummy this one
        $tech_rec->dummify();
    }
    # create duplicate records for each test area
    push @limit_records, @{$tech_rec->create_copies_at_each_area([keys %test_areas])};
    #if(scalar @{$records}





    my @functional_eff_rout;
    return (\@functional_eff_rout, \@limit_records);
}

sub does_f_summary_record_match_effective_routing_options{
    my ($f_summary_record, $effective_routing) = @_;
    my $requirements = $f_summary_record->{"PROCESS_OPTIONS"};
    unless(defined $requirements){
        confess "Could not extract process options requirements from record";
    }
     

}



1;
