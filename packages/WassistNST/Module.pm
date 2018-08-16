package WassistNST::Module;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Logging;

our %orientations = (
    DOWN        => "yep",
    LEFT        => "yep",
    UP          => "yep",
    RIGHT       => "yep",
);

my %locations = (
    UL      => "yep",
    UR      => "yep",
    LL      => "yep",
    LR      => "yep",
    MM      => "yep",
    CC      => "yep",
    M       => "yep",
    T       => "yep",
    B       => "yep",
    L       => "yep", 
    R       => "yep",);

our %numeric_orientations = (
    1       =>      'DOWN',
    2       =>      'LEFT',
    3       =>      'UP',
    4       =>      'RIGHT',
);

my %coord_types = (
    UNKOWN      => 1,
    PAD1        => 1,
    ARRAY       => 1,
);

my %default = (
    RAW_NAME => undef,
    NAME => undef,
    COORD_TYPE => "UNKOWN",
    X => undef,
    Y => undef,
    ORIENTATION => "UNKNOWN",
    PLACEMENT => 0,
    ORIENTATION => "UNKNOWN",
    LOCATION => undef,
    SOURCE => undef,
    SUBSOURCE => undef,
    X_SIZE_MM => undef,
    Y_SIZE_MM => undef,
);

sub new{
    my ($class, $raw_name) = (@_);
    # create a copy of the defaults
    my $self = {%default};
    bless $self, $class;
    $self->set("RAW_NAME", $raw_name);
    $self->get_any_info_from_raw_name();
    return $self;
}

sub new_copy{
    my ($class, $reference) = @_;
    my $new = {%{$reference}};
    bless $new, $class;
    return $new;
}

sub has_all_necessary_info{
    my ($self) = @_;
    return 0 if $self->get("ORIENTATION") eq "UNKNOWN";
    return 0 unless defined $self->get("NAME");
    return 0 unless defined $self->get("X");
    return 0 unless defined $self->get("Y");
    return 0 unless defined $self->get("REVISION");
    return 1;
}

sub record_header{
    my ($self) = @_;
    my @keys = sort keys %{$self};
    return \@keys;
}

sub arrayify{
    my ($self) = @_;
    my $header = $self->record_header();
    my @record;
    foreach my $key (@{$header}){
        push @record, $self->{$key};
    }
    return \@record;
}

sub stringify{
    my ($self) = @_;
    my ($name, $rev, $plc, $ori, $x, $y, $type);
    $name = $self->get("NAME");
    $rev  = $self->get("REVISION");
    $plc  = $self->get("PLACEMENT");
    $ori  = $self->get("ORIENTATION");
    $x    = $self->get("X");
    $y    = $self->get("Y");
    $type = $self->get("COORD_TYPE");
    my $string = sprintf('%20s revision %10s placement %02s in notch %5s at (%9s mm x, %9s mm y, notch down, Coordinate type is %s)',
        defined $name ? $name : "unknown",
        defined $rev  ? $rev  : "??",
        defined $plc  ? $plc  : "??",
        defined $ori  ? $ori  : "??",
        defined $x    ? sprintf('%+0.3f', $x) : "unknown",
        defined $y    ? sprintf('%+0.3f', $y) : "unknown",
        $type,
    );
    return $string;
}

sub set{
    my ($self, $key, $value) = @_;
    unless (exists $default{$key}){
        confess "<$key> is not a valid field to set!";
    }
    if ($key eq "RAW_NAME"){
        if(defined $value){
            $value =~ tr/[a-z]/[A-Z]/;
            $value =~ s/_//g;
        }
    }elsif ($key eq "NAME"){
        if(defined $value){
            $value =~ tr/a-z/A-Z/;
            $value =~ s/[^A-Z0-9]//g;
            # C07 fix
            $value =~ s/^SCRIBE//;
        }
    }elsif ($key eq "ORIENTATION"){
        if(defined $value){
            $value =~ tr/[a-z]/[A-Z]/;
        }
        confess "<$value> is not an allowed orientation" unless defined $orientations{$value};
    }elsif ($key eq "COORD_TYPE"){
        confess "<$value> is not an allowed coordinate type" unless exists $coord_types{$value};
    }elsif ($key eq "PLACEMENT"){
        if(defined $value){
            $value =~ s/^P//i; 
        }
    }elsif ($key eq "REVISION"){
        if(defined $value){
            $value =~ s/_//g;
            $value =~ s/^ver//i;
            $value =~ s/^v([0-9]+)[p\.]([a-z0-9]+)$/$1.$2/i;
            $value =~ tr/[a-z]/[A-Z]/;
        }
    }
    $self->{$key} = $value;
    if ($key =~ m/^[XY]_SIZE_MM$/){
        $self->update_orientation_from_size();
    }
}

sub get{
    my ($self, $key, $value) = @_;
    unless (exists $default{$key}){
        confess "<$key> is not a valid field to get!";
    }
    return $self->{$key};
}

sub update_orientation_from_size{
    my ($self) = @_;
    my $x = $self->get("X_SIZE_MM");
    my $y = $self->get("Y_SIZE_MM");
    if ((defined $x) && (defined $y) && ($self->get("ORIENTATION") eq "UNKNOWN")){
        if ($x > $y){
            $self->set("ORIENTATION", "DOWN");
        }else{
            $self->set("ORIENTATION", "LEFT");
        }
    }
}

sub get_any_info_from_raw_name{
    my ($self) = @_;
    my $raw_name = $self->get("RAW_NAME");
    $self->set("NAME", $raw_name);
    
    my $name;
    # try location
    $name = $self->get("NAME");
    foreach my $location (sort {length($b) <=> length($a)} keys %locations){
        if ($name =~ m/^(.*)$location$/i){
            $self->set("NAME", $1);
            $self->set("LOCATION", $location);
            last;
        }
        if ($name =~ m/^(.*)${location}V$/i){
            $self->set("NAME", $1);
            $self->set("LOCATION", $location);
            last;
        }
    }

    if($raw_name !~ m/C(07|10|12)/){

        # try placement
        my $try_place = sub{
            my ($self) = @_;
            my $name = $self->get("NAME");
            if ($name =~ m/^(.*)(P[0-9])$/){
                $self->set("NAME", $1);
                $self->set("PLACEMENT", $2);
                return 1;
            }
            return 0;
        };
        my $found_place = $try_place->($self);

        # try orientation
        $name = $self->get("NAME");
        if ($name =~ m/^(.*)V([1-4])$/){
            if (defined $numeric_orientations{$2}){
                $self->set("NAME", $1);
                $self->set("ORIENTATION", $numeric_orientations{$2});
            }
        }

        # try placement again
        $found_place = $try_place->($self) unless ($found_place);
        
    }else{ # legacy CMOS specific code - works in a totally different format...
        $name = $self->get("NAME");
        if ($name =~ m/(.*)(V[0-9]+)$/){
            $self->set("NAME", $1);
            $self->set("REVISION", $2);
        }	
    }
}

1;
