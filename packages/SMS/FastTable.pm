package FastTable;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use SMS::SMSDigest;

# class to make sorting/indexing sms records faster
# all records are assumed to be hashrefs with identical keys
# FastTable has an INDEX member that can be set to some key available to all records
# the FastTable will group all records by the INDEXed key and store them as an arrayref, pointed to in RECORDS by the value of their INDEXed member
# dump the structure if you need a better look at it

sub new{
    # <class> [index] <record_arrayref> = @_;
    my $class = shift;
    my $index = "DEVICE";
    # take index if scalar profided
    $index = shift if (ref($_[0]) eq "");
    my $records = shift;
    
    my $self = {
        RECORDS         => {},
        INDEX           => "DEVICE",
    };
    bless $self, $class;
    $self->index_by($index);

    $self->add_arrayref($records) if defined $records;
    return $self;
}

sub new_extract{
    my ($class, $index) = @_;
    my $records = SMSDigest::get_all_records();
    my $self;
    if (defined $index) {
        $self = $class->new($index, $records);
    } else {
        $self = $class->new($records);
    }
    return $self;
}

sub new_copy{
    my ($orig) = @_;
    my $self = new(ref($orig), $orig->{"INDEX"}, $orig->get_all_records());
    return $self;
}

# adds a list of records to the object, indexed off whatever INDEX is
sub add_arrayref{
    my ($self, $arrayref) = @_;
    foreach my $record (@{$arrayref}){
        $self->add_record($record);
    }
}

# adds a single record to the object, indexed off whatever INDEX is
sub add_record{
    my ($self, $record) = @_;
    my $field = $self->{"INDEX"};
    my $key = $record->{$field};
    unless (defined $key){
        confess "Tried to index SMS record by $field but $field does not exist in the record: " . Dumper($record);
    }
    $self->{"RECORDS"}->{$key} = [] unless defined $self->{"RECORDS"}->{$key};
    push @{$self->{"RECORDS"}->{$key}}, $record;
}

# returns an arrayref of all records
sub get_all_records{
    my ($self) = @_;
    my @records;
    foreach my $key (keys %{$self->{"RECORDS"}}){
        push @records, @{$self->{"RECORDS"}->{$key}};
    }
    return \@records;
}

# resets the indexing field and re-indexes all records
sub index_by{
    my ($self, $index) = @_;
    my $records = $self->get_all_records();
    $self->clear_all_records();
    $self->{"INDEX"} = $index;
    $self->add_arrayref($records);
}

# removes all records from the object
sub clear_all_records{
    my ($self) = @_;
    $self->{"RECORDS"} = {};
}

# takes a lambda function that takes an index value as an input
# should be indexed by proper field before hand
# for all unique INDEXes:
#   if lambda returns true, nothing happens
#   if lambda returns false, that key (and all records associated with it) are deleted from the FastTable
sub filter_indexes{
    my ($self, $lambda) = @_;
    foreach my $index (@{$self->get_all_indexes()}){
        unless($lambda->($index)){
            delete $self->{"RECORDS"}->{$index};
        }
    }
}

# returns all currently indexes
sub get_all_indexes{
    my ($self) = @_;
    my @keys = keys %{$self->{"RECORDS"}};
    return \@keys;
} 

# takes a lambda function that takes a record value as an input
# for all unique records
#   if lambda returns true, record remains in the FastTable
#   if lambda returns false, record is removed from the FastTable
sub filter_records{
    my ($self, $lambda) = @_;
    my $records = $self->get_all_records();
    # remove everything
    $self->clear_all_records();
    foreach my $record (@{$records}){
        if($lambda->($record)){
            $self->add_record($record);
        } # else don't add it back
    }
}

1;
