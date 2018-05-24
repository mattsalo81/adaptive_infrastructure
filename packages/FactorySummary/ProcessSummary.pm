package ProcessSummary;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use FactorySummary::ParameterProcessing;
use SMS::SMSDigest;
use ProcessOptions::OptionLookup;

my $f_summary_records_for_parameter_sth;
my $factory_summary_table = "f_summary";
my $all_f_summary_parameters_for_technology_sth;

sub process_technology{
    my ($technology) = @_;
    my $parms = get_all_f_summary_parameters_for_technology($technology);
    my @parm_info;
    my @functional;
    my @limits;
    # Get all SMS records for the technology
    my $all_sms = SMSDigest::get_entries_for_tech($technology);
    # remove sms records where the effective routing does not have process options populated
    my @sms = map {OptionLookup::are_options_available_for_effective_routing($technology, $_->{"EFFECTIVE_ROUTING"}) ? $_ : ()} @{$all_sms};
    my $test_areas = SMSDigest::convert_sms_records_into_area_to_effective_routing_lookup(\@sms);
    Logging::event("Processing Factory Summary for $technology");
    ParameterProcessing::reset_memoization();
    foreach my $parameter (@{$parms}){
        Logging::debug("Processing Factory Summary for $technology - $parameter");
        my $records = get_f_summary_records_for_parameter($technology, $parameter);
        my ($inf, $func, $lim) = ParameterProcessing::process_f_summary_parameter_records($records, $test_areas);
        push @parm_info, $inf;
        push @functional, @{$func};
        push @limits, @{$lim};
    }
    return (\@parm_info, \@functional, \@limits);
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

sub get_all_f_summary_parameters_for_technology{
    my ($technology) = @_;
    my $sth = get_all_f_summary_parameters_for_technology_sth();
    $sth->execute($technology) or confess "Could not get all parameters from f_summary";
    my $records = $sth->fetchall_arrayref();
    my @parameters = map {$_->[0]} @{$records};
    if (scalar @parameters == 0){
        confess "Could not find any F-summary entries for $technology";
    }
    return \@parameters;
}

sub get_all_f_summary_parameters_for_technology_sth{
    unless (defined $all_f_summary_parameters_for_technology_sth){
        my $conn = Connect::read_only_connection('etest');
        my $sql = qq{
            select distinct etest_name from $factory_summary_table where technology = ?
        };
        $all_f_summary_parameters_for_technology_sth = $conn->prepare($sql);
    }
    unless (defined $all_f_summary_parameters_for_technology_sth){
        confess "Could not get all_f_summary_parameters_for_technology";
    }
    return $all_f_summary_parameters_for_technology_sth
}

1;
