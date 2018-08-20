package PrimaryKeys;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;

# returns list of primary key attributes in order
sub get_primary_key_attributes{
    my ($database, $table) = @_;
    my $conn = Connect::read_only_connection($database);
    confess "<$table does not exist in <$database>" unless does_table_exist($database, $table);
    my $sql = q{
        select
          c.constraint_name,
          cc.column_name,
          cc.position
        from 
          user_constraints c
          inner join user_cons_columns cc
            on  cc.CONSTRAINT_NAME = c.CONSTRAINT_NAME
        where 
          UPPER(c.table_name) = UPPER(?)
          and c.constraint_type = 'P'
        order by
          cc.position
    };
    my $sth = $conn->prepare($sql);
    $sth->execute($table);
    my @primary_keys;
    while(my $rec = $sth->fetchrow_hashref('NAME_uc')){
        push @primary_keys, $rec->{'COLUMN_NAME'};
    }
    return \@primary_keys;
}

sub does_table_exist{
    my ($database, $table) = @_;
    my $conn = Connect::read_only_connection($database);
    my $sql = q{select table_name from user_tables where table_name = UPPER(?)};
    my $sth = $conn->prepare($sql);
    $sth->execute($table);
    my $rec = $sth->fetchall_arrayref();
    return (scalar @{$rec} > 0);
}

1;
