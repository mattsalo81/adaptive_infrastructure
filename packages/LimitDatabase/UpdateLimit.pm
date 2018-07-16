package UpdateLimit;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;

# inserts the record into the current transaction
# Handles the PRIORITY field
sub update_limit{
    my ($trans, $limit) = @_;
    my $priorities = get_priorities_used($trans, $limit);
    my $priority = get_new_priority($priorities);
    $limit->set_priority($priority);
    insert_limit($trans, $limit);
}

sub get_new_priority{
    my ($priorities) = @_;
    my %used;
    @used{@{$priorities}} = @{$priorities};
    my $new = 0;
    until(not defined $used{$new}){
        $new++;
        confess "something is really broken" if $new > 9999;
    }
    return $new;
}

sub get_priorities_used{
    my ($trans, $limit) = @_;
    my $sth = get_similar_limits_sth($trans);
    my $tech = $limit->get("TECHNOLOGY");
    my $area = $limit->get("TEST_AREA");
    my $item_type = $limit->get("ITEM_TYPE");
    my $item = $limit->get("ITEM");
    my $etest = $limit->get("ETEST_NAME");
    $sth->execute($tech, $area, $item_type, $item, $etest);
    my $rec = $sth->fetchall_arrayref();
    my @priorities = map {$_->[0]} @{$rec};
    return \@priorities;
}

my %similar_limits_sth;
sub get_similar_limits_sth{
    my ($trans) = @_;
    unless(defined $similar_limits_sth{"$trans"}){
        my $sql = q{
            select 
                priority
            from
                limits_database
            where
                technology = ?
                and test_area = ?
                and item_type = ?
                and item = ?
                and etest_name = ?
            order by
                priority
        };
        $similar_limits_sth{"$trans"} = $trans->prepare($sql);
    }
    unless(defined $similar_limits_sth{"$trans"}){
        confess "Could not get similar_limits_sth for trans <$trans>";
    }
    return $similar_limits_sth{"$trans"};
}

sub insert_limit{
    my ($trans, $limit) = @_;
    my $sth = get_insert_limit_sth($trans);
    $sth->execute($limit->get_ordered_values());
}

my %insert_limit_sth;
sub get_insert_limit_sth{
    my ($trans) = @_;
    unless (defined $insert_limit_sth{"$trans"}){
        my $keys = join(", ", LimitRecord->get_ordered_keys());
        my $values = join(", ", ("?") x scalar LimitRecord->get_ordered_keys());
        my $sql = qq{
            insert into limits_database ($keys) values ($values)
        };
        $insert_limit_sth{"$trans"} = $trans->prepare($sql);
    }
    unless (defined $insert_limit_sth{"$trans"}){
        confess "Could not get insert_limit_sth for transaction <$trans>";
    }
    return $insert_limit_sth{"$trans"};
}


1;
