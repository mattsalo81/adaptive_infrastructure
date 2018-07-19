package Functionality::Core;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Functionality::Valid;
use Functionality::Table;

sub evaluate_sms_rec_functionality{
    my ($sms_rec, $requirement) = @_;
    my $technology = $sms_rec->get("TECHNOLOGY");
    my $coordref = $sms_rec->get("COORDREF");
    my $effective_routing = $sms_rec->get("EFFECTIVE_ROUTING");
    my $sms_routing = $sms_rec->get("ROUTING");
    # check coordref/testgroup
    unless(Functionality::Valid::check_coordref($technology, $coordref)){
        confess "Coordref <$coordref> is not valid in the system"
    }
    my ($test_group, $scope, $functionality) = parse_functionality_req($requirement);
    unless(Functionality::Valid::check_test_group($technology, $test_group)){
        confess "Test group <$test_group> is not valid on $technology";
    }   
    # build functionality table and check functionality
    my $t = Functionality::Table->new();
    $t->populate($technology, $coordref, $test_group);
    $t->process($effective_routing, $sms_routing);
    return $t->evaluate_functionality($scope, $functionality);
}

sub parse_functionality_req{
    my ($requirement) = @_;
    
    # Fields
    my @fields = split /:/, $requirement;
    if (scalar @fields == 2){
        $fields[2] = $fields[1];
        $fields[1] = undef;
    }elsif(scalar @fields != 3){
        confess "Could not parse functionality requirement <$requirement>";
    }
    
    my ($test_group, $scope, $functionality) = @fields;
    $scope = undef if ((defined $scope) && $scope eq "");

    confess "No test group defined" unless defined $test_group; 
    confess "unkown test_group <$test_group>" unless $test_group !~ m/^\s*$/;
    unless ((not defined $scope) || $scope =~ m/^(TOP|ANY)$/){
        confess "unknown Scope <$scope>";
    }
    confess "No functionality defined" unless defined $functionality;
    confess "unkown Functionality <$functionality>" unless $functionality =~ m/^(SF|NF|NSF[0-9])$/;

    return ($test_group, $scope, $functionality);
    
}



1;
