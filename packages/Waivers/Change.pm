package Waivers::Change;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Switch;
use Exceptions::ExceptionRules;

# a Waivers::Change object contains an action/method for modifying a LimitRecord

# Classifies known things into their category, each action is associated to a function
# functions take ($self, $limit) and return true if a change was made
my %known_things = (
    LSL                         => {
                                        RELAX   => \&RELAX_LSL,
                                        TIGHTEN => \&TIGHTEN_LSL,
                                        SET     => \&SET_LSL,
                                    },
    USL                         => {
                                        RELAX   => \&RELAX_USL,
                                        TIGHTEN => \&TIGHTEN_USL,
                                        SET     => \&SET_USL,
                                    },
    LRL                         => {
                                        RELAX   => \&RELAX_LRL,
                                        TIGHTEN => \&TIGHTEN_LRL,
                                        SET     => \&SET_LRL,
                                    },
    URL                         => {
                                        RELAX   => \&RELAX_URL,
                                        TIGHTEN => \&TIGHTEN_URL,
                                        SET     => \&SET_URL,
                                    },
    PASS_CRITERIA_PERCENT       => {    
                                        RELAX   => sub {return lower_value($_[1], "PASS_CRITERIA_PERCENT", $_[0]->{"VALUE"})},
                                        TIGHTEN => sub {return raise_value($_[1], "PASS_CRITERIA_PERCENT", $_[0]->{"VALUE"})},
                                        SET     => sub {return set_value($_[1], "PASS_CRITERIA_PERCENT", $_[0]->{"VALUE"})},
                                    },
    SAMPLING_RATE               => {
                                        RELAX   => \&RELAX_SAMPLING_RATE,
                                        TIGHTEN => \&TIGHTEN_SAMPLING_RATE,
                                        SET     => sub {return set_value($_[1], "SAMPLING_RATE", $_[0]->{"VALUE"})},
                                    },
    SPEC                        => {
                                        SET_REVERSED    => sub {return set_value($_[1], "REVERSE_SPEC_LIMIT", "Y")},
                                        SET_UNREVERSED  => sub {return set_value($_[1], "REVERSE_SPEC_LIMIT", "N")},
                                        USE             => sub {return set_value($_[1], "DISPO", "Y")},
                                        NO_USE          => sub {return set_value($_[1], "DISPO", "N")},
                                    },
    REL                         => {
                                        SET_REVERSED    => sub {return set_value($_[1], "REVERSE_RELIABILITY_LIMIT", "Y")},
                                        SET_UNREVERSED  => sub {return set_value($_[1], "REVERSE_RELIABILITY_LIMIT", "N")},
                                        USE             => sub {return set_value($_[1], "RELIABILITY", "Y")},
                                        NO_USE          => sub {return set_value($_[1], "RELIABILITY", "N")},
                                    },
    DISPO_RULE                  => {
                                        SET     => sub{return set_value($_[1], "DISPO_RULE", $_->{"VALUE"})},
                                    },
    REPROBE_MAP                 => {
                                        SET     => sub{return set_value($_[1], "REPROBE_MAP", $_->{"VALUE"})},
                                    },
    PARAMETER                   => {
                                        DISABLE => sub{return set_value($_[1], "DEACTIVATE", "Y")},
                                    },
);


sub new{
    my ($class, $action, $thing, $parameter, $value) = @_;
    my $self = {
        ACTION  => $action,
        THING   => $thing,
        PARM    => $parameter,
        VALUE   => $value,
    }; 
    bless $self, $class;
    return $self;
}

# applies the change to the limit ( if needed)
# returns true if anything was changed
sub apply{
    my ($self, $limit) = @_;
    if ($self->should_apply($limit)){
        my $thing = $self->{"THING"};
        my $actions = $known_things{$thing};
        unless (defined $actions){
            confess "<$thing> is not a known thing we can apply a waiver to";
        }
        my $action = $self->{"ACTION"};
        my $lambda = $actions->{$action};
        unless ((defined $lambda)){
            confess "No action lambda available to <$action> a <$thing>";
        };
        my $thing_done = $lambda->($self, $limit);
        return $thing_done;
    }else{
        return 0
    }
}

# compares the PARAMETER field in the waiver agains the ETEST_NAME of the limit
# uses explicit regex comparison
sub should_apply{
    my ($self, $limit) = @_;
    my $parameter = $limit->get("ETEST_NAME");
    my $expression = $self->{"PARM"};
    return ExceptionRules::explicit_anchored_regex_with_numeric_comparison($parameter, $expression);
}

