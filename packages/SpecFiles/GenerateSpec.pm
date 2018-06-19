package GenerateSpec;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use LimitDatabase::GetLimit;
use LimitDatabase::LimitRecord;
use SpecFiles::Spec;

sub get_limits_for_spec{
    my ($technology, $test_area, $effective_routing, $program) = @_;
    my $limits = GetLimit::get_all_limits($technology, $test_area, $effective_routing, $program, undef);

}


sub add_spec_for_limits{
    my ($spec, $limits) = @_;

    my $current_component = "????????";
    foreach my $limit (@{$limits}){
        my $new_component = $limit->get("COMPONENT");
        $new_component = "NO COMPONENT" unless defined $new_component;
        if ($current_component ne $new_component){
            $spec->add_blank_lines(2);
            $spec->comment("    Starting $new_component Parameters");
            $current_component = $new_component;
        }
        add_spec_for_limit($spec, $limit);        
    }
}

sub add_spec_for_limit{
    my ($spec, $limit) = @_;

    my $scrap = $limit->get_scrap_entry();
    my $rel = $limit->get_reliability_entry();
    my $has_limits = (defined $scrap) || (defined $rel);
    # print out predecessors
    $has_limits = add_predecessor_spec_for_limit($spec, $limit->get_predecessor(), $has_limits);
    if($has_limits && !$limit->is_dummy){
        # comment
        my $comment = $limit->get_comment();
        if (defined $comment){
            $spec->comment($comment);
        }
        # entries
        $spec->add_entry($scrap) if defined $scrap;
        $spec->add_entry($rel) if defined $rel;
    }
}

# for all non-dummy predecessors in reverse order (lowest priority to highest)
# add the limit comment
# add commented was/rel limits if defined
sub add_predecessor_spec_for_limit{
    my ($spec, $limit, $has_limits) = @_;
    # base case for recursion
    return $has_limits unless defined $limit;
    # get limits
    my $scrap = $limit->get_scrap_entry();
    my $rel = $limit->get_reliability_entry();
    if ((defined $scrap) || (defined $rel)){
        $has_limits = 1;
    }
    # recursion
    $has_limits = add_predecessor_spec_for_limit($spec, $limit->get_predecessor(), $has_limits);
    if($has_limits && !$limit->is_dummy()){
        # comment
        my $comment = $limit->get_comment();
        if (defined $comment){
            $spec->comment($comment);
        }
        # entries
        $spec->add_comment_entry($scrap) if defined $scrap;
        $spec->add_comment_entry($rel) if defined $rel;
    }
    return $has_limits;
}

1;
