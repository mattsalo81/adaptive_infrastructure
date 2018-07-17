package GetExceptions;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $exceptions_sth;
my $exception_nums_sth;

sub get_all_exception_numbers{
    my $sth = get_exception_nums_sth();
    $sth->execute();
    my $rec = $sth->fetchall_arrayref();
    my @exception_nums = map {$_->[0]} @{$rec};
    return \@exception_nums;
}

sub get_exception_nums_sth{
    unless (defined $exception_nums_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct exception_number
            from exceptions
            order by exception_number
        };
        $exception_nums_sth = $conn->prepare($sql);
    }
    unless (defined $exception_nums_sth){
        confess "Could not prepare exception_nums_sth";
    }
    return $exception_nums_sth;
}

sub for_exception_number{
    my ($exception_number) = @_;
    my $sth = get_exceptions_sth();
    $sth->execute($exception_number);
    my @exceptions;
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        push @exceptions, $rec;
    }
    return \@exceptions;
}

sub get_exceptions_sth{
    unless (defined $exceptions_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select device, lpt, opn from exceptions
            where exception_number = ?
            order by device, lpt, opn
        };
        $exceptions_sth = $conn->prepare($sql);
    }
    unless (defined $exceptions_sth){
        confess "Could not prepare exceptions_sth";
    }
    return $exceptions_sth;
}


1;
