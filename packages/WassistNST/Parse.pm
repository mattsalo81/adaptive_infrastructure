package WassistNST::Parse;
use warnings;
use strict;
use lib '/dm5/ki/adaptive_infrastructure/packages';
use Carp;
use Data::Dumper;
use Logging;
use Safe;

sub parse_nst{
    my ($text_ref) = @_;
    my $mod_list_ref = [];
    # parse  the text reference in a safe (eval from unknown source)
    my $sandbox = Safe->new("NST");
    $sandbox->reval($$text_ref);
    my $ret = \%NST::reticle_layout;
    my @units = @NST::units;
    # handle scale
    my $scale = 1/1000000;
    my @failed_revision_extracts;
    # start processing the data
    unless (@units && $units[1] eq 'MICRONS'){
        confess "The units array was not what I expected <" . join(", ", @units) . ">\n";
    }
    $scale *= $units[0];
    # search through reticle layout
    if (not defined $ret){
        confess "Could not resolve reticle layout from nst! problem with the eval\n";
    }else{
        # assuming there's only one scribe called SCRIBE_01
        if (scalar keys %{$ret->{"scribes"}} != 1){
                confess "More than one (or zero) scribe on the reticle! I didn't know that could happen\n";
        }
        my @scribe_names = keys %{$ret->{"scribes"}};
        my $scribe_name = $scribe_names[0];
        my $ref = $ret->{"scribes"}{$scribe_name}{"hotspots"};
        unless(defined $ref){
                confess "Couldn't find hotspots in SCRIBE_01\n";
        }
        # go through each module, some may not be for parametric
        foreach my $module (keys %{$ref}){
            # pull out information structures
            my $dim_info = $ref->{$module}->[0]->{'_DIMENSION'};
            my $info = $ref->{$module}->[1];
            my $mod_info = $info->{"ll"};
            my $pad1_info = $info->{"pad1_center"};
            unless (defined $pad1_info){
                # bicom update, but there are some other weird things in DMD
                $pad1_info = $info->{'pad1_mod1'};
            }
            if(defined($pad1_info) and defined $pad1_info->[2]->{"user"} and $pad1_info->[2]->{"user"} eq "parm_test"){
                # assert that the dimension info is what's expected
                unless (defined $dim_info && $dim_info->[0] eq 'width' && $dim_info->[1] eq 'height'){
                    confess "dimension array for <$module> is not what I expected\n";
                }
                # assert that we have the info we need
                my $mod = WassistNST::Module->new($module);
                unless (defined $pad1_info && defined $mod_info){
                    confess "Could not find pad1 or ll info for <$module>\n";
                }
                
                # import module location
                my @array_loc = ($mod_info->[0] * $scale, $mod_info->[1] * $scale);
                
                # import orientation
                my $orient = $mod_info->[2]->{'orient'};
                unless (defined $orient and defined $WassistNST::Module::numeric_orientations{$orient}){
                    confess "nonexistant or unexpected orientation for module <$module>\n";
                }
                $mod->set("ORIENTATION", $WassistNST::Module::numeric_orientations{$orient});
                
                # import pad information
                $mod->set("COORD_TYPE", "PAD1");
                $mod->set("X", $pad1_info->[0] * $scale);
                $mod->set("Y", $pad1_info->[1] * $scale);
                $mod->set("NAME", $pad1_info->[2]->{"cell"});
        
                # revision -> either its own field, and also appended to the name, or have to find it from the raw name
                my $rev = $pad1_info->[2]->{"revision"};
                if (defined $rev){
                    #update revision
                    $rev =~ s/_//g;
                    $mod->set("REVISION", $rev);
                    #remove revision from name if it exists...
                    my $name = $mod->get_name();
                    if ($name =~ m/^(.*)$rev$/i){
                        $mod->set("NAME", $1);
                    }
                }else{
                    # it may be in the raw name...	
                    my $trash_mod = WassistNST::Module->new($mod->get("RAW_NAME"));
                    my $maybe_has_rev = $trash_mod->get("NAME");
                    my $maybe_no_rev = $mod->get("NAME");
                    if ($maybe_has_rev =~ m/^.*$maybe_no_rev([A-Z])$/i){
                        $mod->set("REVISION", $1);
                }
                push @{$mod_list_ref}, $mod;
                $mod = WassistNST::Module->new_copy($mod);
                $mod->set("COORD_TYPE", "ARRAY");
                $mod
            }
        }
    }
    if (@failed_revision_extracts){
            confess "No rulesets defined for following names!\n" . join("\n", @failed_revision_extracts) . "\n\n";
    }
    return $mod_list_ref;
}
