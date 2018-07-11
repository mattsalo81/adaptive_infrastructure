package GetLimit;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use LimitDatabase::LimitRecord;

my %limits_sth;

sub get_all_limits{
    my ($tech, $area, $rout, $prog, $dev) = @_;
    return get_all_limits_trans(Connect::read_only_connection('etest'), $tech, $area, $rout, $prog, $dev);
}

sub get_all_limits_trans{
    my ($trans, $tech, $area, $rout, $prog, $dev) = @_;
    my @limits;
    unless (defined $tech){
        confess "Cannot query limits without technology";
    }
    unless (defined $rout){
        confess "Cannot query limits without effective_routing";
    }
    if(defined $dev and not defined $prog){
        confess "Cannot resolve limits at the device level without a valid program";
    }
    my $sth = get_limits_sth($trans);
    $sth->bind_param(':tech', $tech);
    $sth->bind_param(':area', $area);
    $sth->bind_param(':rout', $rout);
    $sth->bind_param(':prog', $prog);
    $sth->bind_param(':dev', $dev);

    $sth->execute();
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        push @limits, LimitRecord->new_from_hash($rec);
    }
    return LimitRecord->resolve_limit_table(\@limits);
}

sub get_limits_sth{
    my ($trans) = @_;
    unless (defined $limits_sth{"$trans"}){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct
                fp.technology,
                fp.effective_routing,
                fp.etest_name,
                pi.component,
                ld.*,
                cb.bit
            from 
                functional_parameters fp
                inner join parameter_info pi
                    on  pi.technology = fp.technology
                    and pi.etest_name = fp.etest_name
                inner join limits_database ld
                    on  ld.technology = fp.technology
                    and ld.test_area = fp.test_area
                    and (
                        (
                            ld.item_type = 'DEVICE'
                            and ld.item = :dev
                        ) or (
                            ld.item_type = 'PROGRAM'
                            and ld.item = :prog
                        ) or (
                            ld.item_type = 'ROUTING'
                            and ld.item = fp.effective_routing
                        ) or (
                            ld.item_type = 'TECHNOLOGY'
                            and ld.item = fp.technology
                        )
                    )
                    and ld.etest_name = fp.etest_name
                left outer join component_to_bit cb
                    on  cb.technology = fp.technology
                    and cb.component = pi.component
            where
                fp.technology = :tech
                and fp.test_area = :area
                and fp.effective_routing = :rout
            order by pi.component, fp.etest_name
        };
        $limits_sth{"$trans"} = $conn->prepare($sql);
    }
    unless (defined $limits_sth{"$trans"}){
        confess "Could not get limits_sth for transaction <$trans>";
    }
    return $limits_sth{"$trans"};
}

1;
