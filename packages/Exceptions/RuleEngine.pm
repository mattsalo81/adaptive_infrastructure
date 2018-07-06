package RuleEngine;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Exceptions::ExceptionRules;
use Exceptions::GetRules;
use Database::Connect;
use SMS::FastTable;

sub run{
    # get all elements from sms
    my $ft = FastTable::new_extract();
    # start a new transaction
    my $trans = Connect::new_transaction("etest");
    eval{
        clear_exceptions_table($trans);
        my $ins_sth = get_insert_exception_sth($trans);
        my $exceptions = GetRules::get_all_active_exceptions();
        foreach my $exception (@{$exceptions}){
            eval{
                my $rules = GetRules::get_rules_for_exception($exception);
                my $records = get_matching_records_fasttable($rules, $ft);
                insert_exceptions($ins_sth, $records, $exception);
            } or do {
                my $e = $@;
                warn "Could not apply exception $exception because : $e";
            }
        }
        $trans->commit();
        1;
    }or do{
        my $e = $@;
        $trans->rollback();
        confess "Rule Engine failed to run because : $e";
    };
}

# takes an arrayref of ExceptionRules and a Fasttable
# returns an arrayref of matching SMS Records
# will print debug information for any useless rules
# does NOT modify provided fasttable
sub get_matching_records_fasttable{
    my ($rules, $ft_m) = @_;

    # save original records for comparisons
    my $original_records = $ft_m->get_all_records();

    my @all_matching;
    foreach my $rule (@{$rules}){
        # Copy/Filter
        my $ft = $ft_m->new_copy();
        $rule->filter_fasttable($ft);
        # extract records 
        my $records = $ft->get_all_records();
        if (scalar @{$records} == scalar @{$original_records}){
            # die on dangerous rules
            confess("This rule applies to every device : " . Dumper $rule);
        }
        if (scalar @{$records} == 0){
            # warn useles rules
            Logging::debug("This rule applies to no devices : " . Dumper $rule);
        }
        push @all_matching, @{$records};
    }

    # remove duplicate records
    my %unique_records;
    foreach my $record (@all_matching){
        $unique_records{$record->unique_id()} = $record;
    }
    my @matching = values %unique_records;
    
    return \@matching;
}

sub clear_exception_table{
    my ($trans) = @_;
    my $sql = q{delete from exceptions};
    my $sth = $trans->prepare($sql);
    $sth->execute();
}

sub get_insert_exception_sth{
    my ($trans) = @_;
    my $sql = q{
        insert into exceptions 
        (device, lpt, opn, exception_number) values
        (?, ?, ?, ?)
    };
    my $sth = $trans->prepare($sql);
    return $sth;
}

sub insert_exception{
    my ($sth, $record, $exception) = @_;
    $sth->execute(
        $record->get("DEVICE"),
        $record->get("LPT"),
        $record->get("OPN"),
        $exception
    );
}

sub insert_exceptions{
    my ($sth, $records, $exception) = @_;
    foreach my $record (@{$records}){
        insert_exception($sth, $record, $exception);
    }
}

1;
