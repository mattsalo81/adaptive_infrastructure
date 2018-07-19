package Functionality::Record;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Parse::BooleanExpression;

my @ok_fields = qw(TECHNOLOGY SCRIBE_MODULE TEST_MOD MATCHED_REV MATCHED_GROUP PRIORITY FUNCTIONALITY PROCESS_OPTION LOGPOINTS);
my %ok_fields;
@ok_fields{@ok_fields} = @ok_fields;

sub new{
    my ($class, $hash) = @_;
    my $self = {};
    bless $self, $class;
    $self->populate_from_hash($hash);
    return $self;
}

sub populate_from_hash{
    my ($self, $hash) = @_;
    foreach my $key (keys %{$hash}){
        $self->set($key, $hash->{$key});
    }
}

sub set{
    my ($self, $key, $value) = @_;
    if (defined $ok_fields{$key}){
        $self->{$key} = $value;
    }else{
        die "<$key> is not an ok field";
    }
}

sub get{
    my ($self, $key) = @_;
    if (exists $self->{$key}){
        return $self->{$key};
    }else{
        die "<$key> is not a defined field!";
    }
}

sub satisfies_lpt_and_po{
    my ($self, $effective_routing, $sms_routing) = @_;
    my $technology = $self->get("TECHNOLOGY");
    my $process_option = $self->get("PROCESS_OPTION");
    my $logpoint = $self->get("LOGPOINTS");
    if(defined $process_option && $process_option !~ m/^\s*$/){
        unless(BooleanExpression::does_effective_routing_match_expression_using_database($technology, $effective_routing, $process_option)){
            return 0;
        }
    }
    if(defined $logpoint && $logpoint !~ m/^\s*$/){
        unless(BooleanExpression::does_sms_routing_match_lpt_string($sms_routing, $logpoint)){
            return 0;
        }
    }
    return 1;
}

# returns a priority value for resolution 
# based on which fields are wildcards
sub get_resolve_priority{
    my ($self) = @_;
    my $priority = 0;
    $priority += 1 if ($self->{"MATCHED_GROUP"} ne '*');
    $priority += 2 if ($self->{"MATCHED_REV"} ne '*');
    return $priority;
}

1;
