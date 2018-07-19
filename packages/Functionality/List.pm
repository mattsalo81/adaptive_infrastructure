package Functionality::List;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;


sub new{
    my ($class) = @_;
    my $self = {
        SPEC_FUNC       => "NO",
        NON_FUNC        => "NO",
        NON_SPEC_FUNC   => [],
    };
    bless $self, $class;
    return $self;
}

# setters

sub set_functional{
    my ($self) = @_;
    $self->{"SPEC_FUNC"} = "YES"
}

sub set_nonfunctional{
    my ($self) = @_;
    $self->{"NON_FUNC"} = "YES"
}

sub add_nonspec{
    my ($self, $nsf, $priority) = @_;
    my $prev = $self->{"NON_SPEC_FUNC"}->[$priority];
    if ((defined $prev) && $prev ne $nsf ){
        die "Incompatible Priorities! <$prev> and <$nsf> at priority $priority";
    }
    $self->{"NON_SPEC_FUNC"}->[$priority] = $nsf;
}

# evaluator
sub make_prioritized_list{
    my ($self) = @_;
    my @list;
    push @list, "SF" if $self->{"SPEC_FUNC"} eq "YES";
    push @list, grep {defined $_} @{$self->{"NON_SPEC_FUNC"}};
    push @list, "NF" if $self->{"NON_FUNC"} eq "YES";
    @list = ("NF") if (scalar @list == 0);
    Logging::diag("Prioritized list <" . join(", ", @list) . ">");
    return \@list;
}


sub evaluate_functionality{
    my ($self, $scope, $functionality) = @_;

    # determine if should invert results
    my $invert = 0;
    if ($functionality =~ m/^!(.*)$/){
        $functionality = $1;
        $invert = 1;
    }

    # look for a match
    my $list = $self->make_prioritized_list();
    my $match = 0;
    if ((not defined $scope) || $scope eq "TOP"){
        $match = 1 if (($list->[0] eq $functionality) xor $invert);
    }elsif($scope eq "ANY"){
        foreach my $f (@{$list}){
            $match = 1 if (($f eq $functionality) xor $invert);
        }
    }else{
        die "Unknown scope <$scope>";
    }

    # return (possible inverted) result
    Logging::diag("Match for " . (defined $scope ? $scope : "TOP") . " $functionality = $match.  Invert = $invert" );
    return $match;
    
}
1;
