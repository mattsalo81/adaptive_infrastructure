package FactorySummary::Upload;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use FactorySummary::ProcessSummary;

my @functional_fields = qw(technology test_area effective_routing etest_name svn component parm_type_pcd test_type description);
@functional_fields = map {tr/a-z/A-Z/; $_} @functional_fields;

my @limit_fields = qw(technology test_area item_type item etest_name deactivate sampling_rate);
push @limit_fields, qw(dispo pass_criteria_percent reprobe_map dispo_rule spec_upper spec_lower reverse_spec_limit);
push @limit_fields, qw(reliability reliability_upper reliability_lower reverse_reliability_limit limit_comments);
@limit_fields = map {tr/a-z/A-Z/; $_} @limit_fields;

sub update_technology_functional_and_limits{
    my ($technology) = @_;
    eval{
        my ($func, $lim) = ProcessSummary::process_technology($technology);
        update_functional_and_limits($technology, $func, $lim);
        1;
    }or do{
        my $e = $@;
        if ($e =~ m/Could not find any F-summary entries/){
            print "Skipping $technology, no F-summary records found\n";
        }else{
            confess "Could not update $technology functional parameter table and limits database because : $e";
        }
    }
}

sub update_functional_and_limits{
    my ($technology, $functional, $limits) = @_;
    my $trans = Connect::new_transaction("etest");
    eval{
        update_functional_list($trans, $technology, $functional);
        update_limit_list($trans, $technology, $limits);
        $trans->commit();
        1;
    }or do{
        my $e = $@;
        $trans->rollback();
        confess "Could not update because of : $e";
    }

}

sub update_functional_list{
    my ($trans, $tech, $functional_list) = @_;
    Logging::debug("Clearing functional parameters table for $tech");
    my $del_sth = $trans->prepare("delete from functional_parameters where TECHNOLOGY = ?");
    $del_sth->execute($tech);
    my $ins_sth = get_insert_functional_sth($trans);
    Logging::event("Updating Functional parameters table for $tech");
    foreach my $func (@{$functional_list}){
        insert_functional($ins_sth, $func);
    }
    1;
}

sub update_limit_list{
    my ($trans, $tech, $limit_list) = @_;
    Logging::debug("Clearing Limits database for $tech");
    my $del_sth = $trans->prepare("delete from limits_database where TECHNOLOGY = ?");
    $del_sth->execute($tech);
    my $ins_sth = get_insert_limit_sth($trans);
    Logging::event("Updating Limit database for $tech");
    foreach my $limit (@{$limit_list}){
        insert_limit($ins_sth, $limit);
    }
    1;
}

sub get_insert_functional_sth{
    my ($trans) = @_;
    my $keys = join(", ", @functional_fields);
    my $values = join(", ", ("?") x scalar @functional_fields);
    my $sql = qq{
        insert into functional_parameters ($keys) values ($values)
    };
    my $sth = $trans->prepare($sql);
    return $sth;
}

sub get_insert_limit_sth{
    my ($trans) = @_;
    my $keys = join(", ", @limit_fields);
    my $values = join(", ", ("?") x scalar @limit_fields);
    my $sql = qq{
        insert into limits_database ($keys) values ($values)
    };
    my $sth = $trans->prepare($sql);
    return $sth;
}

sub insert_functional{
    my ($sth, $func_hash) = @_;
    $sth->execute(@{$func_hash}{@functional_fields}); 
}

sub insert_limit{
    my ($sth, $limit) = @_;
    $sth->execute($limit->index_array(@limit_fields));
}

1;
