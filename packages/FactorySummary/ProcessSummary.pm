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

    # determine if limits should be set at the technology level or at the effective routing level
    if (scalar @{$records} == 1){
        # TECHNOLOGY LEVEL LIMIT -> just copy the F report records to the limits_db nearly as is
        # create a limit record
        my $record = $records->[0];
        my $limit = copy_f_summary_to_limit_record($record);
        $limit->{"ITEM_TYPE"} = "TECHNOLOGY";
        $limit->{"ITEM"} = $limit->{"TECHNOLOGY"};
        # create unique record for each test area
        foreach my $area (keys %test_areas){
            my %limit = %{$limit};
            $limit{"TEST_AREA"} = $area;
            push @limit_records, \%limit;
        }
    }else{
        # DEVICE LEVEL LIMIT -> Create a dummy technology level limit and add effective Routing override copies.
        # create a technology limit record
        my $record = $records->[0];
        my %limit = (
            TECHNOLOGY => $record->{"TECHNOLOGY"},
            ITEM_TYPE => "TECHNOLOGY",
            ITEM => $record->{"TECHNOLOGY"},
        );
        # create unique record for each test area
        foreach my $area (keys %test_areas){
            my %generic_limit = %limit;
            $generic_limit{"TEST_AREA"} = $area;
            push @limit_records, \%generic_limit;
        }
    }
    my @functional_eff_rout;
    return (\@functional_eff_rout, \@limit_records);
}

sub which_f_summary_records_match_sms_digest{
    my ($summary_record, $digest) = @_;
    
}

sub does_f_summary_record_match_effective_routing{
    my ($f_summary_record, $effective_routing) = @_;
    my $requirements = $f_summary_record->{"PROCESS_OPTIONS"};
    unless(defined $requirements){
        confess "Could not extract process options requirements from record";
    }
    

}


sub copy_f_summary_to_limit_record{
    my ($record) = @_;
    my %limit;
    my @copy_fields = qw(Technology etest_name deactivate sampling_rate dispo pass_criteria_percent);
    push @copy_fields, qw(reprobe_map dispo_rule spec_upper spec_lower reverse_spec_limit);
    push @copy_fields, qw(reliability reliability_upper reliability_lower reverse_reliability_limit);
    foreach my $field (@copy_fields){
        $field =~ tr/[a-z]/[A-Z]/;
        $limit{$field} = $record->{$field};
    }
    return \%limit;
}

1;
