package Exceptions::GetRules;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

my $rules_for_exception_sth;

sub get_all_active_exceptions{
    my $sql = q{
        select distinct
          exception_number
        from
          exception_sources
        where
          active = 'ACTIVE'
        order by
          exception_number
    };
    my $conn = Connect::read_only_connection("etest");
    my $sth = $conn->prepare($sql);
    $sth->execute() or confess "Could not get all active exceptions";
    my $records = $sth->fetchall_arrayref();
    my @exceptions = map {$_->[0]} @{$records};
    return \@exceptions;
}

sub get_rules_for_exception{
    my ($exception) = @_;
    my $sth = get_rules_for_exception_sth();
    $sth->execute($exception);
    
    
    
}

sub get_rules_for_exception_sth{
    unless (defined $rules_for_exception_sth){
        my $sql = q{
            select
              *
            from
              exception_rules
            where
              exception_number = ?
            order by
              rule_number
        };
        my $conn = Connect::read_only_connection("etest");
        $rules_for_exception_sth = $conn->prepare($sql);
    }
    unless (defined $rules_for_exception_sth){
        confess "Could not get rules_for_exception_sth";
    }
    return $rules_for_exception_sth;
}

1;
