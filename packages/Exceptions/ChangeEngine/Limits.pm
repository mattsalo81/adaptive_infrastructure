package Exceptions::ChangeEngine::Limits;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use SMS::Consolidate;
use LimitDatabase::GetLimit;
use LimitDatabase::UpdateLimit;

sub fetch_dev_lpt_opn_for_exception{
    my ($exception_number) = @_;
}

sub fetch_changes_for_exception{
    my ($exception_number) = @_;
    # must fetch comment as well?
}

sub fetch_comment_for_exception{
    my ($exception_number) = @_;
}

sub apply_changes_to_dev_lpt_opn{
    my ($trans, $sms_master, $changes, $dev_lpt_opn_list) = @_;
    my $program_items = promote_dev_lpt_opn_list_to_program_list($sms_master, $dev_lpt_opn_list);
    my $device_items = promote_dev_lpt_opn_list_to_device_list($sms_master, $dev_lpt_opn_list);
    foreach my $prog_item (@{$program_items}){
        my ($tech, $area, $rout, $prog, $dev) = @{$prog_item};
        my $limits = GetLimit::get_all_limits_trans($trans, $tech, $area, $rout, $prog, $dev);
        my $new_limits = apply_changes_to_limits($changes, $limits, "PROGRAM", $prog);
        foreach my $new_l (@{$new_limits}){
            LimitRecord::UpdateLimit($trans, $new_l);
        }
    }
    foreach my $dev_item (@{$device_items}){
        my ($tech, $area, $rout, $prog, $dev) = @{$dev_item};
        my $limits = GetLimit::get_all_limits_trans($trans, $tech, $area, $rout, $prog, $dev);
        my $new_limits = apply_changes_to_limits($changes, $limits, "DEVICE", $dev);
        foreach my $new_l (@{$new_limits}){
            LimitRecord::UpdateLimit($trans, $new_l);
        }
    }
}

sub promote_dev_lpt_opn_list_to_program_list{
    my ($sms_master, $dev_lpt_opn_list) = @_;
    my ($unmatched_prog, $consol_prog) = SMS::Consolidate::consolidate($sms_master, $dev_lpt_opn_list, [qw(TECHNOLOGY AREA EFFECTIVE_ROUTING PROGRAM)]);
    my @items = map {[(@{$_}, undef)]} @{$consol_prog};
    print Dumper();
    return \@items;
}

sub promote_dev_lpt_opn_list_to_device_list{
    my ($sms_master, $dev_lpt_opn_list) = @_;
    my ($unmatched_dev, $consol_dev) = SMS::Consolidate::consolidate($sms_master, $dev_lpt_opn_list, [qw(TECHNOLOGY AREA EFFECTIVE_ROUTING PROGRAM DEVICE)]);
    if (scalar @{$unmatched_dev} > 0){
        confess "The following device/lpt/opn could not be promoted to a device : " . Dumper $unmatched_dev;
    }
    return $consol_dev;
}

# input limits may be modified
# returns list of changed limits, set at ITEM TYPE and ITEM
sub apply_changes_to_limits{
    my ($changes, $limits, $item_type, $item);
    my %changed;
    foreach my $limit (@{$limits}){
        foreach my $change (@{$changes}){
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
