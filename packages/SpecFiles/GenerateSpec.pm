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

sub add_spec_for_limits{
    my ($spec, $limits) = @_;
    
}

sub add_spec_for_limit{
    my ($spec, $limit) = @_;
    # print out predecessors
    add_predecessor_spec_for_limit($spec, $limit->get_predecessor());
    unless($limit->is_dummy){
        # comment
        my $comment = $limit->get_comment();
        if (defined $comment){
            $spec->comment($comment);
        }
        # entries
        my $scrap = $limit->get_scrap_entry();
        $spec->add_entry($scrap) if defined $scrap;
        my $rel = $limit->get_reliability_entry();
        $spec->add_entry($rel) if defined $rel;
    }
}

# for all non-dummy predecessors in reverse order (lowest priority to highest)
# add the limit comment
# add commented was/rel limits if defined
sub add_predecessor_spec_for_limit{
    my ($spec, $limit) = @_;
    # base case
    return unless defined $limit;
    # recursion
    add_predecessor_spec_for_limit($spec, $limit->get_predecessor());
    unless($limit->is_dummy()){
        # comment
        my $comment = $limit->get_comment();
        if (defined $comment){
            $spec->comment($comment);
        }
        # entries
        my $scrap = $limit->get_scrap_entry();
        $spec->add_comment_entry($scrap) if defined $scrap;
        my $rel = $limit->get_reliability_entry();
        $spec->add_comment_entry($rel) if defined $rel;
    }
}

# so what do I even need to do here?
# get all the waivers... -> comment?

1;
