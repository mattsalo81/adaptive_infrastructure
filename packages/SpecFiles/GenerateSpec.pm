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
use Components::EffectiveComponents;
use Components::DeviceString;
use ProcessOptions::OptionLookup;

sub get_spec{
    my ($technology, $test_area, $effective_routing, $program, $comp) = @_;
    my $limits = GetLimit::get_all_limits($technology, $test_area, $effective_routing, $program, undef);
    if (scalar @{$limits} == 0){
        confess "Got 0 limits from the database, is something wrong?";
    }
    my $comps = [];
    if ((defined $comp) && $comp){
        Logging::diag("Generating spec by COMP");
        $comps = EffectiveComponents::get_effective_components($technology, $program);
        if (scalar @{$comps} != 0){
            my $disabled = LimitRecord->filter_limit_table_by_component($limits, $comps);
            Logging::diag("Removed $disabled limit(s) based on component list");
        }
    }else{
        Logging::diag("Generating spec by FLOW");
    }
    if (scalar @{$limits} == 0){
        confess "Got 0 limits after filtering by component, is something wrong?";
    }
    my $spec = Spec->new();
    add_header($spec, $technology, $test_area, $effective_routing, $program, $comps);
    add_spec_for_limits($spec, $limits);
    return $spec;
}

sub add_header{
    my ($spec, $tech, $area, $rout, $prog, $comps) = @_;


    # Basic Information
    my $time = get_time();
    my $text = qq{
        Specfile Generated from database with waivers applied
        =====================================================

        Factory         :       DMOS5
        Technology      :       $tech
        Test Area       :       $area
        Eff. Routing    :       $rout
        Program         :       $prog
        Date            :       $time
    };

    # Process Options
    my $options = OptionLookup::get_options_for_effective_routing($tech, $rout);
    my @options = sort keys %{$options};

    $text .= qq{
        Process Options :
        =================
        (Current, may have changed since Factory Summary generated)\n\n};
        $text .= join("", map {"          * " . $_ . "\n"} @options);
    
    if (scalar @{$comps} > 0){
        $text .= qq{
        Components Used :
        =================
        (Current, may have changed since Factory Summary generated)};
        eval {
            my $device_string = DeviceString::get_device_string($tech, $prog);
            $device_string = "##-ALL-SLASHES-##" if $device_string =~ m/^\/+$/;
            $text .= qq{
        Device String   : $device_string};
        } or do {
            Logging::diag("Could not fetch device string for $tech program $prog.  Not a problem now but will probably be an issue later");
        };
        $text .= "\n\n" . join("", map {"          * " . $_ . "\n"} @{$comps});
        
    }
    $spec->wrap_comment($text);
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

sub get_time{
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    my $nice_timestamp = sprintf ( "%04d/%02d/%02d %02d:%02d:%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;
}

1;
