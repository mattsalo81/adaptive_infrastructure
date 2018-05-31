package GetLimit;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Database::Connect;
use LimitRecord;

my $limits_sth;

sub get_all_limits{
    my ($tech, $rout, $prog, $dev) = @_;
    my @limits;
    unless (defined $tech){
        confess "Cannot query limits without technology";
    }
    unless (defined $rout){
        confess "Cannot query limits without effective_routing";
    }
    my $sth = get_limits_sth();
    $sth->execute($tech, $rout, $dev, $prog);
    while(my $rec = $sth->fetchrow_hashref("NAME_uc")){
        push @limits, LimitRecord->new_from_hash($rec);
    }
    return LimitRecord->resolve_limit_table(\@limits);
}

sub get_limits_sth{
    unless (defined $limits_sth){
        my $conn = Connect::read_only_connection("etest");
        my $sql = q{
            select distinct
                fp.technology,
                fp.effective_routing,
                fp.etest_name,
                pi.component,
                ld.*
            from 
                functional_parameters fp
                inner join parameter_info pi
                    on  pi.technology = fp.technology
                    and pi.etest_name = fp.etest_name
                inner join limits_database ld
                    on  ld.technology = fp.technology
                    and ld.etest_name = fp.etest_name
            where
                fp.technology = ?
                and fp.effective_routing = ?
                and ld.technology = fp.technology
                and (
                        (
                            ld.item_type = 'DEVICE'
                            and ld.item = ?
                        ) or (
                            ld.item_type = 'PROGRAM'
                            and ld.item = ?
                        ) or (
                            ld.item_type = 'ROUTING'
                            and ld.item = fp.effective_routing
                        ) or (
                            ld.item_type = 'TECHNOLOGY'
                            and ld.item = fp.technology
                        )
                    )
                and ld.etest_name = fp.etest_name
            order by pi.component, fp.etest_name
        };
        $limits_sth = $conn->prepare($sql);
    }
    unless (defined $limits_sth){
        confess "Could not get limits_sth";
    }
    return $limits_sth;
}

1;