# raises a value in a limit record
# LOWER SPEC STUFF
sub RELAX_LSL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->spec_is_reversed()){
        return raise_value($limit, "SPEC_LOWER", $value);
    }else{
        return lower_value($limit, "SPEC_LOWER", $value);
    }
}

sub TIGHTEN_LSL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->spec_is_reversed()){
        return lower_value($limit, "SPEC_LOWER", $value);
    }else{
        return raise_value($limit, "SPEC_LOWER", $value);
    }
}

sub SET_LSL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    return set_value($limit, "SPEC_LOWER", $value);
}

# UPPER SPEC STUFF
sub RELAX_USL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->spec_is_reversed()){
        return lower_value($limit, "SPEC_UPPER", $value);
    }else{
        return raise_value($limit, "SPEC_UPPER", $value);
    }
}

sub TIGHTEN_USL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->spec_is_reversed()){
        return raise_value($limit, "SPEC_UPPER", $value);
    }else{
        return lower_value($limit, "SPEC_UPPER", $value);
    }
}

sub SET_USL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    return set_value($limit, "SPEC_UPPER", $value);
}

# LOWER RELIABILITY STUFF
sub RELAX_LRL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->reliability_is_reversed()){
        return raise_value($limit, "RELIABILITY_LOWER", $value);
    }else{
        return lower_value($limit, "RELIABILITY_LOWER", $value);
    }
}

sub TIGHTEN_LRL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->reliability_is_reversed()){
        return lower_value($limit, "RELIABILITY_LOWER", $value);
    }else{
        return raise_value($limit, "RELIABILITY_LOWER", $value);
    }
}

sub SET_LRL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    return set_value($limit, "RELIABILITY_LOWER", $value);
}

# UPPER SPEC STUFF
sub RELAX_URL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->reliability_is_reversed()){
        return lower_value($limit, "RELIABILITY_UPPER", $value);
    }else{
        return raise_value($limit, "RELIABILITY_UPPER", $value);
    }
}

sub TIGHTEN_URL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    if ($limit->reliability_is_reversed()){
        return raise_value($limit, "RELIABILITY_UPPER", $value);
    }else{
        return lower_value($limit, "RELIABILITY_UPPER", $value);
    }
}

sub SET_URL{
    my ($self, $limit) = @_;
    my $value = $self->{"VALUE"};
    return set_value($limit, "RELIABILITY_UPPER", $value);
}

# SAMPLING_RATE STUFF
sub RELAX_SAMPLING_RATE{
    my ($self, $limit) = @_;
    my $new_val = $self->{"VALUE"};
    my $old_num = $limit->how_many_sites_to_test();
    my $new_num = $LimitRecord::sampling{$new_val};
    if($new_num < $old_num){
        return set_value($limit, "SAMPLING_RATE", $new_val);
    }
    return 0;                                
}

sub TIGHTEN_SAMPLING_RATE{
    my ($self, $limit) = @_;
    my $new_val = $self->{"VALUE"};
    my $old_num = $limit->how_many_sites_to_test();
    my $new_num = $LimitRecord::sampling{$new_val};
    if($new_num > $old_num){
        return set_value($limit, "SAMPLING_RATE", $new_val);
    }
    return 0;                                
}

# HELPER FUNCTIONS
# returns true/false if something modified
sub raise_value{
    my ($limit, $key, $value) = @_;
    if (not defined $value){
        confess "Value not defined";
    }
    my $old_val = $limit->get($key);
    if ((not defined $old_val) || $old_val < $value){
        $limit->set($key, "$value");
        return 1;
    }
    return 0
}

# lowers a value in a limit record
# returns true/false if something modified
sub lower_value{
    my ($limit, $key, $value) = @_;
    if (not defined $value){
        confess "Value not defined";
    }
    my $old_val = $limit->get($key);
    if ((not defined $old_val) || $old_val > $value){
        $limit->set($key, "$value");
        return 1;
    }
    return 0;
}

# sets a value in a limit record
# returns true if value was changed or not
sub set_value{
    my ($limit, $key, $value) = @_;
    my $old_val = $limit->get($key);
    if (((defined $old_val) xor (defined $value)) || ((defined $value) && (defined $old_val) && $old_val ne $value)){
        $limit->set($key, "$value");
        return 1;
    }
    return 0;
}


1;
