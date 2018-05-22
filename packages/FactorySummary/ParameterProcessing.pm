package ParameterProcessing;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use LimitDatabase::LimitRecord;
use Parse::BooleanExpression;

# this package is meant to process a block of f-summary records for a particular technology/parameter against SMS records from the digest
# process_f_summary_parameter_records will return the functional parameters and the entries for the limitsdb



# takes 
#               arrayref of hashrefs for a particular parameter from the f_summary
#               arrayref of sms records (hashref, NAME_uc) from the daily_sms_extract
# returns array of 
#               arrayref of hashref of {'EFFECTIVE ROUTING', 'TEST_AREA', 'TECHNOLOGY', 'PARAMETER'}
#               arrayref of records to add to limitsdb
sub process_f_summary_parameter_records{
    my @args = @_;
    my $lambda = \&does_f_summary_record_match_effective_routing_options;
    return _process_f_summary_parameter_records(@args, $lambda);
}

# main body of expression, takes a lambda function to decouple testing from the process option DB
sub _process_f_summary_parameter_records{
    my ($records, $sms_extracts, $check_match_lambda) = @_;
    my @limit_records;
    my @functional_eff_rout;

    # handle missing records
    if (scalar @{$records} == 0){
        confess "No records from f_summary to process";
    }
    
    # extract technology
    my $technology = $records->[0]->{"TECHNOLOGY"};
    unless (defined $technology){
        confess "Could not extract TECHNOLOGY from first record of f_summary records";
    }
    # extract parameter name
    my $parameter = $records->[0]->{"ETEST_NAME"};
    unless (defined $parameter){
        confess "Could not extract PARAMETER from first record of f_summary records";
    }
   
    # get test area data structure 
    my $test_areas = convert_sms_records_into_area_to_effective_routing_lookup($sms_extracts);    

    # create the technology level record
    my $tech_rec = LimitRecord->new_copy_from_f_summary($records->[0]);
    $tech_rec->set_item_type('TECHNOLOGY', $tech_rec->get('TECHNOLOGY'));
    if(scalar @{$records} > 1){
        # records will be set at the effective routing, so dummy this one
        $tech_rec->dummify();
    }
    # create duplicate records for each test area
    push @limit_records, @{$tech_rec->create_copies_at_each_area([keys %{$test_areas}])};

    # determine which routings are functional
    my @effective_routing_limits;
    foreach my $area (keys %{$test_areas}){
        foreach my $eff_rout (@{$test_areas->{$area}}){
            my @matching_records;
            my $functional;
            foreach my $record (@{$records}){
                #if (does_f_summary_record_match_effective_routing_options($eff_rout, $record)){
                if ($check_match_lambda->($eff_rout, $record)){
                    # flag the parameter as functional at a certain area
                    $functional = {
                        EFFECTIVE_ROUTING     =>        $eff_rout,
                        TEST_AREA             =>        $area,
                        TECHNOLOGY            =>        $technology,
                        ETEST_NAME            =>        $parameter,
                    };
                    
                    # store record as matching
                    push @matching_records, $record;
                }
            }
            # add functional effective routing to list
            push @functional_eff_rout, $functional if defined $functional;

            # resolve conflicts on limit records and add
            my @unresolved_records = map {LimitRecord->new_copy_from_f_summary($_)} @matching_records;
            my $resolved_record = LimitRecord->merge(\@unresolved_records);
            if (defined $resolved_record){
                $resolved_record->set_item_type('EFFECTIVE_ROUTING', $eff_rout);
                push @effective_routing_limits, @{$resolved_record->create_copies_at_each_area([$area])};
            }
        }
    }

    # add the effective routing records to the limit list provided we're setting limits at the effective routing level
    if(scalar @{$records} > 1){
        push @limit_records, @effective_routing_limits;
    }

    return (\@functional_eff_rout, \@limit_records);
}

sub does_f_summary_record_match_effective_routing_options{
    my ($effective_routing, $f_summary_record) = @_;
    my $technology = $f_summary_record->{"TECHNOLOGY"};
    unless(defined $technology){
        confess "Could not extract technology from record";
    }
    my $requirements = $f_summary_record->{"PROCESS_OPTIONS"};
    unless(defined $requirements){
        confess "Could not extract process options requirements from record";
    }
    return BooleanExpression::does_effective_routing_match_expression_using_database($technology, $effective_routing, $requirements);
}

sub convert_sms_records_into_area_to_effective_routing_lookup{
    my ($sms_records) = @_;
    my %lookup;
    # build a unique list of all effecitve routing and test area combinations
    foreach my $rec (@{$sms_records}){
        my $area = $rec->{"AREA"};
        my $effective_routing = $rec->{"EFFECTIVE_ROUTING"};
        unless (defined $area){
            confess "Could not extract area from record";
        }
        unless (defined $effective_routing){
            confess "Could not extract effective routing from record";
        }
        $lookup{$area} = {} unless scalar keys %{$lookup{$area}};
        $lookup{$area}->{$effective_routing} = "yep";
    }
    # return a simplified list of test areas to effective routings 
    my %area_to_routings;
    foreach my $area (keys %lookup){
        $area_to_routings{$area} = [keys %{$lookup{$area}}];
    }
    return \%area_to_routings;
}

1;
