package Parse::KRF;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;


my $header_footer = "<EOH>";
my $recipe_footer = "<EOR>";

sub new{
    my ($class, $text) = @_;
    my $self = {
        TEXT    => $text,
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
        $line =~ s/\s*$//;
        next if $line eq "";
        next if $line =~ m/^#/;
        if($status eq "header" || $status eq "recipe"){
            if ($status eq "header" && $line =~ m/$header_footer/){
                $status = "recipe";
                next;
            }
            if ($status eq "recipe" && $line =~ m/$recipe_footer/){
                $status = "done";
                next;
            }
            my ($field, $value) = split /,/, $line;
            $field =~ tr/a-z/A-Z/;
            $self->{$field} = $value;
        }
    }
    confess "Unexpected file format" if $status ne "done";
}

sub get_wdf{
    my ($self) = @_;
    my $wdf = $self->{"WDF"};
    confess "Could not get wdf from krf" unless defined $wdf;
    return $wdf;
}      

1;
