package Parse::WPF;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $header_footer = "<EOH>";
my $site_plan_footer = "<EOSP>";
my $wafer_footer = "<EOW>";

sub new{
    my ($class, $text) = @_;
    my $self = {
        TEXT    => $text,
        ktms    => [],
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
                $status = "site plan";
                next;
            }
            my ($field, $value) = split /,/, $line;
            $field =~ tr/a-z/A-Z/;
            $self->{$field} = $value;
        }
        if($status eq "site plan"){
            if ($line =~ m/$site_plan_footer/){
                $status = "wafer";
                next;
            }
        }
        if($status eq "wafer"){
            
            if ($line =~ m/$wafer_footer/){
                $status = "";
                next;
            }
            my ($ktm, $pattern ,$garbage) = split /,/, $line;
            confess "Malformed line $line" if ((defined $garbage) || (not defined $pattern));
            push @{$self->{"ktms"}}, [$ktm, $pattern];
        }
    }
    confess "Unexpected file format" if $status ne "";
}

sub get_all_ktms{
    my ($self) = @_;
    my @ktms;
    foreach my $item (@{$self->{"ktms"}}){
        push @ktms, $item->[0];
    }
    return \@ktms;
}

sub get_klf{
    my ($self) = @_;
    return $self->{"LIMITS"};
}      

1;
