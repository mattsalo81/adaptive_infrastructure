package Parse::KTM;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

my $subsite_header = ">> KTM WAFER & SUBSITE NAME";
my $subsite_footer = "END KTM WAFER & SUBSITE NAME";
my $plot_header = ">> KTM TEST MODULE PLOT AND LOG";
my $plot_footer = "END PLOT AND LOG SETTINGS";


sub new{
    my ($class, $text) = @_;
    my $self = {
        TEXT    =>      $text,
        SUBSITE =>      undef,
        TEST_ID =>      [],
    };
    parse($self);
    return bless $self, $class;
}

sub parse{
    my ($self) = @_;
    my @lines = split /\n/, $self->{"TEXT"};
    my $status = "";
    my $temp;
    foreach my $line (@lines){
        if ($status eq ""){
            $temp = undef;
            $status = "subsite" if $line =~ m/$subsite_header/;
            $status = "plot" if $line =~ m/$plot_header/;
            next;
        }
        if ($status eq "subsite"){
            if ($line =~ m/$subsite_footer/){
                $status = "";
                $self->{"SUBSITE"} = $temp;
                next;
            }
            $line =~ s/\s//g;
            next if $line eq "";
            $temp = $line;
        }
        if ($status eq "plot"){
            if ($line =~ m/$plot_footer/){
                $status = "";
                next;
            }
            $line =~ s/\s//g;
            next if $line eq "";
            my ($parm, $plot, $log, $size, $user, $garbage) = split /,/, $line;
            confess "malformed line $line" if ((defined $garbage) || (not defined $user));
            push @{$self->{"TEST_ID"}}, $parm;
        }
    }
}

sub get_subsite{
    my ($self) = @_;
    my $subsite = $self->{"SUBSITE"};
    confess "Subsite not defined, did parser fail/not run?" unless defined $subsite;
    return $subsite;
}

sub get_parameters{
    my ($self) = @_;
    my $parms = $self->{"TEST_ID"};
    return $parms;
}

1;
