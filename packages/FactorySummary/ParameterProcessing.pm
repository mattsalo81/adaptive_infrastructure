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

my %memoize;

sub reset_memoization{
    %memoize = ();
}

my @functional_fields = q(technology test_area effective_routing etest_name svn component parm_type_pcd test_type description);
@functional_fields = map {tr/a-z/A-Z/; $_} @functional_fields;

# takes 
#               arrayref of hashrefs for a particular parameter from the f_summary
#               hashref of TESTAREAS to arrayref of EFFECTIVE_ROUTING
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
    my ($records, $test_areas, $check_match_lambda) = @_;
    my $parameter_info;
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
    
    # create the technology level record
    my $tech_rec = LimitRecord->new_copy_from_f_summary($records->[0]);
    $tech_rec->set_item_type('TECHNOLOGY', $tech_rec->get('TECHNOLOGY'));
    my $tech_option = $records->[0]->{"PROCESS_OPTIONS"};
    $tech_option = "" unless defined $tech_option;
    $tech_rec->comment("From Factory Summary $tech_option");
    
    if(scalar @{$records} > 1){
        # records will be set at the effective routing, so dummy this one
        $tech_rec->dummify();
    }
    # create duplicate records for each test area
    push @limit_records, @{$tech_rec->create_copies_at_each_area([keys %{$test_areas}])};

    # Assert that there are no unresolvable conflicts for fields going into the functionality table
    $parameter_info = get_parameter_info($records);

    # determine which routings are functional
    my @effective_routing_limits;
    foreach my $area (keys %{$test_areas}){
        foreach my $eff_rout (@{$test_areas->{$area}}){
            my @matching_records;
            my $functional;
            my $options;
            foreach my $record (@{$records}){
                #if (does_f_summary_record_match_effective_routing_options($eff_rout, $record)){
                if ($check_match_lambda->($eff_rout, $record)){
                    $options = $record->{"PROCESS_OPTIONS"};
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
                $options = "" unless (defined $options);
                $resolved_record->comment("From Factory Summary $options");
                $resolved_record->set_item_type('ROUTING', $eff_rout);
                push @effective_routing_limits, @{$resolved_record->create_copies_at_each_area([$area])};
            }
        }
    }

    # add the effective routing records to the limit list provided we're setting limits at the effective routing level
    if(scalar @{$records} > 1){
        push @limit_records, @effective_routing_limits;
    }

    return ($parameter_info, \@functional_eff_rout, \@limit_records);
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
    my $key = "$technology $requirements $effective_routing";
    unless (defined $memoize{$key}){
        $memoize{$key} = BooleanExpression::does_effective_routing_match_expression_using_database($technology, $effective_routing, $requirements);
    }
    return $memoize{$key};

}

#my @functional_fields = q(technology test_area effective_routing etest_name svn component parm_type_pcd test_type description);
sub get_parameter_info{
    my ($parameter_f_summary_records) = @_;
    
    # input checking
    if(scalar @{$parameter_f_summary_records} == 0){
        confess "Could not get parameter information, because no records provided";
    }
    my $record = $parameter_f_summary_records->[0];
    
    my $technology = $record->{"TECHNOLOGY"};
    my $parameter = $record->{"ETEST_NAME"};

    unless(defined $technology){
        confess "Could not extract TECHNOLOGY from record";
    }
    unless(defined $parameter){
        confess "Could not extract PARAMETER from record";
    }

    # create the parameter info record
    my $parm_info = {
        TECHNOLOGY            =>        $technology,
        ETEST_NAME            =>        $parameter,
        SVN                   =>        $record->{"SVN"},
        COMPONENT             =>        $record->{"COMPONENT"},
        PARM_TYPE_PCD         =>        $record->{"PARM_TYPE_PCD"},
        TEST_TYPE             =>        $record->{"TEST_TYPE"},
        DESCRIPTION           =>        $record->{"DESCRIPTION"},
    };

    # All records must have identical values, otherwise die
    if(scalar @{$parameter_f_summary_records} > 1){
        # use the last one as the reference
        my $ref = $parameter_f_summary_records->[-1];
        foreach my $other (@{$parameter_f_summary_records}[0..-2]){
            foreach my $field (@functional_fields){
                my $ref_c = $ref->{$field};
                $ref_c = "" unless defined $ref_c;
                my $oth_c = $ref->{$field};
                $oth_c = "" unless defined $oth_c;
                if ($ref_c ne $oth_c){
                    confess "Conflicting $field information found on parameter $parameter";
                }
            }
        }
    }

    return $parm_info;
}

1;
