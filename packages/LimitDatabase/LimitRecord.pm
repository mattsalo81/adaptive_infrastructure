package LimitRecord;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use POSIX qw(ceil);
use Keithley::KLFEntry;

# ============================================================== #
# GLOBAL DATA AND CONFIGURATION                                  #
# ============================================================== #

my $number_format = '[-+]?[0-9]*(\.)?[0-9]+([eE][-+]?[0-9]+)?';

# Configuration information
my %item_types = (
    TECHNOLOGY        => 1,
    ROUTING           => 1,
    PROGRAM           => 1,
    DEVICE            => 1,
);

my $dummy_comment = "Dummy limit";
# Dummy Values
my %dummy_values = (
    DEACTIVATE                  => 'Y',
    SAMPLING_RATE               => 'RANDOM',
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
    PRIORITY                    => 0,
    LIMIT_COMMENTS              => $dummy_comment,
);

# ITEM_TYPE priorities -> Bigger means more important
my %priority = (
    TECHNOLOGY  =>      1,
    ROUTING     =>      2,
    PROGRAM     =>      3,
    DEVICE      =>      4,
    LOT         =>      5,
    WAFERNO     =>      6,
);

# Mapping for sampling rates -> number of sites
our %sampling = (
    '5 SITE'    => 5,
    '9 SITE'    => 9,
    'RANDOM'    => 1,
);

# fields that can be copied from an f_summary
my   @fields_that_match_f_summary = qw(Technology etest_name deactivate sampling_rate dispo pass_criteria_percent);
push @fields_that_match_f_summary, qw(reprobe_map dispo_rule spec_upper spec_lower reverse_spec_limit);
push @fields_that_match_f_summary, qw(reliability reliability_upper reliability_lower reverse_reliability_limit);
@fields_that_match_f_summary = map {tr/a-z/A-Z/; $_} @fields_that_match_f_summary;


# all fields in the limits_database
my @limit_fields = qw(technology test_area item_type item etest_name priority deactivate sampling_rate);
push @limit_fields, qw(dispo pass_criteria_percent reprobe_map dispo_rule spec_upper spec_lower reverse_spec_limit);
push @limit_fields, qw(reliability reliability_upper reliability_lower reverse_reliability_limit limit_comments);
@limit_fields = map {tr/a-z/A-Z/; $_} @limit_fields;

# accessory information that isn't technically part of the limits_database
my @accessory_fields = qw(component effective_routing predecessor bit);
@accessory_fields = map {tr/a-z/A-Z/; $_} @accessory_fields;

# fields that are okay to have
my %ok_fields;
@ok_fields{@limit_fields} = @limit_fields;
@ok_fields{@fields_that_match_f_summary} = @fields_that_match_f_summary;
@ok_fields{@accessory_fields} = @accessory_fields;


# ============================================================== #
# Basic class methods                                            #
# ============================================================== #
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

sub is_dummy{
    my ($self) = @_;
    my $comment = $self->{"LIMIT_COMMENTS"};
    if (defined $comment){
        return $comment eq $dummy_comment;
    }
    return 0;
}

sub get_ordered_keys{
    my ($class) = @_;
    return @limit_fields;

}

sub get_ordered_values{
    my ($self) = @_;
    return @{$self}{@limit_fields};
}

sub new_from_hash{
    my ($class, $hash) = @_;
    my $self = $class->new_empty();
    $self->populate_from_hash($hash);
    return $self;
}

sub populate_from_hash{
    my ($self, $hashref) = @_;
    foreach my $key (keys %{$hashref}){
        $self->set($key, $hashref->{$key});
    }
    return $self;
}

# ============================================================== #
# Limit record manipulation methods                              #
# ============================================================== #

