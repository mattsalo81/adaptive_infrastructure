package Exceptions::ChangeEngine::Limits;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;


sub promote_dev_lpt_opn_list_to_item_type_list{
    my ($sms, $dev_lpt_opn_list) = @_;
}




sub fetch_limits{
    my ($test_area, $item_type, $item, $changes) = @_;
    
    
}

# input limits may be modified
# returns list of changed limits, set at ITEM TYPE and ITEM
sub apply_changes_to_limits{
    my ($changes, $limits, $item_type, $item);
    my %changed;
    foreach my $limit (@{$limites}){
        foreach my $change (@{}){
            my $changed = $change->apply($limit);
            if ($changed){
                # save a reference to each limit that was changed
                $changed{"$limit"} = $limit;
            }
        }
    }
    my @changed = values %changed;
    @changed = map{$_->set_item_type($item_type, $item); $_} @changed;
    return \@changed;
}


1;
