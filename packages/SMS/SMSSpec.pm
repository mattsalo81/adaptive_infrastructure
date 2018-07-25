package SMSSpec;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

# basic class to provide a unique_id and getter method.  Don't change the structure from a hash because lots of code accesses members directly

sub new{
    my ($class, $hash) = @_;
    my $self = {%{$hash}};
    bless $self, $class;
    return $self;
}

sub get{
    my ($self, $key) = @_;
    my $value = $self->{$key};
    unless (exists $self->{$key}){
        confess "Could not extract value of <$key> from SMSSpec";
    }
    return $value;
}

sub unique_id{
    my ($self) = @_;
    my $dev = $self->get("DEVICE");
    my $lpt = $self->get("LPT");
    my $opn = $self->get("OPN");
    return "$dev $lpt $opn";    
}

1;
