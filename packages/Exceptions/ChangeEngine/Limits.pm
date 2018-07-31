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
use LimitDatabase::Change;
use Exceptions::ChangeEngine::GetActions;
use Exceptions::ChangeEngine::Core;

sub process_exceptions{
    my ($trans, $sms_master, $exception_number, $dev_lpt_opn_list) = @_;
    my $changes = fetch_changes_for_exception($exception_number);
    apply_changes_to_dev_lpt_opn($trans, $sms_master, $changes, $dev_lpt_opn_list);
}

my %change_to_action_map = (
    ACTION      => 'ACTION',
    THING       => 'OBJECT',
    PARM        => 'SUBJECT',
    VALUE       => 'VALUE',
);

sub fetch_changes_for_exception{
    my ($exception_number) = @_;
    Logging::diag("Fetching changes for exception $exception_number");
    # must fetch comment as well?
    my $actions= Exceptions::ChangeEngine::GetActions::for_limits($exception_number);
    my @changes;
    my $found_limit = 0;
    foreach my $action (@{$actions}){
        my @keys = @change_to_action_map{qw(ACTION THING PARM VALUE)};
        my $change = LimitDatabase::Change->new(@{$action}{@keys});
        if ($change->is_comment()){
            $found_limit = 1;
        }
        push @changes, $change;
    }
    unless ($found_limit){
        push @changes, generate_default_comment_for_exception($exception_number);
    }
    return \@changes;
}

sub generate_default_comment_for_exception{
    my ($exception_number) = @_;
    Logging::diag("generating a default comment");
    my $comment = "Exception $exception_number : ";
    $comment .= Exceptions::ChangeEngine::Core::get_exception_source($exception_number);
    chomp($comment);
    my $change = LimitDatabase::Change->new("SET", "LIMIT_COMMENTS", '/.*/', $comment);
    return $change;
}

sub apply_changes_to_dev_lpt_opn{
    my ($trans, $sms_master, $changes, $dev_lpt_opn_list) = @_;
    my $program_items = promote_dev_lpt_opn_list_to_program_list($sms_master, $dev_lpt_opn_list);
    my $device_items = promote_dev_lpt_opn_list_to_device_list($sms_master, $dev_lpt_opn_list);
    # apply to all things at the program level
    foreach my $prog_item (@{$program_items}){
        my ($tech, $area, $rout, $prog, $dev) = @{$prog_item};
        Logging::debug("modifying limits for $tech, $area, $rout, $prog");
        my $limits = GetLimit::get_all_limits_trans($trans, $tech, $area, $rout, $prog, $dev);
        my $new_limits = apply_changes_to_limits($changes, $limits, "PROGRAM", $prog);
        foreach my $new_l (@{$new_limits}){
            UpdateLimit::update_limit($trans, $new_l);
        }
    }
    # apply to all things at the device level
    foreach my $dev_item (@{$device_items}){
        my ($tech, $area, $rout, $prog, $dev) = @{$dev_item};
        Logging::debug("modifying limits for $tech, $area, $rout, $prog, $dev");
        my $limits = GetLimit::get_all_limits_trans($trans, $tech, $area, $rout, $prog, $dev);
        my $new_limits = apply_changes_to_limits($changes, $limits, "DEVICE", $dev);
        foreach my $new_l (@{$new_limits}){
            UpdateLimit::update_limit($trans, $new_l);
        }
    }
}

sub promote_dev_lpt_opn_list_to_program_list{
    my ($sms_master, $dev_lpt_opn_list) = @_;
    # limits must be consistant at the program level, but must also be set in the limits database at the effective routing level
    # resolve the exceptions at the program level
    my ($unmatched_prog, $consol_prog) = SMS::Consolidate::consolidate($sms_master, $dev_lpt_opn_list, [qw(TECHNOLOGY AREA PROGRAM)]);
    my %prog = map {($_->[2], $_->[2])} @{$consol_prog};
    # resolve the exceptions at the effective_routing/program level
    my ($unmatched_rout_prog, $consol_rout_prog) = SMS::Consolidate::consolidate($sms_master, $dev_lpt_opn_list, [qw(TECHNOLOGY AREA EFFECTIVE_ROUTING PROGRAM)]);
    my %rout_prog = map {($_->[3], $_->[3])} @{$consol_rout_prog};
    # remove any programs that are only partially satisfied at the program level (some effective routings but not others)
    foreach my $program (keys %rout_prog){
        unless (defined $prog{$program}){
            warn "program <$program> is satisfied for some effective routings, but not others.  Probably some conflicting process options";
            # remove any partially satisfied programs
            @{$consol_rout_prog} = grep {$_->[3] ne $program} @{$consol_rout_prog};
        }
    }
    # print unsatisfied programs
    if (scalar @{$unmatched_prog} > 0){
        warn "The following device, lpt, opn could not have a waiver applied at the program level : " . Dumper $unmatched_prog;
    }
    my @items = map {[(@{$_}, undef)]} @{$consol_rout_prog};
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
    my ($changes, $limits, $item_type, $item) = @_;
    my %changed;
    foreach my $limit (@{$limits}){
        foreach my $change (@{$changes}){
            my $changed = $change->apply($limit);
            if ($changed){
                Logging::diag("Changing limit for " . $limit->get("ETEST_NAME"));
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
