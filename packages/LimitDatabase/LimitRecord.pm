package LimitRecord;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;



# Configuration information
my %item_types = (
    TECHNOLOGY        => 1,
    ROUTING           => 1,
    PROGRAM           => 1,
    DEVICE            => 1,
);

# Dummy Values
my %dummy_values = (
    DEACTIVATE                  => 'Y',
    SAMPLING_RATE               => 'MON',
    DISPO                       => undef,
    PASS_CRITERIA_PERCENT       => undef,
    REPROBE_MAP                 => undef,
    DISPO_RULE                  => undef,
    SPEC_UPPER                  => undef,
    SPEC_LOWER                  => undef,
    REVERSE_SPEC_LIMIT          => undef,
    RELIABILITY                 => undef,
    RELIABILITY_UPPER           => undef,
    RELIABILITY_LOWER           => undef,
    REVERSE_RELIABILITY_LIMIT   => undef,
    LIMIT_COMMENTS              => "Dummy limit",
);

# all possible fields
#my @all_fields = (
#    'technology',
#    'test_area',
#    'item_type',
#    'item',
#    'etest_name',
#    'deactivate',
#    'sampling_rate',
#    'dispo',
#    'pass_criteria_percent',
#    'reprobe_map',
#    'dispo_rule',
#    'spec_upper',
#    'spec_lower',
#    'reverse_spec_limit',
#    'reliability',
#    'reliability_upper',
#    'reliability_lower',
#    'reverse_reliability_limit',
#    'limit_comments',
#    'constraint',
#);
#@all_fields =~ map {tr/a-z/A-Z/; $_} @all_fields;

# fields that can be copied from an f_summary
my   @fields_that_match_f_summary = qw(Technology etest_name deactivate sampling_rate dispo pass_criteria_percent);
push @fields_that_match_f_summary, qw(reprobe_map dispo_rule spec_upper spec_lower reverse_spec_limit);
push @fields_that_match_f_summary, qw(reliability reliability_upper reliability_lower reverse_reliability_limit);
@fields_that_match_f_summary = map {tr/a-z/A-Z/; $_} @fields_that_match_f_summary;

# a limit record is for populating/pulling from the limits DB

sub new_empty{
    my ($class) = @_;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub new_copy{
    my ($ref) = @_;
    my $copy = LimitRecord->new_empty();
    %{$copy} = %{$ref};
    return $copy;
}

# put the information from the f_summary record into the limit object
sub new_copy_from_f_summary{
    my ($class, $f_summary_record) = @_;
    my $obj = LimitRecord->new_empty();
    return copy_matching_f_summary_fields($obj, $f_summary_record);
}

# copy over matching fields from the f_summary to the limit record
sub copy_matching_f_summary_fields{
    my ($self, $f_summary_record) = @_;
    foreach my $field (@fields_that_match_f_summary){
        $self->{$field} = $f_summary_record->{$field} if exists $f_summary_record->{$field};
    }
    return $self;
}

# set the Item Type -> used for resolve limits
sub set_item_type{
    my ($self, $item_type, $item) = @_;
    $item_type =~ tr/a-z/A-Z/;
    unless (defined $item_types{$item_type}){
        confess "Tried to set a Limit Record to a non-standard item_type <$item_type>"
    }
    $self->{"ITEM_TYPE"} = $item_type;
    $self->{"ITEM"} = $item;
    return $self;
}

# override useful fields with dummy values 
sub dummify{
    my ($self) = @_;
    foreach my $field (keys %dummy_values){
        $self->{$field} = $dummy_values{$field};
    }
    return $self;
}

# create copies of $self at each area provided in the given arrayref
sub create_copies_at_each_area{
    my ($self, $areas) = @_;
    my @copies;
    foreach my $area (@{$areas}){
        my $copy = $self->new_copy();
        $copy->{"TEST_AREA"} = $area;
        push @copies, $copy;
    }
    return \@copies;
}

# getter method, dies on nonexistant entry
sub get{
    my ($self, $thing) = @_;
    $thing =~ tr/a-z/A-Z/;
    unless (exists $self->{$thing}){
        confess "Could not extract value of <$thing> from LimitRecord";
    }
    return $self->{$thing};
}

# takes an array ref of limit objects
# returns undef if none provided
# returns single object if only one object provided (that ref)
# if multiple objects provided, tries to resolve into one object.  Returns that object if successful, otherwise dies
sub merge{
    my ($class, $objects) = @_;
    if (scalar @{$objects} == 0){
        return undef;
    }
    if (scalar @{$objects} == 1){
        return $objects->[0];
    }
    my $resolved = LimitRecord->new_empty();
    foreach my $object (@{$objects}){
        foreach my $field (keys %{$object}){
            # merge each field into the resolved limit
            my $new_value = $object->{$field};
            if (exists $resolved->{$field}){
                # compare the two fields
                my $current_value = $resolved->{$field};
                my $current_value_clean = $current_value;
                $current_value_clean = "undef" unless defined $current_value_clean;
                my $new_value_clean = $new_value;
                $new_value_clean = "undef" unless defined $new_value_clean;
                if ($new_value_clean eq $current_value_clean){
                    # no problem
                }else{
                    confess "Unresolvable conflicts for $field on two records";
                }
            }else{
                $resolved->{$field} = $new_value;
            }
        }
    }
    return $resolved;
}

sub comment{
    my ($self, $comment) = @_;
    $self->{"LIMIT_COMMENTS"} = $comment;
}

# just incase we switch from the hashref
sub index_array{
    my $self = shift;
    return map {$self->{$_}} @_;
}
1;
