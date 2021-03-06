package FactorySummary::Upload;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use FactorySummary::ProcessSummary;
use LimitDatabase::UpdateLimit;

# define parameters 
my @parm_info_fields = qw(technology etest_name svn component parm_type_pcd test_type description);
@parm_info_fields = map {tr/a-z/A-Z/; $_} @parm_info_fields;

my @functional_fields = qw(technology test_area effective_routing etest_name);
@functional_fields = map {tr/a-z/A-Z/; $_} @functional_fields;


sub update_technology_info_functional_and_limits{
    my ($technology) = @_;
    eval{
        my ($info, $func, $lim) = ProcessSummary::process_technology($technology);
        update_info_functional_and_limits($technology, $info, $func, $lim);
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

sub update_info_functional_and_limits{
    my ($technology, $info, $functional, $limits) = @_;
    my $trans = Connect::new_transaction("etest");
    eval{
        update_parm_info_list($trans, $technology, $info);
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
    Logging::event("Updating Limit database for $tech");
    foreach my $limit (@{$limit_list}){
        UpdateLimit::insert_limit($trans, $limit);
    }
    1;
}

sub update_parm_info_list{
    my ($trans, $tech, $info_list) = @_;
    Logging::debug("Clearing Parameter Info for $tech");
    my $del_sth = $trans->prepare("delete from parameter_info where TECHNOLOGY = ?");
    $del_sth->execute($tech);
    my $ins_sth = get_insert_info_sth($trans);
    Logging::event("Updating parameter info table for $tech");
    foreach my $info (@{$info_list}){
        insert_info($ins_sth, $info);
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

sub get_insert_info_sth{
    my ($trans) = @_;
    my $keys = join(", ", @parm_info_fields);
    my $values = join(", ", ("?") x scalar @parm_info_fields);
    my $sql = qq{
        insert into parameter_info ($keys) values ($values)
    };
    my $sth = $trans->prepare($sql);
    return $sth;
}

sub insert_functional{
    my ($sth, $func_hash) = @_;
    $sth->execute(@{$func_hash}{@functional_fields}); 
}

sub insert_info{
    my ($sth, $info) = @_;
    $sth->execute(@{$info}{@parm_info_fields});
}

1;