# returns true if limit record's component field is not populated/empty, or if 
# the component is defined in the comp_hash
# otherwise returns false
# dies if called before COMPONENT member populated
sub required_by_component_hash{
    my ($self, $comp_hash) = @_;
    my $comp = $self->get("COMPONENT");
    if((not defined $comp) or $comp =~ m/^\s*$/){
        return 1;
    }
    return defined $comp_hash->{$comp};
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

sub set_priority{
    my ($self, $priority) = @_;
    $self->{"PRIORITY"} = $priority;
}

sub set{
    my ($self, $thing, $value) = @_;
    if (defined $ok_fields{$thing}){
        $self->{$thing} = $value;
    }else{
        confess "Tried to set a LimitRecord value for key $thing, which is not a known key";
    }
}

# put the information from the f_summary record into the limit object
sub new_copy_from_f_summary{
    my ($class, $f_summary_record) = @_;
    my $obj = LimitRecord->new_empty();
    $obj->{"PRIORITY"} = 0;
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

sub remove_predecessor{
    my ($self) = @_;
    delete $self->{"PREDECESSOR"};
}

sub get_predecessor{
    my ($self) = @_;
    return $self->{"PREDECESSOR"};
}

# links the two limits by priority.  Returns the highest priority limit record
# with the PREDECESSOR member pointing to the lower priority limit
# if the PREDECESSOR member is already populated, the method will recursively call itself to link that limit with the
# new predecessor
# the result is a linked list of limits through the PREDECESSOR member in decreasing priority order.
sub link_by_priority{
    my ($class, $limit1, $limit2) = @_;
    # order the two limits
    my $successor = LimitRecord->choose_highest_priority($limit1, $limit2);
    my $predecessor = ($limit1 eq $successor ? $limit2 : $limit1);
    
    # see if new successor has a predecessor 
    my $current_predecessor = $successor->get_predecessor();
    if (defined $current_predecessor){
        # link the old/new predecessor
        $successor->{"PREDECESSOR"} = LimitRecord->link_by_priority($predecessor, $current_predecessor);
    }else{
        # put our predecessor in
        $successor->{"PREDECESSOR"} = $predecessor;
    }
    return $successor;
}

# returns the higher priority limit
sub choose_highest_priority{
    my ($class, $limit1, $limit2) = @_;
    # choose more specific item_type
    my $type1 = $limit1->{"ITEM_TYPE"};
    my $type2 = $limit2->{"ITEM_TYPE"};
    unless (defined $type1){
        confess "Limit1 does not have an item_type defined";
    }
    unless (defined $type2){
        confess "Limit2 does not have an item_type defined";
    }
    my $p1 = $priority{$type1};
    my $p2 = $priority{$type2};
    unless (defined $p1){
        confess "limit1 has an undefined priority level for item_type $type1";
    }
    unless (defined $p2){
        confess "limit2 has an undefined priority level for item_type $type2";
    }
    return $limit1 if($p1 > $p2);
    return $limit2 if($p1 < $p2);
    # now check actual priority
    $p1 = $limit1->{"PRIORITY"};
    $p2 = $limit2->{"PRIORITY"};
    return $limit1 if($p1 > $p2);
    return $limit2 if($p1 < $p2);
    confess "Both limits provided are set at the same item_type level and priority. Limit1 = " . Dumper($limit1) . "\nLimit2 = " . Dumper($limit2);
}

# given an arbitrary list of limits, resolves conflicts of limits between limits of different priorities
# IE, if two limits are given, both of the same technology, test_area, and etest_name, but set at different levels 
# (say technology and device), the lower priority limit will be removed (technology)
sub resolve_limit_table{
    my ($class, $limits) = @_;
    # keep track of the order of the limits 
    my @order;
    my %key_limit;
    Logging::debug("Resolving different leveled limits");
    foreach my $limit (@{$limits}){
        $limit->remove_predecessor();
        # get dies on failure, no need to check
        my $technology = $limit->get("TECHNOLOGY");
        my $test_area = $limit->get("TEST_AREA");
        my $etest_name = $limit->get("ETEST_NAME");

        # generate a unique key for storing the order + current limit
        my $key = join("__X__", ($technology, $test_area, $etest_name));

        if(defined $key_limit{$key}){
            #resolve the limits
            Logging::diag("Resolving priority for two limits on $key");
            $limit = LimitRecord->link_by_priority($limit, $key_limit{$key});
        }else{
            # add the etest_name to the order
            push @order, $key;
        }
        $key_limit{$key} = $limit;
    }
    my @resolved_limits = @key_limit{@order};
    return \@resolved_limits;
}

# filters a limit table to the given component list only
# returns number of components removed
sub filter_limit_table_by_component{
    my ($class, $limits, $components) = @_;

    if(scalar @{$components} == 0){
        return 0;
    }

    my %comps;
    @comps{@{$components}} = @{$components};

    my @new_limits;
    my $removed = 0;

    foreach my $limit (@{$limits}){
        if($limit->required_by_component_hash(\%comps)){
            push @new_limits, $limit;
        }else{
            $removed++;
        }
    }

    @{$limits} = @new_limits;
    return $removed;
}

# ============================================================== #
# Specfile generation methods                                    #
# ============================================================== #

# determine sampling rate from SAMPLING_RATE field
sub how_many_sites_to_test{
    my ($self) = @_;
    my $sampling = $self->get("SAMPLING_RATE");
    my $sites = $sampling{$sampling};
    unless (defined $sites){
        confess "Unexpected sampling rate $sampling";
    }
    return $sites;
}

# determine number of fails/wafer for a scrap dispo (from sampling rate and pass percentage)
sub get_num_fails{
    my ($self) = @_;
    my $sites = $self->how_many_sites_to_test();
    my $pass = $self->get("PASS_CRITERIA_PERCENT");
    my $num_fails = ceil($sites * (1 - $pass));
}

sub scrap_is_reversed{
    my ($self) = @_;
    my $io = $self->get("REVERSE_SPEC_LIMIT");
    return ((defined $io) && $io eq "Y");
}

# get scrap entry for a specfile, return undef or arrayref
sub get_scrap_entry{
    my ($self) = @_; 
    return undef if $self->is_disabled();
    my $parm = $self->get("ETEST_NAME");
    my $was = $self->get("DISPO");
    if ((defined $was) && $was eq "Y"){
        # generate a limit
        my $fail = $self->get_num_fails();
        my $lsl = $self->get("SPEC_LOWER");
        my $usl = $self->get("SPEC_UPPER");
        my $io = ($self->scrap_is_reversed() ? 0 : 1);
        return [$parm, $fail, $lsl, $usl, $io, 6];
    }
    return undef;
}

sub reliability_is_reversed{
    my ($self) = @_;
    my $io = $self->get("REVERSE_RELIABILITY_LIMIT");
    return ((defined $io) && $io eq "Y");
}

# get reliability entry for a specfile, return undef or arrayref
sub get_reliability_entry{
    my ($self) = @_;
    return undef if $self->is_disabled();
    my $parm = $self->get("ETEST_NAME");
    my $rel = $self->get("RELIABILITY");
    if ((defined $rel) && $rel eq "Y"){
        my $lrl = $self->get("RELIABILITY_LOWER");
        my $url = $self->get("RELIABILITY_UPPER");
        my $io = ($self->reliability_is_reversed()) ? 0 : 1;
        return [$parm, 1, $lrl, $url, $io, 2];
    }
    return undef; 
}

sub get_comment{
    my ($self) = @_;
    return $self->{"LIMIT_COMMENTS"};
}

# KLF generation

sub is_disabled{
    my ($self) = @_;
    my $deactivate = $self->get("DEACTIVATE");
    if(defined $deactivate){
        return 1 if $deactivate =~ m/^Y$/i; 
        return 0 if $deactivate =~ m/^N$/i; 
        die "unexpected deactivate flag '$deactivate'";
    }
    return 0;
}

sub uses_immediate_map{
    my ($self) = @_;
    my $pattern = $self->get("REPROBE_MAP");
    if (defined $pattern and $pattern ne ""){
        if ($pattern =~ m/^(map|mapping|all|alt|std_alt)$/i){
            return 1;
        }
        confess "unexpected pattern type $pattern";
    }
    return 0;
}

sub get_klf_entry{
    my ($self) = @_;
    my $entry = KLFEntry->new($self->get("ETEST_NAME"));
    $entry->set_bit($self->get("BIT"));
    $entry->set_test(! $self->is_disabled());
    $entry->set_num_sites($self->how_many_sites_to_test());
    my $ll;
    my $ul;
    my $was = $self->get_scrap_entry();
    if (defined $was){
        $ll = $was->[2];
        $ul = $was->[3];
    }    
    my $rel = $self->get_reliability_entry();
    if (defined $rel){
        $ll = $rel->[2];
        $ul = $rel->[3];
    }
    if (defined $ll and defined $ul){
        $entry->set_limits("SPC", $ll, $ul);
        $entry->set_reporting_on_ms_screen(1);
    }
    if($self->uses_immediate_map()){
        $entry->enable_mapping();
    }
    return $entry;
}

1;
