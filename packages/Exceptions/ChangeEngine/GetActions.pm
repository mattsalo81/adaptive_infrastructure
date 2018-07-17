package Exceptions::ChangeEngine::GetActions;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $limits_sth;

sub for_limits{
    my ($exception_number) = @_;
    my $sth = get_limits_sth();
    $sth->execute($exception_number);
    my @actions;
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        push @actions, $rec;
    }
    return \@actions;
}

sub get_limits_sth{
    unless (defined $limits_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select * from exception_actions
            where exception_number = ?
            order by action_number
        };
        $limits_sth = $conn->prepare($sql);
    }
    unless (defined $limits_sth){
        confess "Could not prepare limits_sth";
    }
    return $limits_sth;
}


1;
