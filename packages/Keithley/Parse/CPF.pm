package Parse::CPF;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $header_footer = "<EOH>";
my $slot_footer = "<EOSLOTS>";
my $uap_footer = "<EOUAP>";

sub new{
    my ($class, $text) = @_;
    my $self = {
        TEXT    => $text,
        wpf     => undef,
    };
    bless $self, $class;
    parse($self);
    return $self;
}

sub parse{
    my ($self) = @_;
    my @lines = split /\n/, $self->{"TEXT"};
    my $status = "header";
    foreach my $line (@lines){
        $line =~ s/^\s*//;
        next if $line eq "";
        next if $line =~ m/^#/;
        if($status eq "header"){
            if ($line =~ m/$header_footer/){
                $status = "slots";
                next;
            }
            my ($field, $value) = split /,/, $line;
            $field =~ tr/a-z/A-Z/;
            $self->{$field} = [] unless defined $self->{$field};
            push @{$self->{$field}}, $value;
        }
        if($status eq "slots"){
            if ($line =~ m/$slot_footer/){
                $status = "uap";
                next;
            }
            if($line =~ m/ALL,,(\S*)\s*/){
                $self->{"wpf"} = $1;
            }else{
                confess "Unexpected SLOT format <$line>";
            }
        }
        if($status eq "uap"){
            
            if ($line =~ m/$uap_footer/){
                $status = "done";
                next;
            }
        }
    }
    confess "Unexpected file format" if $status ne "done";
}

sub get_wpf{
    my ($self) = @_;
    return $self->{"wpf"};
}      

1;
