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
    my $success = 0;
    eval{
        # check coordref/testgroup
        unless(Functionality::Valid::check_coordref($technology, $coordref)){
            die "Coordref <$coordref> is not valid in the system"
        }
        my ($test_group, $scope, $functionality) = parse_functionality_req($requirement);
        unless(Functionality::Valid::check_test_group($technology, $test_group)){
            die "Test group <$test_group> is not valid on $technology";
        }   
        # build functionality table and check functionality
        my $t = Functionality::Table->new();
        $t->populate($technology, $coordref, $test_group);
        $t->process($effective_routing, $sms_routing);
        $success = $t->evaluate_functionality($scope, $functionality);
        1;
    } or do{
        my $e = $@;
        warn "Could not evalue <$technology, $coordref, $effective_routing, $sms_routing> for <$requirement> because : $e";
    };
    return $success;
}

sub parse_functionality_req{
    my ($requirement) = @_;
    
    # Fields
    my @fields = split /:/, $requirement;
    if (scalar @fields == 2){
        $fields[2] = $fields[1];
        $fields[1] = undef;
    }elsif(scalar @fields != 3){
        die "Could not parse functionality requirement <$requirement>";
    }
    
    my ($test_group, $scope, $functionality) = @fields;
    $scope = undef if ((defined $scope) && $scope eq "");

    die "No test group defined" unless defined $test_group; 
    die "unkown test_group <$test_group>" unless $test_group !~ m/^\s*$/;
    unless ((not defined $scope) || $scope =~ m/^(TOP|ANY)$/){
        die "unknown Scope <$scope>";
    }
    die "No functionality defined" unless defined $functionality;
    die "unkown Functionality <$functionality>" unless $functionality =~ m/^!?(SF|NF|NSF[0-9])$/;

    Logging::diag("Parsed functionality request to $test_group, " .  (defined $scope ? $scope : "undef") . ", $functionality");

    return ($test_group, $scope, $functionality);
    
}



1;
